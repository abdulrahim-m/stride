//! Image files and image links that belong to an entity (for now: notes).
//!
//! Nothing here touches the database. Everything lives in
//! `<base>/<owner>_images/` (see [`ImageOwner::dir_name`]):
//!
//! * uploaded images: `<id>_<unique>.<ext>`, a copy of the picked file
//! * links: `<id>_links.txt`, one URL per line
//!
//! The id prefix is `<id>_` (with the underscore), so id 1 never matches the
//! files of id 12. Deleting an entity's images means deleting every file in
//! the folder whose name starts with its prefix.
//!
//! One folder per owner type keeps ids of different entities from colliding
//! without having to prefix every file name.

use std::path::{Path, PathBuf};
use std::sync::atomic::{AtomicU64, Ordering};
use std::time::{SystemTime, UNIX_EPOCH};

use crate::utils::app_error::{AppError, ErrorType, Result};

/// The kinds of entity that can hold images.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ImageOwner {
    Note,
}

impl ImageOwner {
    pub const ALL: [ImageOwner; 1] = [ImageOwner::Note];

    /// Folder (inside the base path) that holds this owner's images.
    pub fn dir_name(self) -> &'static str {
        match self {
            ImageOwner::Note => "note_images",
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ImageKind {
    /// A file in the images folder; `value` is its absolute path.
    File,
    /// An external http(s) link; `value` is the URL.
    Link,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct UIImage {
    pub kind: ImageKind,
    /// File name for a file (what you pass to `remove_image`), the URL for a link.
    pub name: String,
    /// Absolute path for a file, the URL for a link.
    pub value: String,
}

const EXTENSIONS: [&str; 8] = ["jpg", "jpeg", "png", "gif", "webp", "bmp", "heic", "heif"];
const MAX_URL_LEN: usize = 2048;

static COUNTER: AtomicU64 = AtomicU64::new(0);

/// Unique, and sorts in creation order (fixed width hex).
fn unique() -> String {
    let nanos = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_nanos() as u64)
        .unwrap_or(0);
    let n = COUNTER.fetch_add(1, Ordering::Relaxed) % 0x1_0000;
    format!("{:016x}{:04x}", nanos, n)
}

fn validation(msg: &str) -> AppError {
    AppError::new(msg, ErrorType::Validation)
}

fn clean_ext(ext: &str) -> Result<String> {
    let e = ext.trim().trim_start_matches('.').to_ascii_lowercase();
    if EXTENSIONS.contains(&e.as_str()) {
        Ok(e)
    } else {
        Err(validation("Unsupported image type"))
    }
}

#[derive(Debug, Clone)]
pub struct ImageService {
    root: PathBuf,
}

impl ImageService {
    /// `base_path` is the same folder the database lives in.
    pub fn new(base_path: &str) -> Result<Self> {
        let service = ImageService {
            root: PathBuf::from(base_path),
        };
        for owner in ImageOwner::ALL {
            std::fs::create_dir_all(service.dir(owner))?;
        }
        Ok(service)
    }

    fn dir(&self, owner: ImageOwner) -> PathBuf {
        self.root.join(owner.dir_name())
    }

    fn prefix(id: i64) -> String {
        format!("{id}_")
    }

    fn links_name(id: i64) -> String {
        format!("{id}_links.txt")
    }

    fn links_path(&self, owner: ImageOwner, id: i64) -> PathBuf {
        self.dir(owner).join(Self::links_name(id))
    }

    fn entry(&self, owner: ImageOwner, name: &str) -> UIImage {
        UIImage {
            kind: ImageKind::File,
            name: name.to_string(),
            value: self.dir(owner).join(name).to_string_lossy().to_string(),
        }
    }

    // ------------------------------------------------------------------ get

    /// Files first (oldest first), then links in the order they were added.
    pub async fn list(&self, owner: ImageOwner, id: i64) -> Result<Vec<UIImage>> {
        let prefix = Self::prefix(id);
        let links_name = Self::links_name(id);

        let mut names = Vec::new();
        if let Ok(mut rd) = tokio::fs::read_dir(self.dir(owner)).await {
            while let Some(e) = rd.next_entry().await? {
                let name = e.file_name().to_string_lossy().to_string();
                if name.starts_with(&prefix) && name != links_name {
                    names.push(name);
                }
            }
        }
        names.sort();

        let mut out: Vec<UIImage> = names.iter().map(|n| self.entry(owner, n)).collect();
        for url in self.read_links(owner, id).await? {
            out.push(UIImage {
                kind: ImageKind::Link,
                name: url.clone(),
                value: url,
            });
        }
        Ok(out)
    }

    async fn read_links(&self, owner: ImageOwner, id: i64) -> Result<Vec<String>> {
        match tokio::fs::read_to_string(self.links_path(owner, id)).await {
            Ok(text) => Ok(text
                .lines()
                .map(|l| l.trim().to_string())
                .filter(|l| !l.is_empty())
                .collect()),
            Err(e) if e.kind() == std::io::ErrorKind::NotFound => Ok(Vec::new()),
            Err(e) => Err(e.into()),
        }
    }

    // ------------------------------------------------------------------ add

    /// Copies the file at `source` into the images folder.
    pub async fn add_image_from_path(
        &self,
        owner: ImageOwner,
        id: i64,
        source: &str,
    ) -> Result<UIImage> {
        let src = Path::new(source);
        let ext = clean_ext(src.extension().and_then(|e| e.to_str()).unwrap_or(""))?;
        let is_file = tokio::fs::metadata(src)
            .await
            .map(|m| m.is_file())
            .unwrap_or(false);
        if !is_file {
            return Err(validation("Image file not found"));
        }

        tokio::fs::create_dir_all(self.dir(owner)).await?;
        let name = format!("{}{}.{}", Self::prefix(id), unique(), ext);
        tokio::fs::copy(src, self.dir(owner).join(&name)).await?;
        Ok(self.entry(owner, &name))
    }

    /// Same as [`add_image_from_path`] for callers that have the bytes but no
    /// file (a web frontend, say).
    pub async fn add_image_bytes(
        &self,
        owner: ImageOwner,
        id: i64,
        bytes: &[u8],
        ext: &str,
    ) -> Result<UIImage> {
        let ext = clean_ext(ext)?;
        tokio::fs::create_dir_all(self.dir(owner)).await?;
        let name = format!("{}{}.{}", Self::prefix(id), unique(), ext);
        tokio::fs::write(self.dir(owner).join(&name), bytes).await?;
        Ok(self.entry(owner, &name))
    }

    /// Adds an http(s) link. Adding the same link twice is a no-op.
    pub async fn add_link(&self, owner: ImageOwner, id: i64, url: &str) -> Result<UIImage> {
        let url = url.trim();
        let lower = url.to_ascii_lowercase();
        let scheme_ok = lower.starts_with("http://") || lower.starts_with("https://");
        if !scheme_ok
            || url.len() > MAX_URL_LEN
            || url.chars().any(char::is_whitespace)
            || url.ends_with("://")
        {
            return Err(validation("Enter a valid http(s) link"));
        }

        let mut links = self.read_links(owner, id).await?;
        if !links.iter().any(|l| l == url) {
            links.push(url.to_string());
            self.write_links(owner, id, &links).await?;
        }
        Ok(UIImage {
            kind: ImageKind::Link,
            name: url.to_string(),
            value: url.to_string(),
        })
    }

    async fn write_links(&self, owner: ImageOwner, id: i64, links: &[String]) -> Result<()> {
        let path = self.links_path(owner, id);
        if links.is_empty() {
            match tokio::fs::remove_file(&path).await {
                Ok(()) => {}
                Err(e) if e.kind() == std::io::ErrorKind::NotFound => {}
                Err(e) => return Err(e.into()),
            }
            return Ok(());
        }
        tokio::fs::create_dir_all(self.dir(owner)).await?;
        tokio::fs::write(path, format!("{}\n", links.join("\n"))).await?;
        Ok(())
    }

    // --------------------------------------------------------------- remove

    /// `name` is `UIImage::name` of a file. Anything that is not one of this
    /// id's own image files is refused (no path tricks).
    pub async fn remove_image(&self, owner: ImageOwner, id: i64, name: &str) -> Result<()> {
        let bad = !name.starts_with(&Self::prefix(id))
            || name == Self::links_name(id)
            || name.contains('/')
            || name.contains('\\')
            || name.contains("..");
        if bad {
            return Err(validation("Not an image of this item"));
        }
        match tokio::fs::remove_file(self.dir(owner).join(name)).await {
            Ok(()) => Ok(()),
            Err(e) if e.kind() == std::io::ErrorKind::NotFound => Ok(()),
            Err(e) => Err(e.into()),
        }
    }

    pub async fn remove_link(&self, owner: ImageOwner, id: i64, url: &str) -> Result<()> {
        let url = url.trim();
        let links = self.read_links(owner, id).await?;
        let kept: Vec<String> = links.iter().filter(|l| l.as_str() != url).cloned().collect();
        if kept.len() != links.len() {
            self.write_links(owner, id, &kept).await?;
        }
        Ok(())
    }

    /// Deletes every file in the owner's folder whose name starts with the id
    /// prefix: the images and the links file.
    pub async fn delete_all(&self, owner: ImageOwner, id: i64) -> Result<()> {
        let prefix = Self::prefix(id);
        let mut rd = match tokio::fs::read_dir(self.dir(owner)).await {
            Ok(rd) => rd,
            Err(e) if e.kind() == std::io::ErrorKind::NotFound => return Ok(()),
            Err(e) => return Err(e.into()),
        };
        while let Some(e) = rd.next_entry().await? {
            if e.file_name().to_string_lossy().starts_with(&prefix) {
                let _ = tokio::fs::remove_file(e.path()).await;
            }
        }
        Ok(())
    }
}

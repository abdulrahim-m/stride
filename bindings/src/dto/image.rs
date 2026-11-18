use notecore::services::images::{ImageKind, ImageOwner, UIImage};

/// Which kind of item the images belong to. Mirrors `ImageOwner`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ImageOwnerDto {
    Note,
}

impl From<ImageOwnerDto> for ImageOwner {
    fn from(o: ImageOwnerDto) -> Self {
        match o {
            ImageOwnerDto::Note => ImageOwner::Note,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ImageKindDto {
    File,
    Link,
}

impl From<ImageKind> for ImageKindDto {
    fn from(k: ImageKind) -> Self {
        match k {
            ImageKind::File => ImageKindDto::File,
            ImageKind::Link => ImageKindDto::Link,
        }
    }
}

#[derive(Debug, Clone)]
pub struct ImageDto {
    pub kind: ImageKindDto,
    /// File name (pass it to `remove_image`) or the URL.
    pub name: String,
    /// Absolute path of the file, or the URL.
    pub value: String,
}

impl From<UIImage> for ImageDto {
    fn from(i: UIImage) -> Self {
        ImageDto {
            kind: i.kind.into(),
            name: i.name,
            value: i.value,
        }
    }
}

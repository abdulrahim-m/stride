// use super::common::*;
use crate::services::images::{ImageKind, ImageOwner, ImageService};
use crate::services::notes::NotesService;

const NOTE: ImageOwner = ImageOwner::Note;

fn svc(db: &TestDb) -> ImageService {
    ImageService::new(&db.path()).unwrap()
}

/// Writes a fake picture outside the images folder and returns its path.
fn source(db: &TestDb, name: &str) -> String {
    let p = db.dir.join(name);
    std::fs::write(&p, b"not really a picture").unwrap();
    p.to_string_lossy().to_string()
}

fn is_validation<T>(r: crate::utils::app_error::Result<T>) -> bool {
    matches!(r, Err(e) if matches!(e.error_type, crate::utils::app_error::ErrorType::Validation))
}

#[tokio::test]
async fn creates_the_owner_folder_next_to_the_database() {
    let db = TestDb::new().await;
    let _ = svc(&db);
    assert!(db.dir.join("note_images").is_dir());
    assert!(db.dir.join("notecore.db").is_file());
}

#[tokio::test]
async fn copies_a_picked_file_with_the_note_id_in_its_name() {
    let db = TestDb::new().await;
    let s = svc(&db);
    let src = source(&db, "photo.PNG");

    let img = s.add_image_from_path(NOTE, 7, &src).await.unwrap();

    assert_eq!(img.kind, ImageKind::File);
    assert!(img.name.starts_with("7_") && img.name.ends_with(".png"));
    assert!(std::path::Path::new(&img.value).is_file());
    assert!(std::path::Path::new(&src).is_file(), "the original stays");
}

#[tokio::test]
async fn two_copies_of_the_same_file_get_different_names() {
    let db = TestDb::new().await;
    let s = svc(&db);
    let src = source(&db, "a.jpg");
    let a = s.add_image_from_path(NOTE, 1, &src).await.unwrap();
    let b = s.add_image_from_path(NOTE, 1, &src).await.unwrap();
    assert_ne!(a.name, b.name);
    assert_eq!(s.list(NOTE, 1).await.unwrap().len(), 2);
}

#[tokio::test]
async fn rejects_unsupported_types_and_missing_files() {
    let db = TestDb::new().await;
    let s = svc(&db);
    let txt = source(&db, "notes.txt");
    assert!(is_validation(s.add_image_from_path(NOTE, 1, &txt).await));
    let missing = db.dir.join("nope.png").to_string_lossy().to_string();
    assert!(is_validation(s.add_image_from_path(NOTE, 1, &missing).await));
}

#[tokio::test]
async fn adds_images_from_bytes() {
    let db = TestDb::new().await;
    let s = svc(&db);
    let img = s.add_image_bytes(NOTE, 3, b"abc", ".webp").await.unwrap();
    assert!(img.name.starts_with("3_") && img.name.ends_with(".webp"));
    assert_eq!(std::fs::read(&img.value).unwrap(), b"abc");
    assert!(is_validation(s.add_image_bytes(NOTE, 3, b"abc", "exe").await));
}

#[tokio::test]
async fn lists_files_in_creation_order_then_links() {
    let db = TestDb::new().await;
    let s = svc(&db);
    let src = source(&db, "a.jpg");
    s.add_link(NOTE, 2, "https://example.com/1.png").await.unwrap();
    let first = s.add_image_from_path(NOTE, 2, &src).await.unwrap();
    let second = s.add_image_from_path(NOTE, 2, &src).await.unwrap();
    s.add_link(NOTE, 2, "https://example.com/2.png").await.unwrap();

    let list = s.list(NOTE, 2).await.unwrap();
    let names: Vec<&str> = list.iter().map(|i| i.name.as_str()).collect();
    assert_eq!(
        names,
        vec![
            first.name.as_str(),
            second.name.as_str(),
            "https://example.com/1.png",
            "https://example.com/2.png"
        ]
    );
    assert_eq!(list[2].kind, ImageKind::Link);
}

#[tokio::test]
async fn list_for_an_item_without_images_is_empty() {
    let db = TestDb::new().await;
    assert!(svc(&db).list(NOTE, 99).await.unwrap().is_empty());
}

#[tokio::test]
async fn ids_that_share_digits_do_not_mix() {
    let db = TestDb::new().await;
    let s = svc(&db);
    let src = source(&db, "a.jpg");
    s.add_image_from_path(NOTE, 1, &src).await.unwrap();
    s.add_image_from_path(NOTE, 12, &src).await.unwrap();
    s.add_link(NOTE, 12, "https://example.com/x.png").await.unwrap();

    assert_eq!(s.list(NOTE, 1).await.unwrap().len(), 1);
    assert_eq!(s.list(NOTE, 12).await.unwrap().len(), 2);

    s.delete_all(NOTE, 1).await.unwrap();
    assert!(s.list(NOTE, 1).await.unwrap().is_empty());
    assert_eq!(s.list(NOTE, 12).await.unwrap().len(), 2);
}

#[tokio::test]
async fn links_are_validated_trimmed_and_deduplicated() {
    let db = TestDb::new().await;
    let s = svc(&db);
    for bad in ["", "ftp://x.com/a.png", "example.com/a.png", "https://a b.com", "https://"] {
        assert!(is_validation(s.add_link(NOTE, 1, bad).await), "{bad}");
    }
    s.add_link(NOTE, 1, "  https://example.com/a.png ").await.unwrap();
    s.add_link(NOTE, 1, "https://example.com/a.png").await.unwrap();
    assert_eq!(s.list(NOTE, 1).await.unwrap().len(), 1);
}

#[tokio::test]
async fn links_live_in_a_text_file_named_after_the_id() {
    let db = TestDb::new().await;
    let s = svc(&db);
    s.add_link(NOTE, 5, "https://example.com/a.png").await.unwrap();
    s.add_link(NOTE, 5, "https://example.com/b.png").await.unwrap();
    let text = std::fs::read_to_string(db.dir.join("note_images/5_links.txt")).unwrap();
    assert_eq!(text, "https://example.com/a.png\nhttps://example.com/b.png\n");
}

#[tokio::test]
async fn removes_a_link_and_the_file_goes_with_the_last_one() {
    let db = TestDb::new().await;
    let s = svc(&db);
    s.add_link(NOTE, 5, "https://example.com/a.png").await.unwrap();
    s.add_link(NOTE, 5, "https://example.com/b.png").await.unwrap();
    s.remove_link(NOTE, 5, "https://example.com/a.png").await.unwrap();
    assert_eq!(s.list(NOTE, 5).await.unwrap().len(), 1);
    s.remove_link(NOTE, 5, "https://example.com/b.png").await.unwrap();
    assert!(!db.dir.join("note_images/5_links.txt").exists());
}

#[tokio::test]
async fn removes_one_image_file() {
    let db = TestDb::new().await;
    let s = svc(&db);
    let src = source(&db, "a.jpg");
    let a = s.add_image_from_path(NOTE, 4, &src).await.unwrap();
    let b = s.add_image_from_path(NOTE, 4, &src).await.unwrap();
    s.remove_image(NOTE, 4, &a.name).await.unwrap();
    assert!(!std::path::Path::new(&a.value).exists());
    assert!(std::path::Path::new(&b.value).exists());
    // removing it again is fine
    s.remove_image(NOTE, 4, &a.name).await.unwrap();
}

#[tokio::test]
async fn remove_image_refuses_other_files_and_path_tricks() {
    let db = TestDb::new().await;
    let s = svc(&db);
    let src = source(&db, "a.jpg");
    let other = s.add_image_from_path(NOTE, 9, &src).await.unwrap();
    for name in [
        other.name.as_str(), // belongs to id 9, not 4
        "4_../notecore.db",
        "4_/etc/passwd",
        "4_..\\x.png",
        "4_links.txt",
    ] {
        assert!(is_validation(s.remove_image(NOTE, 4, name).await), "{name}");
    }
    assert!(std::path::Path::new(&other.value).exists());
    assert!(db.dir.join("notecore.db").exists());
}

#[tokio::test]
async fn delete_all_removes_images_and_links() {
    let db = TestDb::new().await;
    let s = svc(&db);
    let src = source(&db, "a.jpg");
    s.add_image_from_path(NOTE, 6, &src).await.unwrap();
    s.add_link(NOTE, 6, "https://example.com/a.png").await.unwrap();
    s.delete_all(NOTE, 6).await.unwrap();
    let left: Vec<_> = std::fs::read_dir(db.dir.join("note_images")).unwrap().collect();
    assert!(left.is_empty());
    // nothing to delete is fine
    s.delete_all(NOTE, 6).await.unwrap();
}

#[tokio::test]
async fn deleting_a_note_deletes_its_images() {
    let db = TestDb::new().await;
    let images = svc(&db);
    let notes = NotesService::new(db.pool.clone()).await.unwrap().with_images(images.clone());
    let src = source(&db, "a.jpg");

    let kept = notes.create_note().await.unwrap();
    let gone = notes.create_note().await.unwrap();
    images.add_image_from_path(NOTE, kept.id, &src).await.unwrap();
    images.add_image_from_path(NOTE, gone.id, &src).await.unwrap();
    images.add_link(NOTE, gone.id, "https://example.com/a.png").await.unwrap();

    notes.delete_note(gone.id).await.unwrap();

    assert!(images.list(NOTE, gone.id).await.unwrap().is_empty());
    assert_eq!(images.list(NOTE, kept.id).await.unwrap().len(), 1);
}

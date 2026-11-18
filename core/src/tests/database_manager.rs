// use super::common::*;
use crate::models::settings::Settings;
use crate::services::database_manager::DatabaseManager;

#[tokio::test]
async fn creates_the_database_file() {
    let db = TestDb::new().await;
    assert!(db.dir.join("notecore.db").exists());
}

#[tokio::test]
async fn creates_every_table() {
    let db = TestDb::new().await;
    for table in [
        "app_settings",
        "tags",
        "tasks",
        "note_groups",
        "notes",
        "short_note_sections",
        "short_note_items",
        "short_task_sections",
        "short_task_items",
    ] {
        let found: i64 = sqlx::query_scalar(
            "SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' AND name = ?",
        )
        .bind(table)
        .fetch_one(&*db.pool)
        .await
        .unwrap();
        assert_eq!(found, 1, "missing table {table}");
    }
}

#[tokio::test]
async fn a_new_database_gets_the_default_settings() {
    let db = TestDb::new().await;
    let all = Settings::get_all(&db.pool).await.unwrap();
    assert_eq!(all.len(), 5);
    assert_eq!(all["language"], "default");
    assert_eq!(all["theme"], "default");
    assert_eq!(all["theme_color"], "default");
    assert_eq!(all["reset_time"], "0");
    assert_eq!(all["font_size"], "14");
}

#[tokio::test]
async fn foreign_keys_are_enforced() {
    let db = TestDb::new().await;
    let on: i64 = sqlx::query_scalar("PRAGMA foreign_keys")
        .fetch_one(&*db.pool)
        .await
        .unwrap();
    assert_eq!(on, 1);
}

#[tokio::test]
async fn reopening_keeps_data_and_does_not_reset_settings() {
    let db = TestDb::new().await;
    Settings::set(&db.pool, "theme", "aqua").await.unwrap();

    let reopened = DatabaseManager::init(db.path()).await.unwrap();
    assert_eq!(
        Settings::get(&reopened, "theme").await.unwrap().as_deref(),
        Some("aqua")
    );
}

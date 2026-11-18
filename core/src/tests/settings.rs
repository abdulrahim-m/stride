// use super::common::*;
use crate::models::settings::Settings;

#[tokio::test]
async fn get_returns_none_for_unknown_keys() {
    let db = TestDb::new().await;
    assert_eq!(Settings::get(&db.pool, "nope").await.unwrap(), None);
}

#[tokio::test]
async fn get_returns_a_default_value() {
    let db = TestDb::new().await;
    assert_eq!(
        Settings::get(&db.pool, "font_size").await.unwrap().as_deref(),
        Some("14")
    );
}

#[tokio::test]
async fn set_adds_a_new_key() {
    let db = TestDb::new().await;
    Settings::set(&db.pool, "custom", "1").await.unwrap();
    assert_eq!(
        Settings::get(&db.pool, "custom").await.unwrap().as_deref(),
        Some("1")
    );
}

#[tokio::test]
async fn set_overwrites_an_existing_key() {
    let db = TestDb::new().await;
    Settings::set(&db.pool, "theme", "rust").await.unwrap();
    Settings::set(&db.pool, "theme", "forest").await.unwrap();
    assert_eq!(
        Settings::get(&db.pool, "theme").await.unwrap().as_deref(),
        Some("forest")
    );
    // still one row for the key
    assert_eq!(Settings::get_all(&db.pool).await.unwrap().len(), 5);
}

#[tokio::test]
async fn get_all_returns_every_pair() {
    let db = TestDb::new().await;
    Settings::set(&db.pool, "extra", "x").await.unwrap();
    let all = Settings::get_all(&db.pool).await.unwrap();
    assert_eq!(all.len(), 6);
    assert_eq!(all["extra"], "x");
}

#[tokio::test]
async fn setup_defaults_never_overwrites_existing_values() {
    let db = TestDb::new().await;
    Settings::set(&db.pool, "language", "ar").await.unwrap();
    Settings::setup_defaults(&db.pool).await.unwrap();
    assert_eq!(
        Settings::get(&db.pool, "language").await.unwrap().as_deref(),
        Some("ar")
    );
}

#[tokio::test]
async fn setup_defaults_restores_missing_keys() {
    let db = TestDb::new().await;
    sqlx::query("DELETE FROM app_settings WHERE key = 'font_size'")
        .execute(&*db.pool)
        .await
        .unwrap();
    Settings::setup_defaults(&db.pool).await.unwrap();
    assert_eq!(
        Settings::get(&db.pool, "font_size").await.unwrap().as_deref(),
        Some("14")
    );
}

#[tokio::test]
async fn theme_color_defaults_to_default() {
    let db = TestDb::new().await;
    assert_eq!(
        Settings::get(&db.pool, "theme_color").await.unwrap().as_deref(),
        Some("default")
    );
}

#[tokio::test]
async fn reset_defaults_overwrites_changed_values() {
    let db = TestDb::new().await;
    Settings::set(&db.pool, "theme_color", "dark").await.unwrap();
    Settings::set(&db.pool, "font_size", "20").await.unwrap();
    Settings::set(&db.pool, "language", "ar").await.unwrap();

    Settings::reset_defaults(&db.pool).await.unwrap();

    let all = Settings::get_all(&db.pool).await.unwrap();
    assert_eq!(all["theme_color"], "default");
    assert_eq!(all["font_size"], "14");
    assert_eq!(all["language"], "default");
}

#[tokio::test]
async fn reset_defaults_keeps_unrelated_keys() {
    let db = TestDb::new().await;
    Settings::set(&db.pool, "extra", "x").await.unwrap();
    Settings::reset_defaults(&db.pool).await.unwrap();
    assert_eq!(Settings::get(&db.pool, "extra").await.unwrap().as_deref(), Some("x"));
}

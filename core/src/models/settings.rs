use std::collections::HashMap;

use chrono::Utc;
use sqlx::{Row, SqlitePool};

use crate::utils::app_error::Result;

pub struct Settings;

impl Settings {
    pub async fn get_all(pool: &SqlitePool) -> Result<HashMap<String, String>> {
        Ok(sqlx::query(
            "SELECT key, value FROM app_settings"
        ).fetch_all(pool).await?.into_iter().map(|r| (r.get("key"), r.get("value"))).collect())
    }

    pub async fn set(pool: &SqlitePool, key: &str, value: &str) -> Result<()> {
        sqlx::query(
            "INSERT OR REPLACE INTO app_settings (key, value) VALUES (?, ?)"
        )
        .bind(key)
        .bind(value)
        .execute(pool)
        .await?;
        
        Ok(())
    }

    pub async fn get(pool: &SqlitePool, key: &str) -> Result<Option<String>> {
        let result: Option<(String,)> = sqlx::query_as(
            "SELECT value FROM app_settings WHERE key = ?"
        )
        .bind(key)
        .fetch_optional(pool)
        .await?;

        Ok(result.map(|row| row.0))
    }

    fn get_defaults() -> [(String, String); 10] {
        let now = Utc::now().to_string();
        [
            ("language".to_string(), "default".to_string()),    // default | en | ar | ...
            ("theme".to_string(), "default".to_string()),       // default | rust | aqua | neutral | ...
            ("theme_color".to_string(), "default".to_string()), // default | light | dark
            ("reset_time".to_string(), "0".to_string()),        // 0-23 (hours of the day)
            ("font_size".to_string(), "14".to_string()),        // 12-24

            ("sync".to_string(), "false".to_string()),             // false | true
            ("cloud-backup".to_string(), "false".to_string()),     // false | true
            ("encrypted_backup".to_string(), "false".to_string()), // false | true
            ("backup_interval".to_string(), "0".to_string()), // 0 1-7 (days)

            ("last_backup".to_string(), now),     // ISO 8601
        ]
    }

    pub async fn setup_defaults(pool: &SqlitePool) -> Result<()> {
        Self::write_defaults(pool, "INSERT OR IGNORE").await
    }

    /// "Reset settings": every default goes back to its default value, other
    /// keys are left alone.
    pub async fn reset_defaults(pool: &SqlitePool) -> Result<()> {
        Self::write_defaults(pool, "INSERT OR REPLACE").await
    }

    async fn write_defaults(pool: &SqlitePool, verb: &str) -> Result<()> {
        let mut query_builder =
            sqlx::QueryBuilder::new(format!("{verb} INTO app_settings (key, value) "));

        query_builder.push_values(Self::get_defaults(), |mut b, (key, value)| {
            b.push_bind(key).push_bind(value);
        });

        query_builder.build().execute(pool).await?;
        Ok(())
    }
}
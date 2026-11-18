pub mod notes;
pub mod short_notes;
pub mod short_tasks;
pub mod tags;
pub mod tasks;
pub mod images;

use std::collections::HashMap;
use std::sync::Arc;

use flutter_rust_bridge::frb;
use notecore::models::settings::Settings;
use notecore::services::images::ImageService;
use notecore::services::{
    database_manager::DatabaseManager, notes::NotesService, short_notes::ShortNotesService,
    short_tasks::ShortTasksService, tags_service::TagsService, tasks::TasksService,
};
use sqlx::SqlitePool;

use crate::api::images::ImagesApi;
use crate::error::ApiError;

use self::{
    notes::NotesApi, short_notes::ShortNotesApi, short_tasks::ShortTasksApi, tags::TagsApi,
    tasks::TasksApi,
};

#[frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

#[frb(opaque)]
pub struct NoteCore {
    pool: Arc<SqlitePool>,
    images: ImageService,
    notes: NotesService,
    short_notes: ShortNotesService,
    tasks: TasksService,
    short_tasks: ShortTasksService,
    tags: TagsService,
}

impl NoteCore {
    pub async fn open(base_path: String) -> Result<NoteCore, ApiError> {
        let images = ImageService::new(&base_path)?;
        let pool = Arc::new(DatabaseManager::init(base_path).await?);

        Ok(NoteCore {
            notes: NotesService::new(pool.clone()).await?.with_images(images.clone()),  // CHANGED
            short_notes: ShortNotesService::new(pool.clone()).await?,
            tasks: TasksService::new(pool.clone()).await?,
            short_tasks: ShortTasksService::new(pool.clone()).await?,
            tags: TagsService::new(pool.clone()).await?,
            images,
            pool,
        })
    }

    // pub async fn refresh(&self) -> Result<(), ApiError> {
    //     self.notes.refrech().await?;
    //     self.short_notes.refrech().await?;
    //     self.tasks.refrech().await?;
    //     self.short_tasks.refrech().await?;
    //     self.tags.refrech().await?;

    //     Ok(())
    // }

    pub async fn close(&self) {
        self.pool.close().await;
    }

    // --- Feature APIs ---

    #[frb(sync)]
    pub fn notes(&self) -> NotesApi {
        NotesApi::new(self.notes.clone())
    }

    #[frb(sync)]
    pub fn short_notes(&self) -> ShortNotesApi {
        ShortNotesApi::new(self.short_notes.clone())
    }

    #[frb(sync)]
    pub fn tasks(&self) -> TasksApi {
        TasksApi::new(self.tasks.clone())
    }

    #[frb(sync)]
    pub fn short_tasks(&self) -> ShortTasksApi {
        ShortTasksApi::new(self.short_tasks.clone())
    }

    #[frb(sync)]
    pub fn tags(&self) -> TagsApi {
        TagsApi::new(self.tags.clone())
    }

    #[frb(sync)]
    pub fn images(&self) -> ImagesApi {
        ImagesApi::new(self.images.clone())
    }

    // --- Settings ---

    pub async fn get_setting(&self, key: String) -> Result<Option<String>, ApiError> {
        Ok(Settings::get(&self.pool, &key).await?)
    }

    pub async fn get_settings(&self) -> Result<HashMap<String, String>, ApiError> {
        Ok(Settings::get_all(&self.pool).await?)
    }

    pub async fn set_setting(&self, key: String, value: String) -> Result<(), ApiError> {
        Ok(Settings::set(&self.pool, &key, &value).await?)
    }

    pub async fn reset_settings(&self) -> Result<(), ApiError> {
        Ok(Settings::setup_defaults(&self.pool).await?)
    }
}

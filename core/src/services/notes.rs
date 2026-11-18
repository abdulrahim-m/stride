use std::sync::Arc;

use sqlx::{SqlitePool};

use crate::{
    models::{
        notes::{
            notes::{Note, NoteGroup}, 
            ui_notes::{UINote, UINoteGroup, UINoteListItem}
        }, 
        repo::{ListRequest, Model, SearchParams}, 
        tags::{tags::Tag, ui_tags::UITag}
    }, 
    services::images::{ImageOwner, ImageService},
    utils::app_error::{
        AppError, ErrorType, Result
    }
};


#[derive(Debug, Clone)]
pub struct NotesService {
    pool: Arc<SqlitePool>,
    images: Option<ImageService>,
}

impl NotesService {
    pub async  fn new(pool: Arc<SqlitePool>) -> Result<Self> {
       let service = NotesService { pool: pool, images: None };
        service.refrech().await?;
        Ok(service)
    }
    
    pub async fn refrech(&self) -> Result<()> {
        Ok(())
    }
    
    // Get
    
    pub fn with_images(mut self, images: ImageService) -> Self {
        self.images = Some(images);
        self
    }
    
    pub async fn get_note(&self, id: i64) -> Result<UINote> {
        let item = Note::get_by_id(&self.pool, id).await?;
        self.map_note(item).await
    }

    pub async fn get_list(&self, req: ListRequest) -> Result<Vec<UINoteListItem>> {
        let list = Note::get_all(&self.pool, Some(req)).await?;
        self.map_ui_notes(list).await
    }

    pub async fn get_list_group(&self, req: ListRequest, group_id: i64) -> Result<Vec<UINoteListItem>> {
        let list = Note::get_with_group_id(&self.pool, req, group_id).await?;
        self.map_ui_notes(list).await
    }

    pub async fn search(&self, params: SearchParams, list: ListRequest) -> Result<Vec<UINoteListItem>> {
        let notes = Note::search(&self.pool, params, Some(list)).await?;
        self.map_ui_notes(notes).await
    }
    
    pub async fn get_groups(&self) -> Result<Vec<UINoteGroup>> {
        let list = NoteGroup::get_all(&self.pool, None).await?;

        let mut res = Vec::new();
        for group in list {
            res.push(UINoteGroup {
                id: group.id,
                name: group.name,
                listed_notes: group.listed_notes,
                placing: group.placing
            });
        }

        Ok(res)
    }

    // Create

    pub async fn create_note(&self) -> Result<UINote> {
        let mut note = Note::new();
        note.create(&self.pool).await?;
        Ok(UINote::from(note, Vec::new()))
    }

    pub async fn create_note_group(&self, name: &str, placing: i64) -> Result<UINoteGroup> {
        let mut group = NoteGroup::new(name, placing);
        group.create(&self.pool).await?;
        Ok(UINoteGroup::from(group))
    }

    // Update

    pub async fn update_note(&self, id: i64, title: String, content: String) -> Result<()> {
        let mut note = Note::get_by_id(&self.pool, id).await?;

        note.title = title;
        note.content = content;
        note.update(&self.pool).await?;

        Ok(())
    }

    pub async fn add_to_group(&self, group_id: Option<i64>, notes_ids: Vec<i64>) -> Result<()> {
        Note::add_to_group(&self.pool, group_id, notes_ids).await?;
        Ok(())
    }

    pub async fn update_tags(&self, note_id: i64, tag_ids: Vec<i64>) -> Result<()> {
        let mut note = Note::get_by_id(&self.pool, note_id).await?;

        note.tags.0 = tag_ids;
        note.update(&self.pool).await?;

        Ok(())
    }

    pub async fn update_note_group(&self, id: i64, name: String) -> Result<()> {
        let mut group = NoteGroup::get_by_id(&self.pool, id).await?;

        group.name = name;
        group.update(&self.pool).await?;

        Ok(())
    }

    /// Saves a new group order: the i-th id gets `placing = i`.
    pub async fn reorder_note_groups(&self, ordered_ids: Vec<i64>) -> Result<()> {
        for (i, id) in ordered_ids.iter().enumerate() {
            let mut group = NoteGroup::get_by_id(&self.pool, *id).await?;
            group.placing = i as i64;
            group.update(&self.pool).await?;
        }
        Ok(())
    }

    // Delete

    pub async fn delete_group(&self, id: i64) -> Result<()> {
        let group = NoteGroup::get_by_id(&self.pool, id).await?;

        if group.listed_notes != 0 {
            return Err(AppError::new("Group is not empty", ErrorType::Forbidden));
        }

        NoteGroup::delete(&self.pool, id).await?;

        Ok(())
    }

    pub async fn delete_note(&self, id: i64) -> Result<()> {
        Note::delete(&self.pool, id).await?;
        if let Some(images) = &self.images {
            let _ = images.delete_all(ImageOwner::Note, id).await;
        }
        Ok(())
    }

    // Helpers

    async fn map_ui_notes(&self, list: Vec<Note>) -> Result<Vec<UINoteListItem>> {
        let mut res = Vec::new();
        for item in list {
            let tags = Tag::get_with_ids(&self.pool, item.tags.0).await?;
            let ui_tags = tags
                .iter()
                .map(|t| UITag{id: t.id, name: t.name.clone(), created_at: t.created_at})
                .collect();

            res.push(UINoteListItem{
                id: item.id,
                group_id: item.group_id,
                title: item.title,
                preview: item.content.lines().next().unwrap_or_default().to_string(),
                tags: ui_tags,
                created_at: item.created_at,
                updated_at: item.updated_at,
            });
        }

        Ok(res)
    }

    async fn map_note(&self, note: Note) -> Result<UINote> {
        let tags = Tag::get_with_ids(&self.pool, note.tags.0).await?;
        let ui_tags = tags
            .iter()
            .map(|t| UITag{id: t.id, name: t.name.clone(), created_at: t.created_at})
            .collect();

        Ok(UINote {
            id: note.id,
            group_id: note.group_id,
            title: note.title,
            content: note.content,
            tags: ui_tags,
            created_at: note.created_at,
            updated_at: note.updated_at,
        })
    }
}


use flutter_rust_bridge::frb;
use notecore::models::repo::ListRequest;
use notecore::services::notes::NotesService;

use crate::dto::note::{NoteDto, NoteGroupDto, NoteListItemDto};
use crate::dto::query::{ListRequestDto, SearchParamsDto};
use crate::error::ApiError;

/// Notes and note groups.
#[frb(opaque)]
pub struct NotesApi {
    service: NotesService,
}

impl NotesApi {
    pub(crate) fn new(service: NotesService) -> Self {
        Self { service }
    }

    pub async fn refresh(&self) -> Result<(), ApiError> {
        self.service.refrech().await?;

        Ok(())
    }

    // --- Get ---

    pub async fn get_note(&self, id: i64) -> Result<NoteDto, ApiError> {
        Ok(self.service.get_note(id).await?.into())
    }

    pub async fn get_list(&self, req: ListRequestDto) -> Result<Vec<NoteListItemDto>, ApiError> {
        let list = self.service.get_list(ListRequest::try_from(req)?).await?;
        Ok(list.into_iter().map(Into::into).collect())
    }

    pub async fn get_list_in_group(
        &self,
        req: ListRequestDto,
        group_id: i64,
    ) -> Result<Vec<NoteListItemDto>, ApiError> {
        let list = self
            .service
            .get_list_group(ListRequest::try_from(req)?, group_id)
            .await?;
        Ok(list.into_iter().map(Into::into).collect())
    }

    pub async fn search(&self, params: SearchParamsDto, list: ListRequestDto) -> Result<Vec<NoteListItemDto>, ApiError> {
        let list = self.service.search(params.into(), ListRequest::try_from(list)?).await?;
        Ok(list.into_iter().map(Into::into).collect())
    }

    pub async fn get_groups(&self) -> Result<Vec<NoteGroupDto>, ApiError> {
        let list = self.service.get_groups().await?;
        Ok(list.into_iter().map(Into::into).collect())
    }

    // --- Create ---

    /// Creates an empty note titled "untitled".
    pub async fn create_note(&self) -> Result<NoteDto, ApiError> {
        Ok(self.service.create_note().await?.into())
    }

    pub async fn create_note_group(
        &self,
        name: String,
        placing: i64,
    ) -> Result<NoteGroupDto, ApiError> {
        Ok(self.service.create_note_group(&name, placing).await?.into())
    }

    // --- Update ---

    pub async fn update_note(
        &self,
        id: i64,
        title: String,
        content: String,
    ) -> Result<(), ApiError> {
        Ok(self.service.update_note(id, title, content).await?)
    }

    /// Moves notes into a group. `group_id = None` removes them from any group.
    pub async fn add_to_group(
        &self,
        group_id: Option<i64>,
        note_ids: Vec<i64>,
    ) -> Result<(), ApiError> {
        Ok(self.service.add_to_group(group_id, note_ids).await?)
    }

    /// Replaces the note's tags with exactly `tag_ids`.
    pub async fn update_tags(&self, note_id: i64, tag_ids: Vec<i64>) -> Result<(), ApiError> {
        Ok(self.service.update_tags(note_id, tag_ids).await?)
    }

    pub async fn update_note_group(&self, id: i64, name: String) -> Result<(), ApiError> {
        Ok(self.service.update_note_group(id, name).await?)
    }

    /// Saves the order of the groups: `ids` from first to last.
    pub async fn reorder_note_groups(&self, ids: Vec<i64>) -> Result<(), ApiError> {
        self.service.reorder_note_groups(ids).await.map_err(ApiError::from)
    }

    // --- Delete ---

    /// Fails with `ApiErrorKind::Forbidden` if the group still contains notes.
    pub async fn delete_group(&self, id: i64) -> Result<(), ApiError> {
        Ok(self.service.delete_group(id).await?)
    }

    pub async fn delete_note(&self, id: i64) -> Result<(), ApiError> {
        Ok(self.service.delete_note(id).await?)
    }
}

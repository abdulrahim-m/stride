use flutter_rust_bridge::frb;
use notecore::services::images::ImageService;

use crate::dto::image::{ImageDto, ImageOwnerDto};
use crate::error::ApiError;

/// Images and image links of notes (and later other items).
#[frb(opaque)]
pub struct ImagesApi {
    service: ImageService,
}

impl ImagesApi {
    pub(crate) fn new(service: ImageService) -> Self {
        Self { service }
    }

    /// Files first (oldest first), then links.
    pub async fn list(&self, owner: ImageOwnerDto, owner_id: i64) -> Result<Vec<ImageDto>, ApiError> {
        let list = self.service.list(owner.into(), owner_id).await?;
        Ok(list.into_iter().map(Into::into).collect())
    }

    /// The core copies the file into its own folder, the original is untouched.
    pub async fn add_from_path(
        &self,
        owner: ImageOwnerDto,
        owner_id: i64,
        path: String,
    ) -> Result<ImageDto, ApiError> {
        Ok(self
            .service
            .add_image_from_path(owner.into(), owner_id, &path)
            .await?
            .into())
    }

    /// Fails with `ApiErrorKind::Validation` unless it is an http(s) link.
    pub async fn add_link(
        &self,
        owner: ImageOwnerDto,
        owner_id: i64,
        url: String,
    ) -> Result<ImageDto, ApiError> {
        Ok(self
            .service
            .add_link(owner.into(), owner_id, &url)
            .await?
            .into())
    }

    /// `name` is `ImageDto::name` of a file image.
    pub async fn remove_image(
        &self,
        owner: ImageOwnerDto,
        owner_id: i64,
        name: String,
    ) -> Result<(), ApiError> {
        Ok(self.service.remove_image(owner.into(), owner_id, &name).await?)
    }

    pub async fn remove_link(
        &self,
        owner: ImageOwnerDto,
        owner_id: i64,
        url: String,
    ) -> Result<(), ApiError> {
        Ok(self.service.remove_link(owner.into(), owner_id, &url).await?)
    }
}

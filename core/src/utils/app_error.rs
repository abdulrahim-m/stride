use std::fmt;

#[derive(Debug, Clone)]
pub enum ErrorType{
    Internal,
    Forbidden,
    Validation
}

#[derive(Debug, Clone)]
pub struct AppError {
    pub message: String,
    pub error_type: ErrorType,
}

impl From<sqlx::Error> for AppError {
    fn from(err: sqlx::Error) -> Self {
        AppError{
            message: err.to_string(),
            error_type: ErrorType::Internal
        }
    }
}

impl From<std::io::Error> for AppError {
    fn from(err: std::io::Error) -> Self {
        AppError {
            message: err.to_string(),
            error_type: ErrorType::Internal,
        }
    }
}

impl std::error::Error for AppError {}

impl fmt::Display for AppError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{:?}: {}", self.error_type, self.message)
    }
}

impl AppError {
    pub fn new(err: &str, error_type: ErrorType) -> Self {
        AppError{
            message: err.to_string(),
            error_type
        }
    }
}

pub type Result<T, E = AppError> = ::std::result::Result<T, E>;
#[derive(Debug, thiserror::Error)]
pub enum ToolError {
    #[error("knowledge base search failed: {0}")]
    SearchFailed(String),

    #[error("failed to retrieve user profile: {0}")]
    ProfileFailed(String),
}

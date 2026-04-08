#[derive(Debug, thiserror::Error)]
pub enum ToolError {
    #[error("knowledge base search failed: {0}")]
    SearchFailed(String),

    #[error("decision-tree inference failed: {0}")]
    InferenceFailed(String),
}

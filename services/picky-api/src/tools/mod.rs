//! Tool definitions for the AI agent.
//!
//! Each tool implements the [`rig::tool::Tool`] trait. The agent will
//! automatically serialize/deserialize arguments and dispatch calls to the
//! correct [`Tool::call`] implementation.

mod error;
mod knowledge;
mod predict;

pub use error::ToolError;

pub use knowledge::SearchKnowledgeBase;
pub use predict::PredictPreference;

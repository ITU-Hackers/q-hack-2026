//! Application state shared across all axum handlers.

use std::sync::Arc;

use axum::extract::FromRef;

use crate::agent::Agent;
use crate::food2vec::EmbeddingMap;

pub type AgentState = Arc<Agent>;
pub type EmbeddingMapState = EmbeddingMap;

#[derive(Clone)]
pub struct AppState {
    pub agent: AgentState,
    pub embeddings: EmbeddingMapState,
}

impl AppState {
    pub fn new(agent: Agent, embeddings: EmbeddingMap) -> Self {
        Self {
            agent: Arc::new(agent),
            embeddings,
        }
    }
}

impl FromRef<AppState> for AgentState {
    fn from_ref(state: &AppState) -> Self {
        state.agent.clone()
    }
}

impl FromRef<AppState> for EmbeddingMapState {
    fn from_ref(state: &AppState) -> Self {
        state.embeddings.clone()
    }
}

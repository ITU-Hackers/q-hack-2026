//! Application state shared across all axum handlers.

use std::sync::Arc;

use axum::extract::FromRef;
use qdrant_client::Qdrant;

use crate::agent::{Agent, SharedAgent};
use crate::model_watcher::SharedModel;

pub type AgentState = SharedAgent;

pub type ModelState = SharedModel;

pub type DbState = sqlx::PgPool;

pub type QdrantState = Arc<Qdrant>;

#[derive(Clone)]
pub struct AppState {
    pub agent: AgentState,
    pub model: ModelState,
    pub db: DbState,
    pub qdrant: QdrantState,
}

impl AppState {
    pub fn new(
        agent: SharedAgent,
        model: ModelState,
        db: DbState,
        qdrant: QdrantState,
    ) -> Self {
        Self {
            agent,
            model,
            db,
            qdrant,
        }
    }
}

impl FromRef<AppState> for AgentState {
    fn from_ref(state: &AppState) -> Self {
        state.agent.clone()
    }
}

impl FromRef<AppState> for ModelState {
    fn from_ref(state: &AppState) -> Self {
        state.model.clone()
    }
}

impl FromRef<AppState> for DbState {
    fn from_ref(state: &AppState) -> Self {
        state.db.clone()
    }
}

impl FromRef<AppState> for QdrantState {
    fn from_ref(state: &AppState) -> Self {
        state.qdrant.clone()
    }
}
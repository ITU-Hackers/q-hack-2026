//! Application state shared across all axum handlers.

use std::sync::Arc;

use axum::extract::FromRef;

use crate::agent::Agent;

pub type AgentState = Arc<Agent>;

#[derive(Clone)]
pub struct AppState {
    pub agent: AgentState,
}

impl AppState {
    pub fn new(agent: Agent) -> Self {
        Self {
            agent: Arc::new(agent),
        }
    }
}

impl FromRef<AppState> for AgentState {
    fn from_ref(state: &AppState) -> Self {
        state.agent.clone()
    }
}

//! HTTP API router for the AI agent service.

use crate::state::AppState;

use utoipa_axum::{router::OpenApiRouter, routes};

mod chat;

pub fn router(state: AppState) -> OpenApiRouter<AppState> {
    OpenApiRouter::new()
        .routes(routes!(chat::handler))
        .with_state(state)
}

//! Chat handler for the AI agent HTTP API.

use std::sync::Arc;

use axum::{Json, extract::State};
use http::StatusCode;
use picky_axum::error::{HandlerError, HandlerErrorSchema, HandlerResult};
use rig::completion::Prompt;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

use crate::agent::Agent;
use crate::oapi::AGENT_TAG;
use crate::state::{AgentState, AppState};

#[derive(Debug, Deserialize, ToSchema)]
pub struct ChatRequest {
    pub message: String,
}

#[derive(Debug, Serialize, ToSchema)]
pub struct ChatResponse {
    pub response: String,
}

#[utoipa::path(
    post,
    path = "/chat",
    tag = AGENT_TAG,
    summary = "Chat with the AI agent",
    description = "Send a plain-text message to the AI agent and receive a \
        response. The agent will automatically retrieve relevant context from the \
        knowledge base and invoke tools as needed.",
    request_body = ChatRequest,
    responses(
        (
            status = 200,
            description = "Agent replied successfully",
            body = ChatResponse
        ),
        (
            status = UNAUTHORIZED,
            description = "Missing or invalid authentication token",
            body = HandlerErrorSchema,
            content_type = "application/problem+json"
        ),
        (
            status = 500,
            description = "Internal server error",
            body = HandlerErrorSchema
        ),
    )
)]
#[axum::debug_handler(state = AppState)]
pub async fn handler(
    State(agent): State<AgentState>,
    Json(payload): Json<ChatRequest>,
) -> HandlerResult<Json<ChatResponse>> {
    if payload.message.is_empty() {
        return Err(HandlerError::new(
            StatusCode::BAD_REQUEST,
            "Message cannot be empty",
            "Please provide a message to send to the AI agent",
        ));
    }

    let response = agent.prompt(payload.message.as_str()).await?;

    Ok(Json(ChatResponse { response }))
}

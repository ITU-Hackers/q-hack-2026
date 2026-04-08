//! Chat handler for the AI agent HTTP API.
//!
//! Streams the agent's response to the client as **Server-Sent Events (SSE)**.

use std::convert::Infallible;

use axum::{
    Json,
    extract::State,
    response::sse::{Event, KeepAlive, Sse},
};
use http::StatusCode;
use picky_axum::error::{HandlerError, HandlerErrorSchema};
use rig::agent::MultiTurnStreamItem;
use rig::streaming::{StreamedAssistantContent, StreamingPrompt};
use serde::Deserialize;
use tokio_stream::StreamExt;
use utoipa::ToSchema;

use crate::oapi::AGENT_TAG;
use crate::state::{AgentState, AppState};

#[derive(Debug, Deserialize, ToSchema)]
pub struct ChatRequest {
    pub message: String,
}

#[utoipa::path(
    post,
    path = "/chat",
    tag = AGENT_TAG,
    summary = "Chat with the AI agent (streaming)",
    description = "Send a plain-text message to the AI agent and receive a \
        streamed response via Server-Sent Events (SSE). The agent will \
        automatically retrieve relevant context from the knowledge base and \
        invoke tools as needed.\n\n\
        ## SSE Event Types\n\
        - `message` — A text chunk from the agent's response.\n\
        - `error` — An error occurred during generation.\n\
        - `done` — The stream has completed (data will be `[DONE]`).",
    request_body = ChatRequest,
    responses(
        (
            status = 200,
            description = "Streamed agent response via Server-Sent Events",
            content_type = "text/event-stream"
        ),
        (
            status = 400,
            description = "Invalid request",
            body = HandlerErrorSchema,
            content_type = "application/problem+json"
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
            body = HandlerErrorSchema,
            content_type = "application/problem+json"
        ),
    )
)]
#[axum::debug_handler(state = AppState)]
pub async fn handler(
    State(agent): State<AgentState>,
    Json(payload): Json<ChatRequest>,
) -> Result<Sse<impl tokio_stream::Stream<Item = Result<Event, Infallible>>>, HandlerError> {
    if payload.message.is_empty() {
        return Err(HandlerError::new(
            StatusCode::BAD_REQUEST,
            "Message cannot be empty",
            "Please provide a message to send to the AI agent",
        ));
    }

    let stream = agent.stream_prompt(payload.message.as_str()).await;

    let event_stream = stream
        .filter_map(|item| match item {
            Ok(MultiTurnStreamItem::StreamAssistantItem(StreamedAssistantContent::Text(text))) => {
                Some(Ok(Event::default().event("message").data(text.text)))
            }
            Ok(_) => None,
            Err(e) => {
                tracing::error!(error = %e, "Error while streaming agent response");
                Some(Ok(Event::default().event("error").data(e.to_string())))
            }
        })
        .chain(tokio_stream::once(Ok(Event::default()
            .event("done")
            .data("[DONE]"))));

    Ok(Sse::new(event_stream).keep_alive(KeepAlive::default()))
}

//! OpenAPI documentation definition for the Picky AI agent HTTP service.

use picky_axum::error::HandlerErrorSchema;
use utoipa::openapi::security::{Http, HttpAuthScheme, SecurityScheme};
use utoipa::{Modify, OpenApi};

use crate::api::chat::ChatRequest;
use crate::api::profile::model::{
    CreateProfile, LoginRequest, Preferences, Profile, UpdateProfile,
};
use crate::api::recommend::{RecommendQuery, RecommendResponse, RecommendedMeal};

pub const AGENT_TAG: &str = "agent";
pub const RECS_TAG: &str = "recommendations";
pub const PROFILE_TAG: &str = "profiles";
pub const RECIPES_TAG: &str = "recipes";

#[derive(OpenApi)]
#[openapi(
    info(
        title = "Picky API",
        version = "1.0.0",
        description = "REST API for the Picky AI shopping assistant.",
        contact(
            name = "Picky Team",
            email = "picky@picnic.com",
        ),
        license(name = "MIT"),
    ),
    servers(
        (url = "/api/v1", description = "Current version"),
    ),
    tags(
        (
            name = AGENT_TAG,
            description = "Stream natural-language messages to the AI agent \
                and receive responses via Server-Sent Events."
        ),
        (
            name = RECS_TAG,
            description = "Personalised meal recommendations powered by a \
                two-tower ONNX model and Qdrant ANN search."
        ),
        (
            name = PROFILE_TAG,
            description = "CRUD operations for food-preference profiles, \
                including household size, cuisine preferences, dietary \
                restrictions, and more."
        ),
    ),
    components(
        schemas(
            ChatRequest,
            RecommendQuery,
            RecommendResponse,
            RecommendedMeal,
            Profile,
            Preferences,
            CreateProfile,
            UpdateProfile,
            LoginRequest,
            HandlerErrorSchema,
        )
    ),
)]
pub struct ApiDoc;

use std::sync::Arc;

use axum::Json;
use axum::response::{IntoResponse, Redirect};
use axum::routing::get;
use http::Method;
use picky_axum::shutdown_signal;
use qdrant_client::Qdrant;
use secrecy::ExposeSecret;
use tower_http::cors::{Any, CorsLayer};
use tower_http::trace::TraceLayer;
use tracing_subscriber::{EnvFilter, layer::SubscriberExt, util::SubscriberInitExt};
use utoipa::OpenApi;
use utoipa_axum::router::OpenApiRouter;
use utoipa_scalar::{Scalar, Servable};

use crate::config::CONFIG;
use crate::oapi::ApiDoc;
use crate::state::AppState;

mod agent;
mod api;
mod config;
mod model;
mod model_watcher;
mod oapi;
mod portkey;
mod profile_features;
mod state;
mod tools;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    #[cfg(debug_assertions)]
    {
        use std::path::PathBuf;
        let env_path = PathBuf::from_iter([env!("CARGO_MANIFEST_DIR"), ".env"]);
        let _ = dotenvy::from_path(&env_path);
    }

    tracing_subscriber::registry()
        .with(EnvFilter::try_from_default_env().unwrap_or_else(|_| {
            EnvFilter::from(format!("{}=debug,none", env!("CARGO_CRATE_NAME")))
        }))
        .with(tracing_subscriber::fmt::layer())
        .init();

    // Build the S3 client for model downloads.
    // MinIO requires path-style addressing (http://host:port/bucket/key)
    // instead of the default virtual-hosted style (http://bucket.host:port/key).
    // We supply explicit credentials so the SDK doesn't fall back to
    // ~/.aws/credentials (which may contain unrelated AWS session tokens).
    let s3_creds = aws_sdk_s3::config::Credentials::new(
        CONFIG.S3_ACCESS_KEY_ID.as_ref(),
        CONFIG.S3_SECRET_ACCESS_KEY.expose_secret(),
        None, // session token
        None, // expiry
        "picky-env",
    );
    let s3_config = aws_config::defaults(aws_config::BehaviorVersion::latest())
        .endpoint_url(CONFIG.S3_ENDPOINT_URL.as_ref())
        .region(aws_config::Region::new("us-east-1"))
        .credentials_provider(s3_creds)
        .load()
        .await;
    let s3_client = aws_sdk_s3::Client::from_conf(
        aws_sdk_s3::config::Builder::from(&s3_config)
            .force_path_style(true)
            .build(),
    );

    // Spawn the background model watcher (polls S3 for user-tower model changes).
    let (shared_model, _model_watcher_handle) = model_watcher::spawn(
        s3_client,
        CONFIG.S3_BUCKET.to_string(),
        CONFIG.S3_MODEL_KEY.to_string(),
        None,
    );

    // Connect to PostgreSQL.
    let db_pool = sqlx::PgPool::connect(CONFIG.DATABASE_URL.as_ref()).await?;
    sqlx::migrate!().run(&db_pool).await?;

    // Build the Qdrant gRPC client for ANN recipe search.
    let qdrant = Arc::new(Qdrant::from_url(CONFIG.QDRANT_URL_GRPC.as_ref()).build()?);

    let agent = Arc::new(agent::build_agent().await?);
    let state = AppState::new(agent, shared_model, db_pool, qdrant);

    let cors = CorsLayer::new()
        .allow_origin(CONFIG.ALLOWED_ORIGINS.clone())
        .allow_methods([Method::GET, Method::POST, Method::PUT, Method::DELETE])
        .allow_headers(Any);

    let (router, api) = OpenApiRouter::with_openapi(ApiDoc::openapi())
        .nest("/api/v1", api::router(state.clone()))
        .with_state(state)
        .layer(cors)
        .fallback(redirect)
        .split_for_parts();

    let openapi_json = api.clone();
    let app = router
        .route("/api/openapi.json", get(|| async { Json(openapi_json) }))
        .merge(Scalar::with_url("/scalar", api))
        .layer(TraceLayer::new_for_http());

    let listener = tokio::net::TcpListener::bind(&CONFIG.ADDR).await?;
    tracing::info!("server started listening on {}", CONFIG.ADDR);

    let service = app.into_make_service();
    axum::serve(listener, service)
        .with_graceful_shutdown(shutdown_signal())
        .await?;

    Ok(())
}

#[axum::debug_handler]
pub async fn redirect() -> impl IntoResponse {
    Redirect::to("/scalar")
}

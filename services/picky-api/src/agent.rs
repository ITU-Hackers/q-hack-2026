//! Agent construction and execution.

use picky_axum::error::HandlerResult;
use qdrant_client::Qdrant;
use qdrant_client::qdrant::QueryPointsBuilder;
use rig::agent::AgentBuilder;
use rig::client::CompletionClient;
use rig::client::EmbeddingsClient;
use rig::completion::Prompt;
use rig::providers::openai::responses_api::ResponsesCompletionModel;
use rig_qdrant::QdrantVectorStore;
use tracing::instrument;

use crate::config::CONFIG;
use crate::portkey::build_portkey_client;
use crate::tools::SearchKnowledgeBase;

const RAG_TOP_N: usize = 5;

pub type SharedAgent = std::sync::Arc<Agent>;

pub type Agent = rig::agent::Agent<ResponsesCompletionModel>;

pub async fn build_agent() -> anyhow::Result<Agent> {
    let portkey_client = build_portkey_client(
        &CONFIG.PORTKEY_BASE_URL,
        &CONFIG.PORTKEY_API_KEY,
        &CONFIG.PORTKEY_PROVIDER,
    )?;

    let qdrant = Qdrant::from_url(CONFIG.QDRANT_URL_GRPC.as_ref()).build()?;
    let embed_model = portkey_client.embedding_model(CONFIG.EMBEDDING_MODEL.as_ref());
    let query_params = QueryPointsBuilder::new(CONFIG.QDRANT_COLLECTION.as_ref())
        .with_payload(true)
        .build();

    let tool = QdrantVectorStore::new(qdrant, embed_model, query_params);

    let completion_model = portkey_client.completion_model(CONFIG.TEXT_MODEL.as_ref());

    let agent = AgentBuilder::new(completion_model)
        .preamble(include_str!("prompts/intro.txt"))
        .tool(SearchKnowledgeBase(tool))
        .build();

    tracing::info!(
        model             = %CONFIG.TEXT_MODEL,
        embedding_model   = %CONFIG.EMBEDDING_MODEL,
        qdrant_collection = %CONFIG.QDRANT_COLLECTION,
        rag_top_n         = RAG_TOP_N,
        "Agent built successfully",
    );

    Ok(agent)
}

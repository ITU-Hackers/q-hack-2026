//! Food-preference prediction tool for the AI agent.

use rig::completion::ToolDefinition;
use rig::tool::Tool;
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};
use tracing::instrument;

use crate::model::PredictFeatures;
use crate::model_watcher::SharedModel;
use crate::tools::ToolError;

/// Arguments for the food-preference prediction tool.
#[derive(Debug, Deserialize, JsonSchema)]
pub struct PredictPreferenceArgs {
    /// Whether the food is spicy (0.0 or 1.0).
    pub spicy: f32,
    /// Whether the food is sweet (0.0 or 1.0).
    pub sweet: f32,
    /// Whether the food is salty (0.0 or 1.0).
    pub salty: f32,
    /// Whether the food is warm (0.0 or 1.0).
    pub warm: f32,
}

/// Output of the food-preference prediction tool.
#[derive(Debug, Serialize)]
pub struct PredictPreferenceOutput {
    /// Whether the user is predicted to like the food.
    pub liked: bool,
    /// Raw predicted class label (0 = dislike, 1 = like).
    pub label: i64,
}

/// Agent tool that predicts whether a user will like a food item
/// based on its attributes using the trained decision-tree model.
///
/// Holds a [`SharedModel`] so it always reads the latest hot-swapped
/// model from the background watcher without any locking overhead.
pub struct PredictPreference(pub SharedModel);

impl Tool for PredictPreference {
    const NAME: &'static str = "predict_food_preference";

    type Error = ToolError;
    type Args = PredictPreferenceArgs;
    type Output = PredictPreferenceOutput;

    async fn definition(&self, _prompt: String) -> ToolDefinition {
        ToolDefinition {
            name: Self::NAME.to_string(),
            description: "Predict whether the user will like a food item based \
                on its attributes. Call this tool when the user asks about food \
                preferences, recommendations, or whether they would enjoy a \
                particular dish. Each attribute should be 0.0 (absent) or 1.0 \
                (present)."
                .to_string(),
            parameters: serde_json::json!({
                "type": "object",
                "properties": {
                    "spicy": {
                        "type": "number",
                        "description": "Whether the food is spicy (0.0 = not spicy, 1.0 = spicy)."
                    },
                    "sweet": {
                        "type": "number",
                        "description": "Whether the food is sweet (0.0 = not sweet, 1.0 = sweet)."
                    },
                    "salty": {
                        "type": "number",
                        "description": "Whether the food is salty (0.0 = not salty, 1.0 = salty)."
                    },
                    "warm": {
                        "type": "number",
                        "description": "Whether the food is warm (0.0 = cold, 1.0 = warm)."
                    }
                },
                "required": ["spicy", "sweet", "salty", "warm"],
                "additionalProperties": false
            }),
        }
    }

    #[instrument(skip(self), fields(tool = Self::NAME))]
    async fn call(&self, args: Self::Args) -> Result<Self::Output, Self::Error> {
        // Load a lock-free snapshot of the current model from the ArcSwap.
        let model_guard = self.0.load();
        let model = model_guard
            .as_ref()
            .as_ref()
            .ok_or_else(|| ToolError::InferenceFailed(
                "Decision-tree model has not been loaded yet — the background watcher is still waiting for the model to appear in S3".to_string(),
            ))?;

        let features = PredictFeatures {
            spicy: args.spicy,
            sweet: args.sweet,
            salty: args.salty,
            warm: args.warm,
        };

        tracing::debug!(?features, "Running food-preference prediction");

        let result = model
            .predict(&features)
            .map_err(|e| ToolError::InferenceFailed(e.to_string()))?;

        tracing::debug!(
            liked = result.liked,
            label = result.label,
            "Prediction complete"
        );

        Ok(PredictPreferenceOutput {
            liked: result.liked,
            label: result.label,
        })
    }
}

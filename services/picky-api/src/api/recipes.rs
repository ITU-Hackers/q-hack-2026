//! Recipe listing endpoint with ingredient details.

use std::collections::HashMap;

use axum::{Json, extract::State};
use http::StatusCode;
use picky_axum::error::{HandlerError, HandlerErrorSchema, HandlerResult};
use serde::{Deserialize, Serialize};
use utoipa::{IntoParams, ToSchema};

use crate::oapi::RECIPES_TAG;
use crate::state::{AppState, DbState};

#[derive(Serialize, ToSchema)]
pub struct IngredientResponse {
    pub id: i32,
    pub name: String,
    pub emoji: String,
    pub category: String,
    pub default_unit: String,
    pub default_price: f64,
}

#[derive(Serialize, ToSchema)]
pub struct RecipeResponse {
    pub id: i32,
    pub region: String,
    pub dish: String,
    pub emoji: String,
    pub ingredients: Vec<IngredientResponse>,
}

#[derive(Deserialize, IntoParams)]
pub struct RecipeQuery {
    /// Filter recipes by region (e.g. "Italian", "Asian").
    pub region: Option<String>,
}

#[utoipa::path(
    get,
    path = "/recipes",
    tag = RECIPES_TAG,
    summary = "List recipes with ingredients",
    description = "Returns all recipes with their resolved ingredients. Optionally filter by region.",
    params(RecipeQuery),
    responses(
        (
            status = 200,
            description = "List of recipes",
            body = Vec<RecipeResponse>,
            content_type = "application/json"
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
pub async fn list(
    State(db): State<DbState>,
    axum::extract::Query(query): axum::extract::Query<RecipeQuery>,
) -> HandlerResult<Json<Vec<RecipeResponse>>> {
    let rows = sqlx::query!(
        r#"
        SELECT
            r.id AS recipe_id,
            r.region,
            r.dish,
            r.emoji AS recipe_emoji,
            i.id AS "ingredient_id?",
            i.name AS "ingredient_name?",
            i.emoji AS "ingredient_emoji?",
            i.category AS "category?",
            i.default_unit AS "default_unit?",
            i.default_price::FLOAT8 AS "default_price?"
        FROM recipes r
        LEFT JOIN recipe_ingredients ri ON ri.recipe_id = r.id
        LEFT JOIN ingredients i ON i.id = ri.ingredient_id
        WHERE ($1::TEXT IS NULL OR r.region = $1)
        ORDER BY r.id, i.id
        "#,
        query.region,
    )
    .fetch_all(&db)
    .await
    .map_err(|e| {
        tracing::error!(error = %e, "Failed to query recipes");
        HandlerError::new(
            StatusCode::INTERNAL_SERVER_ERROR,
            "Failed to list recipes",
            e.to_string(),
        )
    })?;

    // Group flat rows into nested RecipeResponse structs.
    let mut recipe_map: HashMap<i32, RecipeResponse> = HashMap::new();
    let mut order: Vec<i32> = Vec::new();

    for row in rows {
        let entry = recipe_map.entry(row.recipe_id).or_insert_with(|| {
            order.push(row.recipe_id);
            RecipeResponse {
                id: row.recipe_id,
                region: row.region.clone(),
                dish: row.dish.clone(),
                emoji: row.recipe_emoji.clone(),
                ingredients: Vec::new(),
            }
        });

        if let (Some(ing_id), Some(name), Some(emoji), Some(cat), Some(unit), Some(price)) = (
            row.ingredient_id,
            row.ingredient_name,
            row.ingredient_emoji,
            row.category,
            row.default_unit,
            row.default_price,
        ) {
            entry.ingredients.push(IngredientResponse {
                id: ing_id,
                name,
                emoji,
                category: cat,
                default_unit: unit,
                default_price: price,
            });
        }
    }

    let recipes: Vec<RecipeResponse> = order
        .into_iter()
        .filter_map(|id| recipe_map.remove(&id))
        .collect();

    Ok(Json(recipes))
}

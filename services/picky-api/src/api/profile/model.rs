//! Profile data model for user profiles.

use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use uuid::Uuid;

/// A user profile stored in the database.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema, sqlx::FromRow)]
pub struct ProfileRow {
    pub id: Uuid,
    pub email: String,
    pub password: String,
    pub adults: i32,
    pub kids: i32,
    pub dogs: i32,
    pub cats: i32,
    pub cuisines: Vec<String>,
    pub pref_fish: i32,
    pub pref_pork: i32,
    pub pref_beef: i32,
    pub pref_dairy: i32,
    pub pref_spicy: i32,
    pub restrictions: Vec<String>,
    pub health_goal: String,
    pub cooking_time: String,
    pub budget: String,
}

/// A user profile as returned by the API.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct Profile {
    /// The unique identifier for the profile.
    #[schema(value_type = String, example = "a1b2c3d4-e5f6-7890-abcd-ef1234567890")]
    pub id: Uuid,
    /// The user's email address.
    #[schema(example = "alice@example.com")]
    pub email: String,
    /// Number of adults in the household.
    #[schema(example = 2)]
    pub adults: i32,
    /// Number of kids in the household.
    #[schema(example = 1)]
    pub kids: i32,
    /// Number of dogs in the household.
    #[schema(example = 1)]
    pub dogs: i32,
    /// Number of cats in the household.
    #[schema(example = 1)]
    pub cats: i32,
    /// Preferred cuisine types.
    #[schema(example = json!(["Asian", "Italian", "French"]))]
    pub cuisines: Vec<String>,
    /// Ingredient preference scores.
    pub preferences: Preferences,
    /// Dietary restrictions.
    #[schema(example = json!(["nut-allergy", "gluten-free"]))]
    pub restrictions: Vec<String>,
    /// Health goal (e.g. "balanced", "mediterranean", "high-protein").
    #[schema(example = "mediterranean")]
    pub health_goal: String,
    /// Cooking time preference (e.g. "quick", "moderate", "enthusiast").
    #[schema(example = "enthusiast")]
    pub cooking_time: String,
    /// Budget level (e.g. "budget", "moderate", "flexible").
    #[schema(example = "flexible")]
    pub budget: String,
}

/// Ingredient preference scores (0–100).
#[derive(Debug, Clone, Default, Serialize, Deserialize, ToSchema)]
pub struct Preferences {
    /// Preference score for fish (0–100).
    #[schema(minimum = 0, maximum = 100, example = 75)]
    pub fish: i32,
    /// Preference score for pork (0–100).
    #[schema(minimum = 0, maximum = 100, example = 0)]
    pub pork: i32,
    /// Preference score for beef (0–100).
    #[schema(minimum = 0, maximum = 100, example = 0)]
    pub beef: i32,
    /// Preference score for dairy (0–100).
    #[schema(minimum = 0, maximum = 100, example = 0)]
    pub dairy: i32,
    /// Preference score for spicy food (0–100).
    #[schema(minimum = 0, maximum = 100, example = 0)]
    pub spicy: i32,
}

impl From<ProfileRow> for Profile {
    fn from(row: ProfileRow) -> Self {
        Self {
            id: row.id,
            email: row.email,
            adults: row.adults,
            kids: row.kids,
            dogs: row.dogs,
            cats: row.cats,
            cuisines: row.cuisines,
            preferences: Preferences {
                fish: row.pref_fish,
                pork: row.pref_pork,
                beef: row.pref_beef,
                dairy: row.pref_dairy,
                spicy: row.pref_spicy,
            },
            restrictions: row.restrictions,
            health_goal: row.health_goal,
            cooking_time: row.cooking_time,
            budget: row.budget,
        }
    }
}

/// Request body for creating a new profile.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct CreateProfile {
    /// The user's email address.
    #[schema(example = "alice@example.com")]
    pub email: String,
    /// The user's password.
    #[schema(example = "s3cret")]
    pub password: String,
    /// Number of adults in the household.
    #[schema(example = 2)]
    #[serde(default)]
    pub adults: i32,
    /// Number of kids in the household.
    #[schema(example = 1)]
    #[serde(default)]
    pub kids: i32,
    /// Number of dogs in the household.
    #[schema(example = 1)]
    #[serde(default)]
    pub dogs: i32,
    /// Number of cats in the household.
    #[schema(example = 1)]
    #[serde(default)]
    pub cats: i32,
    /// Preferred cuisine types.
    #[schema(example = json!(["Asian", "Italian", "French"]))]
    #[serde(default)]
    pub cuisines: Vec<String>,
    /// Ingredient preference scores.
    #[serde(default)]
    pub preferences: Option<Preferences>,
    /// Dietary restrictions.
    #[schema(example = json!(["nut-allergy", "gluten-free"]))]
    #[serde(default)]
    pub restrictions: Vec<String>,
    /// Health goal (e.g. "balanced", "mediterranean", "high-protein").
    #[schema(example = "mediterranean")]
    #[serde(default = "default_health_goal")]
    pub health_goal: String,
    /// Cooking time preference (e.g. "quick", "moderate", "enthusiast").
    #[schema(example = "enthusiast")]
    #[serde(default = "default_cooking_time")]
    pub cooking_time: String,
    /// Budget level (e.g. "budget", "moderate", "flexible").
    #[schema(example = "flexible")]
    #[serde(default = "default_budget")]
    pub budget: String,
}

fn default_health_goal() -> String {
    "balanced".into()
}
fn default_cooking_time() -> String {
    "quick".into()
}
fn default_budget() -> String {
    "moderate".into()
}

/// Request body for updating an existing profile (all fields optional).
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct UpdateProfile {
    /// The user's email address.
    #[schema(example = "alice@example.com")]
    pub email: Option<String>,
    /// The user's password.
    #[schema(example = "n3wpassword")]
    pub password: Option<String>,
    /// Number of adults in the household.
    #[schema(example = 2)]
    pub adults: Option<i32>,
    /// Number of kids in the household.
    #[schema(example = 1)]
    pub kids: Option<i32>,
    /// Number of dogs in the household.
    #[schema(example = 1)]
    pub dogs: Option<i32>,
    /// Number of cats in the household.
    #[schema(example = 1)]
    pub cats: Option<i32>,
    /// Preferred cuisine types.
    #[schema(example = json!(["Asian", "Italian"]))]
    pub cuisines: Option<Vec<String>>,
    /// Ingredient preference scores.
    pub preferences: Option<Preferences>,
    /// Dietary restrictions.
    #[schema(example = json!(["nut-allergy"]))]
    pub restrictions: Option<Vec<String>>,
    /// Health goal.
    #[schema(example = "mediterranean")]
    pub health_goal: Option<String>,
    /// Cooking time preference.
    #[schema(example = "enthusiast")]
    pub cooking_time: Option<String>,
    /// Budget level.
    #[schema(example = "flexible")]
    pub budget: Option<String>,
}

/// Request body for logging in.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct LoginRequest {
    /// The user's email address.
    #[schema(example = "alice@example.com")]
    pub email: String,
    /// The user's password.
    #[schema(example = "s3cret")]
    pub password: String,
}

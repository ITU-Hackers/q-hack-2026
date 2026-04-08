//! Food2Vec embedding model: loads ingredient vectors and vectorizes recipes.
//!
//! The model file is a plain-text file with one line per ingredient:
//! ```text
//! ingredient f1 f2 ... f100
//! ```
//! Multi-word ingredients use underscores (e.g. `olive_oil`). There is no header line.

use std::collections::HashMap;
use std::fs::File;
use std::io::{BufRead, BufReader};
use std::path::Path;
use std::sync::Arc;

pub const DIM: usize = 100;

pub type EmbeddingMap = Arc<HashMap<String, [f32; DIM]>>;

/// Load the food2vec embeddings from a plain-text file into an [`EmbeddingMap`].
pub fn load(path: &Path) -> anyhow::Result<EmbeddingMap> {
    let file = File::open(path).map_err(|e| {
        anyhow::anyhow!(
            "Failed to open food2vec model at {}: {}",
            path.display(),
            e
        )
    })?;
    let reader = BufReader::new(file);
    let mut map = HashMap::new();

    for line in reader.lines() {
        let line = line?;
        let line = line.trim();
        if line.is_empty() {
            continue;
        }
        let mut parts = line.split_ascii_whitespace();
        let name = match parts.next() {
            Some(n) => n.to_string(),
            None => continue,
        };
        let mut vec = [0f32; DIM];
        let mut i = 0;
        for part in parts {
            if i >= DIM {
                break;
            }
            vec[i] = part.parse::<f32>().unwrap_or(0.0);
            i += 1;
        }
        if i == DIM {
            map.insert(name, vec);
        }
    }

    tracing::info!("Loaded {} food2vec embeddings", map.len());
    Ok(Arc::new(map))
}

/// Cooking units to strip from raw ingredient strings.
static UNITS: &[&str] = &[
    "tsp",
    "tsps",
    "teaspoon",
    "teaspoons",
    "tbsp",
    "tbsps",
    "tablespoon",
    "tablespoons",
    "cup",
    "cups",
    "oz",
    "ounce",
    "ounces",
    "lb",
    "lbs",
    "pound",
    "pounds",
    "g",
    "gram",
    "grams",
    "kg",
    "kilogram",
    "kilograms",
    "ml",
    "milliliter",
    "milliliters",
    "l",
    "liter",
    "liters",
    "pint",
    "pints",
    "quart",
    "quarts",
    "gallon",
    "gallons",
    "can",
    "cans",
    "package",
    "packages",
    "pkg",
    "bunch",
    "bunches",
    "clove",
    "cloves",
    "slice",
    "slices",
    "piece",
    "pieces",
    "handful",
    "pinch",
    "dash",
];

/// Strip quantity tokens (numbers, fractions, units) from a raw ingredient string.
fn strip_quantities(s: &str) -> String {
    s.split_whitespace()
        .filter(|tok| {
            // Pure number (integer or decimal)
            if tok.parse::<f64>().is_ok() {
                return false;
            }
            // Simple fraction like "1/2"
            if tok.contains('/') {
                let mut parts = tok.splitn(2, '/');
                let num = parts.next().unwrap_or("").parse::<u32>();
                let den = parts.next().unwrap_or("").parse::<u32>();
                if num.is_ok() && den.is_ok() {
                    return false;
                }
            }
            // Known cooking unit (case-insensitive)
            let lower = tok.to_lowercase();
            if UNITS.contains(&lower.as_str()) {
                return false;
            }
            true
        })
        .collect::<Vec<_>>()
        .join(" ")
}

/// Normalize a raw ingredient string into the form used as a map key:
/// strip quantities/units, lowercase, collapse whitespace to underscores.
pub fn normalize(ingredient: &str) -> String {
    strip_quantities(ingredient)
        .to_lowercase()
        .split_whitespace()
        .collect::<Vec<_>>()
        .join("_")
}

/// Vectorize a recipe (list of raw ingredient strings) into a single 100-dimensional vector
/// by mean-pooling the matched food2vec embeddings. Unknown ingredients are skipped.
///
/// Returns `(vector, matched_count, total_count)`.
pub fn vectorize(
    map: &HashMap<String, [f32; DIM]>,
    ingredients: &[&str],
) -> ([f32; DIM], usize, usize) {
    let total = ingredients.len();
    let mut accum = [0f32; DIM];
    let mut matched = 0usize;

    for raw in ingredients {
        let key = normalize(raw);
        if let Some(vec) = map.get(&key) {
            for (a, v) in accum.iter_mut().zip(vec.iter()) {
                *a += v;
            }
            matched += 1;
        }
    }

    if matched > 0 {
        let n = matched as f32;
        for a in accum.iter_mut() {
            *a /= n;
        }
    }

    (accum, matched, total)
}

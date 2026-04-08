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
    load_from_reader(BufReader::new(file))
}

/// Parse food2vec embeddings from any [`BufRead`] source.
///
/// Separated from [`load`] so that tests can pass an in-memory
/// [`std::io::Cursor`] instead of a real file.
fn load_from_reader(reader: impl BufRead) -> anyhow::Result<EmbeddingMap> {
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
#[allow(clippy::missing_panics_doc)]
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

// ── Tests ────────────────────────────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use std::io::Cursor;

    use super::*;

    // ── Tier 1: normalize() ──────────────────────────────────────────────────

    #[test]
    fn normalize_strips_leading_number() {
        assert_eq!(normalize("2 cups flour"), "flour");
    }

    #[test]
    fn normalize_strips_fraction() {
        assert_eq!(normalize("1/2 tsp salt"), "salt");
    }

    #[test]
    fn normalize_joins_spaces_with_underscores() {
        assert_eq!(normalize("olive oil"), "olive_oil");
    }

    #[test]
    fn normalize_lowercases() {
        assert_eq!(normalize("Salt"), "salt");
    }

    /// Descriptor words that are not units should be kept, since they form
    /// part of the model key (e.g. `black_pepper`).
    #[test]
    fn normalize_keeps_non_unit_descriptors() {
        assert_eq!(normalize("3 large eggs"), "large_eggs");
    }

    #[test]
    fn normalize_strips_decimal_quantity() {
        assert_eq!(normalize("0.5 cup sugar"), "sugar");
    }

    // ── Tier 2: vectorize() ──────────────────────────────────────────────────

    /// Build a minimal 3-dimensional map for math tests.
    /// Using DIM=3 so expected values are easy to compute by hand.
    /// The real DIM is 100, but the algorithm is dimension-agnostic.
    fn make_map() -> HashMap<String, [f32; DIM]> {
        let mut map = HashMap::new();

        let mut a = [0f32; DIM];
        a[0] = 1.0;
        a[1] = 2.0;
        a[2] = 3.0;
        map.insert("flour".to_string(), a);

        let mut b = [0f32; DIM];
        b[0] = 3.0;
        b[1] = 4.0;
        b[2] = 5.0;
        map.insert("salt".to_string(), b);

        map
    }

    #[test]
    fn vectorize_single_match_returns_exact_embedding() {
        let map = make_map();
        let (vec, matched, total) = vectorize(&map, &["flour"]);
        assert_eq!(matched, 1);
        assert_eq!(total, 1);
        assert_eq!(vec[0], 1.0);
        assert_eq!(vec[1], 2.0);
        assert_eq!(vec[2], 3.0);
    }

    #[test]
    fn vectorize_two_ingredients_returns_mean() {
        let map = make_map();
        let (vec, matched, total) = vectorize(&map, &["flour", "salt"]);
        assert_eq!(matched, 2);
        assert_eq!(total, 2);
        // mean of [1,2,3] and [3,4,5] = [2,3,4]
        assert_eq!(vec[0], 2.0);
        assert_eq!(vec[1], 3.0);
        assert_eq!(vec[2], 4.0);
    }

    #[test]
    fn vectorize_all_unknown_returns_zero_vector_and_zero_matched() {
        let map = make_map();
        let (vec, matched, total) = vectorize(&map, &["xyzzy", "nonsense"]);
        assert_eq!(matched, 0);
        assert_eq!(total, 2);
        assert!(vec.iter().all(|&v| v == 0.0));
    }

    #[test]
    fn vectorize_mixed_known_unknown_averages_over_known_only() {
        let map = make_map();
        // "xyzzy" is unknown — mean should be over "flour" only
        let (vec, matched, total) = vectorize(&map, &["flour", "xyzzy"]);
        assert_eq!(matched, 1);
        assert_eq!(total, 2);
        assert_eq!(vec[0], 1.0);
        assert_eq!(vec[1], 2.0);
        assert_eq!(vec[2], 3.0);
    }

    #[test]
    fn vectorize_strips_quantities_before_lookup() {
        let map = make_map();
        // "2 cups flour" should normalize to "flour" and match
        let (_, matched, total) = vectorize(&map, &["2 cups flour"]);
        assert_eq!(matched, 1);
        assert_eq!(total, 1);
    }

    // ── Tier 3: load_from_reader() ───────────────────────────────────────────

    fn make_embedding_line(name: &str, values: &[f32; DIM]) -> String {
        let floats = values.map(|v| v.to_string()).join(" ");
        format!("{name} {floats}")
    }

    #[test]
    fn load_from_reader_parses_known_entries() {
        let mut a = [0f32; DIM];
        a[0] = 0.5;
        let mut b = [0f32; DIM];
        b[1] = -1.0;

        let content = format!(
            "{}\n{}\n",
            make_embedding_line("salt", &a),
            make_embedding_line("pepper", &b),
        );

        let map = load_from_reader(Cursor::new(content)).expect("parse should succeed");
        assert_eq!(map.len(), 2);
        assert_eq!(map["salt"][0], 0.5);
        assert_eq!(map["pepper"][1], -1.0);
    }

    #[test]
    fn load_from_reader_skips_empty_lines() {
        let mut a = [0f32; DIM];
        a[0] = 1.0;
        let content = format!("\n{}\n\n", make_embedding_line("salt", &a));
        let map = load_from_reader(Cursor::new(content)).expect("parse should succeed");
        assert_eq!(map.len(), 1);
    }

    #[test]
    fn load_from_reader_skips_lines_with_wrong_dimension() {
        // Only 3 values — should be ignored (DIM = 100)
        let content = "bad_entry 0.1 0.2 0.3\n";
        let map = load_from_reader(Cursor::new(content)).expect("parse should succeed");
        assert!(map.is_empty());
    }
}

from dagster import AssetSelection, define_asset_job

from picky_recs.assets.recipes import recipe_collection, recipe_vectors

training_job = define_asset_job(
    name="training_job",
    selection=AssetSelection.assets(
        "customer_vectors", "recipe_vectors", "trained_model"
    ),
    description="Train the two-tower recommendation model and upload the user tower to S3.",
)

recipe_seeding_job = define_asset_job(
    name="recipe_seeding_job",
    selection=AssetSelection.assets(recipe_collection, recipe_vectors),
    description="Create the Qdrant recipes collection and embed all recipes using food2vec vectors.",
)

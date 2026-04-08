from dagster import AssetSelection, define_asset_job

from picky_recs.assets.seed_synthetic_users import seed_synthetic_users

training_job = define_asset_job(
    name="training_job",
    selection=AssetSelection.assets("training_data", "trained_model"),
    description="Train the recommendation model and upload to S3.",
)

seeding_job = define_asset_job(
    name="seeding_job",
    selection=AssetSelection.assets(seed_synthetic_users),
    description="Seed PostgreSQL with synthetic user profiles, order histories and weekly ML metrics.",
)
from dagster import AssetSelection, define_asset_job

training_job = define_asset_job(
    name="training_job",
    selection=AssetSelection.all(),
    description="Train the recommendation model and upload to S3.",
)

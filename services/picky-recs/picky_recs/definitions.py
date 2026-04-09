"""Dagster code location definition for picky-recs.

This is the entry point that Dagster uses to discover all assets, resources,
jobs, and schedules for the picky-recs ML training pipeline.
"""

from dagster import Definitions

from picky_recs.assets import customer_vectors, seed_synthetic_users, trained_model
from picky_recs.assets.recipes import recipe_collection, recipe_vectors
from picky_recs.jobs import recipe_seeding_job, training_job
from picky_recs.resources import s3_resource
from picky_recs.schedules import training_schedule

defs = Definitions(
    assets=[customer_vectors, trained_model, seed_synthetic_users, recipe_collection, recipe_vectors],
    resources={"s3": s3_resource},
    jobs=[training_job, recipe_seeding_job],
    schedules=[training_schedule],
)
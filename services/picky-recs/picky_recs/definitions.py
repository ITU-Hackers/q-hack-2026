"""Dagster code location definition for picky-recs.

This is the entry point that Dagster uses to discover all assets, resources,
jobs, and schedules for the picky-recs ML training pipeline.
"""

from dagster import Definitions

from picky_recs.assets import trained_model, training_data
from picky_recs.jobs import training_job
from picky_recs.resources import s3_resource
from picky_recs.schedules import training_schedule

defs = Definitions(
    assets=[training_data, trained_model],
    resources={"s3": s3_resource},
    jobs=[training_job],
    schedules=[training_schedule],
)

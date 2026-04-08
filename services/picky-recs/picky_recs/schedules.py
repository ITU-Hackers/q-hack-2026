from dagster import DefaultScheduleStatus, ScheduleDefinition

from picky_recs.jobs import training_job

training_schedule = ScheduleDefinition(
    job=training_job,
    cron_schedule="0 3 * * 0",  # Every Sunday at 3 AM
    default_status=DefaultScheduleStatus.STOPPED,
)

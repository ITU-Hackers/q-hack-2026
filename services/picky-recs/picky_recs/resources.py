from dagster import EnvVar
from dagster_aws.s3 import S3Resource

s3_resource = S3Resource(
    endpoint_url=EnvVar("S3_ENDPOINT_URL"),
    aws_access_key_id=EnvVar("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=EnvVar("AWS_SECRET_ACCESS_KEY"),
    region_name=EnvVar("AWS_REGION"),
)

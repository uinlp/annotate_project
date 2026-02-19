from aws_lambda_powertools.logging import Logger
from aws_lambda_powertools.utilities.data_classes import event_source, S3Event
import boto3
import os
from internal.repositories.datasets import DatasetsRepository

logger = Logger()

datasets_repository = DatasetsRepository()

aws_region = os.getenv("AWS_DEFAULT_REGION") or os.getenv("AWS_REGION")

s3_client = boto3.client("s3", endpoint_url=f"https://s3.{aws_region}.amazonaws.com")


@event_source(data_class=S3Event)
def handler(event: S3Event, context):
    logger.info(f"Event: {event}")
    logger.info(f"Context: {context}")

    for record in event.records:
        bucket_name = record.s3.bucket.name
        object_key = record.s3.get_object.key
        datasets_repository.make_batches(bucket_name, object_key)

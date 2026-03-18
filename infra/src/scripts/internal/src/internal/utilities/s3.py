import boto3
import os

region = os.getenv("AWS_REGION") or os.getenv("AWS_DEFAULT_REGION")
s3_client = boto3.client("s3", endpoint_url=f"https://s3.{region}.amazonaws.com")

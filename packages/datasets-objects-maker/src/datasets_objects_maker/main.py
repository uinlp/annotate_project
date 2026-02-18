from aws_lambda_powertools.logging import Logger

logger = Logger()


def handler(event, context):
    logger.info(f"Event: {event}")
    logger.info(f"Context: {context}")

from aws_lambda_powertools.logging import Logger

logger = Logger()


def handler(event, context):
    logger.info("Hello! Ping Pong")

import re


def make_id(text: str) -> str:
    return re.sub(r"\W+", "-", text).lower().strip("-")

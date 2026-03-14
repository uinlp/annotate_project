FROM public.ecr.aws/lambda/python:3.10

# Upgrade pip to avoid issues with older versions
RUN pip install --upgrade pip

COPY functions/datasets-objects-maker/requirements.txt .
COPY scripts/internal/ dependencies/internal/
# Install the requirements
# Leverage a cache mount to /root/.cache/pip to speed up subsequent builds.
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt \
    && pip install dependencies/internal/

RUN rm -rf dependencies

COPY functions/datasets_objects_maker/src/datasets_objects_maker/ ${LAMBDA_TASK_ROOT}/

CMD ["main.handler"]
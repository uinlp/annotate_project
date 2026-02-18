FROM public.ecr.aws/lambda/python:3.10

# Upgrade pip to avoid issues with older versions
RUN pip install --upgrade pip

# The build context is 'packages/' as defined in compose.local.yml
COPY . /tmp/packages
# Install the datasets-objects-maker package by navigating to its directory
RUN cd /tmp/packages/datasets-objects-maker && pip install --no-cache-dir .

# Remove the temporary build packages
RUN rm -rf /tmp/packages

# Copy the application source code to Lambda's task root
# We copy contents of datasets-objects-maker/src/datasets_objects_maker/ directly to ${LAMBDA_TASK_ROOT}
COPY datasets-objects-maker/src/datasets_objects_maker/ ${LAMBDA_TASK_ROOT}/

CMD ["main.handler"]
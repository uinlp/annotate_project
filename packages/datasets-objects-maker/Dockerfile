FROM public.ecr.aws/lambda/python:3.10

# Upgrade pip to avoid issues with older versions
RUN pip install --upgrade pip

# The build context is 'packages/' as defined in compose.local.yml
COPY . /tmp/packages
# Install the backend package by navigating to its directory
RUN cd /tmp/packages/backend && pip install --no-cache-dir .

# Remove the temporary build packages
RUN rm -rf /tmp/packages

# Copy the application source code to Lambda's task root
# We copy contents of backend/src/backend/ directly to ${LAMBDA_TASK_ROOT}
COPY backend/src/backend/ ${LAMBDA_TASK_ROOT}/

CMD ["main.handler"]
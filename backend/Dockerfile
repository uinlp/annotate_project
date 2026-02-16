FROM public.ecr.aws/lambda/python:3.10

# Copy requirements.txt and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY src/ ${LAMBDA_TASK_ROOT}/src/
COPY main.py ${LAMBDA_TASK_ROOT}

CMD ["main.handler"]
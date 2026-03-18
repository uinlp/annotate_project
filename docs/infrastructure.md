# Infrastructure

All AWS resources are managed with **Terraform**, located at `infra/`.

## Directory Structure

```
infra/
├── environments/
│   └── prod/           # Production Terraform root module
├── modules/
│   ├── apis/           # API Gateway + Backend Lambda
│   ├── authentications/# Cognito User Pool & Client
│   ├── databases/      # DynamoDB tables, S3 buckets
│   └── user_interfaces/# Route 53 DNS records
└── src/
    ├── functions/
    │   ├── backend/            # FastAPI backend Lambda
    │   └── datasets_objects_maker/ # Batch processing Lambda
    └── scripts/
        └── internal/           # Shared Python library (repositories, models)
```

## AWS Services Used

| Service | Purpose |
|---|---|
| **API Gateway** | HTTP API fronting the backend Lambda |
| **Lambda** | Backend API (`backend`) + batch processor (`datasets_objects_maker`) |
| **DynamoDB** | Datasets, Assets, Publishes tables |
| **S3** | Dataset ZIPs (temp + objects buckets) + annotator publish ZIPs |
| **Cognito** | User Pool for authentication (admins + annotators) |
| **ECR** | Docker images for Lambda functions |
| **Route 53** | DNS records for `api.uinlp.org.ng` and `annotate.uinlp.org.ng` |

## Deploying

```bash
cd infra/environments/prod
terraform init
terraform plan
terraform apply
```

> Terraform will build and push Docker images to ECR, then deploy all Lambda functions and infrastructure automatically.

## Backend Lambda (`functions/backend`)

- **Runtime**: Python 3.12 (Docker-based)
- **Entry point**: `backend.main.handler` (Mangum ASGI adapter)
- **Env vars required** (set via Terraform outputs):
  - `COGNITO_USER_POOL_ID`
  - `COGNITO_CLIENT_ID`
  - `COGNITO_REDIRECT_URI`
  - `SECRET_KEY`
  - `DATASETS_TABLE_NAME`
  - `ASSETS_TABLE_NAME`
  - `PUBLISHES_TABLE_NAME`
  - `DATASETS_TEMP_BUCKET_NAME`
  - `DATASETS_OBJECTS_BUCKET_NAME`
  - `PUBLISHES_BUCKET_NAME`

## Batch Processor Lambda (`functions/datasets_objects_maker`)

Triggered by an **S3 event** when a dataset ZIP is uploaded to the temp bucket.

1. Downloads and extracts the ZIP to `/tmp/datasets`.
2. Determines modality from the DynamoDB dataset record.
3. Splits files into `batch_size` chunks.
4. For **text** modality: reads lines and packages them as `.txt` batch files.
5. For **image / audio / video**: walks the extracted directory, filters valid extensions, and packages batches as `.zip` archives.
6. Uploads each batch to the objects bucket under `datasets/<dataset_id>/batch-N.<ext>`.
7. Sets `is_completed = true` on the dataset record in DynamoDB.
8. Cleans up `/tmp`.

## Shared Internal Library (`scripts/internal`)

The `internal` Python package is shared between both Lambda functions (added to each Docker image). It contains:

- `internal/database/models/` — Pydantic data models (datasets, assets, publishes, shared)
- `internal/repositories/` — DynamoDB + S3 access logic (`DatasetsRepository`, `AssetsRepository`)
- `internal/utilities/` — Helpers (`s3.py` client, `parser.py` ID generator)

## CORS Configuration

S3 buckets that receive direct browser uploads (temp + publishes buckets) have CORS rules configured to allow `PUT` and `GET` from any origin, with `ETag` exposed for multipart validation.

## DNS

| Subdomain | Target |
|---|---|
| `api.uinlp.org.ng` | API Gateway custom domain |
| `annotate.uinlp.org.ng` | Vercel deployment (CNAME) |

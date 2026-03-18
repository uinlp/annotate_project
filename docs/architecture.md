# Architecture Overview

## System Components

UINLP is a three-tier platform built on AWS, consisting of:

1. **Admin Web App** (`web_app/`) — Next.js 15 dashboard for managing datasets, assets, and reviewing annotator publishes.
2. **Backend API** (`infra/src/functions/backend/`) — FastAPI service running on AWS Lambda via Mangum, handling all business logic.
3. **Mobile App** (`mobile_app/`) — Flutter offline-first application for annotators to complete labelling tasks.
4. **Infrastructure** (`infra/`) — Terraform-managed AWS resources (DynamoDB, S3, Cognito, API Gateway, Lambda).
5. **Internal Scripts** (`infra/src/scripts/internal/`) — Python processing scripts that run as Lambda functions to batch and distribute dataset files.

## High-Level Data Flow

```
Admin uploads dataset ZIP
        │
        ▼
POST /v1/datasets  ──►  Backend creates DynamoDB record
                         + returns presigned S3 PUT URL
        │
        ▼
Admin PUTs ZIP to S3 (temp bucket)
        │
        ▼
S3 Event triggers ──►  datasets_objects_maker Lambda
                         • Extracts ZIP
                         • Splits into batch_size chunks
                         • Uploads batch ZIPs to objects bucket
                         • Sets is_completed = True on dataset
        │
        ▼
Admin creates Asset linked to Dataset
        │
        ▼
Annotator opens Mobile App
  • Fetches available assets (total_publishes < 2)
  • Downloads batch ZIP for annotation
  • Completes tasks, uploads result ZIP
  • Calls POST /v1/assets/acknowledge-publish
        │
        ▼
Admin views Asset Detail page
  • Lists all publishes for the asset
  • Downloads annotator ZIP via presigned GET URL
```

## Authentication

All API calls are protected by **Amazon Cognito** (OAuth 2.0 Authorization Code flow with PKCE):

- The web app uses `oidc-client-ts` to manage the Cognito session.
- The backend validates the `Authorization: Bearer <access_token>` header on every request using Cognito's JWKS endpoint.
- The mobile app uses `amplify_auth_cognito`.

## Data Stores

| Store | Type | Purpose |
|---|---|---|
| `uinlp-datasets` | DynamoDB Table | Dataset records (metadata, batch keys, status flags) |
| `uinlp-assets` | DynamoDB Table | Asset records and annotate field definitions |
| `uinlp-publishes` | DynamoDB Table | Annotator publish records per asset |
| `datasets-temp-bucket` | S3 | Receiving uploaded dataset ZIPs before processing |
| `datasets-objects-bucket` | S3 | Split batch ZIPs ready for distribution |
| `assets-publishes-bucket` | S3 | Completed annotation ZIPs uploaded by annotators |

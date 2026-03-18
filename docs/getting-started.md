# Getting Started

This guide covers running the entire UINLP stack locally.

## Prerequisites

| Tool | Version |
|---|---|
| Node.js | 20+ |
| Python | 3.12 |
| Flutter | 3.x |
| Docker | Latest |
| AWS CLI | v2 |
| Terraform | 1.9+ |

---

## 1. Clone the Repository

```bash
git clone <repo-url>
cd uinlp_project
```

---

## 2. Backend API (Local)

The backend uses Docker Compose for local development.

```bash
cd infra/src/functions/backend

# Copy the environment file
cp .env.local.example .env.local
# Fill in your Cognito and DynamoDB local values

# Start the API
docker compose -f compose.local.yml up --build
# API runs at http://localhost:8000
# Swagger UI at http://localhost:8000/docs
```

### Local `.env.local` values

```env
COGNITO_USER_POOL_ID=af-south-1_xxxxx
COGNITO_CLIENT_ID=xxxxxx
COGNITO_REDIRECT_URI=http://localhost:3000/oauth2/callback
SECRET_KEY=any-random-secret
DATASETS_TABLE_NAME=uinlp-datasets
ASSETS_TABLE_NAME=uinlp-assets
PUBLISHES_TABLE_NAME=uinlp-publishes
DATASETS_TEMP_BUCKET_NAME=uinlp-datasets-temp
DATASETS_OBJECTS_BUCKET_NAME=uinlp-datasets-objects
PUBLISHES_BUCKET_NAME=uinlp-publishes
AWS_REGION=af-south-1
```

> For local DynamoDB you can use [DynamoDB Local](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.html) or point directly at your AWS account credentials.

---

## 3. Admin Web App (Local)

```bash
cd web_app

# Copy environment file
cp .env.example .env.local
# Fill in Cognito details (see web-app.md for variable names)

npm install
npm run dev
# Runs at http://localhost:3000
```

---

## 4. Mobile App (Local)

```bash
cd mobile_app
flutter pub get
```

Create or update `.vscode/launch.json` with your `--dart-define` values (Cognito pool ID, client ID, API base URL), then press **F5** in VS Code or run:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8000 \
            --dart-define=COGNITO_USER_POOL_ID=af-south-1_xxx \
            --dart-define=COGNITO_APP_CLIENT_ID=xxx
```

---

## 5. Full Cloud Deployment

```bash
cd infra/environments/prod

# Ensure you have AWS credentials configured
aws configure

terraform init
terraform plan   # Review changes
terraform apply  # Deploy everything
```

This provisions all DynamoDB tables, S3 buckets, Cognito pools, API Gateway, Lambda functions (built from Docker), and Route 53 DNS records in one command.

---

## Useful Commands

| Task | Command |
|---|---|
| Run backend tests | `cd infra/src/scripts/internal && pytest` |
| Lint Python | `ruff check infra/src/` |
| Type-check Python | `pyright infra/src/` |
| Build Next.js | `cd web_app && npm run build` |
| Type-check Next.js | `cd web_app && npx tsc --noEmit` |
| Compile check Python script | `python -m py_compile infra/src/scripts/internal/src/internal/repositories/datasets.py` |

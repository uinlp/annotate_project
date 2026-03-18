# UINLP — Annotation Platform

A full-stack platform for collecting, distributing, and managing multi-modal annotation tasks at scale, powered by AWS.

## Repositories

| Directory | Description |
|---|---|
| [`web_app/`](./web_app/README.md) | Next.js 15 admin dashboard |
| `mobile_app/` | Flutter offline-first annotator app |
| `infra/` | Terraform infrastructure + Python Lambda functions |
| [`docs/`](./docs/README.md) | Full project documentation |

## Architecture

```
Admin (web_app)  ──►  API Gateway  ──►  Backend Lambda (FastAPI)
                                           │           │
                                       DynamoDB       S3
                                                       │
                                       Batch Lambda ◄──┘
                                       (splits ZIPs into batches)
                                                       │
Annotator (mobile_app)  ◄──────────────────────────────┘
```

Authentication is handled by **Amazon Cognito** across all clients.

## Quick Start

- **Admin Dashboard**: see [`web_app/README.md`](./web_app/README.md)
- **Full local setup**: see [`docs/getting-started.md`](./docs/getting-started.md)
- **API reference**: see [`docs/api.md`](./docs/api.md)

## License

MIT
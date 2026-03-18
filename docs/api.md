# Backend API Reference

Base URL: `https://api.uinlp.org.ng`

All endpoints (except auth callbacks) require an `Authorization: Bearer <access_token>` header.

---

## Datasets

### `GET /v1/datasets`

List all datasets.

| Query Param | Type | Default | Description |
|---|---|---|---|
| `admin_all` | `bool` | `false` | If `true`, returns all datasets including incomplete and soft-deleted ones |

**Response** `200 OK`
```json
[
  {
    "id": "my-dataset",
    "name": "My Dataset",
    "description": "A text annotation dataset",
    "modality": "text",
    "batch_size": 100,
    "batch_keys": ["batch-1", "batch-2"],
    "created_at": "2026-03-01T00:00:00",
    "updated_at": "2026-03-01T00:00:00",
    "is_completed": true,
    "is_deleted": false
  }
]
```

### `POST /v1/datasets`

Create a new dataset record and get a presigned S3 URL to upload the source ZIP file.

**Request Body**
```json
{
  "name": "My Dataset",
  "description": "A text annotation dataset",
  "modality": "text",
  "batch_size": 100
}
```

**Response** `200 OK`
```json
{ "url": "https://s3.amazonaws.com/...", "expires_in": 3600 }
```

> After receiving the URL, the client must **PUT** the ZIP file directly to the S3 URL. The processing Lambda is then automatically triggered by the S3 event.

### `GET /v1/datasets/{dataset_id}`

Get a single dataset by ID.

### `PUT /v1/datasets/{dataset_id}`

Replace a dataset record entirely.

### `DELETE /v1/datasets/{dataset_id}`

Soft-delete a dataset (sets `is_deleted = true` in DynamoDB; no data is permanently removed).

### `POST /v1/datasets/batch-download-url`

Get a presigned GET URL to download a processed batch ZIP.

**Request Body**
```json
{ "dataset_id": "my-dataset", "batch_key": "batch-1" }
```

---

## Assets

### `GET /v1/assets`

List all assets.

| Query Param | Type | Default | Description |
|---|---|---|---|
| `modality` | `string` | — | Filter by modality (`text`, `image`, `audio`, `video`) |
| `admin_all` | `bool` | `false` | Return all assets regardless of publish count |

### `POST /v1/assets`

Create a new asset.

**Request Body**
```json
{
  "dataset_id": "my-dataset",
  "name": "My Asset",
  "description": "First annotation batch",
  "annotate_fields": [
    { "name": "label", "modality": "text", "description": "The sentiment label" }
  ],
  "tags": ["sentiment", "batch-1"]
}
```

### `GET /v1/assets/{asset_id}`

Get a single asset by ID.

### `PUT /v1/assets/{asset_id}`

Replace an asset record entirely.

### `DELETE /v1/assets/{asset_id}`

Delete an asset.

---

## Asset Publishes

### `GET /v1/assets/publishes`

List publish records.

| Query Param | Type | Description |
|---|---|---|
| `asset_id` | `string` | Filter by asset |
| `publisher_id` | `string` | Filter by annotator |

### `GET /v1/assets/publishes/me`

List the authenticated user's publish records.

### `POST /v1/assets/publish-upload-url`

Get a presigned S3 PUT URL for an annotator to upload their completed annotation ZIP.

**Request Body** `{ "asset_id": "my-asset" }` (publisher_id taken from JWT)

### `POST /v1/assets/acknowledge-publish`

Mark a publish as submitted after the annotator has successfully uploaded their ZIP.

### `POST /v1/assets/publish-download-url`

Get a presigned S3 GET URL to download a specific annotator's published ZIP.

**Request Body**
```json
{ "asset_id": "my-asset", "publisher_id": "cognito-sub-uuid" }
```

**Response** `200 OK`
```json
{ "url": "https://s3.amazonaws.com/...", "expires_in": 3600 }
```

### `POST /v1/assets/publishes/verify`

Mark a publish as verified by an admin.

---

## Data Models

### Modality

`"text"` | `"image"` | `"audio"` | `"video"`

### `DatasetModel`

| Field | Type |
|---|---|
| `id` | `string` |
| `name` | `string` |
| `description` | `string` |
| `modality` | `Modality` |
| `batch_size` | `int` |
| `batch_keys` | `list[string]` |
| `created_at` | `datetime` |
| `updated_at` | `datetime` |
| `is_completed` | `bool` |
| `is_deleted` | `bool` |

### `AssetModel`

| Field | Type |
|---|---|
| `id` | `string` |
| `dataset_id` | `string` |
| `dataset_batch_key` | `string` |
| `modality` | `Modality` |
| `name` | `string` |
| `description` | `string` |
| `annotate_fields` | `list[AnnotateFieldModel]` |
| `tags` | `list[string]` |
| `total_publishes` | `int` |
| `is_deleted` | `bool` |
| `created_at` | `datetime` |
| `updated_at` | `datetime` |

### `AssetPublishModel`

| Field | Type |
|---|---|
| `asset_id` | `string` |
| `publisher_id` | `string` |
| `publish_key` | `string` |
| `is_verified` | `bool` |
| `is_published` | `bool` |
| `created_at` | `datetime` |
| `updated_at` | `datetime` |

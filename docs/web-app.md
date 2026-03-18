# Admin Web App

The admin dashboard is a **Next.js 15** application located at `web_app/`.

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Next.js 15 (App Router) |
| Styling | Tailwind CSS |
| Data Fetching | TanStack Query (`@tanstack/react-query`) |
| Auth | `oidc-client-ts` + Amazon Cognito |
| Validation | Zod |
| Icons | Lucide React |

## Local Development

```bash
cd web_app
cp .env.example .env.local   # fill in Cognito values
npm install
npm run dev                  # starts on http://localhost:3000
```

## Environment Variables

Create a `.env.local` file in `web_app/`:

```env
NEXT_PUBLIC_COGNITO_AUTHORITY=https://cognito-idp.<region>.amazonaws.com/<user-pool-id>
NEXT_PUBLIC_COGNITO_CLIENT_ID=<your-client-id>
NEXT_PUBLIC_COGNITO_REDIRECT_URI=http://localhost:3000/oauth2/callback
NEXT_PUBLIC_COGNITO_LOGOUT_URI=http://localhost:3000/oauth2/logout
NEXT_PUBLIC_COGNITO_DOMAIN=https://<your-cognito-domain>.auth.<region>.amazoncognito.com
NEXT_PUBLIC_API_BASE_URL=http://localhost:8000
```

## Route Structure

```
/                           → Landing page (public)
/admin                      → Dashboard overview (protected)
/admin/datasets             → Dataset list
/admin/datasets/create      → Create a new dataset
/admin/datasets/[id]        → Dataset detail & soft-delete
/admin/assets               → Asset list
/admin/assets/upload        → Create a new asset
/admin/assets/[id]          → Asset detail & publish downloads
/oauth2/callback            → Cognito redirect handler
/oauth2/logout              → Post-logout landing (redirects to /admin)
```

## Key Architecture Patterns

### `QueryProvider`

All data fetching uses TanStack Query, configured globally in `components/providers/QueryProvider.tsx` and mounted in the admin layout. The `QueryClient` is configured with a 60-second `staleTime` to prevent redundant re-fetches on tab focus.

### `AuthProvider`

Wraps all admin pages (`app/(admin)/layout.tsx`). On mount it calls `userManager.getUser()`. If the session is missing or expired it displays a sign-in dialog. If valid, it attaches the access token to the `ApiClient` via `apiClient.setTokenFetcher(...)`.

### `ApiClient`

`lib/api/client.ts` is a thin wrapper around `fetch` that automatically injects the `Authorization: Bearer ...` header on every request. All repository classes use it.

### Repository Pattern

Data access is centralised in `lib/repositories/`:
- `DatasetsRepository` — `listDatasets`, `getDataset`, `createDataset`, `deleteDataset`
- `AssetsRepository` — `listAssets`, `getAsset`, `createAsset`, `deleteAsset`, `listPublishes`, `createPublishDownloadUrl`

## Creating a Dataset (End-to-End)

1. Navigate to `/admin/datasets/create`.
2. Fill in the name, description, modality, and batch size. Attach a `.zip` file.
3. On submit the form calls `DatasetsRepository.createDataset()` → `POST /v1/datasets` → receives `{ url }`.
4. The form then does a `PUT` directly to the S3 presigned URL with the ZIP file body.
5. The backend Lambda processes the ZIP and populates `batch_keys`, then sets `is_completed = true`.
6. The dataset list page shows a **green "Ready"** indicator once processing is complete.

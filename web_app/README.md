# UINLP Admin Web App

Admin dashboard for the UINLP annotation platform, built with **Next.js 15**.

## Stack

- **Framework**: Next.js 15 (App Router)
- **Styling**: Tailwind CSS
- **Data Fetching**: TanStack Query
- **Auth**: `oidc-client-ts` + Amazon Cognito
- **Validation**: Zod · **Icons**: Lucide React

## Setup

```bash
npm install
cp .env.example .env.local   # fill in Cognito values
npm run dev                  # http://localhost:3000
```

### Required environment variables (`.env.local`)

```env
NEXT_PUBLIC_COGNITO_AUTHORITY=https://cognito-idp.<region>.amazonaws.com/<pool-id>
NEXT_PUBLIC_COGNITO_CLIENT_ID=<client-id>
NEXT_PUBLIC_COGNITO_REDIRECT_URI=http://localhost:3000/oauth2/callback
NEXT_PUBLIC_COGNITO_LOGOUT_URI=http://localhost:3000/oauth2/logout
NEXT_PUBLIC_COGNITO_DOMAIN=https://<domain>.auth.<region>.amazoncognito.com
NEXT_PUBLIC_API_BASE_URL=http://localhost:8000
```

## Routes

| Path | Description |
|---|---|
| `/` | Public landing page |
| `/admin` | Dashboard overview |
| `/admin/datasets` | Dataset list |
| `/admin/datasets/create` | Create a dataset |
| `/admin/datasets/[id]` | Dataset detail & delete |
| `/admin/assets` | Asset list |
| `/admin/assets/upload` | Create an asset |
| `/admin/assets/[id]` | Asset detail & publish downloads |

## Full documentation

See [`docs/web-app.md`](../docs/web-app.md).

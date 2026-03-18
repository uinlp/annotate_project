# Mobile App

The Flutter annotator app is located at `mobile_app/`. It is designed for offline-first operation — annotators can download tasks, complete them without internet, and upload results when connectivity is restored.

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| Auth | `amplify_auth_cognito` |
| HTTP | `http` package |
| State | BLoC pattern |
| Storage | Local filesystem (path_provider) |

## Local Development

```bash
cd mobile_app
flutter pub get
flutter run
```

## Environment Configuration

Environment variables are passed via `--dart-define` in `launch.json` (or `flutter run --dart-define=KEY=VALUE`):

```json
"COGNITO_USER_POOL_ID": "af-south-1_xxx",
"COGNITO_APP_CLIENT_ID": "xxxxxx",
"API_BASE_URL": "https://api.uinlp.org.ng"
```

## Key Screens & Features

### Authentication
- Sign in via Cognito using `amplify_auth_cognito`.
- Tokens are automatically refreshed in the background.

### Asset Discovery
- Fetches available assets (`GET /v1/assets`) filtered to those with `total_publishes < 2`.
- Displays each asset as a tile showing modality, name, and annotation field count.

### Annotation Task
- Annotators tap an asset to open the annotation editor.
- The editor renders fields dynamically based on `annotate_fields`:
  - `text` → free-text input
  - `image` → image capture or gallery picker
  - `audio` → microphone recorder with playback
  - `video` → video capture
- Progress is saved locally so the app can be closed and resumed.

### Publishing
1. On completion, the app calls `POST /v1/assets/publish-upload-url` to get a presigned S3 URL.
2. The collected task data is zipped and PUT to the S3 URL.
3. `POST /v1/assets/acknowledge-publish` is called to register the publish in DynamoDB.

### Profile Screen
- Shows the authenticated user's Cognito profile information.
- Provides a sign-out action.

## Project Structure

```
mobile_app/lib/
├── components/         # Reusable widgets (fields, displays, tiles)
├── exceptions.dart     # Typed exception classes
├── features/
│   ├── annotate_task/  # BLoC, screens, and state for annotation
│   └── main/           # Root navigation and profile screen
├── repositories/
│   ├── asset.dart      # Asset and publish API calls
│   └── task.dart       # Task download/upload helpers
└── utilities/
    └── helper.dart     # Shared utility functions
```

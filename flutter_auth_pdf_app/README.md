# Flutter Auth + PDF Upload

A sample Flutter app with email/password authentication, data entry, and PDF upload to Firebase Storage with metadata in Firestore.

## Prerequisites
- Flutter SDK (included in this workspace under `flutter_sdk`)
- A Firebase project (enable Authentication [Email/Password], Firestore, and Storage)

## Configure Firebase
1. Create a Firebase project.
2. Enable Email/Password in Authentication.
3. Create Firestore database in test or production mode.
4. Create a Storage bucket and set appropriate Security Rules.
5. Generate Flutter configuration:
   - Recommended: use FlutterFire CLI
     - `dart pub global activate flutterfire_cli`
     - `flutterfire configure` (select your project, platforms)
   - This generates `lib/firebase_options.dart` automatically.
6. Alternatively, replace placeholders in `lib/firebase_options.dart` with your project values.
7. Android: download `google-services.json` and place it at `android/app/google-services.json`.
8. iOS: download `GoogleService-Info.plist` and add it to the `Runner` target.

## Run
```
flutter pub get
flutter run -d chrome   # web
# or
flutter run              # pick a device
```

## Notes
- Uploaded PDFs go to Storage under `uploads/{uid}/{docId}-{filename}`.
- Firestore collection `documents` stores metadata: title, description, file info, downloadUrl, ownerUid, createdAt.

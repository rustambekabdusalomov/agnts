# hiro mobile (Flutter)

The phone app: home (what needs you, live runs, plan usage), tickets with a
pinned action bar (answer, approve, request changes, reject, retry, stop),
side-project tasks, the activity log, and settings (usage, theme, language,
default models, push switches, integrations, repositories).

It talks to the same API as the admin panel, through the Dart client generated
from `shared/openapi/openapi.yaml`, follows the live event stream while open,
and receives push notifications through Firebase Cloud Messaging.

## First-time setup

Requires Flutter 3.44 or newer.

```sh
flutter upgrade
cd apps/mobile
flutter create --platforms=ios,android --org dev.hiro --project-name hiro_mobile .
(cd packages/hiro_api && dart run build_runner build --delete-conflicting-outputs)
flutter pub get
dart run flutter_launcher_icons   # app icon from assets/icon/ (hiro's mark)
flutter run
```

### Push notifications

1. Create a Firebase project and add an iOS and an Android app
   (`dev.hiro.hiro_mobile`).
2. Run `flutterfire configure` here, or put `google-services.json` in
   `android/app/` and `GoogleService-Info.plist` in `ios/Runner/`.
3. iOS: enable Push Notifications and Background Modes → Remote notifications
   in Xcode, and upload an APNs key in Firebase (Project settings → Cloud
   Messaging).
4. On the server, download a service account key (Project settings → Service
   accounts) and set `HIRO_FCM_CREDENTIALS` to its path.

Without Firebase files the app still works; push is simply off.

## Distribution

- iOS: `flutter build ipa`, then upload to TestFlight (Xcode Organizer or Transporter).
- Android: `flutter build appbundle` for the Play internal testing track, or
  `flutter build apk` for a direct install.

## Generated code

Run `make gen` from the repository root after changing the spec or the
dictionaries. It writes `lib/l10n/app_*.arb` and `packages/hiro_api/`.

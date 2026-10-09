# agnts mobile (Flutter)

One codebase, two apps, picked by the build flavor. Each has its own id, so
both install side by side:

| Flavor | App | iOS id | Android id |
| --- | --- | --- | --- |
| `user` | **agnts**: for workspace members | `dev.agnts.agntsMobile` | `dev.agnts.agnts_mobile` |
| `admin` | **agnts admin**: the Admin cabinet, for system Admins | `dev.agnts.agntsAdmin` | `dev.agnts.agnts_admin` |

The user app: home (what needs you, live runs, plan usage), tickets with a
pinned action bar (answer, approve, request changes, reject, retry, stop),
side-project tasks, the activity log, and settings (usage, theme, language,
default models, push switches, integrations, repositories).

The admin app: the platform dashboard, workspaces (plan, slots, member limit,
credits, suspension), users, Admins and feedback. It signs in only Admin
accounts, and the user app turns away an Admin account that has no
workspaces. Push and the live event stream are user-app only.

```sh
flutter run --flavor user
flutter run --flavor admin
flutter build ios --release --flavor admin && flutter install --release --flavor admin
```

Android needs `--flavor` on every build. On iOS a build without it is the
user app.

It talks to the same API as the admin panel, through the Dart client generated
from `shared/openapi/openapi.yaml`, follows the live event stream while open,
and receives push notifications through Firebase Cloud Messaging.

## First-time setup

Requires Flutter 3.44 or newer.

```sh
flutter upgrade
cd apps/mobile
flutter create --platforms=ios,android --org dev.agnts --project-name agnts_mobile .
(cd packages/agnts_api && dart run build_runner build --delete-conflicting-outputs)
flutter pub get
dart run flutter_launcher_icons   # app icon from assets/icon/ (agnts's mark)
flutter run --flavor user
```

### Push notifications

1. Create a Firebase project and add an iOS and an Android app
   (`dev.agnts.agnts_mobile`).
2. Run `flutterfire configure` here, or put `google-services.json` in
   `android/app/` and `GoogleService-Info.plist` in `ios/Runner/`.
3. iOS: enable Push Notifications and Background Modes → Remote notifications
   in Xcode, and upload an APNs key in Firebase (Project settings → Cloud
   Messaging).
4. On the server, download a service account key (Project settings → Service
   accounts) and set `AGNTS_FCM_CREDENTIALS` to its path.

Without Firebase files the app still works; push is simply off.

## Distribution

- iOS: `flutter build ipa --flavor user` (or `admin`), then upload to
  TestFlight (Xcode Organizer or Transporter).
- Android: `flutter build appbundle --flavor user` for the Play internal
  testing track, or `flutter build apk --flavor user` for a direct install.

## Generated code

Run `make gen` from the repository root after changing the spec or the
dictionaries. It writes `lib/l10n/app_*.arb` and `packages/agnts_api/`.

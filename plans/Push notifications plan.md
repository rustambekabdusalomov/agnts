# agnts Push Notifications — Plan

Oct 17, 2026 · v1 code implemented (phases 2 and 3); phase 1 (Firebase setup) is manual and still to do

## Overview

The mobile app should tell a ticket's owner what its agents are doing without anyone watching the app: when a ticket needs them (questions, review), when it stops (failed, plan limit), when it is pushed, and as each step of the pipeline finishes.

Most of the pipeline already existed before this plan:

- Every state change is an `events` row; `pg_notify` wakes the notifier (`server/internal/notify/notifier.go`), which follows the log from a saved cursor and sends FCM pushes (`fcm.go`) and Telegram messages.
- The app registers its FCM token (`apps/mobile/lib/core/push.dart`), opens the right screen on a tap and switches to the push's workspace first (`main.dart` `openFromPush`).
- Per-workspace toggles in Settings (admin panel and the app's More screen).

What was missing: Firebase was never configured, pushes went to **every** member of the workspace, the steps in between were silent, and a push arriving while the app was open was dropped.

**Decisions**

- **Recipients: the ticket's owner only.** Owner = `tickets.member_id`, else `created_by`, else the workspace's `default_member_id`, else the workspace owner (the same order `claude.whose` uses to pick whose account runs it). Nobody gets a push about what they did themselves (`event.user_id` = owner). Pushes about no ticket (a red CI branch) still go to every member.
- **Progress = ordinary pushes, one per ticket.** Each step replaces the ticket's previous notification (Android `tag`, APNs `apns-collapse-id`), so the lock screen shows one line per ticket that moves along: *PAY-1: analysis done, coding* → *PAY-1: code written, running checks* → *PAY-1 is ready for review* → *PAY-1 pushed*. Step pushes are silent (low-importance Android channel, iOS `passive`), phone only (never Telegram, a shared chat), on by default, with their own toggle.
- A true live view (iOS Live Activities, Android Live Updates) is phase 4, after v1 is in use.

## Phase 1 — Firebase setup (manual, not done)

1. Firebase project with four apps: Android `dev.agnts.agnts_mobile` and `dev.agnts.agnts_admin`, iOS `dev.agnts.agntsMobile` and `dev.agnts.agntsAdmin`. Only the user flavor uses push today; registering the admin ids too saves a second trip.
2. Android: `flutterfire configure` (or `google-services.json` per flavor in `android/app/src/user/` and `src/admin/`) and apply the `com.google.gms.google-services` Gradle plugin.
3. iOS: Push Notifications capability (adds the entitlements file with `aps-environment`), Background Modes → Remote notifications, `GoogleService-Info.plist`, and an APNs auth key (.p8) uploaded in Firebase → Cloud Messaging.
4. Server: put the service account JSON in `/opt/agnts`, mount it into the `agnts` container and set `AGNTS_FCM_CREDENTIALS` in the server's own `.env`/`docker-compose.yml` (merge by hand, see `deploy.md`). The log line "push notifications off" disappears once it loads.
5. Smoke test: register a phone, run a ticket, see each step replace the last; answer a question yourself and get no push for it.

## Phase 2 — Mobile (done)

- `push.dart`: a push that arrives while the app is open is shown with `flutter_local_notifications` on both platforms (`setForegroundNotificationPresentationOptions()` turns the system's off, so there are no duplicates). Same tag → same id, so a step replaces the last one in the foreground too. Silent pushes use the quiet channel / passive level.
- Not shown when its screen is open already (`showing` callback in `main.dart` compares the router's path).
- Taps on these local notifications go through the same `_open` → `openFromPush` path as system ones (payload = the push's data).
- Android channels created on start: `agnts` (high) and `agnts_progress` (low, no sound or vibration); `default_notification_channel_id` = `agnts`; `POST_NOTIFICATIONS` in the manifest; core library desugaring enabled (the plugin needs it).
- More → Push: "When an agent finishes a step" toggle.
- No background handler: the server sends notification messages, which the OS shows when the app is in the background or killed.

## Phase 3 — Server (done)

- `kindFor(from, to)`: new kind **progress** for `analyzing → coding` and `coding → testing`. `testing → coding` (checks sent the code back) stays quiet, as do `new → analyzing` and `waiting_for_answers → coding` (the owner just answered).
- `pushText`: "KEY: analysis done, coding", "KEY: code written, running checks".
- `NotifySettings.Progress` (default true; existing workspaces get it because saved settings are unmarshalled over the defaults), in the OpenAPI spec, `PUT /settings` and the admin panel's Settings → Notifications.
- `Push` gains `Tag`, `Quiet`, `Actor`. Every state push of a ticket carries tag `KEY:state`; every ticket push carries iOS `thread-id` = key so a ticket's pushes group together. Data payload repeats `tag` and `quiet` for the app.
- `postgres.Agent.OwnerDevices(ws, key)` returns the owner and their devices (only while they are still a member). `Notifier.push` uses it for every push with a ticket.
- Tests: `notify_test.go` (owner-only delivery, payload tag/channel/collapse-id/thread-id, silent progress, no send-back push, no push for the owner's own action, toggle off, no Telegram for steps); `postgres_test.go` (owner by member, webhook ticket falls back to the workspace owner, missing ticket).

## Phase 4 — Live progress (later)

- **iOS Live Activity**: a widget extension (ActivityKit) showing Analyzing → Coding → Testing → Review → Pushing → Done on the lock screen and Dynamic Island, a Flutter bridge to start it from the ticket screen (or automatically for the owner's running tickets), and the server sending `liveactivity` pushes with each activity's push token (FCM v1 supports them through `apns.live_activity_token`). Limits: 8 hours per activity, Apple's update budget. About 1–2 weeks.
- **Android**: an ongoing notification with a progress bar (Android 16 Live Updates / `ProgressStyle`), updated from data messages through `flutter_local_notifications`. About 2–3 days.
- **Per-person settings**: the toggles are per workspace today, so one member turning a kind off turns it off for all. A `notify_prefs (user_id, workspace_id, …)` table read by the notifier before sending.

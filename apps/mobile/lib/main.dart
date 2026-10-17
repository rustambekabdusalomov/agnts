import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart' show AgntsApi;

import 'app_router.dart';
import 'core/api.dart';
import 'core/data.dart';
import 'core/flavor.dart';
import 'core/google_auth.dart';
import 'core/live.dart';
import 'core/prefs.dart';
import 'core/push.dart';
import 'core/session.dart';
import 'l10n/app_localizations.dart';
import 'theme.dart';

const appVersion = '0.1.0';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  // Push and the event stream follow a workspace's tickets: the user app's.
  if (!isAdminApp) {
    await Push.init(
      (route, ws) => openFromPush(container, route, ws),
      showing: (route) => container.read(routerProvider).state.uri.path == route,
    );
  }
  runApp(UncontrolledProviderScope(container: container, child: const AgntsApp()));
}

class AgntsApp extends ConsumerStatefulWidget {
  const AgntsApp({super.key});

  @override
  ConsumerState<AgntsApp> createState() => _AgntsAppState();
}

class _AgntsAppState extends ConsumerState<AgntsApp> {
  @override
  void initState() {
    super.initState();
    // While signed in: follow the live stream and register for push. Set up
    // once here: Riverpod 3 cannot fire a listener immediately from build.
    if (isAdminApp) return;
    ref.listenManual(apiProvider, (prev, api) {
      final live = ref.read(liveProvider);
      if (api == null) {
        live.stop();
        return;
      }
      if (prev == null) {
        live.start();
        Push.register(api, appVersion);
      } else {
        // Another workspace (or a new token): its own event stream.
        live.restart();
      }
    }, fireImmediately: true);
    // An Admin account with no workspaces has no event stream: stop the one
    // started before the account loaded, and start it if a workspace appears.
    ref.listenManual(adminProvider, (_, admin) {
      final live = ref.read(liveProvider);
      if (admin?.only ?? false) {
        live.stop();
      } else if (ref.read(apiProvider) != null) {
        live.start();
      }
    });
    // A workspace the person no longer belongs to: fall back to the server's choice.
    ref.listenManual(meProvider, (_, me) {
      final slug = ref.read(sessionProvider).value?.workspace;
      final ws = me.value?.workspaces;
      if (slug != null && ws != null && !ws.any((w) => w.slug == slug)) {
        ref.read(sessionProvider.notifier).setWorkspace(null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(prefsProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: agntsTheme(Brightness.light),
      darkTheme: agntsTheme(Brightness.dark),
      themeMode: prefs.theme,
      locale: prefs.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => Actions(actions: tapOutsideUnfocuses, child: child!),
    );
  }
}

/// A tap outside a text field closes the keyboard. Flutter keeps the focus
/// on phones by default, so the keyboard stayed up over the buttons below
/// the field (Retry under a failed ticket's note) with no way to close it.
/// Every text field asks its ancestors first, so this covers all screens,
/// sheets and dialogs.
final tapOutsideUnfocuses = <Type, Action<Intent>>{
  EditableTextTapOutsideIntent: CallbackAction<EditableTextTapOutsideIntent>(
    onInvoke: (intent) => intent.focusNode.unfocus(),
  ),
};

/// Opens a notification's screen, first switching to the workspace its
/// ticket is in.
Future<void> openFromPush(ProviderContainer container, String route, int ws) async {
  if (ws > 0 && container.read(sessionProvider).value != null) {
    try {
      final me = await container.read(meProvider.future);
      final w = me.workspaces?.where((w) => w.id == ws).firstOrNull;
      if (w != null && w.slug != container.read(currentWorkspaceProvider)?.slug) {
        await container.read(sessionProvider.notifier).setWorkspace(w.slug);
      }
    } catch (_) {
      // Offline or signed out: open the link anyway.
    }
  }
  container.read(routerProvider).push(route);
}

/// Signs out on this phone at once, then tells the server (ends the session,
/// stops push) in the background: an unreachable server must not keep the
/// person signed in until its calls time out.
Future<void> signOut(WidgetRef ref) async {
  final api = ref.read(apiProvider);
  await ref.read(sessionProvider.notifier).signedOut();
  unawaited(GoogleAuth.signOut());
  if (api != null) unawaited(_endServerSession(api));
}

Future<void> _endServerSession(AgntsApi api) async {
  const wait = Duration(seconds: 10);
  try {
    await Push.unregister(api).timeout(wait);
  } catch (_) {}
  try {
    await api.getAuthApi().logout().timeout(wait);
  } catch (_) {}
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_router.dart';
import 'core/api.dart';
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
  await Push.init((route) => container.read(routerProvider).push(route));
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
    ref.listenManual(apiProvider, (_, api) {
      final live = ref.read(liveProvider);
      if (api == null) {
        live.stop();
        return;
      }
      live.start();
      Push.register(api, appVersion);
    }, fireImmediately: true);
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
    );
  }
}

/// Signs out on the server and locally, and stops push to this phone.
Future<void> signOut(WidgetRef ref) async {
  final api = ref.read(apiProvider);
  if (api != null) {
    await Push.unregister(api);
    try {
      await api.getAuthApi().logout();
    } catch (_) {}
  }
  await ref.read(sessionProvider.notifier).signedOut();
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/session.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';
import 'login_screen.dart' show defaultServer;

/// The server an account screen talks to: the one passed in the link
/// (?server=, from the sign-in screen), else the signed-in one, else the default.
String serverFor(BuildContext context, WidgetRef ref) {
  String? q;
  try {
    q = GoRouterState.of(context).uri.queryParameters['server'];
  } catch (_) {} // shown outside the router (tests)
  if (q != null && q.isNotEmpty) return q;
  return ref.read(sessionProvider).value?.server ?? defaultServer;
}

/// A path with the server kept as ?server= (and any other [query]).
String withServer(String path, String server, [Map<String, String> query = const {}]) =>
    Uri(path: path, queryParameters: {...query, if (server.isNotEmpty) 'server': server}).toString();

/// The server's message for a failed account call, or [fallback]; a 429
/// says to wait.
String authError(AppLocalizations l, Object e) {
  if (e is DioException) {
    final r = e.response;
    if (r?.statusCode == 429) {
      final after = int.tryParse(r?.headers.value('retry-after') ?? '') ?? 60;
      return l.authRateLimited(after);
    }
    final data = r?.data;
    if (data is Map && data['message'] is String) return data['message'] as String;
  }
  return l.commonError;
}

/// The signed-out account screens' frame: the wordmark, a title and lede,
/// the form in a card, and links under it (the web's AuthCard).
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.title, this.lede, required this.children, this.links = const []});
  final String title;
  final String? lede;
  final List<Widget> children;
  final List<Widget> links;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = Agnts.of(context);
    return Scaffold(
      appBar: Navigator.of(context).canPop() ? DetailBar(backLabel: l.navBack) : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SvgPicture.asset(
                        theme.brightness == Brightness.dark ? 'assets/brand/wordmark_dark.svg' : 'assets/brand/wordmark.svg',
                        height: 30,
                        semanticsLabel: l.appName,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(title, style: theme.textTheme.headlineSmall),
                    if (lede != null) ...[
                      const SizedBox(height: 8),
                      Text(lede!, style: TextStyle(fontSize: 15, height: 1.45, color: c.ink2)),
                    ],
                    const SizedBox(height: 18),
                    HCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
                    ),
                    if (links.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, spacing: 4, children: links),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A link-styled text button under an account form.
class AuthLink extends StatelessWidget {
  const AuthLink(this.text, {super.key, required this.onTap, this.prefix});
  final String text;
  final String? prefix;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prefix != null) Text(prefix!, style: TextStyle(fontSize: 14, color: c.ink3)),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6), minimumSize: const Size(40, 40)),
          child: Text(
            text,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.primary),
          ),
        ),
      ],
    );
  }
}

/// A form's message: green when done, red when it failed.
class AuthNote extends StatelessWidget {
  const AuthNote(this.text, {super.key, this.tone = Tone.bad});
  final String text;
  final Tone tone;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: HelpBox(text, tone: tone),
  );
}

/// Opens sign-in from an account screen, keeping the server it used.
void goSignIn(BuildContext context, String server, [Map<String, String> query = const {}]) =>
    context.go(withServer('/login', server == defaultServer ? '' : server, query));

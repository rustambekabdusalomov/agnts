import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/session.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _server = TextEditingController();
  final _user = TextEditingController();
  final _pass = TextEditingController();
  final _code = TextEditingController();
  bool _busy = false;
  bool _needCode = false; // the account signs in with a second factor
  bool _asking = false; // the message asks for the code rather than reports an error
  String? _error;

  @override
  void dispose() {
    for (final c in [_server, _user, _pass, _code]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final server = _server.text.trim();
    final uri = Uri.tryParse(server);
    if (uri == null || uri.host.isEmpty || !(uri.scheme == 'https' || (allowLocalHttp && uri.scheme == 'http' && isLocalHost(uri.host)))) {
      setState(() {
        _error = l.mobileServerInvalid;
        _asking = false;
      });
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).signIn(server, _user.text, _pass.text, _code.text);
    } on SignInError catch (e) {
      // The first code_required just asks for the code; after one was typed it was wrong.
      final ask = e.kind == 'codeRequired' && !_needCode;
      _code.clear();
      setState(() => _error = switch (e.kind) {
            _ when ask => l.authCodeLede,
            'credentials' || 'codeRequired' => l.authWrongCredentials,
            'rateLimited' => l.authRateLimited(60),
            _ => l.commonError,
          });
      setState(() {
        _asking = ask;
        if (ask) _needCode = true;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = Agnts.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AutofillGroup(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  // agnts's wordmark, as in the admin sidebar: light letters on a dark theme.
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SvgPicture.asset(
                      theme.brightness == Brightness.dark ? 'assets/brand/wordmark_dark.svg' : 'assets/brand/wordmark.svg',
                      height: 34,
                      semanticsLabel: l.appName,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(l.appTagline, style: TextStyle(fontSize: 13.5, color: c.ink3)),
                  const SizedBox(height: 24),
                  Text(l.authTitle, style: theme.textTheme.displaySmall),
                  const SizedBox(height: 8),
                  Text(l.mmoreLoginLede, style: TextStyle(fontSize: 15, height: 1.45, color: c.ink2)),
                  const SizedBox(height: 18),
                  HCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      TextField(
                        controller: _server,
                        keyboardType: TextInputType.url,
                        autocorrect: false,
                        style: const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 15),
                        decoration: InputDecoration(labelText: l.mobileServer, hintText: l.mobileServerHint),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _user,
                        autofillHints: const [AutofillHints.username],
                        autocorrect: false,
                        decoration: InputDecoration(labelText: l.authUsername),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _pass,
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(labelText: l.authPassword),
                        onSubmitted: _needCode ? null : (_) => _submit(),
                      ),
                      if (_needCode) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _code,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          autofillHints: const [AutofillHints.oneTimeCode],
                          maxLength: 6,
                          style: const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 17, letterSpacing: 4),
                          decoration: InputDecoration(
                            labelText: l.authCode,
                            helperText: l.authCodeHint,
                            helperStyle: TextStyle(fontSize: 12.5, color: c.ink3),
                            counterText: '',
                          ),
                          onSubmitted: (_) => _submit(),
                        ),
                      ],
                    ]),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: HelpBox(_error!, tone: _asking ? Tone.info : Tone.bad),
                    ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: Text(_busy ? l.authSubmitting : l.authSubmit),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Plain http is allowed only to a server on the local network (a dev server
/// on your computer), and only in debug builds or builds made with
/// `--dart-define=AGNTS_LOCAL_HTTP=true`. Other builds always require https.
const allowLocalHttp = kDebugMode || bool.fromEnvironment('AGNTS_LOCAL_HTTP');

@visibleForTesting
bool isLocalHost(String host) {
  final h = host.toLowerCase();
  if (h == 'localhost' || h.endsWith('.local')) return true;
  final p = h.split('.').map(int.tryParse).toList();
  if (p.length != 4 || p.any((x) => x == null || x < 0 || x > 255)) return false;
  final a = p[0]!, b = p[1]!;
  return a == 10 || a == 127 || (a == 172 && b >= 16 && b <= 31) || (a == 192 && b == 168);
}

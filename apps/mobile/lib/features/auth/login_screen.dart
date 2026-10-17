import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart' show BeginLoginTotp200Response;

import '../../core/flavor.dart';
import '../../core/google_auth.dart';
import '../../core/session.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';
import '../account/account_widgets.dart';
import 'auth_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _server = TextEditingController(text: defaultServer);
  final _user = TextEditingController();
  final _pass = TextEditingController();
  final _code = TextEditingController();
  bool _busy = false;
  bool _needCode = false; // the account signs in with a second factor
  bool _asking = false; // the message asks for the code rather than reports an error
  bool _passwordForm = false; // the user app's password sign-in, shown on request
  BeginLoginTotp200Response? _setup; // an Admin setting up two-factor sign-in while signing in
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Back from an account screen: keep the server it used.
    try {
      final server = GoRouterState.of(context).uri.queryParameters['server'];
      if (server != null && server.isNotEmpty && _server.text == defaultServer) _server.text = server;
    } catch (_) {} // shown outside the router (tests)
  }

  @override
  void dispose() {
    for (final c in [_server, _user, _pass, _code]) {
      c.dispose();
    }
    super.dispose();
  }

  /// The server address, or null after saying it is not a valid one.
  String? _validServer() {
    final server = _server.text.trim();
    final uri = Uri.tryParse(server);
    if (uri == null || uri.host.isEmpty || !(uri.scheme == 'https' || (allowLocalHttp && uri.scheme == 'http' && isLocalHost(uri.host)))) {
      setState(() {
        _error = AppLocalizations.of(context).mobileServerInvalid;
        _asking = false;
      });
      return null;
    }
    return server;
  }

  /// The user app signs in with Google only: the server's web client id,
  /// then Google's account picker on the phone, then the server.
  Future<void> _google() async {
    final l = AppLocalizations.of(context);
    final server = _validServer();
    if (server == null) return;
    setState(() {
      _busy = true;
      _error = null;
      _asking = false;
    });
    final session = ref.read(sessionProvider.notifier);
    try {
      final clientId = await session.googleClientId(server);
      if (clientId == null) throw SignInError('googleOff');
      final token = await GoogleAuth.idToken(clientId);
      if (token == null) return; // backed out of Google's picker
      await session.signInWithGoogle(server, token);
    } on SignInError catch (e) {
      if (!mounted) return;
      setState(() => _error = switch (e.kind) {
            'googleOff' => l.mobileGoogleOff,
            'googleSetup' => l.mobileGoogleSetup,
            'googleInvalid' || 'googleFailed' => l.authGoogleFailed,
            'signupClosed' => l.authGoogleClosed,
            'admin' => l.mobileAdminAppOnly,
            'invite' => l.authGoogleInvite,
            'rateLimited' => l.authGoogleRateLimited,
            _ => l.authGoogleError,
          });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final server = _validServer();
    if (server == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).signIn(server, _user.text, _pass.text, _code.text, totpSecret: _setup?.secret);
    } on SignInError catch (e) {
      if (e.kind == 'totpSetup' && _setup == null) {
        await _beginSetup(server);
        return;
      }
      // The first code_required just asks for the code; after one was typed it was wrong.
      final ask = e.kind == 'codeRequired' && !_needCode;
      _code.clear();
      setState(() => _error = switch (e.kind) {
            _ when ask => l.authCodeLede,
            'credentials' || 'codeRequired' || 'totpSetup' => l.authWrongCredentials,
            'useGoogle' => l.authUseGoogle,
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

  /// An Admin without two-factor sign-in gets a new secret to add, then
  /// signs in with a code from it.
  Future<void> _beginSetup(String server) async {
    final l = AppLocalizations.of(context);
    try {
      final setup = await ref.read(sessionProvider.notifier).beginLoginTotp(server, _user.text, _pass.text);
      if (!mounted) return;
      _code.clear();
      setState(() {
        _setup = setup;
        _needCode = true;
        _asking = true;
        _error = l.maccountSetupLede;
      });
    } catch (e) {
      if (mounted) setState(() => _error = authError(l, e));
    }
  }

  /// Back to the username and password, for another account.
  void _otherAccount() => setState(() {
        _needCode = false;
        _setup = null;
        _asking = false;
        _error = null;
        _code.clear();
        _pass.clear();
      });

  /// The server typed in, kept for the account screens (unless it is the default).
  String get _serverParam => _server.text.trim() == defaultServer ? '' : _server.text.trim();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = Agnts.of(context);
    // The user app signs in with Google (or a password when asked for);
    // the admin app with a password.
    final adminApp = ref.watch(adminAppProvider);
    final google = !adminApp && !_passwordForm;
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
                      if (!google && !_needCode) ...[
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
                          onSubmitted: (_) => _submit(),
                        ),
                      ],
                      if (!google && _needCode) ...[
                        if (_setup != null) ...[
                          const SizedBox(height: 12),
                          TotpSecret(secret: _setup!.secret, url: _setup!.url),
                        ],
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
                  if (google)
                    _GoogleButton(busy: _busy, onPressed: _google)
                  else
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: Text(_busy ? l.authSubmitting : l.authSubmit),
                    ),
                  const SizedBox(height: 8),
                  Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, spacing: 4, children: [
                    if (_needCode)
                      AuthLink(l.authBack, onTap: _otherAccount)
                    else ...[
                      if (!adminApp)
                        AuthLink(
                          _passwordForm ? l.maccountGoogleInstead : l.maccountPasswordInstead,
                          onTap: () => setState(() {
                            _passwordForm = !_passwordForm;
                            _error = null;
                          }),
                        ),
                      if (!google) AuthLink(l.accountForgot, onTap: () => context.push(withServer('/forgot', _serverParam))),
                      if (!adminApp)
                        AuthLink(l.accountSignUp, prefix: l.accountNoAccount, onTap: () => context.push(withServer('/signup', _serverParam))),
                    ],
                  ]),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Continue with Google": Google's mark on a white (or dark) pill, as
/// Google's branding asks.
class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.busy, required this.onPressed});
  final bool busy;
  final VoidCallback onPressed;

  static const _mark = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">'
      '<path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>'
      '<path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>'
      '<path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>'
      '<path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>'
      '</svg>';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return OutlinedButton(
      onPressed: busy ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        shape: const StadiumBorder(),
        backgroundColor: c.surface,
        side: BorderSide(color: c.line4),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (busy)
          SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: c.ink3))
        else
          SvgPicture.string(_mark, width: 18, height: 18),
        const SizedBox(width: 10),
        Flexible(
          child: Text(busy ? l.authGoogleRedirecting : l.mobileGoogleContinue,
              overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: c.ink)),
        ),
      ]),
    );
  }
}

/// The server the sign-in screen starts with; another can be typed in.
const defaultServer = String.fromEnvironment('AGNTS_SERVER', defaultValue: 'https://api.agnts.uz');

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

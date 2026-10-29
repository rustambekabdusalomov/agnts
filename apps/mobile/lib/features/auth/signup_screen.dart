import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/session.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/ui.dart';
import 'auth_widgets.dart';

/// What the server says about signing up there, and an invite's preview.
final signupInfoProvider = FutureProvider.autoDispose.family<SignupInfo, String>((ref, server) async {
  return (await SessionNotifier.client(server).getAuthApi().getSignupInfo()).data!;
});

final invitePreviewProvider = FutureProvider.autoDispose.family<InvitePreview, (String, String)>((ref, args) async {
  return (await SessionNotifier.client(args.$1).getWorkspacesApi().getInvite(token: args.$2)).data!;
});

/// Creating an account with a password (?invite= joins that workspace,
/// ?email= fills the address in). Signed in once created.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _email = TextEditingController();
  final _name = TextEditingController();
  final _pass = TextEditingController();
  final _again = TextEditingController();
  final _workspace = TextEditingController();
  String _server = '';
  String _invite = '';
  bool _busy = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_server.isNotEmpty) return;
    _server = serverFor(context, ref);
    try {
      final q = GoRouterState.of(context).uri.queryParameters;
      _invite = q['invite'] ?? '';
      if (_email.text.isEmpty) _email.text = q['email'] ?? '';
    } catch (_) {}
  }

  @override
  void dispose() {
    for (final c in [_email, _name, _pass, _again, _workspace]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _ready => !_busy && _email.text.contains('@') && _pass.text.length >= 12 && _pass.text == _again.text;

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    if (!_ready) {
      if (_pass.text != _again.text) setState(() => _error = l.accountPasswordsDiffer);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(sessionProvider.notifier)
          .register(
            _server,
            RegisterRequest(
              email: _email.text.trim(),
              password: _pass.text,
              displayName: _name.text.trim().isEmpty ? null : _name.text.trim(),
              workspaceName: _workspace.text.trim().isEmpty || _invite.isNotEmpty ? null : _workspace.text.trim(),
              invite: _invite.isEmpty ? null : _invite,
              client: RegisterRequestClientEnum.mobile,
            ),
          );
      // Signed in: the router opens the app.
    } catch (e) {
      if (mounted) setState(() => _error = authError(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final info = ref.watch(signupInfoProvider(_server)).value;
    final preview = _invite.isEmpty ? null : ref.watch(invitePreviewProvider((_server, _invite))).value;
    final closed = _invite.isEmpty && info != null && !info.open;
    return AuthScaffold(
      title: l.accountSignupTitle,
      lede: preview != null ? l.accountSignupInviteLede(preview.workspace) : l.accountSignupLede,
      links: [AuthLink(l.accountSignIn, prefix: l.accountHaveAccount, onTap: () => goSignIn(context, _server))],
      children: closed
          ? [HelpBox(l.accountSignupClosed)]
          : [
              if (info?.firstUser == true) Padding(padding: const EdgeInsets.only(bottom: 12), child: HelpBox(l.accountFirstUser)),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(labelText: l.accountEmail),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _name,
                maxLength: 100,
                autofillHints: const [AutofillHints.name],
                decoration: InputDecoration(labelText: l.accountDisplayName, counterText: ''),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pass,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(labelText: l.accountPassword, helperText: l.accountPasswordHelp),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _again,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(labelText: l.accountPasswordAgain),
                onChanged: (_) => setState(() {}),
              ),
              if (_invite.isEmpty) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _workspace,
                  maxLength: 80,
                  decoration: InputDecoration(
                    labelText: l.accountWorkspaceName,
                    helperText: l.accountWorkspaceNameHelp,
                    helperMaxLines: 3,
                    counterText: '',
                  ),
                ),
              ],
              if (_error != null) AuthNote(_error!),
              const SizedBox(height: 16),
              FilledButton(onPressed: _ready ? _submit : null, child: Text(_busy ? l.accountCreating : l.accountCreate)),
            ],
    );
  }
}

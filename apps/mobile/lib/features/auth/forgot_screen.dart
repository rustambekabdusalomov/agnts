import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/session.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/ui.dart';
import 'auth_widgets.dart';

/// Asks for a password reset link by email.
class ForgotScreen extends ConsumerStatefulWidget {
  const ForgotScreen({super.key});

  @override
  ConsumerState<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends ConsumerState<ForgotScreen> {
  final _email = TextEditingController();
  String _server = '';
  bool _busy = false;
  bool _sent = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_server.isEmpty) _server = serverFor(context, ref);
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    if (_busy || !_email.text.contains('@')) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await SessionNotifier.client(
        _server,
      ).getAuthApi().forgotPassword(forgotPasswordRequest: ForgotPasswordRequest(email: _email.text.trim()));
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) setState(() => _error = authError(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AuthScaffold(
      title: l.accountForgotTitle,
      lede: l.accountForgotLede,
      links: [AuthLink(l.accountSignIn, onTap: () => goSignIn(context, _server))],
      children: _sent
          ? [HelpBox(l.accountForgotSent, tone: Tone.ok)]
          : [
              TextField(
                controller: _email,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(labelText: l.accountEmail),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _submit(),
              ),
              if (_error != null) AuthNote(_error!),
              const SizedBox(height: 16),
              FilledButton(onPressed: _busy || !_email.text.contains('@') ? null : _submit, child: Text(l.accountForgotSend)),
            ],
    );
  }
}

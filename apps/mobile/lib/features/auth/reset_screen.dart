import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/session.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/ui.dart';
import 'auth_widgets.dart';

/// A new password from an emailed reset link (?token=).
class ResetScreen extends ConsumerStatefulWidget {
  const ResetScreen({super.key, required this.token});
  final String token;

  @override
  ConsumerState<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends ConsumerState<ResetScreen> {
  final _pass = TextEditingController();
  final _again = TextEditingController();
  String _server = '';
  bool _busy = false;
  bool _done = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_server.isEmpty) _server = serverFor(context, ref);
  }

  @override
  void dispose() {
    _pass.dispose();
    _again.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    if (_pass.text != _again.text) {
      setState(() => _error = l.accountPasswordsDiffer);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await SessionNotifier.client(_server)
          .getAuthApi()
          .resetPassword(resetPasswordRequest: ResetPasswordRequest(token: widget.token, password: _pass.text));
      if (mounted) setState(() => _done = true);
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
      title: l.accountResetTitle,
      links: [AuthLink(l.accountSignIn, onTap: () => goSignIn(context, _server))],
      children: _done
          ? [HelpBox(l.accountResetDone, tone: Tone.ok)]
          : [
              if (widget.token.isEmpty) Padding(padding: const EdgeInsets.only(bottom: 12), child: HelpBox(l.accountVerifyFailed, tone: Tone.bad)),
              TextField(
                controller: _pass,
                autofocus: true,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(labelText: l.accountNewPassword, helperText: l.accountPasswordHelp),
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
              if (_error != null) AuthNote(_error!),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy || _pass.text.length < 12 || widget.token.isEmpty ? null : _submit,
                child: Text(l.accountResetSave),
              ),
            ],
    );
  }
}

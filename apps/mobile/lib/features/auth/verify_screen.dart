import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../core/session.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'auth_widgets.dart';

/// Confirms an email address from its emailed link (?token=). When it fails
/// and the person is signed in, a new link can be sent.
class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({super.key, this.token});
  final String? token;

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

enum _State { busy, ok, failed }

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  _State _state = _State.busy;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _verify());
  }

  Future<void> _verify() async {
    final token = widget.token ?? '';
    final server = serverFor(context, ref);
    try {
      if (token.isEmpty) throw StateError('no token');
      await SessionNotifier.client(server).getAuthApi().verifyEmail(tokenRequest: TokenRequest(token: token));
      if (!mounted) return;
      setState(() => _state = _State.ok);
      if (ref.read(sessionProvider).value != null) ref.invalidate(meProvider);
    } catch (_) {
      if (mounted) setState(() => _state = _State.failed);
    }
  }

  Future<void> _resend() async {
    final l = AppLocalizations.of(context);
    final api = ref.read(apiProvider);
    if (api == null) return;
    setState(() => _resending = true);
    try {
      await api.getAccountApi().resendVerification();
      if (mounted) showSnack(context, l.accountResent);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final signedIn = ref.watch(sessionProvider).value != null;
    return AuthScaffold(
      title: l.accountVerifyTitle,
      children: [
        switch (_state) {
          _State.busy => Row(
            children: [
              const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(width: 10),
              Text(l.accountVerifying),
            ],
          ),
          _State.ok => HelpBox(l.accountVerified, tone: Tone.ok),
          _State.failed => HelpBox(l.accountVerifyFailed, tone: Tone.bad),
        },
        if (_state != _State.busy) ...[
          const SizedBox(height: 16),
          if (_state == _State.failed && signedIn)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton(onPressed: _resending ? null : _resend, child: Text(l.accountResend)),
            ),
          FilledButton(onPressed: () => context.go(signedIn ? '/home' : '/login'), child: Text(l.accountContinue)),
        ],
      ],
    );
  }
}

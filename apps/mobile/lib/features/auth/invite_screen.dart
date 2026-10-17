import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../core/google_auth.dart';
import '../../core/session.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'auth_widgets.dart';
import 'signup_screen.dart' show invitePreviewProvider, signupInfoProvider;

/// An invite link: who invited whom to which workspace, and joining it.
/// Signed out, Google sign-in joins on the spot; else it is sign-up first.
class InviteScreen extends ConsumerStatefulWidget {
  const InviteScreen({super.key, required this.token});
  final String token;

  @override
  ConsumerState<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends ConsumerState<InviteScreen> {
  String _server = '';
  bool _busy = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_server.isEmpty) _server = serverFor(context, ref);
  }

  Future<void> _join() async {
    final l = AppLocalizations.of(context);
    final api = ref.read(apiProvider);
    if (api == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final ws = (await api.getWorkspacesApi().acceptInvite(token: widget.token)).data!;
      ref.invalidate(meProvider);
      await ref.read(sessionProvider.notifier).setWorkspace(ws.slug);
      if (!mounted) return;
      showSnack(context, l.mwsSwitched(ws.name));
      context.go('/home');
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _google(String clientId) async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final token = await GoogleAuth.idToken(clientId);
      if (token == null) return;
      await ref.read(sessionProvider.notifier).signInWithGoogle(_server, token, invite: widget.token);
      if (mounted) context.go('/home');
    } on SignInError catch (e) {
      if (mounted) setState(() => _error = e.kind == 'invite' ? l.authGoogleInvite : l.authGoogleFailed);
    } catch (_) {
      if (mounted) setState(() => _error = l.authGoogleError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final signedIn = ref.watch(sessionProvider).value != null;
    final preview = ref.watch(invitePreviewProvider((_server, widget.token)));
    final info = ref.watch(signupInfoProvider(_server)).value;
    final p = preview.value;
    final clientId = info?.googleClientId ?? '';
    return AuthScaffold(
      title: p != null ? l.accountInviteTitle(p.workspace) : l.accountInviteJoin,
      links: [
        if (!signedIn && p != null) AuthLink(l.accountSignIn, prefix: l.accountHaveAccount, onTap: () => goSignIn(context, _server)),
      ],
      children: [
        if (preview.isLoading)
          const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()))
        else if (preview.hasError || p == null)
          HelpBox(l.accountInviteInvalid, tone: Tone.bad)
        else ...[
          if (p.invitedBy?.isNotEmpty == true) Padding(padding: const EdgeInsets.only(bottom: 8), child: HelpBox(l.accountInviteBy(p.invitedBy!))),
          if (p.email?.isNotEmpty == true) Text(l.accountInviteFor(p.email!)),
          const SizedBox(height: 12),
          if (signedIn)
            FilledButton(onPressed: _busy ? null : _join, child: Text(_busy ? l.accountInviteJoining : l.accountInviteJoin))
          else if (clientId.isNotEmpty) ...[
            Text(l.accountInviteGoogle),
            const SizedBox(height: 12),
            FilledButton(onPressed: _busy ? null : () => _google(clientId), child: Text(_busy ? l.authGoogleRedirecting : l.mobileGoogleContinue)),
          ] else ...[
            Text(l.accountInviteSignInFirst),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.push(withServer('/signup', _server, {
                'invite': widget.token,
                if (p.email?.isNotEmpty == true) 'email': p.email!,
              })),
              child: Text(l.accountSignUp),
            ),
          ],
          if (_error != null) AuthNote(_error!),
        ],
      ],
    );
  }
}

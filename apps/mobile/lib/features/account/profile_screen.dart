import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'account_data.dart';
import 'account_widgets.dart';

/// The person's own account: name, email, their Claude account, password
/// and two-factor sign-in (the web's Profile page).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final me = ref.watch(meProvider);
    return Scaffold(
      appBar: DetailBar(backLabel: l.mobileMore),
      body: AsyncBody<User>(
        value: me,
        onRefresh: () async {
          ref.invalidate(meProvider);
          ref.invalidate(myClaudeProvider);
        },
        builder: (u) => ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            PageHeader(title: l.accountProfileTitle, sub: u.username),
            _ProfileSection(u),
            // Admins with no workspace have no runs to give an account to.
            if (!(u.isAdmin ?? false) || (u.workspaces?.isNotEmpty ?? false)) const _ClaudeSection(),
            const _PasswordSection(),
            _TotpSection(u),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends ConsumerStatefulWidget {
  const _ProfileSection(this.user);
  final User user;

  @override
  ConsumerState<_ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends ConsumerState<_ProfileSection> {
  late final _name = TextEditingController(text: widget.user.displayName ?? '');
  late final _email = TextEditingController(text: widget.user.email ?? '');
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function(AgntsApi api) call, String done) async {
    final l = AppLocalizations.of(context);
    final api = ref.read(apiProvider);
    if (api == null) return;
    setState(() => _busy = true);
    try {
      await call(api);
      if (mounted) showSnack(context, done);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final u = widget.user;
    final hasEmail = u.email?.isNotEmpty ?? false;
    final verified = u.emailVerified ?? false;
    return Section(
      title: l.accountProfile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.accountProfileSub, style: TextStyle(fontSize: 13.5, color: c.ink3)),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            maxLength: 100,
            decoration: InputDecoration(labelText: l.accountDisplayName, counterText: ''),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            maxLength: 254,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: l.accountEmail,
              counterText: '',
              helperText: hasEmail ? (verified ? l.accountEmailVerified : l.accountEmailUnverified) : null,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _busy
                    ? null
                    : () => _run((api) async {
                        await api.getAccountApi().updateProfile(
                          updateProfileRequest: UpdateProfileRequest(displayName: _name.text.trim(), email: _email.text.trim()),
                        );
                        ref.invalidate(meProvider);
                      }, l.accountProfileSaved),
                child: Text(l.accountSaveProfile),
              ),
              if (hasEmail && !verified)
                OutlinedButton(
                  onPressed: _busy ? null : () => _run((api) => api.getAccountApi().resendVerification(), l.accountResent),
                  child: Text(l.accountResend),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClaudeSection extends ConsumerStatefulWidget {
  const _ClaudeSection();

  @override
  ConsumerState<_ClaudeSection> createState() => _ClaudeSectionState();
}

class _ClaudeSectionState extends ConsumerState<_ClaudeSection> {
  bool _busy = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final state = ref.watch(myClaudeProvider);
    // Whether subscription tokens are accepted is the server's rule; the
    // workspace's Claude settings know it.
    final subscriptions = ref.watch(workspaceClaudeProvider).value?.subscriptionsAllowed ?? true;
    final api = ref.read(apiProvider);
    return Section(
      title: l.accountMyClaude,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.accountMyClaudeSub, style: TextStyle(fontSize: 13.5, color: c.ink3)),
          const SizedBox(height: 12),
          if (state.isLoading && !state.hasValue)
            const LinearProgressIndicator()
          else
            ClaudeConnect(
              state: state.value,
              subscriptions: subscriptions,
              busy: _busy,
              error: _error,
              onConnect: (kind, token) async {
                if (api == null) return false;
                setState(() => _busy = true);
                try {
                  await api.getAccountApi().setMyClaude(
                    claudeConnectionInput: ClaudeConnectionInput(kind: kind, token: token),
                  );
                  ref.invalidate(myClaudeProvider);
                  if (context.mounted) showSnack(context, l.accountClaudeSaved);
                  if (mounted) setState(() => _error = null);
                  return true;
                } catch (e) {
                  if (mounted) setState(() => _error = errorMessage(e, l.commonError));
                  return false;
                } finally {
                  if (mounted) setState(() => _busy = false);
                }
              },
              onDisconnect: () async {
                if (api == null) return;
                setState(() => _busy = true);
                try {
                  await api.getAccountApi().deleteMyClaude();
                  ref.invalidate(myClaudeProvider);
                  if (context.mounted) showSnack(context, l.accountClaudeRemoved);
                } catch (e) {
                  if (context.mounted) showSnack(context, errorMessage(e, l.commonError));
                } finally {
                  if (mounted) setState(() => _busy = false);
                }
              },
            ),
        ],
      ),
    );
  }
}

class _PasswordSection extends ConsumerStatefulWidget {
  const _PasswordSection();

  @override
  ConsumerState<_PasswordSection> createState() => _PasswordSectionState();
}

class _PasswordSectionState extends ConsumerState<_PasswordSection> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  Future<void> _change() async {
    final l = AppLocalizations.of(context);
    final api = ref.read(apiProvider);
    if (api == null) return;
    setState(() => _busy = true);
    try {
      await api.getAccountApi().changePassword(
        changePasswordRequest: ChangePasswordRequest(current: _current.text, password: _next.text),
      );
      _current.clear();
      _next.clear();
      if (mounted) showSnack(context, l.accountPasswordChanged);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return Section(
      title: l.accountPasswordTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.accountPasswordSub, style: TextStyle(fontSize: 13.5, color: c.ink3)),
          const SizedBox(height: 12),
          TextField(
            controller: _current,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            decoration: InputDecoration(labelText: l.accountCurrentPassword),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _next,
            obscureText: true,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(labelText: l.accountNewPassword, helperText: l.accountPasswordHelp),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: _busy || _current.text.isEmpty || _next.text.length < 12 ? null : _change,
              child: Text(l.accountChangePassword),
            ),
          ),
        ],
      ),
    );
  }
}

/// Two-factor sign-in: a new secret, then a code from it turns it on;
/// the password and a code turn it off (never for an Admin).
class _TotpSection extends ConsumerStatefulWidget {
  const _TotpSection(this.user);
  final User user;

  @override
  ConsumerState<_TotpSection> createState() => _TotpSectionState();
}

class _TotpSectionState extends ConsumerState<_TotpSection> {
  BeginTotp200Response? _enroll;
  final _code = TextEditingController();
  final _offPassword = TextEditingController();
  final _offCode = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_code, _offPassword, _offCode]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _run(Future<void> Function(AgntsApi api) call, [String? done]) async {
    final l = AppLocalizations.of(context);
    final api = ref.read(apiProvider);
    if (api == null) return;
    setState(() => _busy = true);
    try {
      await call(api);
      if (mounted && done != null) showSnack(context, done);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final u = widget.user;
    final on = u.hasTotp ?? false;
    return Section(
      title: l.accountTotpTitle,
      trailing: ToneBadge(on ? l.accountTotpOn : l.accountTotpOff, on ? Tone.ok : Tone.gray),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.accountTotpSub, style: TextStyle(fontSize: 13.5, color: c.ink3)),
          const SizedBox(height: 12),
          if (!on && _enroll == null)
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: _busy
                    ? null
                    : () => _run((api) async {
                        final e = (await api.getAccountApi().beginTotp()).data!;
                        _code.clear();
                        if (mounted) setState(() => _enroll = e);
                      }),
                child: Text(l.accountTotpSetup),
              ),
            )
          else if (!on) ...[
            Text(l.accountTotpScan, style: TextStyle(fontSize: 14, height: 1.4, color: c.ink2)),
            const SizedBox(height: 10),
            TotpSecret(secret: _enroll!.secret, url: _enroll!.url),
            const SizedBox(height: 12),
            CodeField(controller: _code, label: l.accountTotpCode, onChanged: (_) => setState(() {})),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(
                onPressed: _busy || _code.text.length != 6
                    ? null
                    : () => _run((api) async {
                        await api.getAccountApi().confirmTotp(
                          confirmTotpRequest: ConfirmTotpRequest(secret: _enroll!.secret, code: _code.text),
                        );
                        if (mounted) setState(() => _enroll = null);
                        ref.invalidate(meProvider);
                      }, l.accountTotpEnabled),
                child: Text(l.accountTotpConfirm),
              ),
            ),
          ] else if (u.isAdmin ?? false)
            HelpBox(l.accountTotpRequiredAdmin)
          else ...[
            TextField(
              controller: _offPassword,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(labelText: l.accountCurrentPassword),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            CodeField(controller: _offCode, label: l.accountTotpCode, onChanged: (_) => setState(() {})),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(foregroundColor: c.badInk),
                onPressed: _busy || _offPassword.text.isEmpty || _offCode.text.length != 6
                    ? null
                    : () => _run((api) async {
                        await api.getAccountApi().disableTotp(
                          disableTotpRequest: DisableTotpRequest(password: _offPassword.text, code: _offCode.text),
                        );
                        _offPassword.clear();
                        _offCode.clear();
                        ref.invalidate(meProvider);
                      }, l.accountTotpDisabled),
                child: Text(l.accountTotpDisable),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

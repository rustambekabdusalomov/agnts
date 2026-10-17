import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:url_launcher/url_launcher.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';

/// Opens [url] outside the app (the browser, or an authenticator app for
/// an otpauth:// link), saying so when nothing can.
Future<void> openLink(BuildContext context, String url) async {
  final l = AppLocalizations.of(context);
  final uri = Uri.tryParse(url);
  var ok = false;
  try {
    ok = uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!ok && context.mounted) showSnack(context, l.maccountLinkFailed);
}

/// A day, in the app's language.
String fmtDate(BuildContext context, DateTime d) => DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(d.toLocal());

/// A day and time, in the app's language.
String fmtDateTime(BuildContext context, DateTime d) => DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).add_Hm().format(d.toLocal());

/// The 6-digit authenticator code field (digits only).
class CodeField extends StatelessWidget {
  const CodeField({super.key, required this.controller, this.label, this.onChanged, this.onSubmitted, this.autofocus = false});
  final TextEditingController controller;
  final String? label;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      autofillHints: const [AutofillHints.oneTimeCode],
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
      style: const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 17, letterSpacing: 4),
      decoration: InputDecoration(labelText: label ?? l.authCode, hintText: '••••••'),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}

/// A two-factor secret to add to an authenticator app (the web's TotpQr,
/// without the QR): the secret to copy, and its setup link to open here.
class TotpSecret extends StatelessWidget {
  const TotpSecret({super.key, required this.secret, required this.url});
  final String secret;
  final String url;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.accountTotpSecret,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink3),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
          decoration: BoxDecoration(color: c.hover, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  secret,
                  style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 14, color: c.ink),
                ),
              ),
              CopyButton(secret),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(onPressed: () => openLink(context, url), child: Text(l.maccountTotpOpen)),
            ),
            CopyButton(url),
          ],
        ),
      ],
    );
  }
}

/// A Claude account's state and the form to connect or replace it (the
/// workspace's in its settings, a person's in their profile).
class ClaudeConnect extends StatefulWidget {
  const ClaudeConnect({
    super.key,
    required this.state,
    required this.subscriptions,
    required this.onConnect,
    required this.onDisconnect,
    this.busy = false,
    this.readonly = false,
    this.error,
  });
  final ClaudeConnectionState? state;
  final bool subscriptions;
  final bool busy;
  final bool readonly;
  final String? error;

  /// Returns true once connected, which closes the form.
  final Future<bool> Function(ClaudeConnectionInputKindEnum kind, String token) onConnect;
  final VoidCallback onDisconnect;

  @override
  State<ClaudeConnect> createState() => _ClaudeConnectState();
}

class _ClaudeConnectState extends State<ClaudeConnect> {
  late var _kind = widget.subscriptions ? ClaudeConnectionInputKindEnum.subscription : ClaudeConnectionInputKindEnum.apiKey;
  final _token = TextEditingController();
  bool _editing = false;

  @override
  void dispose() {
    _token.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final token = _token.text.trim();
    if (token.length < 10) return;
    if (await widget.onConnect(_kind, token) && mounted) {
      _token.clear();
      setState(() => _editing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final s = widget.state;
    final connected = s?.connected ?? false;
    String pct(double? v) => v == null ? '' : '${(v * 100).round()}%';
    final kindName = s?.kind == ClaudeConnectionStateKindEnum.apiKey ? l.wsKindApiKey : l.wsKindSubscription;
    final steps = _kind == ClaudeConnectionInputKindEnum.subscription
        ? [l.integrationsTokenStep1_claude, l.integrationsTokenStep2_claude, l.integrationsTokenStep3_claude, l.integrationsTokenStep4_claude]
        : [l.wsKeyStep1, l.wsKeyStep2, l.wsKeyStep3, l.wsKeyStep4];
    final note = TextStyle(fontSize: 13.5, height: 1.4, color: c.ink3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                connected ? l.wsConnected : l.wsNotConnected,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink),
              ),
            ),
            connected
                ? ToneBadge('$kindName${s?.tokenHint?.isNotEmpty == true ? ' · …${s!.tokenHint}' : ''}', s?.pausedUntil != null ? Tone.warn : Tone.ok)
                : ToneBadge(l.wsNotConnected, Tone.gray),
          ],
        ),
        if (s?.pausedUntil != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(l.wsPausedUntil(fmtDateTime(context, s!.pausedUntil!)), style: note),
          ),
        if (s?.usage?.fiveHour.utilization != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '${l.navSession}: ${pct(s!.usage!.fiveHour.utilization)}'
              '${s.usage!.sevenDay.utilization != null ? ' · ${l.navWeek}: ${pct(s.usage!.sevenDay.utilization)}' : ''}',
              style: note,
            ),
          ),
        if (s?.lastError?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: HelpBox(s!.lastError!, tone: Tone.bad, copyable: true),
          ),
        if (!widget.readonly && !_editing) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(onPressed: () => setState(() => _editing = true), child: Text(connected ? l.wsReplace : l.wsConnect)),
              if (connected)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(foregroundColor: c.badInk),
                  onPressed: widget.busy ? null : widget.onDisconnect,
                  child: Text(l.wsDisconnect),
                ),
            ],
          ),
        ],
        if (!widget.readonly && _editing) ...[
          const SizedBox(height: 12),
          if (!widget.subscriptions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(l.wsSubscriptionsOff, style: note),
            ),
          Segmented<ClaudeConnectionInputKindEnum>(
            full: true,
            options: [
              if (widget.subscriptions) (ClaudeConnectionInputKindEnum.subscription, l.wsKindSubscription),
              (ClaudeConnectionInputKindEnum.apiKey, l.wsKindApiKey),
            ],
            value: _kind,
            onChanged: (k) => setState(() => _kind = k),
          ),
          const SizedBox(height: 10),
          HelpBox(
            l.integrationsTokenHow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, step) in steps.indexed) Text('${i + 1}. $step', style: const TextStyle(fontSize: 13.5, height: 1.4)),
                const SizedBox(height: 6),
                if (_kind == ClaudeConnectionInputKindEnum.subscription)
                  Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          'claude setup-token',
                          style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13.5, color: c.ink),
                        ),
                      ),
                      const CopyButton('claude setup-token'),
                    ],
                  )
                else
                  OutlinedButton(onPressed: () => openLink(context, 'https://console.anthropic.com/settings/keys'), child: Text('${l.wsKeyOpen} ↗')),
              ],
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _token,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            style: const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 14),
            decoration: InputDecoration(labelText: l.wsToken, hintText: _kind == ClaudeConnectionInputKindEnum.subscription ? 'sk-ant-oat…' : 'sk-ant-api…'),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
          ),
          if (widget.error?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: HelpBox(widget.error!, tone: Tone.bad),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              FilledButton(onPressed: widget.busy || _token.text.trim().length < 10 ? null : _submit, child: Text(l.wsConnect)),
              const SizedBox(width: 8),
              TextButton(onPressed: () => setState(() => _editing = false), child: Text(l.formCancel)),
            ],
          ),
        ],
      ],
    );
  }
}

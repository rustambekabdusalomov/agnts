import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../repos/manage_widgets.dart';
import 'providers.dart';

/// States of the Plane projects linked to repositories, for the status mapping.
final _planeStatesProvider = FutureProvider.autoDispose<List<PlaneState>>((ref) async {
  return (await requireApi(ref).getIntegrationsApi().listPlaneStates()).data!;
});

/// One provider: connect it, or see the connection, test, sync, disconnect
/// and edit its settings (IntegrationPage).
class IntegrationScreen extends ConsumerStatefulWidget {
  const IntegrationScreen({super.key, required this.provider});
  final String provider;

  @override
  ConsumerState<IntegrationScreen> createState() => _IntegrationScreenState();
}

class _IntegrationScreenState extends ConsumerState<IntegrationScreen> {
  // Shown once, right after connecting Jira.
  ({String? url, String? secret})? _webhook;
  String _busy = '';

  String get _p => widget.provider;

  Future<void> _run(String what, Future<void> Function(IntegrationsApi api) f) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = what);
    try {
      await f(ref.read(apiProvider)!.getIntegrationsApi());
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = '');
    }
  }

  Future<void> _test() => _run('test', (api) async {
    final l = AppLocalizations.of(context);
    final v = (await api.testIntegration(provider: _p)).data!;
    ref.invalidate(integrationsProvider);
    final name = providerName(l, _p);
    if (mounted) showSnack(context, v.lastError != null ? l.integrationsTestFail(name, v.lastError!) : l.integrationsTestOk(name));
  });

  Future<void> _sync() => _run('sync', (api) async {
    final l = AppLocalizations.of(context);
    String msg;
    if (_p == 'plane') {
      final r = (await api.syncPlane()).data!;
      msg = l.integrationsPlaneSynced('${r.found}', '${r.created}');
    } else {
      final r = (await api.syncJira()).data!;
      msg = l.integrationsSynced('${r.found}', '${r.created}', '${r.updated ?? 0}', '${r.waiting ?? 0}');
    }
    ref.invalidate(ticketsProvider);
    ref.invalidate(dashboardProvider);
    if (mounted) showSnack(context, msg);
  });

  Future<void> _disconnect() async {
    final l = AppLocalizations.of(context);
    final name = providerName(l, _p);
    final ok = await confirmAction(
      context,
      title: l.integrationsDisconnect,
      message: l.integrationsDisconnectConfirm(name),
      confirmLabel: l.integrationsDisconnect,
      danger: true,
    );
    if (!ok || !mounted) return;
    await _run('disconnect', (api) async {
      await api.disconnectIntegration(provider: _p);
      ref.invalidate(integrationsProvider);
      if (mounted) {
        setState(() => _webhook = null);
        showSnack(context, l.integrationsDisconnected(name));
      }
    });
  }

  String _sideHelp(AppLocalizations l) => switch (_p) {
    'jira' => l.integrationsSecretsHelp,
    'plane' => l.integrationsPlaneHelp,
    'github' => l.integrationsGithubHelp,
    'gitlab' => l.integrationsGitlabHelp,
    'telegram' => l.integrationsTelegramHelp,
    'openai' => l.integrationsOpenaiHelp,
    _ => l.integrationsClaudeHelp,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final known = integrationProviders.contains(_p);
    final list = ref.watch(integrationsProvider);
    final name = providerName(l, _p);
    return Scaffold(
      appBar: DetailBar(backLabel: l.integrationsBack),
      body: !known
          ? EmptyState(title: l.commonError)
          : AsyncBody<List<Integration>>(
              value: list,
              onRefresh: () async {
                ref.invalidate(integrationsProvider);
                if (_p == 'plane') ref.invalidate(_planeStatesProvider);
              },
              builder: (all) {
                final i = all.where((x) => x.provider == _p).firstOrNull;
                final on = i?.connected ?? false;
                // Telegram delivers updates only to a public https address.
                final hook = _p == 'telegram' ? i?.webhookUrl : null;
                final insecure = hook != null && !hook.startsWith('https://') ? hook.replaceAll(RegExp(r'/webhooks/telegram$'), '') : '';
                return ListView(
                  padding: const EdgeInsets.only(bottom: 32),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
                      child: Row(
                        children: [
                          ProviderTile(_p, size: 44),
                          const SizedBox(width: 14),
                          Expanded(child: Text(name, style: Theme.of(context).textTheme.headlineSmall)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Text(
                        on
                            ? l.integrationsConnectedAs(
                                i!.account ?? name,
                                i.checkedAt == null ? l.integrationsNever : agoText(l, i.checkedAt!),
                              )
                            : l.integrationsNotYet,
                        style: TextStyle(fontSize: 14, color: c.ink3),
                      ),
                    ),
                    if (on)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (isTracker(_p)) OutlinedButton(onPressed: _busy.isEmpty ? _sync : null, child: Text(l.integrationsSyncNow)),
                            OutlinedButton(onPressed: _busy.isEmpty ? _test : null, child: Text(l.integrationsTest)),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(foregroundColor: c.badInk),
                              onPressed: _busy.isEmpty ? _disconnect : null,
                              child: Text(l.integrationsDisconnect),
                            ),
                          ],
                        ),
                      ),
                    if (_webhook != null)
                      padCard(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CardTitle(l.integrationsWebhookTitle, sub: l.integrationsWebhookSteps),
                            if (_webhook!.url != null) CopyLine(l.integrationsWebhookUrl, _webhook!.url!),
                            if (_webhook!.secret != null) CopyLine(l.integrationsWebhookSecret, _webhook!.secret!),
                            KvRow(l.integrationsEvents, l.integrationsEventsValue),
                            if (_webhook!.secret != null) ...[
                              const SizedBox(height: 8),
                              HelpBox(l.integrationsWebhookOnce, tone: Tone.warn),
                            ],
                          ],
                        ),
                      ),
                    if (insecure.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: HelpBox(l.integrationsTelegramHttps(insecure), tone: Tone.warn),
                      ),
                    if (!on)
                      padCard(
                        _ConnectForm(
                          provider: _p,
                          onConnected: (r) {
                            if (_p == 'jira') setState(() => _webhook = (url: r.integration.webhookUrl, secret: r.webhookSecret));
                          },
                        ),
                      )
                    else ...[
                      padCard(_Connection(i!)),
                      if (_p == 'jira') _TrackerSettings(integration: i),
                      if (_p == 'plane') ...[padCard(_PlaneWebhook(i)), _TrackerSettings(integration: i)],
                      if ((_p == 'github' || _p == 'gitlab') && i.webhookSecret != null)
                        padCard(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CardTitle(
                                l.integrationsWebhook,
                                sub: _p == 'github' ? l.integrationsGitWebhookSteps_github : l.integrationsGitWebhookSteps_gitlab,
                              ),
                              if (i.webhookUrl != null) CopyLine(l.integrationsWebhookUrl, i.webhookUrl!),
                              CopyLine(l.integrationsWebhookSecret, i.webhookSecret!),
                              KvRow(l.integrationsEvents, _p == 'github' ? l.integrationsGitEvents_github : l.integrationsGitEvents_gitlab),
                              const SizedBox(height: 6),
                              Text(l.integrationsGitWebhookWhy, style: TextStyle(fontSize: 13, color: c.ink3)),
                            ],
                          ),
                        ),
                      if (_p == 'jira')
                        padCard(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CardTitle(l.integrationsWebhook),
                              if (i.webhookUrl != null) CopyLine(l.integrationsWebhookUrl, i.webhookUrl!),
                              const SizedBox(height: 6),
                              Text(l.integrationsSyncHelp, style: TextStyle(fontSize: 13, color: c.ink3)),
                            ],
                          ),
                        ),
                      if (_p == 'plane')
                        padCard(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CardTitle(l.integrationsSync),
                              Text(l.integrationsPlaneSyncHelp, style: TextStyle(fontSize: 13, color: c.ink3)),
                            ],
                          ),
                        ),
                    ],
                    padCard(Text(providerDesc(l, _p), style: TextStyle(fontSize: 13.5, color: c.ink2))),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: HelpBox(_sideHelp(l))),
                  ],
                );
              },
            ),
    );
  }
}

/// What is saved for a connected provider (the web's Connection card).
class _Connection extends StatelessWidget {
  const _Connection(this.i);
  final Integration i;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = i.settings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CardTitle(l.integrationsConnection, trailing: ToneBadge(l.integrationsConnected, Tone.ok, small: true)),
        if ((s['site'] ?? '').isNotEmpty) KvRow(l.integrationsSite, s['site']!, mono: true),
        if ((s['url'] ?? '').isNotEmpty) KvRow(l.integrationsGitlabUrl, s['url']!, mono: true),
        if (i.provider == 'plane') ...[
          KvRow(l.integrationsPlaneBaseUrl, (s['base_url'] ?? '').isEmpty ? 'https://api.plane.so' : s['base_url']!, mono: true),
          if ((s['workspace'] ?? '').isNotEmpty) KvRow(l.integrationsPlaneWorkspace, s['workspace']!, mono: true),
        ],
        if (i.account != null) KvRow(l.integrationsAccount, i.account!),
        if (i.tokenHint != null) KvRow(l.integrationsToken, '•••• ${i.tokenHint}'),
        KvRow(l.integrationsLastChecked, i.checkedAt == null ? l.integrationsNever : agoText(l, i.checkedAt!)),
        if (i.lastError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: HelpBox('${l.integrationsLastError}: ${i.lastError}', tone: Tone.bad, copyable: true),
          ),
      ],
    );
  }
}

// ---- Connect ----

String _connectSub(AppLocalizations l, String p) => switch (p) {
  'jira' => l.integrationsConnectSub_jira,
  'plane' => l.integrationsConnectSub_plane,
  'github' => l.integrationsConnectSub_github,
  'gitlab' => l.integrationsConnectSub_gitlab,
  'telegram' => l.integrationsConnectSub_telegram,
  'openai' => l.integrationsConnectSub_openai,
  _ => l.integrationsConnectSub_claude,
};

String _tokenOpen(AppLocalizations l, String p) => switch (p) {
  'jira' => l.integrationsTokenOpen_jira,
  'plane' => l.integrationsTokenOpen_plane,
  'github' => l.integrationsTokenOpen_github,
  'gitlab' => l.integrationsTokenOpen_gitlab,
  'telegram' => l.integrationsTokenOpen_telegram,
  'openai' => l.integrationsTokenOpen_openai,
  _ => '',
};

List<String> _tokenSteps(AppLocalizations l, String p) => switch (p) {
  'jira' => [l.integrationsTokenStep1_jira, l.integrationsTokenStep2_jira, l.integrationsTokenStep3_jira, l.integrationsTokenStep4_jira],
  'plane' => [
    l.integrationsTokenStep1_plane,
    l.integrationsTokenStep2_plane,
    l.integrationsTokenStep3_plane,
    l.integrationsTokenStep4_plane,
  ],
  'github' => [
    l.integrationsTokenStep1_github,
    l.integrationsTokenStep2_github,
    l.integrationsTokenStep3_github,
    l.integrationsTokenStep4_github,
  ],
  'gitlab' => [
    l.integrationsTokenStep1_gitlab,
    l.integrationsTokenStep2_gitlab,
    l.integrationsTokenStep3_gitlab,
    l.integrationsTokenStep4_gitlab,
  ],
  'telegram' => [
    l.integrationsTokenStep1_telegram,
    l.integrationsTokenStep2_telegram,
    l.integrationsTokenStep3_telegram,
    l.integrationsTokenStep4_telegram,
  ],
  'openai' => [
    l.integrationsTokenStep1_openai,
    l.integrationsTokenStep2_openai,
    l.integrationsTokenStep3_openai,
    l.integrationsTokenStep4_openai,
  ],
  _ => [l.integrationsTokenStep1_claude, l.integrationsTokenStep2_claude, l.integrationsTokenStep3_claude, l.integrationsTokenStep4_claude],
};

/// Connect a provider: the token (and Jira's site and email, or Plane's
/// address and workspace) is checked by the server before it is saved.
class _ConnectForm extends ConsumerStatefulWidget {
  const _ConnectForm({required this.provider, required this.onConnected});
  final String provider;
  final ValueChanged<ConnectResult> onConnected;

  @override
  ConsumerState<_ConnectForm> createState() => _ConnectFormState();
}

class _ConnectFormState extends ConsumerState<_ConnectForm> {
  final _site = TextEditingController();
  final _email = TextEditingController();
  final _token = TextEditingController();
  final _chatId = TextEditingController();
  final _url = TextEditingController(text: 'https://gitlab.com');
  final _planeUrl = TextEditingController(text: 'https://api.plane.so');
  final _workspace = TextEditingController();
  String _error = '';
  bool _busy = false;

  String get _p => widget.provider;

  @override
  void dispose() {
    for (final c in [_site, _email, _token, _chatId, _url, _planeUrl, _workspace]) {
      c.dispose();
    }
    super.dispose();
  }

  String _trim(TextEditingController c) => c.text.trim().replaceAll(RegExp(r'/+$'), '');

  Future<void> _connect() async {
    final l = AppLocalizations.of(context);
    final settings = switch (_p) {
      'jira' => {'site': _trim(_site), 'email': _email.text.trim()},
      'telegram' => {'chat_id': _chatId.text.trim()},
      'gitlab' => {'url': _trim(_url)},
      'plane' => {'base_url': _trim(_planeUrl), 'workspace': _workspace.text.trim().toLowerCase()},
      _ => <String, String>{},
    };
    if (_token.text.trim().length < 8 || settings.values.any((v) => v.isEmpty)) {
      setState(() => _error = l.mmanageFillAll);
      return;
    }
    setState(() {
      _busy = true;
      _error = '';
    });
    try {
      final r =
          (await ref
                  .read(apiProvider)!
                  .getIntegrationsApi()
                  .connectIntegration(
                    provider: _p,
                    connectIntegrationRequest: ConnectIntegrationRequest(token: _token.text.trim(), settings: settings),
                  ))
              .data!;
      ref.invalidate(integrationsProvider);
      _token.clear();
      if (!mounted) return;
      showSnack(context, l.integrationsConnectedToast(providerName(l, _p)));
      widget.onConnected(r);
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final name = providerName(l, _p);
    final link = tokenPage(_p, gitlabUrl: _url.text);
    final tokenLabel = _p == 'jira'
        ? l.integrationsApiToken
        : _p == 'plane' || _p == 'openai'
        ? l.integrationsApiKey
        : l.integrationsAccessToken;
    final tokenHelp = _p == 'jira'
        ? l.integrationsApiTokenHelp
        : _p == 'plane'
        ? l.integrationsApiKeyHelp
        : _p == 'openai'
        ? l.integrationsOpenaiKeyHelp
        : l.integrationsTokenHelp;
    final tokenHint = switch (_p) {
      'plane' => 'plane_api_…',
      'github' => 'github_pat_…',
      'gitlab' => 'glpat-…',
      'telegram' => '123456:ABC…',
      'openai' => 'sk-…',
      _ => null,
    };
    final steps = _tokenSteps(l, _p);
    Widget perm(String name, String help, String need) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              name,
              style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13, color: c.ink),
            ),
          ),
          Expanded(
            child: Text(help, style: TextStyle(fontSize: 13, color: c.ink3)),
          ),
          const SizedBox(width: 6),
          Text(need, style: TextStyle(fontSize: 12, color: c.ink3)),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CardTitle(l.integrationsConnectTitle(name), sub: _connectSub(l, _p)),
        HelpBox(
          l.integrationsTokenHow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (n, s) in steps.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('${n + 1}. $s', style: TextStyle(fontSize: 13.5, color: c.primaryInk)),
                ),
              if (link != null) CopyLine(_tokenOpen(l, _p), link),
              if (_p == 'telegram' && telegramTokenLooksValid(_token.text))
                CopyLine(l.integrationsChatIdFind, 'https://api.telegram.org/bot${_token.text.trim()}/getUpdates'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_p == 'jira') ...[
          ManageField(
            label: l.integrationsSite,
            help: l.integrationsSiteHelp,
            child: ManageInput(controller: _site, mono: true, hint: 'https://your-team.atlassian.net', keyboardType: TextInputType.url),
          ),
          ManageField(
            label: l.integrationsEmail,
            child: ManageInput(controller: _email, keyboardType: TextInputType.emailAddress),
          ),
        ],
        if (_p == 'plane') ...[
          ManageField(
            label: l.integrationsPlaneBaseUrl,
            help: l.integrationsPlaneBaseUrlHelp,
            child: ManageInput(controller: _planeUrl, mono: true, keyboardType: TextInputType.url),
          ),
          ManageField(
            label: l.integrationsPlaneWorkspace,
            help: l.integrationsPlaneWorkspaceHelp,
            child: ManageInput(controller: _workspace, mono: true, hint: 'acme'),
          ),
        ],
        if (_p == 'gitlab')
          ManageField(
            label: l.integrationsGitlabUrl,
            help: l.integrationsGitlabUrlHelp,
            child: ManageInput(controller: _url, mono: true, keyboardType: TextInputType.url, onChanged: (_) => setState(() {})),
          ),
        ManageField(
          label: tokenLabel,
          help: tokenHelp,
          child: ManageInput(controller: _token, mono: true, obscure: true, hint: tokenHint, onChanged: (_) => setState(() {})),
        ),
        if (_p == 'telegram')
          ManageField(
            label: l.integrationsChatId,
            help: l.integrationsChatIdHelp,
            child: ManageInput(controller: _chatId, mono: true, keyboardType: const TextInputType.numberWithOptions(signed: true)),
          ),
        if (_p == 'github') ...[
          CardTitle(l.integrationsScopes),
          perm('Contents', l.integrationsPermContents, l.integrationsRequired),
          perm('Pull requests', l.integrationsPermPulls, l.integrationsRequired),
          perm('Workflows', l.integrationsPermWorkflows, l.integrationsRecommended),
          perm('Metadata', l.integrationsPermMetadata, l.integrationsRequired),
          perm('Actions', l.integrationsPermActions, l.integrationsRecommended),
          perm('Deployments', l.integrationsPermDeployments, l.integrationsRecommended),
          const SizedBox(height: 10),
        ],
        if (_p == 'gitlab') ...[
          CardTitle(l.integrationsScopes),
          perm('api', l.integrationsGlApi, l.integrationsRequired),
          perm('read_repository', l.integrationsGlRead, l.integrationsRequired),
          perm('write_repository', l.integrationsGlWrite, l.integrationsRequired),
          const SizedBox(height: 10),
        ],
        if (_error.isNotEmpty) ErrorLine(_error),
        FilledButton(onPressed: _busy ? null : _connect, child: Text(_busy ? l.integrationsConnecting : l.integrationsConnectTitle(name))),
      ],
    );
  }
}

// ---- Jira and Plane settings ----

const _statusKeys = ['status_started', 'status_in_review', 'status_rejected', 'status_merged'];
// The state group Plane falls back to when nothing is picked.
const _planeGroups = {'status_started': 'started', 'status_in_review': '', 'status_rejected': 'cancelled', 'status_merged': 'completed'};
const _commentKeys = ['comment_questions', 'comment_plan', 'comment_pr', 'comment_summary', 'comment_status'];

/// Editable Jira or Plane settings: pickup label, status mapping and comment
/// kinds, with a save bar while there are changes.
class _TrackerSettings extends ConsumerStatefulWidget {
  const _TrackerSettings({required this.integration});
  final Integration integration;

  @override
  ConsumerState<_TrackerSettings> createState() => _TrackerSettingsState();
}

class _TrackerSettingsState extends ConsumerState<_TrackerSettings> {
  late Map<String, String> _saved = Map.of(widget.integration.settings);
  late Map<String, String> _draft = Map.of(_saved);
  final _ctl = <String, TextEditingController>{};
  String _error = '';
  bool _busy = false;

  bool get _plane => widget.integration.provider == 'plane';

  @override
  void didUpdateWidget(covariant _TrackerSettings old) {
    super.didUpdateWidget(old);
    // Take new values from the server unless there are edits against the old ones.
    final fresh = widget.integration.settings;
    if (jsonEncode(fresh) != jsonEncode(_saved) && jsonEncode(_draft) == jsonEncode(_saved)) {
      _saved = Map.of(fresh);
      _reset();
    }
  }

  @override
  void dispose() {
    for (final c in _ctl.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _c(String key) => _ctl.putIfAbsent(key, () => TextEditingController(text: _draft[key] ?? ''));

  void _set(String key, String v) => setState(() => _draft = {..._draft, key: v});

  void _reset() {
    _draft = Map.of(_saved);
    for (final e in _ctl.entries) {
      e.value.text = _draft[e.key] ?? '';
    }
    _error = '';
  }

  bool get _dirty => jsonEncode(_draft) != jsonEncode(_saved);

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final v =
          (await ref
                  .read(apiProvider)!
                  .getIntegrationsApi()
                  .updateIntegration(
                    provider: widget.integration.provider,
                    updateIntegrationRequest: UpdateIntegrationRequest(settings: _draft),
                  ))
              .data!;
      ref.invalidate(integrationsProvider);
      if (_plane) ref.invalidate(_planeStatesProvider);
      if (!mounted) return;
      setState(() {
        _saved = Map.of(v.settings);
        _reset();
      });
      showSnack(context, l.integrationsSaved(_plane ? 'Plane' : 'Jira'));
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _statusLabel(AppLocalizations l, String k) => switch (k) {
    'status_started' => l.integrationsMapStarted,
    'status_in_review' => l.integrationsMapReview,
    'status_rejected' => l.integrationsMapRejected,
    _ => l.integrationsMapMerged,
  };

  (String, String?) _commentLabel(AppLocalizations l, String k) => switch (k) {
    'comment_questions' => (l.integrationsCQuestions, l.integrationsCQuestionsHelp),
    'comment_plan' => (l.integrationsCPlan, null),
    'comment_pr' => (l.integrationsCPr, null),
    'comment_summary' => (l.integrationsCSummary, null),
    _ => (l.integrationsCStatus, null),
  };

  String _kindLabel(AppLocalizations l, String k) => switch (k) {
    'code' => '${l.kindCode}. ${l.kindCodeHint}',
    'test' => '${l.kindTest}. ${l.kindTestHint}',
    'plan' => '${l.kindPlan}. ${l.kindPlanHint}',
    'analysis' => '${l.kindAnalysis}. ${l.kindAnalysisHint}',
    _ => '${l.kindBug}. ${l.kindBugHint}',
  };

  Widget _planeStatus(AppLocalizations l, String key) {
    final group = _planeGroups[key]!;
    final none = group.isEmpty ? l.integrationsPlaneStateNone : l.integrationsPlaneStateDefault(group);
    final states = ref.watch(_planeStatesProvider);
    if (states.hasError) return ManageInput(controller: _c(key), hint: none, onChanged: (v) => _set(key, v));
    final cur = _draft[key] ?? '';
    final names = [for (final s in states.value ?? const <PlaneState>[]) s.name];
    final options = <(String, String)>[
      ('', none),
      for (final s in states.value ?? const <PlaneState>[]) (s.name, '${s.name} · ${s.group.value}'),
      if (cur.isNotEmpty && !names.contains(cur)) (cur, cur),
    ];
    return DropdownButtonFormField<String>(
      initialValue: cur,
      isExpanded: true,
      items: [
        for (final (v, t) in options)
          DropdownMenuItem(
            value: v,
            child: Text(t, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: states.isLoading ? null : (v) => _set(key, v ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final label = (_draft['label'] ?? '').isEmpty ? 'agnts' : _draft['label']!;
    final assignedOnly = _draft['assigned_only'] != 'false';
    final states = _plane ? ref.watch(_planeStatesProvider) : null;
    final notes = _plane
        ? [l.integrationsPlaneLabelsCreate, l.integrationsPlaneLabelsRepo, l.integrationsLabelsMany, l.integrationsPlaneLabelsLater]
        : [l.integrationsLabelsRepo, l.integrationsLabelsMany, l.integrationsLabelsLater];
    final hint = TextStyle(fontSize: 13, color: c.ink3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        padCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardTitle(l.integrationsPickup, sub: l.integrationsPickupSub),
              ManageField(
                label: l.integrationsLabel,
                help: l.integrationsLabelHelp,
                child: ManageInput(controller: _c('label'), mono: true, hint: 'agnts', onChanged: (v) => _set('label', v)),
              ),
              if (!_plane) ...[
                SwitchLine(
                  title: l.integrationsAssignedOnly,
                  help: l.integrationsAssignedOnlyHelp(widget.integration.settings['email'] ?? 'Jira'),
                  value: assignedOnly,
                  onChanged: (v) => _set('assigned_only', v ? 'true' : 'false'),
                ),
                const SizedBox(height: 8),
                Text(
                  l.integrationsQuery,
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink2),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: c.hover, borderRadius: BorderRadius.circular(10)),
                  child: SelectableText(
                    jiraQuery(label, assignedOnly: assignedOnly),
                    style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink),
                  ),
                ),
                const SizedBox(height: 14),
                ManageField(
                  label: l.followUpsJiraIssueType,
                  help: l.followUpsJiraIssueTypeHelp,
                  child: ManageInput(controller: _c('issue_type'), hint: 'Task', onChanged: (v) => _set('issue_type', v)),
                ),
              ] else ...[
                Text(
                  l.integrationsQuery,
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink2),
                ),
                const SizedBox(height: 4),
                Text(l.integrationsPlaneQueryText(trackerLabels(label).join(', ')), style: hint),
                if (states?.value?.isEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(l.integrationsPlaneNoProjects, style: hint),
                  ),
              ],
            ],
          ),
        ),
        // How to label tickets
        padCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardTitle(l.integrationsLabelsTitle, sub: _plane ? l.integrationsPlaneLabelsSub : l.integrationsLabelsSub),
              _LabelRow(label, l.kindAutoHint),
              for (final k in trackerKinds) _LabelRow('$label-$k', _kindLabel(l, k)),
              const SizedBox(height: 8),
              for (final n in notes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $n', style: hint),
                ),
            ],
          ),
        ),
        padCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardTitle(l.integrationsStatuses, sub: _plane ? l.integrationsPlaneStatusesSub : l.integrationsStatusesSub),
              if (states?.error != null) ErrorLine(l.integrationsPlaneStatesError(errorMessage(states!.error!, l.commonError))),
              for (final k in _statusKeys)
                ManageField(
                  label: _statusLabel(l, k),
                  child: _plane
                      ? _planeStatus(l, k)
                      : ManageInput(controller: _c(k), hint: l.integrationsKeepStatus, onChanged: (v) => _set(k, v)),
                ),
            ],
          ),
        ),
        padCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardTitle(l.integrationsComments, sub: l.integrationsCommentsSub),
              for (final k in _commentKeys)
                SwitchLine(
                  title: _commentLabel(l, k).$1,
                  help: _commentLabel(l, k).$2,
                  value: _draft[k] != 'false',
                  onChanged: (v) => _set(k, v ? 'true' : 'false'),
                ),
            ],
          ),
        ),
        if (_dirty || _error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: HCard(
              color: c.help,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error.isNotEmpty) ErrorLine(_error),
                  Text(
                    l.formUnsaved,
                    style: TextStyle(fontWeight: FontWeight.w700, color: c.primaryInk),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(onPressed: _busy ? null : () => setState(_reset), child: Text(l.formDiscard)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(onPressed: _busy ? null : _save, child: Text(_busy ? l.formSaving : l.formSave)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _LabelRow extends StatelessWidget {
  const _LabelRow(this.label, this.text);
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13, fontWeight: FontWeight.w700, color: c.ink),
          ),
          Text(text, style: TextStyle(fontSize: 13, color: c.ink3)),
        ],
      ),
    );
  }
}

/// Plane makes the webhook secret, unlike Jira: the URL goes into Plane, and
/// the secret Plane shows comes back here.
class _PlaneWebhook extends ConsumerStatefulWidget {
  const _PlaneWebhook(this.i);
  final Integration i;

  @override
  ConsumerState<_PlaneWebhook> createState() => _PlaneWebhookState();
}

class _PlaneWebhookState extends ConsumerState<_PlaneWebhook> {
  final _secret = TextEditingController();
  late bool _editing = !(widget.i.webhookSecretSet ?? false);
  String _error = '';
  bool _busy = false;

  @override
  void dispose() {
    _secret.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (_secret.text.trim().length < 8) {
      setState(() => _error = l.mmanageFillAll);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(apiProvider)!
          .getIntegrationsApi()
          .setPlaneWebhookSecret(setPlaneWebhookSecretRequest: SetPlaneWebhookSecretRequest(secret: _secret.text.trim()));
      ref.invalidate(integrationsProvider);
      if (!mounted) return;
      setState(() {
        _secret.clear();
        _error = '';
        _editing = false;
      });
      showSnack(context, l.integrationsPlaneSecretSaved);
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final set = widget.i.webhookSecretSet ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CardTitle(
          l.integrationsPlaneWebhookTitle,
          sub: l.integrationsPlaneWebhookSteps,
          trailing: set ? ToneBadge(l.integrationsConnected, Tone.ok, small: true) : null,
        ),
        if (widget.i.webhookUrl != null) CopyLine(l.integrationsWebhookUrl, widget.i.webhookUrl!),
        KvRow(l.integrationsEvents, l.integrationsPlaneEventsValue),
        const SizedBox(height: 8),
        if (_editing) ...[
          ManageField(
            label: l.integrationsPlaneSecret,
            help: l.integrationsPlaneSecretHelp,
            child: ManageInput(controller: _secret, mono: true, obscure: true),
          ),
          if (_error.isNotEmpty) ErrorLine(_error),
          FilledButton(onPressed: _busy ? null : _save, child: Text(l.integrationsPlaneSecretSave)),
        ] else
          Row(
            children: [
              Expanded(
                child: Text(l.integrationsPlaneSecretSet, style: TextStyle(fontSize: 13, color: c.ink3)),
              ),
              OutlinedButton(onPressed: () => setState(() => _editing = true), child: Text(l.integrationsPlaneSecretReplace)),
            ],
          ),
        if (!set) ...[const SizedBox(height: 10), HelpBox(l.integrationsPlaneSecretMissing, tone: Tone.warn)],
      ],
    );
  }
}

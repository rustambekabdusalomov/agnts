import 'dart:async';

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
import 'network_editor.dart';
import 'network_logic.dart';

final networksProvider = FutureProvider.autoDispose<PrivateNetworkList>((ref) async {
  return (await requireApi(ref).getNetworkApi().listPrivateNetworks()).data!;
});

/// Recent connections through the networks; null is every network.
final networkActivityProvider = FutureProvider.autoDispose.family<NetworkActivity, int?>((ref, network) async {
  return (await requireApi(ref).getNetworkApi().getNetworkActivity(network: network)).data!;
});

Tone networkTone(PrivateNetworkStatusEnum s) => switch (s) {
  PrivateNetworkStatusEnum.up => Tone.ok,
  PrivateNetworkStatusEnum.connecting => Tone.warn,
  PrivateNetworkStatusEnum.error || PrivateNetworkStatusEnum.gatewayDown => Tone.bad,
  PrivateNetworkStatusEnum.disabled => Tone.gray,
};

String networkStatusLabel(AppLocalizations l, PrivateNetworkStatusEnum s) => switch (s) {
  PrivateNetworkStatusEnum.up => l.networkStatus_up,
  PrivateNetworkStatusEnum.connecting => l.networkStatus_connecting,
  PrivateNetworkStatusEnum.error => l.networkStatus_error,
  PrivateNetworkStatusEnum.gatewayDown => l.networkStatus_gateway_down,
  PrivateNetworkStatusEnum.disabled => l.networkStatus_disabled,
};

/// Runs one network action, refreshes the list and says how it went.
/// Settings and the Home header's sheet both use it; true when it worked.
Future<bool> runNetworkAction(BuildContext context, WidgetRef ref, Future<void> Function(NetworkApi api) f, String done) async {
  final l = AppLocalizations.of(context);
  try {
    await f(ref.read(apiProvider)!.getNetworkApi());
    ref.invalidate(networksProvider);
    if (context.mounted) showSnack(context, done);
    return true;
  } catch (e) {
    if (context.mounted) showSnack(context, errorMessage(e, l.commonError));
    return false;
  }
}

/// Connects a network that is off; asks before disconnecting one that is on.
Future<bool> toggleNetwork(BuildContext context, WidgetRef ref, PrivateNetwork n) async {
  final l = AppLocalizations.of(context);
  if (!n.enabled) return runNetworkAction(context, ref, (api) => api.connectPrivateNetwork(networkId: n.id), l.networkConnecting);
  final ok = await confirmAction(
    context,
    title: l.networkDisconnect,
    message: l.networkDisconnectConfirm(n.name),
    confirmLabel: l.networkDisconnect,
    danger: true,
  );
  if (!ok || !context.mounted) return false;
  return runNetworkAction(context, ref, (api) => api.disconnectPrivateNetwork(networkId: n.id), l.networkDisconnected);
}

/// The workspace's private networks: tunnels into the team's own networks
/// (WireGuard, OpenVPN or agnts-link), each with its routes, plus a
/// connection test and recent activity (PrivateNetworksCard).
class NetworksScreen extends ConsumerStatefulWidget {
  const NetworksScreen({super.key, this.add = false});

  /// Opens the add form straight away (the Home header's "Add network").
  final bool add;

  @override
  ConsumerState<NetworksScreen> createState() => _NetworksScreenState();
}

class _NetworksScreenState extends ConsumerState<NetworksScreen> {
  Timer? _poll;
  bool _busy = false;
  final _target = TextEditingController();
  int? _testNetwork;
  NetworkTest? _result;
  bool _testing = false;
  int? _activityFilter;
  bool _showActivity = false;

  @override
  void initState() {
    super.initState();
    // Status changes on the server side (handshakes, reconnects): keep it fresh.
    _poll = Timer.periodic(const Duration(seconds: 15), (_) => ref.invalidate(networksProvider));
    if (widget.add) WidgetsBinding.instance.addPostFrameCallback((_) => _openAdd());
  }

  Future<void> _openAdd() async {
    final PrivateNetworkList list;
    try {
      list = await ref.read(networksProvider.future);
    } catch (_) {
      return;
    }
    final owner = ref.read(currentWorkspaceProvider)?.role == WorkspaceRole.owner;
    if (mounted && owner && list.available && list.networks.length < list.max) _edit(list, null);
  }

  @override
  void dispose() {
    _poll?.cancel();
    _target.dispose();
    super.dispose();
  }

  Future<void> _act(Future<bool> Function() f) async {
    setState(() => _busy = true);
    final ok = await f();
    if (mounted) {
      setState(() {
        _busy = false;
        if (ok) _result = null;
      });
    }
  }

  Future<void> _run(Future<void> Function(NetworkApi api) f, String done) => _act(() => runNetworkAction(context, ref, f, done));

  Future<void> _remove(PrivateNetwork n) async {
    final l = AppLocalizations.of(context);
    if (!await confirmAction(
      context,
      title: l.networkRemove,
      message: l.networkRemoveConfirm(n.name),
      confirmLabel: l.networkRemove,
      danger: true,
    )) {
      return;
    }
    await _run((api) => api.deletePrivateNetwork(networkId: n.id), l.networkRemoved);
  }

  Future<void> _toggle(PrivateNetwork n) => _act(() => toggleNetwork(context, ref, n));

  Future<void> _test() async {
    final l = AppLocalizations.of(context);
    if (_target.text.trim().isEmpty) return;
    setState(() => _testing = true);
    try {
      final r =
          (await ref
                  .read(apiProvider)!
                  .getNetworkApi()
                  .testPrivateNetwork(
                    testPrivateNetworkRequest: TestPrivateNetworkRequest(target: _target.text.trim(), network: _testNetwork),
                  ))
              .data!;
      ref.invalidate(networkActivityProvider);
      if (mounted) setState(() => _result = r);
    } catch (e) {
      if (mounted) setState(() => _result = NetworkTest(ok: false, error: errorMessage(e, l.commonError)));
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  void _edit(PrivateNetworkList list, PrivateNetwork? n) =>
      showManageSheet<void>(context, NetworkEditor(network: n, linkUrl: list.linkUrl));

  String _ago(AppLocalizations l, DateTime at) {
    final s = DateTime.now().difference(at).inSeconds.clamp(0, 1 << 31);
    return s < 90
        ? l.networkSecondsAgo('$s')
        : s < 5400
        ? l.networkMinutesAgo('${(s / 60).round()}')
        : l.networkHoursAgo('${(s / 3600).round()}');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final owner = ref.watch(currentWorkspaceProvider)?.role == WorkspaceRole.owner;
    final value = ref.watch(networksProvider);
    return Scaffold(
      appBar: DetailBar(backLabel: l.mobileMore),
      body: AsyncBody<PrivateNetworkList>(
        value: value,
        onRefresh: () async {
          ref.invalidate(networksProvider);
          ref.invalidate(networkActivityProvider);
        },
        builder: (list) {
          final nets = list.networks;
          final atMax = nets.length >= list.max;
          final hint = TextStyle(fontSize: 13, color: c.ink3);
          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              PageHeader(title: l.networkTitle, sub: l.networkSub, long: true),
              if (!list.available)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: HelpBox(l.networkUnavailable, tone: Tone.warn),
                )
              else ...[
                if (owner)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: FilledButton.icon(
                      onPressed: atMax ? null : () => _edit(list, null),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(atMax ? l.networkLimit('${list.max}') : l.networkAdd),
                    ),
                  ),
                if (nets.isEmpty) EmptyState(title: l.networkEmpty),
                for (final n in nets)
                  padCard(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    n.name,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.ink),
                                  ),
                                  Text(kindName(n.kind), style: hint),
                                ],
                              ),
                            ),
                            ToneBadge(networkStatusLabel(l, n.status), networkTone(n.status), small: true),
                          ],
                        ),
                        if (n.routes.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              routeText(n.routes),
                              style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink2),
                            ),
                          ),
                        if (n.lastError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: HelpBox(n.lastError!, tone: Tone.bad, copyable: true),
                          ),
                        const SizedBox(height: 6),
                        for (final m in [
                          if (n.summary != null) n.summary!,
                          if (n.handshakeAt != null)
                            '${n.kind == PrivateNetworkKindEnum.wireguard ? l.networkHandshake : l.networkHeartbeat}: ${_ago(l, n.handshakeAt!)}',
                          if (n.detail != null) n.detail!,
                          n.webhooks == PrivateNetworkWebhooksEnum.relay
                              ? l.networkWebhooksRelay
                              : l.networkWebhooksPolling('${n.pollMinutes}'),
                          if (n.ca != null) l.networkCaShort(n.ca!.subjects.join(', ')),
                        ])
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(m, style: hint),
                          ),
                        if (owner) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (n.enabled)
                                OutlinedButton(
                                  onPressed: _busy
                                      ? null
                                      : () => _run((api) => api.reconnectPrivateNetwork(networkId: n.id), l.networkReconnecting),
                                  child: Text(l.networkReconnect),
                                ),
                              OutlinedButton(
                                onPressed: _busy ? null : () => _toggle(n),
                                child: Text(n.enabled ? l.networkDisconnect : l.networkConnect),
                              ),
                              OutlinedButton(onPressed: () => _edit(list, n), child: Text(l.networkEdit)),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(foregroundColor: c.badInk),
                                onPressed: _busy ? null : () => _remove(n),
                                child: Text(l.networkRemove),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                if (nets.isNotEmpty && owner)
                  padCard(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CardTitle(l.networkTest, sub: l.networkTestHelp),
                        ManageInput(controller: _target, mono: true, hint: 'gitlab.corp.local:443', keyboardType: TextInputType.url),
                        const SizedBox(height: 10),
                        ManageField(
                          label: l.networkTestThrough,
                          child: DropdownButtonFormField<int?>(
                            initialValue: _testNetwork,
                            isExpanded: true,
                            items: [
                              DropdownMenuItem(value: null, child: Text(l.networkTestAuto)),
                              for (final n in nets.where((n) => n.enabled)) DropdownMenuItem(value: n.id, child: Text(n.name)),
                            ],
                            onChanged: (v) => setState(() => _testNetwork = v),
                          ),
                        ),
                        FilledButton(onPressed: _testing ? null : _test, child: Text(_testing ? l.networkTesting : l.networkTestRun)),
                        if (_result != null) Padding(padding: const EdgeInsets.only(top: 10), child: _TestResult(_result!)),
                      ],
                    ),
                  ),
                if (nets.isNotEmpty) _activity(l, c, nets),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _activity(AppLocalizations l, Agnts c, List<PrivateNetwork> nets) {
    final a = ref.watch(networkActivityProvider(_activityFilter)).value;
    String nameOf(int? id) => id == null ? '—' : nets.where((n) => n.id == id).firstOrNull?.name ?? l.networkGone;
    return padCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardTitle(l.networkActivity),
          ManageField(
            label: l.networkActivityNetwork,
            child: DropdownButtonFormField<int?>(
              initialValue: _activityFilter,
              isExpanded: true,
              items: [
                DropdownMenuItem(value: null, child: Text(l.networkActivityAll)),
                for (final n in nets) DropdownMenuItem(value: n.id, child: Text(n.name)),
              ],
              onChanged: (v) => setState(() => _activityFilter = v),
            ),
          ),
          if (a == null)
            const LinearProgressIndicator()
          else ...[
            Text(l.networkActivityCounts('${a.today}', '${a.refused}'), style: TextStyle(fontSize: 14, color: c.ink2)),
            if (a.dials.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() => _showActivity = !_showActivity),
                  child: Text(_showActivity ? l.networkActivityHide : l.networkActivityShow),
                ),
              ),
            if (_showActivity)
              for (final d in a.dials.take(100))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.target,
                              style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink),
                            ),
                            Text(
                              [
                                TimeOfDay.fromDateTime(d.at.toLocal()).format(context),
                                nameOf(d.network),
                                d.ticket ?? d.source_,
                              ].join(' · '),
                              style: TextStyle(fontSize: 12, color: c.ink3),
                            ),
                          ],
                        ),
                      ),
                      ToneBadge(
                        d.ok ? '${byteText(d.bytesIn)} / ${byteText(d.bytesOut)}' : l.networkRefused,
                        d.ok ? Tone.ok : Tone.bad,
                        small: true,
                      ),
                    ],
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _TestResult extends StatelessWidget {
  const _TestResult(this.r);
  final NetworkTest r;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final good = r.ok && (r.tls == null || r.tls!.verified);
    if (!r.ok) return HelpBox(r.error ?? l.commonError, tone: Tone.bad, copyable: true);
    final tls = r.tls == null
        ? ''
        : '\n${r.tls!.verified ? l.networkTlsOk(r.tls!.subject ?? '', r.tls!.issuer ?? '') : l.networkTlsBad(r.tls!.error ?? '')}';
    return HelpBox(
      '${l.networkTestOk(r.network?.name ?? '', r.via ?? '', r.resolved ?? '—', '${r.connectMs ?? 0}')}$tls',
      tone: good ? Tone.ok : Tone.bad,
    );
  }
}

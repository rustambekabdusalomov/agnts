import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';
import 'network_logic.dart';
import 'networks_screen.dart';

/// The Home header's private networks button (the admin panel's top-bar
/// menu): a dot for the connected networks' state, and a sheet to connect,
/// disconnect or reconnect them without going to Settings. Hidden when the
/// server has no gateway.
class NetworkButton extends ConsumerWidget {
  const NetworkButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final list = ref.watch(networksProvider).value;
    if (list == null || !list.available) return const SizedBox.shrink();
    final dot = _worst(list.networks);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        RoundIconButton('network', tooltip: l.networkTitle, onTap: () => _open(context, ref)),
        if (dot != null)
          Positioned(
            top: 3,
            right: 3,
            child: IgnorePointer(
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: switch (dot) {
                    Tone.bad => c.bad,
                    Tone.warn => c.warn,
                    _ => c.ok,
                  },
                  shape: BoxShape.circle,
                  border: Border.all(color: c.surface, width: 2),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// The worst state among the connected networks; null when none is on.
  static Tone? _worst(List<PrivateNetwork> nets) {
    final on = nets.where((n) => n.enabled).map((n) => networkTone(n.status)).toList();
    if (on.isEmpty) return null;
    if (on.contains(Tone.bad)) return Tone.bad;
    if (on.contains(Tone.warn)) return Tone.warn;
    return Tone.ok;
  }

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
      builder: (_) => const _NetworkSheet(),
    );
    ref.invalidate(networksProvider);
  }
}

class _NetworkSheet extends ConsumerStatefulWidget {
  const _NetworkSheet();

  @override
  ConsumerState<_NetworkSheet> createState() => _NetworkSheetState();
}

class _NetworkSheetState extends ConsumerState<_NetworkSheet> {
  Timer? _poll;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // A tunnel comes up within seconds: keep the statuses fresh while open.
    _poll = Timer.periodic(const Duration(seconds: 10), (_) => ref.invalidate(networksProvider));
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _act(Future<bool> Function() f) async {
    setState(() => _busy = true);
    await f();
    if (mounted) setState(() => _busy = false);
  }

  /// Closes the sheet and opens Settings → Private networks.
  void _settings({bool add = false}) {
    final router = GoRouter.of(context);
    Navigator.pop(context);
    router.push(add ? '/networks?add=1' : '/networks');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final owner = ref.watch(currentWorkspaceProvider)?.role == WorkspaceRole.owner;
    final list = ref.watch(networksProvider).value;
    final nets = list?.networks ?? const <PrivateNetwork>[];
    final atMax = list != null && nets.length >= list.max;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Row(
              children: [
                Expanded(child: Text(l.networkTitle, style: Theme.of(context).textTheme.titleLarge)),
                TextButton(onPressed: _settings, child: Text(l.networkManage)),
                const SizedBox(width: 4),
                RoundIconButton('close', tooltip: l.navClose, onTap: () => Navigator.pop(context)),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                if (list == null)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (nets.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Text(l.networkEmpty, style: TextStyle(color: c.ink3, fontSize: 14)),
                  ),
                for (final n in nets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: HCard(
                      child: Column(
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
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(kindName(n.kind), style: TextStyle(fontSize: 13, color: c.ink3)),
                                  ],
                                ),
                              ),
                              ToneBadge(networkStatusLabel(l, n.status), networkTone(n.status), small: true),
                            ],
                          ),
                          if (n.lastError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                n.lastError!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13, color: c.badInk),
                              ),
                            ),
                          if (owner) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                if (n.enabled) ...[
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _busy
                                          ? null
                                          : () => _act(
                                              () => runNetworkAction(
                                                context,
                                                ref,
                                                (api) => api.reconnectPrivateNetwork(networkId: n.id),
                                                l.networkReconnecting,
                                              ),
                                            ),
                                      child: Text(l.networkReconnect),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _busy ? null : () => _act(() => toggleNetwork(context, ref, n)),
                                      child: Text(l.networkDisconnect),
                                    ),
                                  ),
                                ] else
                                  Expanded(
                                    child: FilledButton(
                                      onPressed: _busy ? null : () => _act(() => toggleNetwork(context, ref, n)),
                                      child: Text(l.networkConnect),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                if (owner && list != null)
                  OutlinedButton.icon(
                    onPressed: atMax ? null : () => _settings(add: true),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(atMax ? l.networkLimit('${list.max}') : l.networkAdd),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../repos/manage_widgets.dart';

final mcpProvider = FutureProvider.autoDispose<McpStatus>((ref) async {
  return (await requireApi(ref).getMcpApi().getMcpSettings()).data!;
});

/// Claude chat: the MCP connector URL, the Claude apps connected over
/// OAuth, and the optional static token for Claude Code and Desktop (McpCard).
class McpScreen extends ConsumerStatefulWidget {
  const McpScreen({super.key});

  @override
  ConsumerState<McpScreen> createState() => _McpScreenState();
}

class _McpScreenState extends ConsumerState<McpScreen> {
  String _newToken = '';
  bool _busy = false;

  Future<void> _rotate() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final r = (await ref.read(apiProvider)!.getMcpApi().rotateMcpToken()).data!;
      ref.invalidate(mcpProvider);
      if (mounted) setState(() => _newToken = r.token);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _revoke() async {
    final l = AppLocalizations.of(context);
    if (!await confirmAction(context, title: l.mcpRevoke, message: l.mcpRevokeConfirm, confirmLabel: l.mcpRevoke, danger: true)) return;
    setState(() => _busy = true);
    try {
      await ref.read(apiProvider)!.getMcpApi().revokeMcp();
      ref.invalidate(mcpProvider);
      if (!mounted) return;
      setState(() => _newToken = '');
      showSnack(context, l.mcpRevoked);
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
    return Scaffold(
      appBar: DetailBar(backLabel: l.mobileMore),
      body: AsyncBody<McpStatus>(
        value: ref.watch(mcpProvider),
        onRefresh: () async => ref.invalidate(mcpProvider),
        builder: (s) => ListView(padding: const EdgeInsets.only(bottom: 32), children: [
          PageHeader(title: l.mcpTitle, sub: l.mcpSub, long: true),
          padCard(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            CopyLine(l.mcpUrl, s.url),
            const SizedBox(height: 6),
            KvRow(l.mcpConnections, '${s.connections}'),
            KvRow(l.mcpStaticToken, s.staticToken ? l.mcpSet : l.mcpNotSet),
            const SizedBox(height: 10),
            HelpBox(l.mcpHowTo),
            if (_newToken.isNotEmpty) ...[
              const SizedBox(height: 12),
              CopyLine(l.mcpNewToken, _newToken),
              Text(l.mcpShownOnce, style: TextStyle(fontSize: 13, color: c.warnInk)),
            ],
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: _busy ? null : _rotate, child: Text(s.staticToken ? l.mcpRotate : l.mcpCreate))),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(foregroundColor: c.badInk),
                  onPressed: _busy ? null : _revoke,
                  child: Text(l.mcpRevoke),
                ),
              ),
            ]),
          ])),
        ]),
      ),
    );
  }
}

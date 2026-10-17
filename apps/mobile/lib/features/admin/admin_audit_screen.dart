import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'admin_data.dart';
import 'admin_widgets.dart';

/// The audit actions, as the server names them; '' is every action.
const auditActions = ['', 'transcript.view', 'transcript.prompt', 'transcript.download', 'run_history.settings'];

/// An action as the cabinet says it; one it does not know is shown as is.
String auditActionLabel(AppLocalizations l, String action) => switch (action) {
  '' => l.runsAllActions,
  'transcript.view' => l.runsA_transcript_view,
  'transcript.prompt' => l.runsA_transcript_prompt,
  'transcript.download' => l.runsA_transcript_download,
  'run_history.settings' => l.runsA_run_history_settings,
  _ => action,
};

/// The transcript a target names ("transcript:12"), or null.
int? auditTranscriptId(String target) => target.startsWith('transcript:') ? int.tryParse(target.substring('transcript:'.length)) : null;

/// A target as the cabinet says it: "transcript:12" is Transcript #12.
String auditTargetLabel(AppLocalizations l, String target) {
  final id = auditTranscriptId(target);
  return id == null ? target : l.runsAuditTranscript('$id');
}

/// What Admins read of customer content (transcripts, prompts, downloads)
/// and the run history settings they changed, newest first. Read-only:
/// the server writes a row before it serves anything.
class AdminAuditScreen extends ConsumerStatefulWidget {
  const AdminAuditScreen({super.key});

  @override
  ConsumerState<AdminAuditScreen> createState() => _AdminAuditScreenState();
}

class _AdminAuditScreenState extends ConsumerState<AdminAuditScreen> {
  String _action = '';
  String _q = '';
  // Older pages, below the provider's first one; cleared on refresh.
  final _older = <AdminAuditEntry>[];
  bool _end = false;
  bool _loading = false;

  Future<void> _refresh() async {
    setState(() {
      _older.clear();
      _end = false;
    });
    ref.invalidate(platformAuditProvider);
    await ref.read(platformAuditProvider.future);
  }

  Future<void> _more(int before) async {
    final l = AppLocalizations.of(context);
    setState(() => _loading = true);
    try {
      final page = await fetchAuditBefore(ref.read(apiProvider)!, before);
      if (!mounted) return;
      setState(() {
        _older.addAll(page);
        _end = page.length < auditPage;
      });
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(backLabel: l.navBack, onBack: () => context.canPop() ? context.pop() : context.go('/admin/more')),
      body: AsyncBody<List<AdminAuditEntry>>(
        value: ref.watch(platformAuditProvider),
        onRefresh: _refresh,
        builder: (first) {
          final all = [...first, ..._older];
          final more = !_end && first.length == auditPage && all.isNotEmpty;
          final s = _q.trim().toLowerCase();
          final list = all
              .where((a) => _action.isEmpty || a.action == _action)
              .where((a) => s.isEmpty || [a.adminName, a.target, a.workspace ?? '', a.ip ?? ''].any((v) => v.toLowerCase().contains(s)))
              .toList();
          int count(String action) => all.where((a) => action.isEmpty || a.action == action).length;
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              PageHeader(title: l.runsAuditTitle, sub: l.runsAuditLede),
              FilterBar<String>(
                filters: [for (final a in auditActions) (a, auditActionLabel(l, a), count(a))],
                value: _action,
                onChanged: (a) => setState(() => _action = a),
                hint: l.runsAuditSearch,
                onSearch: (v) => setState(() => _q = v),
              ),
              if (list.isEmpty)
                EmptyState(title: l.runsNoAudit)
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListGroup(children: [for (final a in list) AuditRow(a)]),
                ),
              if (more)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: OutlinedButton(
                    onPressed: _loading ? null : () => _more(all.last.id),
                    child: _loading
                        ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(l.runsLoadMore),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// One audit row: who did what to which target, where from and when.
class AuditRow extends StatelessWidget {
  const AuditRow(this.a, {super.key});
  final AdminAuditEntry a;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final settings = a.action == 'run_history.settings';
    final run = auditTranscriptId(a.target);
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HIcon(settings ? 'shield' : 'logs', size: 20, color: settings ? c.ink3 : c.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        auditActionLabel(l, a.action),
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.ink),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(agoText(context, a.createdAt), style: TextStyle(fontSize: 12.5, color: c.ink3)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(auditTargetLabel(l, a.target), style: TextStyle(fontSize: 14, color: run == null ? c.ink2 : c.primaryInk)),
                const SizedBox(height: 3),
                Text(
                  [
                    a.adminId == null ? '${a.adminName} (${l.feedbackAccountGone})' : a.adminName,
                    if (a.workspace != null) a.workspace!,
                    if (a.ip != null) a.ip!,
                  ].join(' · '),
                  style: TextStyle(fontSize: 12.5, height: 1.4, color: c.ink3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    // Opening the transcript is itself a read, and is logged.
    return run == null ? row : InkWell(onTap: () => context.push('/admin/runs/$run'), child: row);
  }
}

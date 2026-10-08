import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import '../core/data.dart';
import '../core/session.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'common.dart';
import 'ui.dart';

/// Lists the person's workspaces and switches to the one tapped.
Future<void> showWorkspaceSheet(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final me = ref.read(meProvider).value;
  final current = ref.read(currentWorkspaceProvider);
  final list = me?.workspaces ?? const <WorkspaceSummary>[];
  final picked = await showModalBottomSheet<WorkspaceSummary>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    builder: (ctx) {
      final c = Agnts.of(ctx);
      return SafeArea(
        child: ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
            child: Text(l.wsSwitcher, style: Theme.of(ctx).textTheme.titleMedium),
          ),
          ListGroup(children: [
            for (final w in list)
              ListRow(
                title: w.name,
                subtitle: [
                  roleLabel(l, w.role),
                  l.mwsMembers(w.members),
                  if (w.suspended == true) l.mwsSuspended,
                ].join(' · '),
                trailing: w.slug == current?.slug ? Icon(Icons.check_rounded, color: c.primary) : null,
                onTap: () => Navigator.pop(ctx, w),
              ),
          ]),
        ]),
      );
    },
  );
  if (picked == null || picked.slug == current?.slug) return;
  await ref.read(sessionProvider.notifier).setWorkspace(picked.slug);
  if (context.mounted) showSnack(context, l.mwsSwitched(picked.name));
}

/// The current workspace's name as a small button that opens the switcher;
/// nothing while the person has only one workspace.
class WorkspaceChip extends ConsumerWidget {
  const WorkspaceChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Agnts.of(context);
    final ws = ref.watch(currentWorkspaceProvider);
    final count = ref.watch(meProvider).value?.workspaces?.length ?? 0;
    if (ws == null || count < 2) return const SizedBox.shrink();
    return Semantics(
      button: true,
      label: '${AppLocalizations.of(context).wsSwitcher}: ${ws.name}',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => showWorkspaceSheet(context, ref),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 160, minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.line), borderRadius: BorderRadius.circular(18)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible(
              child: Text(ws.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink)),
            ),
            const SizedBox(width: 4),
            Icon(Icons.unfold_more_rounded, size: 16, color: c.ink3),
          ]),
        ),
      ),
    );
  }
}

/// A workspace role's name.
String roleLabel(AppLocalizations l, WorkspaceRole r) => switch (r) {
      WorkspaceRole.owner => l.wsRole_owner,
      WorkspaceRole.viewer => l.wsRole_viewer,
      _ => l.wsRole_user,
    };

/// Why a ticket waits for a worker, as a short badge label and its tone.
(String, Tone) waitBadge(AppLocalizations l, WaitReason r) => switch (r) {
      WaitReason.blocked => (l.queueBadge_blocked, Tone.gray),
      WaitReason.slots => (l.queueBadge_slots, Tone.info),
      WaitReason.server => (l.queueBadge_server, Tone.info),
      WaitReason.claude => (l.queueBadge_claude, Tone.warn),
    };

/// Says why a queued ticket has not started, and when it may (the web's
/// WaitBanner): its place in the server queue, or the slots in use.
class WaitBanner extends ConsumerWidget {
  const WaitBanner(this.ticket, {super.key});
  final Ticket ticket;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ticket.waitReason;
    if (r == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final q = ref.watch(queueProvider).value;
    final place = q?.serverQueue.where((e) => e.key == ticket.key).firstOrNull;
    final title = switch (r) {
      WaitReason.blocked => l.queueTitle_blocked,
      WaitReason.slots => l.queueTitle_slots,
      WaitReason.server => l.queueTitle_server,
      WaitReason.claude => l.queueTitle_claude,
    };
    final lines = <String>[
      if (ticket.waitMessage?.isNotEmpty == true) ticket.waitMessage!,
      if (r == WaitReason.slots && q != null) l.queueSlotsHint('${q.running}', '${q.slots}'),
      if (r == WaitReason.server && place != null) ...[
        l.queuePosition('${place.position}'),
        if (place.others > 0) l.queueOthers(place.others),
        if ((place.estimateSec ?? 0) > 0) l.queueEstimate((place.estimateSec! / 60).ceil()),
      ],
      if (r == WaitReason.claude) l.queueClaudeHint,
    ];
    return HelpBox(
      title,
      tone: r == WaitReason.claude ? Tone.warn : Tone.info,
      child: lines.isEmpty ? null : Text(lines.join(' '), style: const TextStyle(fontSize: 13.5, height: 1.4)),
    );
  }
}

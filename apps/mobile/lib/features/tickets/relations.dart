import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';

/// The ticket's place in the queue: what it waits for, what it must not run
/// beside, and what agnts suggests and is not sure about. Accepting or
/// dismissing happens here; new relations are added in the admin panel.
class RelationsFold extends ConsumerStatefulWidget {
  const RelationsFold(this.detail, {super.key});
  final TicketDetail detail;

  /// Whether the fold has anything to show for [d].
  static bool shows(TicketDetail d) => (d.relations?.items.isNotEmpty ?? false) || (d.analysis?.footprint?.files.isNotEmpty ?? false);

  @override
  ConsumerState<RelationsFold> createState() => _RelationsFoldState();
}

class _RelationsFoldState extends ConsumerState<RelationsFold> {
  bool _busy = false;

  Ticket get _t => widget.detail.ticket;
  TicketsApi get _api => ref.read(apiProvider)!.getTicketsApi();

  Future<void> _decide(Relation r, bool accept) async {
    final l = AppLocalizations.of(context);
    if (!accept && r.status == RelationStatusEnum.active) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          content: Text(l.relationsRemoveConfirm(_t.key, r.other.key)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.mobileCancel)),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.relationsRemove)),
          ],
        ),
      );
      if (ok != true) return;
    }
    setState(() => _busy = true);
    try {
      if (accept) {
        await _api.acceptRelation(key: _t.key, id: r.id);
      } else {
        await _api.dismissRelation(key: _t.key, id: r.id);
      }
      ref.invalidate(ticketProvider(_t.key));
      ref.invalidate(ticketsProvider);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _direction(AppLocalizations l, Relation r) => switch (r.direction) {
        RelationDirectionEnum.waitsFor => l.relationsWaitsFor,
        RelationDirectionEnum.waitedBy => l.relationsWaitedBy,
        RelationDirectionEnum.conflicts => l.relationsConflicts,
      };

  String _source(AppLocalizations l, Relation r) => switch (r.source_) {
        RelationSource_Enum.jira => l.relationsSource_jira,
        RelationSource_Enum.user => l.relationsSource_user,
        RelationSource_Enum.agnts => l.relationsSource_agnts,
        RelationSource_Enum.rule => l.relationsSource_rule,
        RelationSource_Enum.git => l.relationsSource_git,
      };

  String? _basis(AppLocalizations l, Relation r) {
    final files = r.files.take(4).join(', ') + (r.files.length > 4 ? ' +${r.files.length - 4}' : '');
    return switch (r.basis) {
      'files' => l.relationsBasis_files(files),
      'migrations' => l.relationsBasis_migrations,
      'lockfile' => l.relationsBasis_lockfile,
      'codegen' => l.relationsBasis_codegen,
      'i18n' => l.relationsBasis_i18n,
      'diff' => l.relationsBasis_diff(files),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final items = widget.detail.relations?.items ?? const <Relation>[];
    final proposed = items.where((r) => r.status == RelationStatusEnum.proposed).toList();
    final active = items.where((r) => r.status == RelationStatusEnum.active).toList();
    final dismissed = items.where((r) => r.status == RelationStatusEnum.dismissed).length;
    final footprint = widget.detail.analysis?.footprint;

    Widget heading(String text) => Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink3)),
        );

    Widget card(Relation r) {
      final basis = _basis(l, r);
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(color: c.line), borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
            ToneBadge(_direction(l, r), r.direction == RelationDirectionEnum.conflicts ? Tone.warn : Tone.info, small: true),
            GestureDetector(
              onTap: () => context.push('/tickets/${r.other.key}'),
              child: Text(r.other.key, style: TextStyle(fontWeight: FontWeight.w700, color: c.primary)),
            ),
            StateBadge(r.other.state),
            if (r.other.landed) ToneBadge(l.relationsLanded, Tone.ok, small: true),
          ]),
          Padding(padding: const EdgeInsets.only(top: 6), child: Text(r.other.title, style: const TextStyle(fontWeight: FontWeight.w600))),
          if (basis != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(basis, style: const TextStyle(fontSize: 14))),
          if (r.reason.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(r.reason, style: const TextStyle(fontSize: 14))),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              [
                _source(l, r),
                if (r.status == RelationStatusEnum.proposed) l.relationsConfidence('${(r.confidence * 100).round()}'),
                if (r.confirmedAt != null) l.relationsConfirmed,
              ].join(' · '),
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink3),
            ),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (r.status == RelationStatusEnum.proposed) ...[
              OutlinedButton(onPressed: _busy ? null : () => _decide(r, false), child: Text(l.relationsDismiss)),
              const SizedBox(width: 8),
              FilledButton(onPressed: _busy ? null : () => _decide(r, true), child: Text(l.relationsAccept)),
            ] else
              OutlinedButton(onPressed: _busy ? null : () => _decide(r, false), child: Text(l.relationsRemove)),
          ]),
        ]),
      );
    }

    return Fold(
      title: l.relationsTitle,
      hint: proposed.isEmpty ? null : '${proposed.length}',
      initiallyOpen: proposed.isNotEmpty,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l.relationsSub, style: TextStyle(fontSize: 14, height: 1.45, color: c.ink3)),
        if (proposed.isNotEmpty) ...[
          heading(l.relationsProposedTitle),
          Text(l.relationsProposedSub, style: TextStyle(fontSize: 13, color: c.ink3)),
          const SizedBox(height: 8),
          for (final r in proposed) card(r),
        ],
        heading(l.relationsActiveTitle),
        if (active.isEmpty) Text(l.relationsEmpty, style: TextStyle(fontSize: 14, color: c.ink3)),
        for (final r in active) card(r),
        if (dismissed > 0)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(l.relationsDismissedCount(dismissed), style: TextStyle(fontSize: 13, color: c.ink3)),
          ),
        if (footprint != null && footprint.files.isNotEmpty) ...[
          heading(l.relationsFootprintTitle),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final f in footprint.files)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: c.hover, borderRadius: BorderRadius.circular(6)),
                child: Text(f, style: const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12)),
              ),
          ]),
          if (footprint.migrations == true)
            Padding(padding: const EdgeInsets.only(top: 6), child: Text(l.relationsFootprintMigrations, style: const TextStyle(fontSize: 14))),
        ],
      ]),
    );
  }
}

/// The tickets holding this one's coding back, shown instead of the coding
/// log while it waits.
class WaitingBlock extends StatelessWidget {
  const WaitingBlock(this.blockers, {super.key});
  final List<Blocker> blockers;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final b in blockers)
        InkWell(
          onTap: () => context.push('/tickets/${b.key}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              ToneBadge(b.type == RelationType.conflicts ? l.relationsConflicts : l.relationsWaitsFor,
                  b.type == RelationType.conflicts ? Tone.warn : Tone.info,
                  small: true),
              const SizedBox(width: 8),
              Text(b.key, style: TextStyle(fontWeight: FontWeight.w700, color: c.primary)),
              const SizedBox(width: 8),
              Expanded(child: Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
              StateBadge(b.state),
            ]),
          ),
        ),
    ]);
  }
}

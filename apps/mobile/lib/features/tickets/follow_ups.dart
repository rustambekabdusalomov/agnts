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

/// Follow-up tickets agnts suggests for finishing a ticket. You pick which
/// to create, as a local task or a Jira issue; they are created queued, so
/// nothing spends tokens until someone starts them.
class FollowUpsFold extends ConsumerStatefulWidget {
  const FollowUpsFold(this.detail, {super.key});
  final TicketDetail detail;

  @override
  ConsumerState<FollowUpsFold> createState() => _FollowUpsFoldState();
}

class _FollowUpsFoldState extends ConsumerState<FollowUpsFold> {
  final Set<int> _picked = {};
  final Map<int, AcceptFollowUpTargetEnum> _target = {};
  bool _busy = false;

  Ticket get _t => widget.detail.ticket;
  TicketsApi get _api => ref.read(apiProvider)!.getTicketsApi();

  Future<void> _run(Future<void> Function() action) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(ticketProvider(_t.key));
      ref.invalidate(ticketsProvider);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setMode(FollowUpsMode m) => _run(
    () => _api.setFollowUps(
      key: _t.key,
      followUpsSetting: FollowUpsSetting(mode: m),
    ),
  );

  Future<void> _create(List<FollowUpSuggestion> open) => _run(() async {
    final l = AppLocalizations.of(context);
    final items = [
      for (final s in open)
        if (_picked.contains(s.id)) AcceptFollowUp(id: s.id, target: _target[s.id] ?? AcceptFollowUpTargetEnum.local),
    ];
    final res = (await _api.acceptFollowUps(
      key: _t.key,
      acceptFollowUps: AcceptFollowUps(items: items),
    )).data;
    final made = res?.results.where((r) => r.ticket != null).length ?? 0;
    final failed = [
      for (final r in res?.results ?? const <AcceptFollowUpResult>[])
        if (r.error != null) l.followUpsFailedItem(open.firstWhere((s) => s.id == r.id, orElse: () => open.first).title, r.error!),
    ];
    _picked.clear();
    if (mounted) showSnack(context, [if (made > 0) l.followUpsCreatedNotice(made), ...failed].join('\n'));
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final f = widget.detail.followUps;
    if (f == null) return const SizedBox.shrink();
    final open = f.suggestions.where((s) => s.status == FollowUpSuggestionStatusEnum.open).toList();
    final dismissed = f.suggestions.where((s) => s.status == FollowUpSuggestionStatusEnum.dismissed).length;
    final jira = (ref.watch(integrationsProvider).value ?? const <Integration>[]).any((i) => i.provider == 'jira' && i.connected);
    final picked = open.where((s) => s.ready && _picked.contains(s.id)).length;

    final body = <Widget>[
      Text(l.followUpsSub, style: TextStyle(fontSize: 14, height: 1.45, color: c.ink3)),
      const SizedBox(height: 10),
      Segmented<FollowUpsMode>(
        full: true,
        value: _t.suggestFollowUps ?? FollowUpsMode.inherit,
        onChanged: (m) => _busy ? null : _setMode(m),
        options: [
          (FollowUpsMode.inherit, l.followUpsModeInherit),
          (FollowUpsMode.on_, l.followUpsModeOn),
          (FollowUpsMode.off, l.followUpsModeOff),
        ],
      ),
      const SizedBox(height: 10),
      if (!f.enabled && f.suggestions.isEmpty)
        Text(l.followUpsOffEmpty, style: TextStyle(fontSize: 14, color: c.ink3))
      else if (f.suggestions.isEmpty && f.children.isEmpty)
        Text(l.followUpsOnEmpty, style: TextStyle(fontSize: 14, color: c.ink3)),
      for (final s in open) _suggestion(context, s, jira),
      if (open.isNotEmpty) ...[
        const SizedBox(height: 4),
        FilledButton(onPressed: _busy || picked == 0 ? null : () => _create(open), child: Text(l.followUpsCreate(picked))),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(l.followUpsQueuedHint, style: TextStyle(fontSize: 13, color: c.ink3)),
        ),
      ],
      if (f.children.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Text(
            l.followUpsChildren,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink3),
          ),
        ),
        for (final k in f.children)
          InkWell(
            onTap: () => context.push('/tickets/${k.key}'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Text(
                    k.key,
                    style: TextStyle(fontWeight: FontWeight.w700, color: c.primary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(k.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  StateBadge(k.state, kind: k.kind),
                ],
              ),
            ),
          ),
      ],
      if (dismissed > 0)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(l.followUpsDismissedCount(dismissed), style: TextStyle(fontSize: 13, color: c.ink3)),
        ),
    ];

    return Fold(
      title: l.followUpsTitle,
      hint: open.isEmpty ? null : '${open.length}',
      initiallyOpen: open.any((s) => s.ready),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: body),
    );
  }

  Widget _suggestion(BuildContext context, FollowUpSuggestion s, bool jira) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final on = _picked.contains(s.id);
    final (typeLabel, tone) = switch (s.type) {
      FollowUpSuggestionTypeEnum.prerequisite => (l.followUpsType_prerequisite, Tone.warn),
      FollowUpSuggestionTypeEnum.split => (l.followUpsType_split, Tone.info),
      FollowUpSuggestionTypeEnum.unfinished => (l.followUpsType_unfinished, Tone.info),
      FollowUpSuggestionTypeEnum.gap => (l.followUpsType_gap, Tone.bad),
    };
    final source = switch (s.source_) {
      FollowUpSuggestionSource_Enum.analyze => l.followUpsSource_analyze,
      FollowUpSuggestionSource_Enum.work => l.followUpsSource_work,
      FollowUpSuggestionSource_Enum.review => l.followUpsSource_review,
      FollowUpSuggestionSource_Enum.manual => l.followUpsSource_manual,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(4, 8, 12, 10),
      decoration: BoxDecoration(
        border: Border.all(color: on ? c.primary : c.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: on,
            onChanged: !s.ready || _busy ? null : (v) => setState(() => v == true ? _picked.add(s.id) : _picked.remove(s.id)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ToneBadge(typeLabel, tone, small: true),
                    Text(
                      source,
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink3),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(s.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                Text('${l.followUpsServes}: ${s.serves}', style: TextStyle(fontSize: 14, height: 1.4, color: c.ink2)),
                if (s.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      s.description,
                      maxLines: on ? null : 3,
                      overflow: on ? null : TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13.5, height: 1.4, color: c.ink3),
                    ),
                  ),
                if (!s.ready)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(l.followUpsWaitsForDone, style: TextStyle(fontSize: 13, color: c.ink3)),
                  ),
                if (on)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Segmented<AcceptFollowUpTargetEnum>(
                      value: _target[s.id] ?? AcceptFollowUpTargetEnum.local,
                      onChanged: (v) {
                        if (v == AcceptFollowUpTargetEnum.jira && !jira) {
                          showSnack(context, l.followUpsJiraOff);
                          return;
                        }
                        setState(() => _target[s.id] = v);
                      },
                      options: [
                        (AcceptFollowUpTargetEnum.local, l.followUpsTargetLocal),
                        (AcceptFollowUpTargetEnum.jira, l.followUpsTargetJira),
                      ],
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4), minimumSize: const Size(0, 32)),
                    onPressed: _busy ? null : () => _run(() => _api.dismissFollowUp(key: _t.key, id: s.id)),
                    child: Text(l.followUpsDismiss),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

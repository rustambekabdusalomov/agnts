import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../../widgets/workspace.dart' show roleLabel;
import 'admin_data.dart';
import 'admin_widgets.dart';

enum _Filter { all, active, suspended, deleted }

/// Every workspace on the platform (metadata only: their tickets are their
/// members'), and the Admin's levers: plan, slots, member limit, credits and
/// suspension.
class AdminWorkspacesScreen extends ConsumerStatefulWidget {
  const AdminWorkspacesScreen({super.key});

  @override
  ConsumerState<AdminWorkspacesScreen> createState() => _AdminWorkspacesScreenState();
}

class _AdminWorkspacesScreenState extends ConsumerState<AdminWorkspacesScreen> {
  _Filter _filter = _Filter.all;
  String _q = '';

  static _Filter _state(PlatformWorkspace w) =>
      w.deletedAt != null ? _Filter.deleted : (w.suspended ?? false) ? _Filter.suspended : _Filter.active;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final value = ref.watch(platformWorkspacesProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AsyncBody<List<PlatformWorkspace>>(
          value: value,
          onRefresh: () async {
            ref.invalidate(platformWorkspacesProvider);
            ref.invalidate(platformUsersProvider);
            await ref.read(platformWorkspacesProvider.future);
          },
          builder: (all) {
            final s = _q.trim().toLowerCase();
            final list = all
                .where((w) => _filter == _Filter.all || _state(w) == _filter)
                .where((w) => s.isEmpty || [w.name, w.slug, w.owner ?? ''].any((x) => x.toLowerCase().contains(s)))
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            int count(_Filter f) => all.where((w) => f == _Filter.all || _state(w) == f).length;
            return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
              PageHeader(title: l.platformWorkspaces, sub: l.platformWsLede),
              FilterBar<_Filter>(
                filters: [
                  (_Filter.all, l.platformF_all, count(_Filter.all)),
                  (_Filter.active, l.platformF_active, count(_Filter.active)),
                  (_Filter.suspended, l.platformF_suspended, count(_Filter.suspended)),
                  (_Filter.deleted, l.platformF_deleted, count(_Filter.deleted)),
                ],
                value: _filter,
                onChanged: (f) => setState(() => _filter = f),
                hint: l.platformSearchWs,
                onSearch: (v) => setState(() => _q = v),
              ),
              if (list.isEmpty)
                EmptyState(title: l.platformNoWorkspaces)
              else
                for (final w in list)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: HCard(
                      onTap: () => _open(w),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(w.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.ink)),
                              Text('/w/${w.slug}', style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink3)),
                            ]),
                          ),
                          ToneBadge(wsState(l, w), wsTone(w), small: true),
                        ]),
                        const SizedBox(height: 8),
                        Text(
                          [
                            if (w.owner != null) w.owner!,
                            '${l.platformMembers}: ${w.members}${w.memberLimit > 0 ? ' / ${w.memberLimit}' : ''}',
                            w.plan,
                            '${l.platformCredits}: ${w.creditsBalance}',
                            if (w.running > 0) '${l.platformRuns}: ${w.running}',
                          ].join(' · '),
                          style: TextStyle(fontSize: 13, color: c.ink2),
                        ),
                      ]),
                    ),
                  ),
            ]);
          },
        ),
      ),
    );
  }

  Future<void> _open(PlatformWorkspace w) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
        builder: (_) => _WorkspaceSheet(id: w.id),
      );
}

/// One workspace: its numbers, members and the Admin's actions.
class _WorkspaceSheet extends ConsumerWidget {
  const _WorkspaceSheet({required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    // Read from the list so the sheet shows each change as soon as it is saved.
    final w = ref.watch(platformWorkspacesProvider).value?.where((x) => x.id == id).firstOrNull;
    if (w == null) return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
    // Members come from the user list, which carries each person's workspaces.
    final members = [
      for (final u in ref.watch(platformUsersProvider).value ?? const <PlatformUser>[])
        for (final m in u.workspaces.where((m) => m.id == id)) (u.user, m.role),
    ]..sort((a, b) => (b.$2 == WorkspaceRole.owner ? 1 : 0) - (a.$2 == WorkspaceRole.owner ? 1 : 0));

    return ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(children: [
          Expanded(child: Text(w.name, style: Theme.of(context).textTheme.titleLarge)),
          ToneBadge(wsState(l, w), wsTone(w)),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 2, 4, 14),
        child: Text('/w/${w.slug}', style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13, color: c.ink3)),
      ),
      Grid2(children: [
        Fact(l.platformOwner, w.owner ?? '—'),
        Fact(l.platformMembers, '${w.members}${w.memberLimit > 0 ? ' / ${w.memberLimit}' : ''}'),
        Fact(l.platformPlan, w.plan),
        Fact(l.platformSlots, '${w.slots}'),
        Fact(l.platformCredits, '${w.creditsBalance}'),
        Fact(l.platformRuns, '${w.running}'),
        Fact(l.platformCreated, agoText(context, w.createdAt)),
      ]),
      if (w.deletedAt == null) ...[
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => _edit(context, ref, w), child: Text(l.platformEdit))),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton(onPressed: () => _grant(context, ref, w), child: Text(l.platformGrant, maxLines: 1, overflow: TextOverflow.ellipsis))),
        ]),
        const SizedBox(height: 8),
        (w.suspended ?? false)
            ? FilledButton(onPressed: () => _suspend(context, ref, w), child: Text(l.platformResume))
            : OutlinedButton(
                style: OutlinedButton.styleFrom(foregroundColor: c.badInk, side: BorderSide(color: c.bad)),
                onPressed: () => _suspend(context, ref, w),
                child: Text(l.platformSuspend),
              ),
      ],
      SectionHeader(l.platformMembers, padding: const EdgeInsets.fromLTRB(4, 18, 4, 8)),
      if (members.isEmpty)
        HCard(child: Text(l.platformNoMembers, style: TextStyle(color: c.ink3)))
      else
        ListGroup(children: [
          for (final (u, role) in members)
            PersonRow(
              user: u,
              sub: contactOf(u),
              trailing: ToneBadge(roleLabel(l, role), role == WorkspaceRole.owner ? Tone.info : Tone.gray, small: true),
            ),
        ]),
    ]);
  }

  Future<void> _save(WidgetRef ref, PlatformWorkspace w, UpdatePlatformWorkspaceRequest body) async {
    await ref.read(apiProvider)!.getPlatformApi().updatePlatformWorkspace(id: w.id, updatePlatformWorkspaceRequest: body);
    ref.invalidate(platformWorkspacesProvider);
    ref.invalidate(platformOverviewProvider);
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, PlatformWorkspace w) async {
    final l = AppLocalizations.of(context);
    final plan = TextEditingController(text: w.plan);
    final slots = TextEditingController(text: '${w.slots}');
    final limit = TextEditingController(text: '${w.memberLimit}');
    final digits = [FilteringTextInputFormatter.digitsOnly];
    final saved = await showFormSheet(
      context,
      title: w.name,
      action: l.wsSave,
      ready: () {
        final s = int.tryParse(slots.text);
        return plan.text.trim().isNotEmpty && s != null && s >= 1 && s <= 50 && int.tryParse(limit.text) != null;
      },
      fields: (setState) => [
        LabeledField(label: l.platformPlan, controller: plan, autocorrect: false, onChanged: (_) => setState(() {})),
        LabeledField(label: l.platformSlots, controller: slots, keyboard: TextInputType.number, formatters: digits, help: '1–50', onChanged: (_) => setState(() {})),
        LabeledField(
          label: '${l.platformMemberLimit} (0 = ${l.platformNoLimit})',
          controller: limit,
          keyboard: TextInputType.number,
          formatters: digits,
          onChanged: (_) => setState(() {}),
        ),
      ],
      submit: () async {
        try {
          await _save(
            ref,
            w,
            UpdatePlatformWorkspaceRequest(plan: plan.text.trim(), slots: int.parse(slots.text), memberLimit: int.parse(limit.text)),
          );
          return null;
        } catch (e) {
          return errorMessage(e, l.commonError);
        }
      },
    );
    if (saved && context.mounted) showSnack(context, l.platformSaved);
  }

  Future<void> _grant(BuildContext context, WidgetRef ref, PlatformWorkspace w) async {
    final l = AppLocalizations.of(context);
    final amount = TextEditingController(text: '1000');
    final note = TextEditingController();
    final done = await showFormSheet(
      context,
      title: l.platformGrant,
      sub: w.name,
      action: l.platformGrant,
      ready: () => (int.tryParse(amount.text.trim()) ?? 0) != 0,
      fields: (setState) => [
        LabeledField(
          label: l.platformGrantAmount,
          controller: amount,
          keyboard: const TextInputType.numberWithOptions(signed: true),
          formatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))],
          onChanged: (_) => setState(() {}),
        ),
        LabeledField(label: l.platformGrantNote, controller: note, maxLength: 300),
      ],
      submit: () async {
        try {
          final n = note.text.trim();
          await ref.read(apiProvider)!.getPlatformApi().grantCredits(
                id: w.id,
                grantCreditsRequest: GrantCreditsRequest(amount: int.parse(amount.text.trim()), note: n.isEmpty ? null : n),
              );
          ref.invalidate(platformWorkspacesProvider);
          return null;
        } catch (e) {
          return errorMessage(e, l.commonError);
        }
      },
    );
    if (done && context.mounted) showSnack(context, l.platformGrantDone(amount.text.trim(), w.name));
  }

  Future<void> _suspend(BuildContext context, WidgetRef ref, PlatformWorkspace w) async {
    final l = AppLocalizations.of(context);
    final suspended = w.suspended ?? false;
    // Suspending stops the workspace's runs, so it asks first; resuming does not.
    if (!suspended &&
        !await confirmAction(context, title: l.platformSuspendTitle(w.name), body: l.platformSuspendBody, action: l.platformSuspend, danger: true)) {
      return;
    }
    try {
      await _save(ref, w, UpdatePlatformWorkspaceRequest(suspended: !suspended));
      if (context.mounted) showSnack(context, l.platformSaved);
    } catch (e) {
      if (context.mounted) showSnack(context, errorMessage(e, l.commonError));
    }
  }
}

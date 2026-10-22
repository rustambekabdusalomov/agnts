import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../core/session.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../../widgets/workspace.dart';
import '../account/account_data.dart';
import '../account/account_widgets.dart';
import '../admin/admin_widgets.dart' show confirmAction;

enum WorkspaceTab { general, members, claude, billing }

/// Workspace settings: General, Members, Claude and (for the owner)
/// Billing; [tab] opens one of them (?tab=members).
class WorkspaceScreen extends ConsumerStatefulWidget {
  const WorkspaceScreen({super.key, this.tab});
  final String? tab;

  @override
  ConsumerState<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends ConsumerState<WorkspaceScreen> {
  late WorkspaceTab _tab = WorkspaceTab.values.where((t) => t.name == widget.tab).firstOrNull ?? WorkspaceTab.general;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ws = ref.watch(currentWorkspaceProvider);
    final owner = ref.watch(isOwnerProvider);
    final detail = ref.watch(workspaceDetailProvider).value;
    final tabs = [WorkspaceTab.general, WorkspaceTab.members, WorkspaceTab.claude, if (owner) WorkspaceTab.billing];
    final tab = tabs.contains(_tab) ? _tab : WorkspaceTab.general;
    if (ws == null) {
      return Scaffold(appBar: DetailBar(backLabel: l.mobileMore), body: EmptyState(title: l.mwsNone));
    }
    return Scaffold(
      appBar: DetailBar(backLabel: l.mobileMore),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(workspaceDetailProvider);
          ref.invalidate(membersProvider);
          ref.invalidate(invitesProvider);
          ref.invalidate(workspaceClaudeProvider);
          ref.invalidate(billingProvider);
        },
        child: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
          PageHeader(title: ws.name, sub: '${roleLabel(l, ws.role)} · /w/${ws.slug}', long: true),
          if (detail?.suspended == true) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: HelpBox(l.wsSuspended, tone: Tone.warn)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Segmented<WorkspaceTab>(
              full: true,
              options: [
                for (final t in tabs)
                  (
                    t,
                    switch (t) {
                      WorkspaceTab.general => l.wsTabGeneral,
                      WorkspaceTab.members => l.wsTabMembers,
                      WorkspaceTab.claude => l.wsTabClaude,
                      WorkspaceTab.billing => l.wsTabBilling,
                    }
                  ),
              ],
              value: tab,
              onChanged: (t) => setState(() => _tab = t),
            ),
          ),
          switch (tab) {
            WorkspaceTab.general => const _GeneralTab(),
            WorkspaceTab.members => const _MembersTab(),
            WorkspaceTab.claude => const _ClaudeTab(),
            WorkspaceTab.billing => const _BillingTab(),
          },
        ]),
      ),
    );
  }
}

/// Runs a call with the screen's error handling: the server's message on failure.
Future<bool> _call(BuildContext context, WidgetRef ref, Future<void> Function(AgntsApi api) call, {String? done}) async {
  final l = AppLocalizations.of(context);
  final api = ref.read(apiProvider);
  if (api == null) return false;
  try {
    await call(api);
    if (context.mounted && done != null) showSnack(context, done);
    return true;
  } catch (e) {
    if (context.mounted) showSnack(context, errorMessage(e, l.commonError));
    return false;
  }
}

Widget _loading() => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));

Widget _failed(AppLocalizations l) => Padding(padding: const EdgeInsets.all(16), child: HelpBox(l.commonError, tone: Tone.bad));

TextStyle _sub(BuildContext context) => TextStyle(fontSize: 13.5, height: 1.4, color: Agnts.of(context).ink3);

/// After leaving or deleting the workspace: back to whichever is left.
Future<void> _afterGone(BuildContext context, WidgetRef ref) async {
  await ref.read(sessionProvider.notifier).setWorkspace(null);
  ref.invalidate(meProvider);
  if (context.mounted) context.go('/home');
}

// ---- General ----

class _GeneralTab extends ConsumerStatefulWidget {
  const _GeneralTab();

  @override
  ConsumerState<_GeneralTab> createState() => _GeneralTabState();
}

class _GeneralTabState extends ConsumerState<_GeneralTab> {
  final _name = TextEditingController();
  final _slug = TextEditingController();
  int? _loadedFor;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _slug.dispose();
    super.dispose();
  }

  Future<void> _save(WorkspaceDetail w) async {
    final l = AppLocalizations.of(context);
    final name = _name.text.trim(), slug = _slug.text.trim();
    setState(() => _busy = true);
    WorkspaceDetail? out;
    await _call(context, ref, (api) async {
      out = (await api.getWorkspaceApi().updateWorkspace(
                updateWorkspaceRequest: UpdateWorkspaceRequest(name: name != w.name ? name : null, slug: slug != w.slug ? slug : null),
              ))
          .data;
    }, done: l.wsSaved);
    if (out != null) {
      // A new address: act in the workspace under it.
      if (out!.slug != w.slug) await ref.read(sessionProvider.notifier).setWorkspace(out!.slug);
      ref.invalidate(meProvider);
      ref.invalidate(workspaceDetailProvider);
      _loadedFor = null;
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _delete(WorkspaceDetail w) async {
    final l = AppLocalizations.of(context);
    final typed = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l.wsDeleteTitle(w.name)),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l.wsDeleteBody(w.slug)),
            const SizedBox(height: 12),
            TextField(
              controller: typed,
              autocorrect: false,
              style: const TextStyle(fontFamily: AgntsFonts.mono),
              decoration: InputDecoration(hintText: w.slug),
              onChanged: (_) => setState(() {}),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.mobileCancel)),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Agnts.of(ctx).bad, foregroundColor: Colors.white),
              onPressed: typed.text.trim() == w.slug ? () => Navigator.pop(ctx, true) : null,
              child: Text(l.wsDelete),
            ),
          ],
        ),
      ),
    );
    final confirm = typed.text.trim();
    typed.dispose();
    if (ok != true || !mounted) return;
    final done = await _call(context, ref, (api) => api.getWorkspaceApi().deleteWorkspace(deleteWorkspaceRequest: DeleteWorkspaceRequest(confirm: confirm)),
        done: l.wsDeleted);
    if (done && mounted) await _afterGone(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final owner = ref.watch(isOwnerProvider);
    final detail = ref.watch(workspaceDetailProvider);
    final w = detail.value;
    if (w == null) return detail.hasError ? _failed(l) : _loading();
    if (_loadedFor != w.id || (!_busy && _name.text.isEmpty && _slug.text.isEmpty)) {
      _loadedFor = w.id;
      _name.text = w.name;
      _slug.text = w.slug;
    }
    final dirty = _name.text.trim() != w.name || _slug.text.trim() != w.slug;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Section(
        title: l.wsGeneral,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(owner ? l.wsGeneralSub : l.wsReadOnly, style: _sub(context)),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            enabled: owner,
            maxLength: 80,
            decoration: InputDecoration(labelText: l.wsName, counterText: ''),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _slug,
            enabled: owner,
            maxLength: 40,
            autocorrect: false,
            style: const TextStyle(fontFamily: AgntsFonts.mono),
            decoration: InputDecoration(
              labelText: l.wsSlug,
              counterText: '',
              helperText: l.wsSlugHelp(_slug.text.trim().isEmpty ? w.slug : _slug.text.trim()),
              helperMaxLines: 3,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          _Kv(label: l.wsPlan, value: w.plan, note: w.trialEndsAt == null ? null : l.wsTrialEnds(fmtDate(context, w.trialEndsAt!))),
          const SizedBox(height: 8),
          _Kv(label: l.wsSlots, value: '${w.slots}', note: l.wsSlotsHelp),
          if (owner) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(onPressed: !dirty || _busy ? null : () => _save(w), child: Text(l.wsSave)),
            ),
          ],
        ]),
      ),
      if (owner)
        Section(
          title: l.wsDanger,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l.wsDangerSub, style: _sub(context)),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(foregroundColor: Agnts.of(context).badInk),
                onPressed: () => _delete(w),
                child: Text(l.wsDelete),
              ),
            ),
          ]),
        ),
    ]);
  }
}

// ---- Members ----

class _MembersTab extends ConsumerStatefulWidget {
  const _MembersTab();

  @override
  ConsumerState<_MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends ConsumerState<_MembersTab> {
  final _email = TextEditingController();
  var _inviteRole = CreateInviteRequestRoleEnum.user;
  CreateInvite201Response? _created;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  String _who(Member m) => (m.displayName?.isNotEmpty ?? false) ? m.displayName! : m.username;

  void _refresh() {
    ref.invalidate(membersProvider);
    ref.invalidate(workspaceClaudeProvider);
  }

  Future<void> _setRole(Member m, SetMemberRoleRequestRoleEnum role) async {
    final l = AppLocalizations.of(context);
    final label = role == SetMemberRoleRequestRoleEnum.viewer ? l.wsRole_viewer : l.wsRole_user;
    await _call(context, ref, (api) => api.getWorkspaceApi().setMemberRole(userId: m.userId, setMemberRoleRequest: SetMemberRoleRequest(role: role)),
        done: l.wsRoleChanged(_who(m), label));
    _refresh();
  }

  Future<void> _remove(Member m) async {
    final l = AppLocalizations.of(context);
    if (!await confirmAction(context, title: l.wsRemoveTitle(_who(m)), body: l.wsRemoveBody, action: l.wsRemove, danger: true)) return;
    if (!mounted) return;
    await _call(context, ref, (api) => api.getWorkspaceApi().removeMember(userId: m.userId), done: l.wsRemoved(_who(m)));
    _refresh();
  }

  Future<void> _transfer(Member m) async {
    final l = AppLocalizations.of(context);
    if (!await confirmAction(context, title: l.wsTransferTitle(_who(m)), body: l.wsTransferBody, action: l.wsMakeOwner)) return;
    if (!mounted) return;
    final ok = await _call(context, ref, (api) => api.getWorkspaceApi().transferWorkspace(transferWorkspaceRequest: TransferWorkspaceRequest(userId: m.userId)),
        done: l.wsTransferred(_who(m)));
    if (ok) {
      ref.invalidate(meProvider);
      ref.invalidate(workspaceDetailProvider);
      _refresh();
    }
  }

  Future<void> _leave(String name) async {
    final l = AppLocalizations.of(context);
    if (!await confirmAction(context, title: l.wsLeaveTitle(name), body: l.wsLeaveBody, action: l.wsLeave, danger: true)) return;
    if (!mounted) return;
    final ok = await _call(context, ref, (api) => api.getWorkspaceApi().leaveWorkspace());
    if (ok && mounted) await _afterGone(context, ref);
  }

  Future<void> _invite() async {
    final email = _email.text.trim();
    setState(() => _busy = true);
    await _call(context, ref, (api) async {
      final r = (await api.getWorkspaceApi().createInvite(
                createInviteRequest: CreateInviteRequest(role: _inviteRole, email: email.isEmpty ? null : email),
              ))
          .data!;
      _email.clear();
      if (mounted) setState(() => _created = r);
      ref.invalidate(invitesProvider);
    });
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final owner = ref.watch(isOwnerProvider);
    final me = ref.watch(meProvider).value?.id;
    final ws = ref.watch(currentWorkspaceProvider);
    final limit = ref.watch(workspaceDetailProvider).value?.memberLimit ?? 0;
    final members = ref.watch(membersProvider);
    final invites = owner ? ref.watch(invitesProvider).value ?? const <Invite>[] : const <Invite>[];
    final list = members.value ?? const <Member>[];
    final limitText = limit > 0 ? l.wsMemberLimit('${list.length}', '$limit') : l.wsMemberLimitNone(list.length);

    Widget roleOf(Member m) {
      if (!owner || m.role == WorkspaceRole.owner) {
        return ToneBadge(roleLabel(l, m.role), switch (m.role) { WorkspaceRole.owner => Tone.info, WorkspaceRole.viewer => Tone.warn, _ => Tone.gray });
      }
      return DropdownButton<SetMemberRoleRequestRoleEnum>(
        value: m.role == WorkspaceRole.viewer ? SetMemberRoleRequestRoleEnum.viewer : SetMemberRoleRequestRoleEnum.user,
        underline: const SizedBox.shrink(),
        isDense: true,
        items: [
          DropdownMenuItem(value: SetMemberRoleRequestRoleEnum.user, child: Text(l.wsRole_user)),
          DropdownMenuItem(value: SetMemberRoleRequestRoleEnum.viewer, child: Text(l.wsRole_viewer)),
        ],
        onChanged: (r) {
          if (r != null) _setRole(m, r);
        },
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(l.wsMembers, trailing: Text(limitText)),
      Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 8), child: Text(l.wsMembersSub, style: _sub(context))),
      if (members.isLoading && !members.hasValue)
        _loading()
      else if (members.hasError)
        _failed(l)
      else
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListGroup(children: [
            for (final m in list)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(text: _who(m)),
                            if (m.userId == me) TextSpan(text: ' (${l.wsYou})', style: TextStyle(color: c.ink3, fontWeight: FontWeight.w400)),
                          ]),
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink),
                        ),
                        Text(
                          [m.username, if (m.email?.isNotEmpty ?? false) m.email!, l.maccountJoined(fmtDate(context, m.joinedAt))].join(' · '),
                          style: TextStyle(fontSize: 13, color: c.ink3),
                        ),
                      ]),
                    ),
                    roleOf(m),
                  ]),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
                    ToneBadge(m.claudeConnected ? l.wsClaudeBadge : l.wsNoClaudeBadge, m.claudeConnected ? Tone.ok : Tone.gray),
                    if (owner && m.role != WorkspaceRole.owner) ...[
                      TextButton(onPressed: () => _transfer(m), child: Text(l.wsMakeOwner)),
                      TextButton(style: TextButton.styleFrom(foregroundColor: c.badInk), onPressed: () => _remove(m), child: Text(l.wsRemove)),
                    ],
                  ]),
                ]),
              ),
          ]),
        ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: owner
            ? Text(l.wsOwnerCannotLeave, style: _sub(context))
            : Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(foregroundColor: c.badInk),
                  onPressed: () => _leave(ws?.name ?? ''),
                  child: Text(l.wsLeave),
                ),
              ),
      ),
      if (owner)
        Section(
          title: l.wsInvite,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l.wsInviteSub, style: _sub(context)),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(labelText: l.wsInviteEmail),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Text(l.wsInviteAs, style: TextStyle(fontSize: 14.5, color: c.ink2))),
              Segmented<CreateInviteRequestRoleEnum>(
                options: [(CreateInviteRequestRoleEnum.user, l.wsRole_user), (CreateInviteRequestRoleEnum.viewer, l.wsRole_viewer)],
                value: _inviteRole,
                onChanged: (r) => setState(() => _inviteRole = r),
              ),
            ]),
            Padding(padding: const EdgeInsets.only(top: 4), child: Text(l.wsInviteAsHelp, style: _sub(context))),
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: FilledButton(onPressed: _busy ? null : _invite, child: Text(l.wsInviteSend))),
            if (_created != null) ...[
              const SizedBox(height: 14),
              Text(l.wsInviteLink, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink3)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
                decoration: BoxDecoration(color: c.hover, borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  Expanded(child: SelectableText(_created!.url, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13, color: c.ink))),
                  CopyButton(_created!.url),
                ]),
              ),
              if (_created!.emailed == true) Padding(padding: const EdgeInsets.only(top: 6), child: Text(l.wsInviteEmailed(_created!.invite.email), style: _sub(context))),
            ],
            if (invites.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(l.wsInvites, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.ink)),
              const SizedBox(height: 4),
              for (final i in invites)
                Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(i.email.isEmpty ? l.wsInviteAnyone : i.email, style: TextStyle(fontSize: 14.5, color: c.ink)),
                      Text('${roleLabel(l, i.role)} · ${l.wsInviteExpires(fmtDate(context, i.expiresAt))}', style: TextStyle(fontSize: 13, color: c.ink3)),
                    ]),
                  ),
                  TextButton(
                    onPressed: () async {
                      await _call(context, ref, (api) => api.getWorkspaceApi().revokeInvite(id: i.id), done: l.wsRevoked);
                      ref.invalidate(invitesProvider);
                    },
                    child: Text(l.wsRevoke),
                  ),
                ]),
            ],
          ]),
        ),
    ]);
  }
}

// ---- Claude ----

class _ClaudeTab extends ConsumerStatefulWidget {
  const _ClaudeTab();

  @override
  ConsumerState<_ClaudeTab> createState() => _ClaudeTabState();
}

class _ClaudeTabState extends ConsumerState<_ClaudeTab> {
  bool _busy = false;
  String? _connError;

  Future<void> _update(UpdateWorkspaceClaudeRequest body) async {
    final l = AppLocalizations.of(context);
    await _call(context, ref, (api) => api.getWorkspaceApi().updateWorkspaceClaude(updateWorkspaceClaudeRequest: body), done: l.wsClaudeSaved);
    ref.invalidate(workspaceClaudeProvider);
    ref.invalidate(workspaceDetailProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final owner = ref.watch(isOwnerProvider);
    final wc = ref.watch(workspaceClaudeProvider);
    final v = wc.value;
    if (v == null) return wc.hasError ? _failed(l) : _loading();
    final member = v.mode == WorkspaceClaudeModeEnum.member;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Section(
        title: l.wsClaude,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(owner ? l.wsClaudeSub : l.wsReadOnly, style: _sub(context)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Text(l.wsMode, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink))),
            if (owner)
              Segmented<WorkspaceClaudeModeEnum>(
                options: [(WorkspaceClaudeModeEnum.shared, l.wsModeShared), (WorkspaceClaudeModeEnum.member, l.wsModeMember)],
                value: v.mode,
                onChanged: (m) {
                  if (m != v.mode) {
                    _update(UpdateWorkspaceClaudeRequest(
                      mode: m == WorkspaceClaudeModeEnum.member ? UpdateWorkspaceClaudeRequestModeEnum.member : UpdateWorkspaceClaudeRequestModeEnum.shared,
                    ));
                  }
                },
              )
            else
              ToneBadge(member ? l.wsModeMember : l.wsModeShared, Tone.info),
          ]),
          Padding(padding: const EdgeInsets.only(top: 4), child: Text(member ? l.wsModeMemberHelp : l.wsModeSharedHelp, style: _sub(context))),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.wsFallback, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink)),
                Text(l.wsCredits(v.creditsBalance), style: _sub(context)),
              ]),
            ),
            Switch(value: v.fallback, onChanged: owner ? (x) => _update(UpdateWorkspaceClaudeRequest(fallback: x)) : null),
          ]),
          Text(l.wsFallbackHelp, style: _sub(context)),
          if (member) ...[
            const SizedBox(height: 14),
            Text(l.wsDefaultMember, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink)),
            DropdownButton<int>(
              isExpanded: true,
              value: v.members.any((m) => m.userId == v.defaultMemberId) ? v.defaultMemberId : 0,
              items: [
                DropdownMenuItem(value: 0, child: Text(l.wsDefaultOwner)),
                for (final m in v.members) DropdownMenuItem(value: m.userId, child: Text(m.username)),
              ],
              onChanged: owner ? (id) => _update(UpdateWorkspaceClaudeRequest(defaultMemberId: id ?? 0)) : null,
            ),
            Text(l.wsDefaultMemberHelp, style: _sub(context)),
          ],
        ]),
      ),
      Section(
        title: l.wsConnection,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.wsConnectionSub, style: _sub(context)),
          const SizedBox(height: 12),
          ClaudeConnect(
            state: v.connection,
            subscriptions: v.subscriptionsAllowed,
            readonly: !owner,
            busy: _busy,
            error: _connError,
            onConnect: (kind, token) async {
              final api = ref.read(apiProvider);
              if (api == null) return false;
              setState(() => _busy = true);
              try {
                await api.getWorkspaceApi().setWorkspaceClaudeConnection(claudeConnectionInput: ClaudeConnectionInput(kind: kind, token: token));
                ref.invalidate(workspaceClaudeProvider);
                if (mounted) setState(() => _connError = null);
                return true;
              } catch (e) {
                if (mounted) setState(() => _connError = errorMessage(e, l.commonError));
                return false;
              } finally {
                if (mounted) setState(() => _busy = false);
              }
            },
            onDisconnect: () async {
              setState(() => _busy = true);
              await _call(context, ref, (api) => api.getWorkspaceApi().deleteWorkspaceClaudeConnection());
              ref.invalidate(workspaceClaudeProvider);
              if (mounted) setState(() => _busy = false);
            },
          ),
        ]),
      ),
      SectionHeader(l.wsMemberAccounts, trailing: TextButton(onPressed: () => context.push('/profile'), child: Text(l.wsYourAccount))),
      Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 8), child: Text(l.wsMemberAccountsSub, style: _sub(context))),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListGroup(children: [
          for (final m in v.members)
            ListRow(
              title: m.username,
              subtitle: m.pausedUntil == null ? null : l.wsPausedUntil(fmtDateTime(context, m.pausedUntil!)),
              trailing: ToneBadge(m.connected ? l.wsConnected : l.wsNotConnected, m.connected ? (m.pausedUntil != null ? Tone.warn : Tone.ok) : Tone.gray),
            ),
        ]),
      ),
    ]);
  }
}

// ---- Billing ----

/// US dollars, with cents (tenths of a cent under a dollar) only when needed.
@visibleForTesting
String usd(num n) =>
    NumberFormat.currency(locale: 'en_US', symbol: r'$', decimalDigits: n == n.roundToDouble() ? 0 : (n < 1 ? 3 : 2)).format(n);

/// So'm, grouped by spaces.
@visibleForTesting
String som(int n) => NumberFormat.decimalPattern('ru').format(n).replaceAll(RegExp(r'[\s  ,]'), ' ');

class _BillingTab extends ConsumerStatefulWidget {
  const _BillingTab();

  @override
  ConsumerState<_BillingTab> createState() => _BillingTabState();
}

class _BillingTabState extends ConsumerState<_BillingTab> {
  int? _slots;
  int _amount = 100000;
  bool _busy = false;

  Future<void> _saveSlots(int slots) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    await _call(context, ref, (api) => api.getBillingApi().setSlots(setSlotsRequest: SetSlotsRequest(slots: slots)), done: l.billingSlotsSaved('$slots'));
    ref.invalidate(billingProvider);
    ref.invalidate(workspaceDetailProvider);
    ref.invalidate(meProvider);
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _checkout(CheckoutCreditsRequestProviderEnum provider) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    String? url;
    await _call(context, ref, (api) async {
      url = (await api.getBillingApi().checkoutCredits(checkoutCreditsRequest: CheckoutCreditsRequest(amountUzs: _amount, provider: provider))).data?.url;
    });
    if (mounted) setState(() => _busy = false);
    if (url == null || !mounted) return;
    await openLink(context, url!);
    if (mounted) showSnack(context, l.maccountPaying);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final billing = ref.watch(billingProvider);
    final b = billing.value;
    if (b == null) return billing.hasError ? _failed(l) : _loading();
    final slots = _slots ?? b.slots;
    final credits = b.prices.creditUzs > 0 ? _amount ~/ b.prices.creditUzs : 0;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (b.selfHosted == true) Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 0), child: HelpBox(l.billingSelfHosted)),
      Section(
        title: l.billingPlan,
        trailing: ToneBadge(b.plan, Tone.info),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.billingPlanSub('${b.prices.includedMembers}'), style: _sub(context)),
          if (b.monthlyUsd != null && b.monthlyUsd! > 0) Padding(padding: const EdgeInsets.only(top: 6), child: Text(l.billingMonthly(usd(b.monthlyUsd!)))),
          if (b.trialEndsAt != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(l.billingTrialUntil(fmtDate(context, b.trialEndsAt!)))),
          const SizedBox(height: 14),
          Text(l.billingSlots, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink)),
          const SizedBox(height: 6),
          Row(children: [
            _Stepper(
              label: '$slots',
              onMinus: slots > 1 ? () => setState(() => _slots = slots - 1) : null,
              onPlus: slots < b.maxSlots ? () => setState(() => _slots = slots + 1) : null,
            ),
            const SizedBox(width: 12),
            OutlinedButton(onPressed: slots == b.slots || _busy ? null : () => _saveSlots(slots), child: Text(l.billingSlotsSave)),
          ]),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              b.selfHosted == true ? l.billingSlotsHelpSelfHosted('${b.maxSlots}') : l.billingSlotsHelp(usd(b.prices.slotUsd)),
              style: _sub(context),
            ),
          ),
          const SizedBox(height: 14),
          _Kv(
            label: l.billingMembers,
            value: b.memberLimit > 0 ? '${b.members} / ${b.memberLimit}' : '${b.members}',
            note: l.billingMembersHelp('${b.prices.includedMembers}', usd(b.prices.memberUsd)),
          ),
        ]),
      ),
      Section(
        title: l.billingCredits,
        trailing: ToneBadge(l.wsCredits(b.creditsBalance), b.creditsBalance > 0 ? Tone.ok : Tone.gray),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.billingCreditsSub, style: _sub(context)),
          const SizedBox(height: 6),
          Text(l.billingCreditPrice(usd(b.prices.creditUsd)), style: _sub(context)),
          if (b.paymentsEnabled) ...[
            const SizedBox(height: 14),
            Text(l.billingAmount, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink)),
            const SizedBox(height: 6),
            _Stepper(
              label: som(_amount),
              onMinus: _amount > 10000 ? () => setState(() => _amount = (_amount - 50000).clamp(10000, 50000000)) : null,
              onPlus: _amount < 50000000 ? () => setState(() => _amount = (_amount + 50000).clamp(10000, 50000000)) : null,
            ),
            Padding(padding: const EdgeInsets.only(top: 6), child: Text(l.billingYouGet('$credits'), style: _sub(context))),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              FilledButton(
                onPressed: _busy ? null : () => _checkout(CheckoutCreditsRequestProviderEnum.payme),
                child: Text(l.billingPayWith('Payme')),
              ),
              FilledButton(
                onPressed: _busy ? null : () => _checkout(CheckoutCreditsRequestProviderEnum.click),
                child: Text(l.billingPayWith('Click')),
              ),
            ]),
          ] else
            Padding(padding: const EdgeInsets.only(top: 10), child: HelpBox(l.billingPaymentsOff)),
        ]),
      ),
      SectionHeader(l.billingHistory),
      if (b.ledger.isEmpty)
        EmptyState(title: l.billingNoHistory)
      else
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListGroup(children: [
            for (final e in b.ledger)
              ListRow(
                title: [if (e.ticketKey?.isNotEmpty ?? false) e.ticketKey!, if (e.note?.isNotEmpty ?? false) e.note!].join(' · ').ifEmpty(_reason(l, e.reason)),
                subtitle: '${_reason(l, e.reason)} · ${fmtDateTime(context, e.createdAt)}',
                trailing: Text(
                  '${e.amount > 0 ? '+' : ''}${e.amount}',
                  style: TextStyle(fontFamily: AgntsFonts.mono, fontWeight: FontWeight.w700, color: e.amount < 0 ? c.badInk : c.okInk),
                ),
                onTap: e.ticketKey?.isNotEmpty ?? false ? () => context.push('/tickets/${e.ticketKey}') : null,
              ),
          ]),
        ),
    ]);
  }
}

String _reason(AppLocalizations l, LedgerEntryReasonEnum r) => switch (r) {
      LedgerEntryReasonEnum.purchase => l.billingReason_purchase,
      LedgerEntryReasonEnum.run => l.billingReason_run,
      LedgerEntryReasonEnum.document => l.mdocumentsLedgerSpent,
      LedgerEntryReasonEnum.refund => l.billingReason_refund,
      LedgerEntryReasonEnum.grant => l.billingReason_grant,
    };

extension on String {
  String ifEmpty(String other) => isEmpty ? other : this;
}

/// − value + (the web's NumberStepper).
class _Stepper extends StatelessWidget {
  const _Stepper({required this.label, this.onMinus, this.onPlus});
  final String label;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return Container(
      decoration: BoxDecoration(border: Border.all(color: c.line), borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(tooltip: l.formDecrease, onPressed: onMinus, icon: const Icon(Icons.remove_rounded)),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 15, fontWeight: FontWeight.w700, color: c.ink)),
        ),
        IconButton(tooltip: l.formIncrease, onPressed: onPlus, icon: const Icon(Icons.add_rounded)),
      ]),
    );
  }
}

/// A setting shown, not edited: label and value on a line, a note under it.
class _Kv extends StatelessWidget {
  const _Kv({required this.label, required this.value, this.note});
  final String label;
  final String value;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink))),
        Text(value, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 14.5, color: c.ink)),
      ]),
      if (note != null) Padding(padding: const EdgeInsets.only(top: 2), child: Text(note!, style: _sub(context))),
    ]);
  }
}

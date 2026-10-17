import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../core/session.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../../widgets/workspace.dart';

/// The token of an invite link (`…/invite/TOKEN`), or the text itself when
/// it is a bare token; null when there is none.
@visibleForTesting
String? inviteToken(String text) {
  final t = text.trim();
  if (t.isEmpty) return null;
  final m = RegExp(r'/invite/([^/?#\s]+)').firstMatch(t);
  if (m != null) return m.group(1);
  return RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(t) ? t : null;
}

/// The workspaces the person is in: switch to one, create one, or open an
/// invite link someone sent (the web's Workspaces page).
class WorkspacesScreen extends ConsumerStatefulWidget {
  const WorkspacesScreen({super.key});

  @override
  ConsumerState<WorkspacesScreen> createState() => _WorkspacesScreenState();
}

class _WorkspacesScreenState extends ConsumerState<WorkspacesScreen> {
  final _name = TextEditingController();
  final _slug = TextEditingController();
  final _invite = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _slug, _invite]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _open(WorkspaceSummary w) async {
    final l = AppLocalizations.of(context);
    await ref.read(sessionProvider.notifier).setWorkspace(w.slug);
    if (!mounted) return;
    showSnack(context, l.mwsSwitched(w.name));
    context.go('/home');
  }

  Future<void> _create() async {
    final l = AppLocalizations.of(context);
    final api = ref.read(apiProvider);
    if (api == null || _name.text.trim().isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final ws = (await api.getWorkspacesApi().createWorkspace(
                createWorkspaceRequest: CreateWorkspaceRequest(
                  name: _name.text.trim(),
                  slug: _slug.text.trim().isEmpty ? null : _slug.text.trim(),
                ),
              ))
          .data!;
      ref.invalidate(meProvider);
      await ref.read(meProvider.future);
      await _open(ws);
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
    final me = ref.watch(meProvider).value;
    final list = me?.workspaces ?? const <WorkspaceSummary>[];
    final current = ref.watch(currentWorkspaceProvider)?.slug;
    final token = inviteToken(_invite.text);
    return Scaffold(
      appBar: DetailBar(backLabel: l.mobileMore),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(meProvider),
        child: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
          PageHeader(title: l.accountWorkspacesTitle, long: true),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Text(l.accountWorkspacesLede, style: TextStyle(fontSize: 14.5, height: 1.4, color: c.ink2)),
          ),
          const SizedBox(height: 8),
          if (list.isEmpty)
            EmptyState(title: l.accountNoWorkspacesTitle, text: l.accountNoWorkspaces)
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListGroup(children: [
                for (final w in list)
                  ListRow(
                    title: w.name,
                    subtitle: [
                      '/w/${w.slug}',
                      roleLabel(l, w.role),
                      l.accountMemberCount(w.members),
                      l.accountSlotCount(w.slots),
                      if (w.suspended == true) l.accountSuspended,
                    ].join(' · '),
                    trailing: w.slug == current ? ToneBadge(l.maccountCurrent, Tone.ok) : null,
                    onTap: () => _open(w),
                  ),
              ]),
            ),
          SectionHeader(list.isEmpty ? l.accountCreateFirst : l.accountCreateWorkspace),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: HCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text(l.accountCreateWorkspaceSub, style: TextStyle(fontSize: 13.5, color: c.ink3)),
                const SizedBox(height: 12),
                TextField(
                  controller: _name,
                  maxLength: 80,
                  decoration: InputDecoration(labelText: l.accountWorkspaceName, counterText: ''),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _slug,
                  maxLength: 40,
                  autocorrect: false,
                  style: const TextStyle(fontFamily: AgntsFonts.mono),
                  decoration: InputDecoration(labelText: l.accountWorkspaceSlug, helperText: l.accountWorkspaceSlugHelp, counterText: ''),
                ),
                if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: HelpBox(_error!, tone: Tone.bad)),
                const SizedBox(height: 14),
                FilledButton(onPressed: _busy || _name.text.trim().isEmpty ? null : _create, child: Text(l.accountCreateWs)),
              ]),
            ),
          ),
          SectionHeader(l.maccountHaveInvite),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: HCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                TextField(
                  controller: _invite,
                  autocorrect: false,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(labelText: l.maccountInviteHint),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: token == null ? null : () => context.push('/invite/${Uri.encodeComponent(token)}'),
                  child: Text(l.maccountInviteOpen),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

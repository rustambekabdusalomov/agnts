import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../../widgets/workspace.dart' show roleLabel;
import 'admin_data.dart';
import 'admin_widgets.dart';

enum _Filter { all, active, new_, google }

/// The platform's Users (Admin accounts are under Admins): how they sign in,
/// which workspaces they are in and when they last signed in.
class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key, this.filter});

  /// "active", "new" or "google" from a link (the dashboard's tiles).
  final String? filter;

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  late _Filter _filter = _parse(widget.filter);
  String _q = '';

  static _Filter _parse(String? f) => switch (f) {
    'active' => _Filter.active,
    'new' => _Filter.new_,
    'google' => _Filter.google,
    _ => _Filter.all,
  };

  @override
  void didUpdateWidget(AdminUsersScreen old) {
    super.didUpdateWidget(old);
    // The tab stays alive, so a new link changes the filter here.
    if (widget.filter != old.filter) _filter = _parse(widget.filter);
  }

  static bool _matches(PlatformUser u, _Filter f) => switch (f) {
    _Filter.all => true,
    _Filter.active => within(u.lastSignInAt, 7),
    _Filter.new_ => within(u.user.createdAt, 7),
    _Filter.google => !u.hasPassword,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AsyncBody<List<PlatformUser>>(
          value: ref.watch(platformUsersProvider),
          onRefresh: () async {
            ref.invalidate(platformUsersProvider);
            await ref.read(platformUsersProvider.future);
          },
          builder: (all) {
            final people = all.where((u) => u.user.isAdmin != true).toList();
            final s = _q.trim().toLowerCase();
            final list =
                people
                    .where((u) => _matches(u, _filter))
                    .where(
                      (u) =>
                          s.isEmpty ||
                          [
                            u.user.username,
                            u.user.displayName ?? '',
                            u.user.email ?? '',
                            ...u.workspaces.map((w) => w.name),
                          ].any((x) => x.toLowerCase().contains(s)),
                    )
                    .toList()
                  ..sort((a, b) => (b.user.createdAt ?? DateTime(0)).compareTo(a.user.createdAt ?? DateTime(0)));
            int count(_Filter f) => people.where((u) => _matches(u, f)).length;
            return ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                PageHeader(title: l.platformUsers, sub: l.platformUsersLede),
                FilterBar<_Filter>(
                  filters: [
                    (_Filter.all, l.platformU_all, count(_Filter.all)),
                    (_Filter.active, l.platformU_active, count(_Filter.active)),
                    (_Filter.new_, l.platformU_new, count(_Filter.new_)),
                    (_Filter.google, l.platformU_google, count(_Filter.google)),
                  ],
                  value: _filter,
                  onChanged: (f) => setState(() => _filter = f),
                  hint: l.platformSearchUsers,
                  onSearch: (v) => setState(() => _q = v),
                ),
                if (list.isEmpty)
                  EmptyState(title: l.platformNoUsers)
                else
                  for (final u in list) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 10), child: _UserCard(u)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard(this.u);
  final PlatformUser u;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final unverified = (u.user.email?.isNotEmpty ?? false) && u.user.emailVerified != true;
    return HCard(
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PersonRow(user: u.user, sub: '${contactOf(u.user)}${unverified ? ' · ${l.platformUnverified}' : ''}'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ToneBadge(u.hasPassword ? l.platformPassword : 'Google', u.hasPassword ? Tone.gray : Tone.ok, small: true),
                    if (u.user.hasTotp == true) const ToneBadge('2FA', Tone.gray, small: true),
                    for (final w in u.workspaces)
                      ToneBadge(w.role == WorkspaceRole.owner ? '${w.name} · ${roleLabel(l, w.role)}' : w.name, Tone.info, small: true),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${l.platformJoined}: ${agoText(context, u.user.createdAt)} · ${l.platformLastSeen}: ${agoText(context, u.lastSignInAt)}',
                  style: TextStyle(fontSize: 12.5, color: c.ink3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

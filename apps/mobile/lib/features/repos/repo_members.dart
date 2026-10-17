import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';

final _membersProvider = FutureProvider.autoDispose.family<List<RepoMember>, int>((ref, id) async {
  return (await requireApi(ref).getReposApi().listRepoMembers(id: id)).data ?? const [];
});

/// Members whose username or name contains [q], ignoring case.
List<RepoMember> filterMembers(List<RepoMember> all, String q) {
  final s = q.trim().toLowerCase();
  if (s.isEmpty) return all;
  return all.where((m) => m.username.toLowerCase().contains(s) || (m.name?.toLowerCase().contains(s) ?? false)).toList();
}

/// Who has access to the repository on GitHub or GitLab (MembersTab.vue):
/// the people a pull request can be assigned to when a review is approved.
class RepoMembersTab extends ConsumerStatefulWidget {
  const RepoMembersTab({super.key, required this.repo});
  final Repository repo;

  @override
  ConsumerState<RepoMembersTab> createState() => _RepoMembersTabState();
}

class _RepoMembersTabState extends ConsumerState<RepoMembersTab> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final members = ref.watch(_membersProvider(widget.repo.id));
    final sub = widget.repo.provider == RepositoryProviderEnum.gitlab ? l.repoMembersSub_gitlab : l.repoMembersSub_github;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 10), child: Text(sub, style: TextStyle(fontSize: 13.5, color: c.ink3))),
      ...switch (members) {
        AsyncData(:final value) => [
            if (value.length > 8) SearchBox(hint: l.repoMembersSearch, onChanged: (v) => setState(() => _q = v)),
            if (filterMembers(value, _q) case final rows when rows.isEmpty)
              EmptyState(title: _q.isNotEmpty ? l.reposNoMatch : l.repoMembersNone)
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListGroup(children: [
                  for (final m in filterMembers(value, _q))
                    ListRow(
                      leading: _MemberAvatar(m),
                      title: m.name?.isNotEmpty == true ? m.name! : m.username,
                      subtitle: m.name?.isNotEmpty == true ? '@${m.username}' : null,
                      trailing: ToneBadge(m.role, Tone.gray, small: true),
                    ),
                ]),
              ),
          ],
        AsyncError(:final error) => [Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: HelpBox(errorMessage(error, l.commonError), tone: Tone.bad))],
        _ => [const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))],
      },
    ]);
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar(this.m);
  final RepoMember m;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final letter = Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: c.graySoft, shape: BoxShape.circle),
      child: Text(m.username.isEmpty ? '?' : m.username[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.w700, color: c.grayInk)),
    );
    final url = m.avatarUrl;
    if (url == null || url.isEmpty) return letter;
    return ClipOval(
      child: Image.network(url, width: 34, height: 34, fit: BoxFit.cover, errorBuilder: (_, _, _) => letter),
    );
  }
}

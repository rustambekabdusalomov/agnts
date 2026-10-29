import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';
import 'package:intl/intl.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'repo_diff.dart';
import 'repo_screen.dart' show CiDot, RepoPipelineCard, ciLabel;
import '../account/account_widgets.dart' show openLink;

typedef _Key = ({int repoId, String sha});

final _commitProvider = FutureProvider.autoDispose.family<CommitDetail, _Key>((ref, k) async {
  return (await requireApi(ref).getReposApi().getRepoCommit(id: k.repoId, sha: k.sha)).data!;
});

/// The commit's overall CI state from its runs, as CommitPage.vue works it out:
/// any failure, else anything running, waiting or manual; all skipped or
/// canceled shows that; otherwise passed.
CI commitCi(List<Pipeline> ps) {
  if (ps.isEmpty) return CI.none;
  for (final s in const [CI.fail, CI.run, CI.pending, CI.manual]) {
    if (ps.any((p) => p.status == s)) return s;
  }
  return ps.every((p) => p.status == CI.skip || p.status == CI.canceled) ? ps.first.status : CI.ok;
}

/// The message's first line, and the rest without surrounding blank lines.
(String, String) splitMessage(String message) {
  final lines = message.split('\n');
  return (lines.first, lines.skip(1).join('\n').trim());
}

/// One commit as the git host has it (CommitPage.vue): who wrote it, its
/// full message, the CI runs on it, the pull requests that carry it and the
/// files it changed.
class CommitScreen extends ConsumerStatefulWidget {
  const CommitScreen({super.key, required this.repoId, required this.sha});
  final int repoId;
  final String sha;

  @override
  ConsumerState<CommitScreen> createState() => _CommitScreenState();
}

class _CommitScreenState extends ConsumerState<CommitScreen> {
  Timer? _poll;

  _Key get _key => (repoId: widget.repoId, sha: widget.sha);

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final commit = ref.watch(_commitProvider(_key));
    // Poll while a run is going.
    _poll?.cancel();
    if (commit.value?.pipelines.any((p) => p.status == CI.run || p.status == CI.pending) ?? false) {
      _poll = Timer(const Duration(seconds: 15), () => ref.invalidate(_commitProvider(_key)));
    }
    return Scaffold(
      appBar: DetailBar(backLabel: l.navBack, title: _short(widget.sha)),
      body: AsyncBody<CommitDetail>(
        value: commit,
        onRefresh: () => ref.refresh(_commitProvider(_key).future),
        builder: (x) => _body(context, l, c, x),
      ),
    );
  }

  Widget _body(BuildContext context, AppLocalizations l, Agnts c, CommitDetail x) {
    final loc = Localizations.localeOf(context).toLanguageTag();
    final (title, body) = splitMessage(x.message);
    final hint = TextStyle(fontSize: 13, color: c.ink3);
    String when(DateTime? at) => at == null ? '—' : DateFormat.yMMMd(loc).add_Hm().format(at.toLocal());
    final sameCommitter = x.committer == null || (x.committer == x.author && x.committerEmail == x.authorEmail);
    Widget kv(String k, Widget v) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(k, style: hint)),
          Expanded(child: v),
        ],
      ),
    );
    final bold = TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.ink);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title.isEmpty ? _short(x.sha) : title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CiDot(commitCi(x.pipelines)),
                      const SizedBox(width: 6),
                      Text(ciLabel(l, commitCi(x.pipelines)), style: hint),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        x.sha.length > 12 ? x.sha.substring(0, 12) : x.sha,
                        style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink2),
                      ),
                      CopyButton(x.sha),
                    ],
                  ),
                  Text(l.commitAuthoredAgo(x.author, x.date == null ? '—' : _ago(l, x.date!)), style: hint),
                  Text.rich(
                    TextSpan(
                      style: hint.copyWith(fontWeight: FontWeight.w700),
                      children: [
                        TextSpan(
                          text: '+${x.add}',
                          style: TextStyle(color: c.okInk),
                        ),
                        TextSpan(
                          text: ' −${x.del}',
                          style: TextStyle(color: c.badInk),
                        ),
                      ],
                    ),
                  ),
                  Text(l.commitFilesN(x.files.length), style: hint),
                ],
              ),
              if (x.ticketKey != null || (x.tickets?.isNotEmpty ?? false) || x.url.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (x.tickets?.isNotEmpty ?? false)
                        for (final t in x.tickets!)
                          OutlinedButton(
                            onPressed: () => context.push('/tickets/${t.key}'),
                            child: Text(t.number != null && t.number != t.key ? '${t.number} · ${t.key}' : t.key),
                          )
                      else if (x.ticketKey != null)
                        OutlinedButton(onPressed: () => context.push('/tickets/${x.ticketKey}'), child: Text(x.ticketKey!)),
                      if (x.url.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: () => openLink(context, x.url),
                          icon: Icon(Icons.open_in_new_rounded, size: 16, color: c.ink2),
                          label: Text(l.mrepodetailCopyLink(x.provider == CommitDetailProviderEnum.gitlab ? 'GitLab' : 'GitHub')),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        // Author
        SectionHeader(l.commitAuthor),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _Av(name: x.author, url: x.authorAvatar),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(x.author, style: bold),
                          if (x.authorLogin?.isNotEmpty == true) Text('@${x.authorLogin}', style: hint),
                          if (x.authorEmail?.isNotEmpty == true)
                            Text(x.authorEmail!, style: hint.copyWith(fontFamily: AgntsFonts.mono, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                kv(l.commitAuthored, Text(when(x.date), style: bold)),
                if (!sameCommitter) kv(l.commitCommitter, Text(x.committer!, style: bold)),
                if (x.committedDate != null && x.committedDate != x.date) kv(l.commitCommitted, Text(when(x.committedDate), style: bold)),
                kv(
                  l.commitParents(x.parents.length),
                  x.parents.isEmpty
                      ? Text('—', style: bold)
                      : Wrap(
                          spacing: 10,
                          children: [
                            for (final p in x.parents)
                              InkWell(
                                onTap: () => context.push('/repos/${widget.repoId}/commits/$p'),
                                child: Text(
                                  _short(p),
                                  style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13, color: c.primaryInk),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
        // Pull requests that carry it
        SectionHeader(l.commitPulls),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(l.commitPullsSub, style: hint),
        ),
        if (x.pulls.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(l.commitNoPulls, style: TextStyle(color: c.ink3)),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListGroup(
              children: [
                for (final p in x.pulls)
                  ListRow(
                    leading: ToneBadge(
                      switch (p.state) {
                        CommitPullStateEnum.open => l.pullsState_open,
                        CommitPullStateEnum.merged => l.pullsState_merged,
                        CommitPullStateEnum.closed => l.pullsState_closed,
                      },
                      switch (p.state) {
                        CommitPullStateEnum.open => Tone.info,
                        CommitPullStateEnum.merged => Tone.ok,
                        CommitPullStateEnum.closed => Tone.gray,
                      },
                      small: true,
                    ),
                    title: '#${p.number} ${p.title}',
                    onTap: () => context.push('/repos/${widget.repoId}/pulls/${p.number}'),
                  ),
              ],
            ),
          ),
        if (body.isNotEmpty) ...[
          SectionHeader(l.commitMessage),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: HCard(
              child: SelectableText(
                body,
                style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13, height: 1.45, color: c.ink),
              ),
            ),
          ),
        ],
        // CI runs
        SectionHeader(l.repoPipelines),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(l.commitPipelinesSub, style: hint),
        ),
        if (x.pipelines.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(l.commitNoPipelines, style: TextStyle(color: c.ink3)),
          )
        else
          for (final (i, p) in x.pipelines.indexed)
            Padding(
              padding: EdgeInsets.fromLTRB(16, i == 0 ? 0 : 10, 16, 0),
              child: RepoPipelineCard(repoId: widget.repoId, p: p),
            ),
        // Changed files
        SectionHeader(l.commitChanges),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
          child: Text(l.commitChangesSub(x.files.length, '${x.add}', '${x.del}'), style: hint),
        ),
        if (x.filesCapped == true)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: HelpBox(l.commitFilesCapped('${x.files.length}'), tone: Tone.warn),
          ),
        if (x.files.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(l.commitNoFiles, style: TextStyle(color: c.ink3)),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Large commits open collapsed; a handful of files open at once.
                for (final f in x.files) RepoFileDiff(file: f, initiallyOpen: x.files.length <= 5),
              ],
            ),
          ),
      ],
    );
  }
}

class _Av extends StatelessWidget {
  const _Av({required this.name, this.url});
  final String name;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final letter = Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: c.graySoft, shape: BoxShape.circle),
      child: Text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        style: TextStyle(fontWeight: FontWeight.w700, color: c.grayInk),
      ),
    );
    if (url == null || url!.isEmpty) return letter;
    return ClipOval(
      child: Image.network(url!, width: 44, height: 44, fit: BoxFit.cover, errorBuilder: (_, _, _) => letter),
    );
  }
}

String _short(String sha) => sha.substring(0, sha.length < 7 ? sha.length : 7);

String _ago(AppLocalizations l, DateTime at) {
  final d = DateTime.now().difference(at);
  return d.inMinutes < 1 ? l.mmoreJustNow : l.mmoreAgo(shortDuration(d));
}

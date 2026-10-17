import 'package:dio/dio.dart';
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
import '../ci/ci_screen.dart' show ciAgo;
import 'pull_widgets.dart';
import 'pulls_data.dart';

/// The repository's pull requests (GitLab merge requests) on the git host,
/// as a non-scrolling column for the repo screen, with agnts's ticket for
/// each: its own change, or its review. One with neither can be reviewed by
/// agnts from here.
class RepoPullsList extends ConsumerStatefulWidget {
  const RepoPullsList({super.key, required this.repoId});
  final int repoId;

  @override
  ConsumerState<RepoPullsList> createState() => _RepoPullsListState();
}

class _RepoPullsListState extends ConsumerState<RepoPullsList> {
  String _state = 'open';
  int _pages = 1;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final canEdit = ref.watch(canEditProvider);
    final pages = [for (var p = 1; p <= _pages; p++) ref.watch(repoPullsPageProvider((widget.repoId, _state, p)))];
    final first = pages.first;
    final last = pages.last;
    final all = [for (final p in pages) ...?p.value];
    final more = last.hasValue && last.value!.length >= pullsPerPage;

    Widget pad(Widget w) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: w);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        pad(Text(l.pullsSub, style: TextStyle(fontSize: 13.5, height: 1.4, color: c.ink3))),
        const SizedBox(height: 10),
        pad(
          Segmented<String>(
            full: true,
            options: [for (final s in pullStates) (s, pullStateLabel(l, s))],
            value: _state,
            onChanged: (s) => setState(() {
              _state = s;
              _pages = 1;
            }),
          ),
        ),
        const SizedBox(height: 10),
        if (first.isLoading && !first.hasValue)
          const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator())
        else if (first.hasError && !first.hasValue)
          pad(HelpBox(errorMessage(first.error!, l.commonError), tone: Tone.bad))
        else if (all.isEmpty)
          EmptyState(title: l.pullsNone)
        else ...[
          pad(ListGroup(children: [for (final p in all) _row(context, p, canEdit)])),
          const SizedBox(height: 8),
          if (last.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (last.hasError)
            pad(HelpBox(errorMessage(last.error!, l.commonError), tone: Tone.bad))
          else if (more)
            Center(
              child: TextButton(onPressed: () => setState(() => _pages++), child: Text(l.repoLoadMore)),
            )
          else
            Center(
              child: Text(l.pullsEnd, style: TextStyle(fontSize: 13, color: c.ink3)),
            ),
        ],
      ],
    );
  }

  Widget _row(BuildContext context, PullItem p, bool canEdit) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final why = whyLabel(l, p.why);
    return InkWell(
      onTap: () => context.push('/repos/${widget.repoId}/pulls/${p.number}'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${p.number}',
                  style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13, color: c.ink3),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    p.title,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.3, color: c.ink),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            DefaultTextStyle.merge(
              style: TextStyle(fontSize: 12.5, color: c.ink3),
              child: Wrap(
                spacing: 10,
                runSpacing: 2,
                children: [
                  Text(p.author),
                  Text(
                    '${p.headRef} → ${p.baseRef}',
                    style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink3),
                  ),
                  Text(l.pullsUpdated(ciAgo(l, p.updatedAt))),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ToneBadge(pullStateLabel(l, p.state.value), pullStateTone(p.state), small: true),
                if (p.draft) ToneBadge(l.pullsDraft, Tone.gray, small: true),
                if (why != null) ToneBadge(why, Tone.warn, small: true),
                if (p.ticketKey != null)
                  ToneBadge(p.own ? l.pullsOwnTicket(p.ticketKey!) : l.pullsReviewTicket(p.ticketKey!), Tone.info, small: true),
                if (canEdit && p.state == PullItemStateEnum.open && p.ticketKey == null)
                  TextButton(
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 8)),
                    onPressed: () => askReview(context, ref, repoId: widget.repoId, number: p.number),
                    child: Text(l.draftsReviewWithBtn),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Asks agnts to review a pull request, for you: a review ticket whose
/// comments stay drafts in agnts until you accept and publish them.
/// Approving it finishes the review; it never merges. True when it started.
Future<bool> askReview(BuildContext context, WidgetRef ref, {required int repoId, required int number}) async {
  final l = AppLocalizations.of(context);
  final focus = TextEditingController();
  var deep = ReviewRepoPullRequestDeepEnum.empty;
  final go = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) {
        final c = Agnts.of(ctx);
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.draftsReviewTitle('$number'), style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(l.draftsReviewSub, style: TextStyle(fontSize: 14, height: 1.45, color: c.ink3)),
              const SizedBox(height: 12),
              Text(l.draftsFocusLabel, style: TextStyle(fontSize: 13.5, color: c.ink3)),
              const SizedBox(height: 6),
              TextField(
                controller: focus,
                minLines: 2,
                maxLines: 4,
                maxLength: 2000,
                decoration: InputDecoration(hintText: l.draftsFocusHint),
              ),
              Text(l.draftsDeepLabel, style: TextStyle(fontSize: 13.5, color: c.ink3)),
              const SizedBox(height: 6),
              Segmented<ReviewRepoPullRequestDeepEnum>(
                full: true,
                options: [
                  (ReviewRepoPullRequestDeepEnum.empty, l.draftsDeep_default),
                  (ReviewRepoPullRequestDeepEnum.always, l.draftsDeep_always),
                  (ReviewRepoPullRequestDeepEnum.off, l.draftsDeep_off),
                ],
                value: deep,
                onChanged: (v) => setSheet(() => deep = v),
              ),
              const SizedBox(height: 14),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.draftsReviewBtn)),
            ],
          ),
        );
      },
    ),
  );
  if (go != true || !context.mounted) return false;
  final f = focus.text.trim();
  try {
    final t =
        (await ref
                .read(apiProvider)!
                .getPullsApi()
                .reviewRepoPull(
                  id: repoId,
                  number: number,
                  reviewRepoPullRequest: ReviewRepoPullRequest(focus: f.isEmpty ? null : f, deep: deep),
                ))
            .data;
    _refresh(ref, repoId, number);
    if (context.mounted && t != null) showSnack(context, l.draftsStartedToast(t.key));
    return true;
  } catch (e) {
    // Already under review (someone else asked meanwhile): the page shows it.
    if (e is DioException && e.response?.statusCode == 409) _refresh(ref, repoId, number);
    if (context.mounted) showSnack(context, errorMessage(e, l.commonError));
    return false;
  }
}

void _refresh(WidgetRef ref, int repoId, int number) {
  ref.invalidate(repoPullsPageProvider);
  ref.invalidate(pullDetailProvider((repoId, number)));
  ref.invalidate(ticketsProvider);
  ref.invalidate(dashboardProvider);
}

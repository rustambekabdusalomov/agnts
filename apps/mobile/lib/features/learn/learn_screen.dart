import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hiro_api/hiro_api.dart';

import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'lesson_text.dart';

/// Lessons from pushed changes: new ones first, or one ticket's when
/// opened from a notification.
class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key, this.ticketKey});
  final String? ticketKey;

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  String _status = 'new';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Hiro.of(context);
    final key = widget.ticketKey;
    final provider = key != null ? ticketLessonsProvider(key) : lessonsProvider(_status);
    final lessons = ref.watch(provider);
    final counts = lessons.value;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(backLabel: l.navBack, onBack: () => context.canPop() ? context.pop() : context.go('/more')),
      body: AsyncBody<LessonList>(
        value: lessons,
        onRefresh: () async {
          ref.invalidate(provider);
          await ref.read(provider.future);
        },
        builder: (list) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            PageHeader(title: l.learnTitle, sub: key != null ? l.learnFromTicket(key) : l.learnLede, long: key != null),
            if (key == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Segmented<String>(
                  full: true,
                  options: [
                    ('new', l.learnViewNew('${counts?.unlearned ?? 0}')),
                    ('all', l.learnViewAll('${counts?.total ?? 0}')),
                    ('learned', l.learnViewLearned),
                  ],
                  value: _status,
                  onChanged: (v) => setState(() => _status = v),
                ),
              ),
            if (list.items.isEmpty)
              EmptyState(title: list.total == 0 ? l.learnNone : (_status == 'new' ? l.learnNoneNew : l.learnNoMatch))
            else
              for (final x in list.items) LessonTile(x),
          ],
        ),
      ),
    );
  }
}

/// A lesson in lists: title, summary, category, level and where it came from.
class LessonTile extends StatelessWidget {
  const LessonTile(this.lesson, {super.key, this.compact = false});
  final LessonBrief lesson;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Hiro.of(context);
    final x = lesson;
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 0 : 16, 0, compact ? 0 : 16, 10),
      child: Material(
        color: c.surface,
        shape: RoundedRectangleBorder(side: BorderSide(color: c.line), borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/learn/${x.id}'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Text(x.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.ink))),
                const SizedBox(width: 8),
                if (!compact)
                  x.learnedAt == null ? ToneBadge(l.learnNewBadge, Tone.info, small: true) : ToneBadge(l.learnLearned, Tone.ok, small: true),
              ]),
              const SizedBox(height: 6),
              Text(x.summary, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, height: 1.4, color: c.ink2)),
              const SizedBox(height: 10),
              Wrap(spacing: 6, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
                SourceChip(categoryLabel(l, x.category)),
                SourceChip(levelLabel(l, x.level), task: true),
                Text(l.learnReadTime(x.readMinutes), style: TextStyle(fontSize: 12.5, color: c.ink3)),
                if (!compact) Text('${x.repoName} · ${x.ticketKey}', style: TextStyle(fontSize: 12.5, color: c.ink3)),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

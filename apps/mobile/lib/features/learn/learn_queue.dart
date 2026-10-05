import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hiro_api/hiro_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';

/// The learning queue screen: done tickets and where their learn run stands.
class LearnQueueScreen extends ConsumerWidget {
  const LearnQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Hiro.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(backLabel: l.navBack, onBack: () => context.canPop() ? context.pop() : context.go('/more')),
      body: AsyncBody<List<LearnQueueItem>>(
        value: ref.watch(learnQueueProvider),
        onRefresh: () async {
          ref.invalidate(learnQueueProvider);
          await ref.read(learnQueueProvider.future);
        },
        builder: (_) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            PageHeader(title: l.learnQueueTitle, sub: l.learnQueueLede, long: true),
            const LearnQueueSection(),
          ],
        ),
      ),
    );
  }
}

/// Done tickets and where their learn run stands, with a button to queue
/// the ones never learned from (or retry failed ones).
class LearnQueueSection extends ConsumerStatefulWidget {
  const LearnQueueSection({super.key});

  @override
  ConsumerState<LearnQueueSection> createState() => _LearnQueueSectionState();
}

class _LearnQueueSectionState extends ConsumerState<LearnQueueSection> {
  bool _busy = false;

  Future<void> _learn(List<String> keys) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final api = ref.read(apiProvider)!.getLearnApi();
      for (final k in keys) {
        await api.learnFromTicket(key: k);
      }
      if (mounted) showSnack(context, keys.length == 1 ? l.learnQueued : l.learnQueuedAll(keys.length));
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      ref.invalidate(learnQueueProvider);
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = ref.watch(learnQueueProvider).value ?? const <LearnQueueItem>[];
    if (items.isEmpty) return EmptyState(title: l.learnQueueEmpty);
    final idle = [for (final x in items) if (x.status == LearnQueueItemStatusEnum.none) x.key];
    final pending = [for (final x in items) if (x.status == LearnQueueItemStatusEnum.pending) x.key];
    (String, Tone) badge(LearnQueueItemStatusEnum s) => switch (s) {
          LearnQueueItemStatusEnum.running => (l.learnStatus_running, Tone.info),
          LearnQueueItemStatusEnum.pending => (l.learnStatus_pending, Tone.warn),
          LearnQueueItemStatusEnum.failed => (l.learnStatus_failed, Tone.bad),
          LearnQueueItemStatusEnum.none => (l.learnStatus_none, Tone.gray),
        };
    return Section(
      title: l.learnQueueTitle,
      trailing: idle.length > 1
          ? TextButton(onPressed: _busy ? null : () => _learn(idle), child: Text(l.learnQueueAll('${idle.length}')))
          : null,
      child: Column(children: [
        for (final x in items)
          InkWell(
            onTap: () => context.push('/tickets/${x.key}'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(x.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Row(children: [
                      ToneBadge(badge(x.status).$1, badge(x.status).$2, small: true),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          x.status == LearnQueueItemStatusEnum.pending
                              ? l.learnQueuePosition('${pending.indexOf(x.key) + 1}')
                              : '${x.key} · ${x.repoName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12.5),
                        ),
                      ),
                    ]),
                  ]),
                ),
                if (x.status == LearnQueueItemStatusEnum.none || x.status == LearnQueueItemStatusEnum.failed)
                  TextButton(
                    onPressed: _busy ? null : () => _learn([x.key]),
                    child: Text(x.status == LearnQueueItemStatusEnum.failed ? l.learnRetryBtn : l.learnQueueBtn),
                  ),
              ]),
            ),
          ),
      ]),
    );
  }
}

import 'package:flutter/material.dart' hide Feedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'admin_data.dart';
import 'admin_widgets.dart';

enum _Filter { new_, done, all }

/// What people sent from their accounts: newest first, new ones until an
/// Admin marks them done.
class AdminFeedbackScreen extends ConsumerStatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  ConsumerState<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends ConsumerState<AdminFeedbackScreen> {
  _Filter _filter = _Filter.new_;
  String _q = '';
  final _busy = <int>{};

  static bool _matches(Feedback f, _Filter filter) => switch (filter) {
    _Filter.all => true,
    _Filter.new_ => f.status == FeedbackStatusEnum.new_,
    _Filter.done => f.status == FeedbackStatusEnum.done,
  };

  Future<void> _toggle(Feedback f) async {
    final l = AppLocalizations.of(context);
    final done = f.status == FeedbackStatusEnum.new_;
    setState(() => _busy.add(f.id));
    try {
      await ref
          .read(apiProvider)!
          .getPlatformApi()
          .updatePlatformFeedback(
            id: f.id,
            updatePlatformFeedbackRequest: UpdatePlatformFeedbackRequest(
              status: done ? UpdatePlatformFeedbackRequestStatusEnum.done : UpdatePlatformFeedbackRequestStatusEnum.new_,
            ),
          );
      ref.invalidate(platformFeedbackProvider);
      if (mounted) showSnack(context, done ? l.feedbackMarkedDone : l.feedbackReopened);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy.remove(f.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AsyncBody<List<Feedback>>(
          value: ref.watch(platformFeedbackProvider),
          onRefresh: () async {
            ref.invalidate(platformFeedbackProvider);
            await ref.read(platformFeedbackProvider.future);
          },
          builder: (all) {
            final s = _q.trim().toLowerCase();
            final list = all
                .where((f) => _matches(f, _filter))
                .where(
                  (f) =>
                      s.isEmpty ||
                      [f.title, f.description, f.sender, f.email ?? '', f.workspace ?? ''].any((v) => v.toLowerCase().contains(s)),
                )
                .toList();
            int count(_Filter f) => all.where((x) => _matches(x, f)).length;
            return ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                PageHeader(title: l.feedbackAdminTitle, sub: l.feedbackAdminLede),
                FilterBar<_Filter>(
                  filters: [
                    (_Filter.new_, l.feedbackF_new, count(_Filter.new_)),
                    (_Filter.done, l.feedbackF_done, count(_Filter.done)),
                    (_Filter.all, l.feedbackF_all, count(_Filter.all)),
                  ],
                  value: _filter,
                  onChanged: (f) => setState(() => _filter = f),
                  hint: l.feedbackSearch,
                  onSearch: (v) => setState(() => _q = v),
                ),
                if (list.isEmpty)
                  EmptyState(title: _filter == _Filter.new_ ? l.feedbackNoneNew : l.feedbackNone)
                else
                  for (final f in list)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: _FeedbackCard(f, busy: _busy.contains(f.id), onToggle: () => _toggle(f)),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard(this.f, {required this.busy, required this.onToggle});
  final Feedback f;
  final bool busy;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final isNew = f.status == FeedbackStatusEnum.new_;
    return Opacity(
      opacity: isNew ? 1 : 0.75,
      child: HCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    f.title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.ink),
                  ),
                ),
                const SizedBox(width: 8),
                ToneBadge(isNew ? l.feedbackS_new : l.feedbackS_done, isNew ? Tone.warn : Tone.ok, small: true),
              ],
            ),
            const SizedBox(height: 6),
            SelectableText(f.description, style: TextStyle(fontSize: 14.5, height: 1.45, color: c.ink2)),
            const SizedBox(height: 10),
            Text(
              [
                [f.sender, if (f.email != null) f.email!, if (f.userId == null) l.feedbackAccountGone].join(' · '),
                if (f.workspace != null) l.feedbackFrom(f.workspace!),
                agoText(context, f.createdAt),
              ].join('\n'),
              style: TextStyle(fontSize: 12.5, height: 1.4, color: c.ink3),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(onPressed: busy ? null : onToggle, child: Text(isNew ? l.feedbackMarkDone : l.feedbackReopen)),
            ),
          ],
        ),
      ),
    );
  }
}

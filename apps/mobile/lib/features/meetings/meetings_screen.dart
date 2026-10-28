import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'meetings_data.dart';

/// Meetings: the live and upcoming ones, the calls that happened (with
/// their notes), a call started now, or one joined by its code. Opened from
/// More; scheduling is on the web.
class MeetingsScreen extends ConsumerStatefulWidget {
  const MeetingsScreen({super.key});

  @override
  ConsumerState<MeetingsScreen> createState() => _MeetingsScreenState();
}

enum _Tab { upcoming, past }

class _MeetingsScreenState extends ConsumerState<MeetingsScreen> {
  _Tab _tab = _Tab.upcoming;
  final _code = TextEditingController();
  bool _starting = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _startNow() async {
    final l = AppLocalizations.of(context);
    setState(() => _starting = true);
    try {
      final m = (await ref.read(apiProvider)!.getMeetingsApi().createMeeting(meetingInput: MeetingInput(kind: MeetingInputKindEnum.instant))).data!;
      if (mounted) context.push('/m/${m.code}');
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.meetingsSomethingWrong));
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  void _join() {
    final l = AppLocalizations.of(context);
    final code = parseMeetingCode(_code.text);
    if (code == null) {
      showSnack(context, l.meetingsBadCode);
      return;
    }
    context.push('/m/$code');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final canEdit = ref.watch(canEditProvider);
    final Future<void> Function() refresh = _tab == _Tab.upcoming
        ? () => ref.refresh(upcomingMeetingsProvider.future)
        : () => ref.refresh(pastMeetingsProvider.future);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(backLabel: l.navBack, onBack: () => context.canPop() ? context.pop() : context.go('/more')),
      floatingActionButton: canEdit ? HFab(onTap: _starting ? () {} : _startNow, tooltip: l.meetingsStartNow, icon: 'video') : null,
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            PageHeader(title: l.meetingsPageTitle, sub: l.meetingsLede),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _code,
                    autocorrect: false,
                    textInputAction: TextInputAction.go,
                    onSubmitted: (_) => _join(),
                    decoration: InputDecoration(hintText: l.meetingsCodePlaceholder, labelText: l.meetingsJoinWithCode),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _join, child: Text(l.meetingsJoin)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Segmented<_Tab>(
                options: [(_Tab.upcoming, l.meetingsTab_upcoming), (_Tab.past, l.meetingsTab_past)],
                value: _tab,
                onChanged: (t) => setState(() => _tab = t),
                full: true,
              ),
            ),
            const SizedBox(height: 12),
            if (_tab == _Tab.upcoming) const _Upcoming() else const _Past(),
          ],
        ),
      ),
    );
  }
}

class _Upcoming extends ConsumerWidget {
  const _Upcoming();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final list = ref.watch(upcomingMeetingsProvider);
    return list.when(
      loading: () => const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
      error: (e, _) => EmptyState(title: errorMessage(e, l.meetingsSomethingWrong)),
      data: (all) => all.isEmpty
          ? EmptyState(title: l.meetingsNoneUpcoming)
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListGroup(children: [for (final m in all) _MeetingRow(m)]),
            ),
    );
  }
}

class _MeetingRow extends StatelessWidget {
  const _MeetingRow(this.m);
  final Meeting m;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final live = m.live;
    final when = live != null
        ? (live.inCall > 0 ? l.meetingsInCallNow(live.inCall) : l.meetingsLiveEmpty)
        : m.startsAt != null
            ? DateFormat('EEE d MMM, HH:mm', locale).format(m.startsAt!.toLocal())
            : l.meetingsKind_instant;
    return InkWell(
      onTap: () => context.push('/m/${m.code}'),
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: m.link));
        showSnack(context, l.meetingsLinkCopiedShort);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          HIcon('video', size: 22, color: live != null ? c.okInk : c.ink3),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.title.isEmpty ? m.code : m.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink)),
              const SizedBox(height: 3),
              Text('$when · ${l.meetingsHostedBy(m.hostName)}', maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: c.ink3)),
            ]),
          ),
          if (live != null) ToneBadge(l.meetingsLive, Tone.ok, small: true),
        ]),
      ),
    );
  }
}

class _Past extends ConsumerWidget {
  const _Past();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final list = ref.watch(pastMeetingsProvider);
    return list.when(
      loading: () => const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
      error: (e, _) => EmptyState(title: errorMessage(e, l.meetingsSomethingWrong)),
      data: (all) => all.isEmpty
          ? EmptyState(title: l.meetingsNonePast)
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListGroup(children: [
                for (final s in all)
                  InkWell(
                    onTap: s.documentId != null && s.notesStatus == MeetingNotesStatus.done ? () => context.push('/documents/${s.documentId}') : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(s.meetingTitle.isEmpty ? s.meetingCode : s.meetingTitle,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink)),
                        const SizedBox(height: 3),
                        Text('${DateFormat('d MMM, HH:mm', locale).format(s.startedAt.toLocal())} · ${l.meetingsAttendance(s.people)}',
                            style: TextStyle(fontSize: 13, color: c.ink3)),
                        const SizedBox(height: 6),
                        Wrap(spacing: 6, runSpacing: 4, children: [
                          if (s.notesStatus == MeetingNotesStatus.done) ToneBadge(l.meetingsOpenNotes, Tone.ok, small: true),
                          if (notesBusy(s.notesStatus)) ToneBadge(l.meetingsNotes_writing, Tone.warn, small: true),
                          if (s.notesStatus == MeetingNotesStatus.failed) ToneBadge(l.meetingsNotes_failed, Tone.bad, small: true),
                          if (s.actionItems > 0) ToneBadge(l.meetingsActionItemsN(s.actionItems), Tone.gray, small: true),
                          if (s.recordings > 0) ToneBadge(l.meetingsRecordings(s.recordings), Tone.gray, small: true),
                        ]),
                      ]),
                    ),
                  ),
              ]),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/session.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';

/// How many screenshots one "Request changes" may point at (the API's limit).
const maxFeedbackShots = 6;

/// A screenshot the feedback points at; [label] is only for the chip.
class FeedbackShot {
  const FeedbackShot({required this.runId, required this.shotId, required this.label});
  final int runId;
  final String shotId;
  final String label;

  ShotRef get ref => ShotRef(runId: runId, shotId: shotId);
}

/// An after screenshot and, when the preview compared, the same page before
/// the change. Either side may be missing.
class ShotGroup {
  const ShotGroup({required this.key, this.after, this.before});
  final String key;
  final PreviewShot? after;
  final PreviewShot? before;

  PreviewShot get any => after ?? before!;
}

final _side = RegExp(r'-(after|before)$');

/// Pairs shots whose ids differ only by a trailing `-after` / `-before`, in
/// the order the preview took them.
List<ShotGroup> groupShots(List<PreviewShot> shots) {
  final order = <String>[];
  final after = <String, PreviewShot>{};
  final before = <String, PreviewShot>{};
  for (final s in shots) {
    final key = s.id.replaceFirst(_side, '');
    if (!after.containsKey(key) && !before.containsKey(key)) order.add(key);
    (s.side == PreviewShotSideEnum.before ? before : after)[key] = s;
  }
  return [for (final k in order) ShotGroup(key: k, after: after[k], before: before[k])];
}

/// The feedback line for a screenshot, as the admin panel writes it.
String shotFeedbackLine(PreviewShot s) => '- On screenshot "${s.name}" (${s.viewport.value}, ${s.route}): ';

/// agnts's preview of a result waiting for review: screenshots of the running
/// app, with notes on what looks wrong. Advice beside the human review, like
/// the code review. Shots can be attached to [feedback]; [shots] holds the
/// ones the "Request changes" call sends.
class PreviewCard extends StatefulWidget {
  const PreviewCard({
    super.key,
    required this.detail,
    required this.feedback,
    required this.shots,
    required this.busy,
    required this.onRun,
  });
  final TicketDetail detail;
  final TextEditingController feedback;
  final ValueNotifier<List<FeedbackShot>> shots;
  final bool busy;

  /// Queues a (re-)preview; [compare] also captures the default branch.
  final void Function(bool compare) onRun;

  @override
  State<PreviewCard> createState() => _PreviewCardState();
}

class _PreviewCardState extends State<PreviewCard> {
  late bool _compare = widget.detail.ticket.previewCompare ?? false;
  var _viewport = PreviewShotViewportEnum.phone;
  // Groups showing their before shot.
  final Set<String> _showBefore = {};
  final Map<String, GlobalKey> _keys = {};

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final t = widget.detail.ticket;
    final state = t.previewState ?? TicketPreviewStateEnum.none;
    final p = widget.detail.preview;
    final working = state == TicketPreviewStateEnum.pending || state == TicketPreviewStateEnum.running;

    Widget status(String text, {Widget? lead, Tone? tone}) => Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lead != null) Padding(padding: const EdgeInsets.only(top: 2, right: 8), child: lead),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 14, height: 1.4, color: tone == null ? c.ink3 : tone.ink(c))),
          ),
        ],
      ),
    );

    final body = <Widget>[];
    switch (state) {
      case TicketPreviewStateEnum.pending:
        body.add(status(l.mpreviewPending));
      case TicketPreviewStateEnum.running:
        body.add(status(l.mpreviewRunning));
      case TicketPreviewStateEnum.failed:
        body.add(status(l.mpreviewFailed, tone: Tone.bad));
      case TicketPreviewStateEnum.none:
      case TicketPreviewStateEnum.done:
        break;
    }
    if (p != null) {
      if (p.revision < t.revision) body.add(status(l.mpreviewStale(p.revision.toString())));
      body.addAll(_preview(context, p));
    }
    body.addAll([
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SwitchListTile(
          value: _compare,
          onChanged: widget.busy || working ? null : (v) => setState(() => _compare = v),
          title: Text(l.mpreviewCompare, style: TextStyle(fontSize: 14.5, color: c.ink)),
          subtitle: Text(l.mpreviewCompareHelp, style: TextStyle(fontSize: 12.5, color: c.ink3)),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4), minimumSize: const Size(0, 36)),
          onPressed: widget.busy || working ? null : () => widget.onRun(_compare),
          child: Text(p == null ? l.mpreviewRun : l.mpreviewRunAgain),
        ),
      ),
    ]);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: HCard(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        radius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.mpreviewTitle,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink),
                  ),
                ),
                if (working)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: c.primary)),
                  )
                else if (p != null)
                  ToneBadge(_statusLabel(l, p.status), _statusTone(p.status), small: true),
              ],
            ),
            const SizedBox(height: 2),
            Text(l.mpreviewSub, style: TextStyle(fontSize: 12.5, height: 1.4, color: c.ink3)),
            ...body,
          ],
        ),
      ),
    );
  }

  List<Widget> _preview(BuildContext context, TicketPreview p) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    if (p.status == TicketPreviewStatusEnum.failed) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Text(l.mpreviewAppFailed, style: TextStyle(fontSize: 14, height: 1.4, color: c.badInk))),
            if (p.summary.isNotEmpty) CopyButton(p.summary, color: c.badInk),
          ]),
        ),
        if (p.summary.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: LogBox(lines: [for (final x in p.summary.trimRight().split('\n')) ('', x)]),
          ),
      ];
    }
    final groups = groupShots(p.shots);
    final viewports = {for (final g in groups) g.any.viewport};
    // Fall back to whichever width the preview has.
    final viewport = viewports.contains(_viewport) || viewports.isEmpty ? _viewport : viewports.first;
    final shown = groups.where((g) => g.any.viewport == viewport).toList();
    return [
      if (p.summary.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(p.summary, style: TextStyle(fontSize: 15, height: 1.45, color: c.ink)),
        ),
      Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(l.mpreviewModel(_modelName(p.model)), style: TextStyle(fontSize: 12.5, height: 1.4, color: c.ink3)),
      ),
      if (p.issues.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              HIcon('check', size: 16, stroke: 2.6, color: c.okInk),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.mpreviewNoIssues,
                  style: TextStyle(fontSize: 14, color: c.okInk, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        )
      else ...[
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 2),
          child: Text(
            l.mpreviewIssues(p.issues.length),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink3),
          ),
        ),
        for (final (i, x) in p.issues.indexed) _issue(context, p, x, first: i == 0),
      ],
      if (groups.isNotEmpty) ...[
        if (viewports.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Segmented<PreviewShotViewportEnum>(
              full: true,
              options: [(PreviewShotViewportEnum.phone, l.mpreviewPhone), (PreviewShotViewportEnum.desktop, l.mpreviewDesktop)],
              value: viewport,
              onChanged: (v) => setState(() => _viewport = v),
            ),
          ),
        if (shown.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(l.mpreviewNoShots, style: TextStyle(fontSize: 14, color: c.ink3)),
          ),
        for (final g in shown) _group(context, p, g),
      ],
    ];
  }

  Widget _issue(BuildContext context, TicketPreview p, PreviewIssue x, {required bool first}) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final shot = p.shots.where((s) => s.id == x.shotId).firstOrNull;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: first ? null : Border(top: BorderSide(color: c.line2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ToneBadge(_severityLabel(l, x.severity), _severityTone(x.severity), small: true),
              if (shot != null) Text(shot.name, style: TextStyle(fontSize: 12.5, color: c.ink3)),
            ],
          ),
          const SizedBox(height: 6),
          Text(x.description, style: TextStyle(fontSize: 14, height: 1.4, color: c.ink2)),
          if (shot != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4), minimumSize: const Size(0, 32)),
                onPressed: () => _jumpTo(shot),
                child: Text(l.mpreviewShowShot),
              ),
            ),
        ],
      ),
    );
  }

  /// Switches to [s]'s width and side, then scrolls its group into view.
  void _jumpTo(PreviewShot s) {
    final key = s.id.replaceFirst(_side, '');
    setState(() {
      _viewport = s.viewport;
      if (s.side == PreviewShotSideEnum.before) {
        _showBefore.add(key);
      } else {
        _showBefore.remove(key);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _keys[key]?.currentContext;
      if (ctx != null && ctx.mounted) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300), alignment: 0.1);
    });
  }

  Widget _group(BuildContext context, TicketPreview p, ShotGroup g) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final before = g.before != null && (g.after == null || _showBefore.contains(g.key));
    final s = before ? g.before! : g.after!;
    final errors = s.consoleErrors ?? 0;
    return Container(
      key: _keys.putIfAbsent(g.key, GlobalKey.new),
      margin: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: TextStyle(fontSize: 14.5, height: 1.35, fontWeight: FontWeight.w700, color: c.ink),
                    ),
                    Text(
                      s.route,
                      style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink3),
                    ),
                  ],
                ),
              ),
              if (g.after != null && g.before != null)
                Segmented<bool>(
                  options: [(true, l.mpreviewBefore), (false, l.mpreviewAfter)],
                  value: before,
                  onChanged: (v) => setState(() => v ? _showBefore.add(g.key) : _showBefore.remove(g.key)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => _FullShot(shot: s))),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  border: Border.all(color: c.line),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: s.viewport == PreviewShotViewportEnum.phone ? 420 : 260,
                    minWidth: double.infinity,
                  ),
                  child: ShotImage(s, fit: BoxFit.cover, alignment: Alignment.topCenter),
                ),
              ),
            ),
          ),
          if ((s.note ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(s.note!, style: TextStyle(fontSize: 14, height: 1.4, color: c.ink2)),
            ),
          if (errors > 0)
            Padding(padding: const EdgeInsets.only(top: 6), child: ToneBadge(l.mpreviewConsoleErrors(errors), Tone.bad, small: true)),
          _attach(context, p, s),
        ],
      ),
    );
  }

  Widget _attach(BuildContext context, TicketPreview p, PreviewShot s) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return ValueListenableBuilder(
      valueListenable: widget.shots,
      builder: (context, shots, _) {
        if (shots.any((x) => x.runId == p.runId && x.shotId == s.id)) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                HIcon('check', size: 15, stroke: 2.6, color: c.okInk),
                const SizedBox(width: 6),
                Text(
                  l.mpreviewAdded,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.okInk),
                ),
              ],
            ),
          );
        }
        final full = shots.length >= maxFeedbackShots;
        return Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4), minimumSize: const Size(0, 32)),
            onPressed: widget.busy
                ? null
                : full
                ? () => showSnack(context, l.mpreviewAttachLimit('$maxFeedbackShots'))
                : () => _add(p, s),
            child: Text(l.mpreviewAddToFeedback),
          ),
        );
      },
    );
  }

  /// Appends the shot's line to the feedback and attaches the shot.
  void _add(TicketPreview p, PreviewShot s) {
    final line = shotFeedbackLine(s);
    var text = widget.feedback.text;
    if (!text.contains(line)) {
      if (text.isNotEmpty && !text.endsWith('\n')) text += '\n';
      text += line;
      widget.feedback.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    final side = s.side == PreviewShotSideEnum.before ? ', ${AppLocalizations.of(context).mpreviewBefore.toLowerCase()}' : '';
    widget.shots.value = [...widget.shots.value, FeedbackShot(runId: p.runId, shotId: s.id, label: '${s.name}$side')];
  }
}

/// The attached screenshots as removable chips, for the feedback sheet.
class FeedbackShotChips extends StatelessWidget {
  const FeedbackShotChips({super.key, required this.shots});
  final ValueNotifier<List<FeedbackShot>> shots;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return ValueListenableBuilder(
      valueListenable: shots,
      builder: (context, list, _) {
        if (list.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.mpreviewAttached,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink3),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final s in list)
                    InputChip(
                      label: Text(s.label, overflow: TextOverflow.ellipsis),
                      deleteButtonTooltipMessage: l.mpreviewRemove,
                      onDeleted: () => shots.value = [
                        for (final x in shots.value)
                          if (x != s) x,
                      ],
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A preview screenshot, loaded with the session's bearer token.
class ShotImage extends ConsumerWidget {
  const ShotImage(this.shot, {super.key, this.fit, this.alignment = Alignment.center});
  final PreviewShot shot;
  final BoxFit? fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Agnts.of(context);
    final s = ref.watch(sessionProvider).value;
    if (s == null) return const SizedBox.shrink();
    final url = shot.url.startsWith('http') ? shot.url : '${s.server}/api${shot.url}';
    final ratio = shot.width != null && shot.height != null && shot.width! > 0 ? shot.width! / shot.height! : null;
    Widget placeholder(Widget child) => ratio == null
        ? SizedBox(height: 160, child: Center(child: child))
        : AspectRatio(
            aspectRatio: ratio,
            child: Center(child: child),
          );
    return Image.network(
      url,
      headers: {'Authorization': 'Bearer ${s.token}'},
      fit: fit,
      alignment: alignment,
      width: double.infinity,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : placeholder(SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: c.primary))),
      errorBuilder: (context, _, _) =>
          placeholder(Text(AppLocalizations.of(context).mpreviewLoadFailed, style: TextStyle(fontSize: 13, color: c.ink3))),
    );
  }
}

/// One screenshot on its own, at the screen's width, with pinch zoom.
class _FullShot extends StatelessWidget {
  const _FullShot({required this.shot});
  final PreviewShot shot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(shot.name, style: const TextStyle(fontSize: 16, color: Colors.white)),
      ),
      body: LayoutBuilder(
        builder: (context, box) => InteractiveViewer(
          // Unconstrained so a full-page shot keeps the screen's width and pans.
          constrained: false,
          maxScale: 5,
          child: SizedBox(
            width: box.maxWidth,
            child: ShotImage(shot, fit: BoxFit.fitWidth),
          ),
        ),
      ),
    );
  }
}

String _modelName(Model m) => switch (m) {
  Model.haiku => 'Haiku',
  Model.sonnet => 'Sonnet',
  Model.opus => 'Opus',
};

String _statusLabel(AppLocalizations l, TicketPreviewStatusEnum s) => switch (s) {
  TicketPreviewStatusEnum.ok => l.mpreviewStatus_ok,
  TicketPreviewStatusEnum.partial => l.mpreviewStatus_partial,
  TicketPreviewStatusEnum.failed => l.mpreviewStatus_failed,
};

Tone _statusTone(TicketPreviewStatusEnum s) => switch (s) {
  TicketPreviewStatusEnum.ok => Tone.ok,
  TicketPreviewStatusEnum.partial => Tone.warn,
  TicketPreviewStatusEnum.failed => Tone.bad,
};

String _severityLabel(AppLocalizations l, PreviewIssueSeverityEnum s) => switch (s) {
  PreviewIssueSeverityEnum.high => l.mpreviewSev_high,
  PreviewIssueSeverityEnum.medium => l.mpreviewSev_medium,
  PreviewIssueSeverityEnum.low => l.mpreviewSev_low,
};

Tone _severityTone(PreviewIssueSeverityEnum s) => switch (s) {
  PreviewIssueSeverityEnum.high => Tone.bad,
  PreviewIssueSeverityEnum.medium => Tone.warn,
  PreviewIssueSeverityEnum.low => Tone.info,
};

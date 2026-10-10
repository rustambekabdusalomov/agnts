import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:agnts_api/agnts_api.dart';

import '../l10n/app_localizations.dart';
import '../theme.dart';

// agnts's mobile components, as mobile.html draws them. Class names in the
// comments are the demo's CSS classes.

// ---- Icons (the demo's ICON set: 24x24, stroked) ----

const _icons = <String, String>{
  'needs': '<circle cx="12" cy="12" r="9"/><path d="M12 7v6M12 16.5h.01"/>',
  'running': '<path d="M3 12h4l3-8 4 16 3-8h4"/>',
  'queue': '<rect x="4" y="4" width="16" height="16" rx="3"/><path d="M8 9h8M8 13h8M8 17h5"/>',
  'done': '<circle cx="12" cy="12" r="9"/><path d="M8 12l3 3 5-6"/>',
  'all':
      '<rect x="3" y="4" width="5" height="16" rx="1"/><rect x="10" y="4" width="5" height="11" rx="1"/><rect x="17" y="4" width="4" height="7" rx="1"/>',
  'usage': '<path d="M4 18a8 8 0 1 1 16 0"/><path d="M12 18l4-6"/>',
  'repos': '<path d="M5 4.5A1.5 1.5 0 0 1 6.5 3H19v15H6.5A1.5 1.5 0 0 0 5 19.5z"/><path d="M5 19.5A1.5 1.5 0 0 0 6.5 21H19v-3M9 7h6"/>',
  'learnQueue': '<path d="M4 6h10M4 11h7M4 16h5"/><circle cx="17" cy="15" r="4.5"/><path d="M17 13v2.2l1.5 1"/>',
  'learn': '<path d="M2 9l10-5 10 5-10 5z"/><path d="M6 11v5c0 1.7 2.7 3 6 3s6-1.3 6-3v-5M22 9v6"/>',
  'info': '<circle cx="12" cy="12" r="9"/><path d="M12 11v5M12 8h.01"/>',
  'back': '<path d="M15 18l-6-6 6-6"/>',
  'chevron': '<path d="M9 6l6 6-6 6"/>',
  'down': '<path d="M6 9l6 6 6-6"/>',
  'logs': '<path d="M4 6h16M4 10h16M4 14h10M4 18h7"/>',
  'dashboard':
      '<rect x="3" y="3" width="8" height="9" rx="2"/><rect x="13" y="3" width="8" height="5" rx="2"/><rect x="13" y="10" width="8" height="11" rx="2"/><rect x="3" y="14" width="8" height="7" rx="2"/>',
  'analytics': '<path d="M4 20V10M10 20V4M16 20v-7M22 20H2"/>',
  'plug': '<path d="M9 7V3M15 7V3M7 7h10v4a5 5 0 0 1-10 0z"/><path d="M12 16v5"/>',
  'tasks': '<rect x="4" y="4" width="16" height="16" rx="3"/><path d="M8.5 12l2.5 2.5 4.5-5"/>',
  'plus': '<path d="M12 5v14M5 12h14"/>',
  'close': '<path d="M6 6l12 12M18 6L6 18"/>',
  'check': '<path d="M5 12.5l4.5 4.5L19 7.5"/>',
  'search': '<circle cx="11" cy="11" r="7"/><path d="M20 20l-3.5-3.5"/>',
  'more': '<circle cx="5" cy="12" r="1.2"/><circle cx="12" cy="12" r="1.2"/><circle cx="19" cy="12" r="1.2"/>',
  'attach': '<path d="M20.5 11.5l-8.4 8.4a5 5 0 0 1-7.1-7.1l8.4-8.4a3.3 3.3 0 0 1 4.7 4.7l-8.4 8.4a1.7 1.7 0 0 1-2.4-2.4l7.7-7.7"/>',
  'image': '<rect x="3" y="4" width="18" height="16" rx="2"/><circle cx="8.5" cy="9.5" r="1.5"/><path d="M21 16l-5-5-9 9"/>',
  'camera':
      '<path d="M4 8h3l2-3h6l2 3h3a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V9a1 1 0 0 1 1-1z"/><circle cx="12" cy="13.5" r="3.5"/>',
  'file': '<path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z"/><path d="M14 3v5h5"/>',
  'users':
      '<circle cx="9" cy="8" r="3.5"/><path d="M2.5 20c.8-3.6 3.4-5.5 6.5-5.5s5.7 1.9 6.5 5.5"/><path d="M16 4.6a3.5 3.5 0 0 1 0 6.8M18 14.8c1.9.7 3.1 2.4 3.5 5.2"/>',
  'shield': '<path d="M12 3l7.5 3v5.5c0 4.4-3.1 8.2-7.5 9.5-4.4-1.3-7.5-5.1-7.5-9.5V6z"/><path d="M9 12l2 2 4-4"/>',
  'feedback': '<path d="M4 5.5A1.5 1.5 0 0 1 5.5 4h13A1.5 1.5 0 0 1 20 5.5v9a1.5 1.5 0 0 1-1.5 1.5H9l-5 4z"/><path d="M8 9h8M8 12h5"/>',
};

/// One of the demo's stroked icons, in [color] (defaults to the text colour).
class HIcon extends StatelessWidget {
  const HIcon(this.name, {super.key, this.size = 24, this.color, this.stroke = 1.9});
  final String name;
  final double size;
  final Color? color;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    final col = color ?? IconTheme.of(context).color ?? Agnts.of(context).ink;
    final hex = '#${(col.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
    final fill = name == 'more' ? hex : 'none';
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="$fill" stroke="$hex" '
        'stroke-width="$stroke" stroke-linecap="round" stroke-linejoin="round" opacity="${col.a}">${_icons[name] ?? ''}</svg>';
    return SvgPicture.string(svg, width: size, height: size);
  }
}

// ---- Tones (badge colours: b-ok, b-warn, b-bad, b-info, b-gray) ----

enum Tone { info, warn, bad, ok, gray }

extension ToneColors on Tone {
  Color soft(Agnts c) => switch (this) {
    Tone.info => c.primarySoft,
    Tone.warn => c.warnSoft,
    Tone.bad => c.badSoft,
    Tone.ok => c.okSoft,
    Tone.gray => c.graySoft,
  };
  Color ink(Agnts c) => switch (this) {
    Tone.info => c.primaryInk,
    Tone.warn => c.warnInk,
    Tone.bad => c.badInk,
    Tone.ok => c.okInk,
    Tone.gray => c.grayInk,
  };
  Color solid(Agnts c) => switch (this) {
    Tone.info => c.primary,
    Tone.warn => c.warn,
    Tone.bad => c.bad,
    Tone.ok => c.ok,
    Tone.gray => c.line3,
  };
}

/// A ticket state's tone, as the demo colours it.
Tone stateTone(TicketState s) => switch (s) {
  TicketState.waitingForAnswers || TicketState.waitingForReview => Tone.warn,
  TicketState.failed || TicketState.rateLimited => Tone.bad,
  TicketState.done => Tone.ok,
  TicketState.new_ || TicketState.rejected => Tone.gray,
  _ => Tone.info,
};

/// A rounded pill with a dot (.badge).
class ToneBadge extends StatelessWidget {
  const ToneBadge(this.text, this.tone, {super.key, this.small = false});
  final String text;
  final Tone tone;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final ink = tone.ink(c);
    return Container(
      height: small ? 20 : 24,
      padding: EdgeInsets.symmetric(horizontal: small ? 7 : 9),
      decoration: BoxDecoration(color: tone.soft(c), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: ink, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: ink, fontSize: small ? 11 : 12, fontWeight: FontWeight.w700, height: 1),
          ),
        ],
      ),
    );
  }
}

/// The small square source chip: "Jira" or "Plane" (gray), or "Task" (purple) (.src).
/// Kinds whose work is a Markdown report instead of a change.
/// A pull request review is one too: its report is agnts's review, and
/// approving it merges the pull request.
bool isReportKind(TicketKind k) => k == TicketKind.plan || k == TicketKind.analysis || k == TicketKind.bug || k == TicketKind.review;

/// Where a ticket came from, for its source chip: Jira, Plane or Task.
String sourceLabel(AppLocalizations l, TicketSource_Enum s) => switch (s) {
  TicketSource_Enum.local => l.ticketsSourceTask,
  TicketSource_Enum.plane => l.ticketsSourcePlane,
  TicketSource_Enum.git => l.ticketsSourceGit,
  _ => l.ticketsSourceJira,
};

/// A kind's name from the shared dictionaries.
String kindLabel(AppLocalizations l, TicketKind k) => switch (k) {
  TicketKind.code => l.kindCode,
  TicketKind.test => l.kindTest,
  TicketKind.plan => l.kindPlan,
  TicketKind.analysis => l.kindAnalysis,
  TicketKind.bug => l.kindBug,
  TicketKind.review => l.kindReview,
};

/// What a ticket produces, as a small chip; "· Auto" while agnts picks it.
class KindChip extends StatelessWidget {
  const KindChip(this.ticket, {super.key});
  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final l = AppLocalizations.of(context);
    final tone = switch (ticket.kind) {
      TicketKind.plan || TicketKind.analysis => Tone.info,
      TicketKind.bug => Tone.warn,
      _ => Tone.gray,
    };
    final text = ticket.kindAuto ? '${kindLabel(l, ticket.kind)} · ${l.kindAuto}' : kindLabel(l, ticket.kind);
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: tone.soft(c), borderRadius: BorderRadius.circular(6)),
      child: Text(
        text,
        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: tone.ink(c)),
      ),
    );
  }
}

class SourceChip extends StatelessWidget {
  const SourceChip(this.text, {super.key, this.task = false});
  final String text;
  final bool task;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: task ? c.taskSoft : c.graySoft, borderRadius: BorderRadius.circular(6)),
      child: Text(
        text,
        style: TextStyle(color: task ? c.taskInk : c.grayInk, fontSize: 11.5, fontWeight: FontWeight.w700, height: 1),
      ),
    );
  }
}

// ---- Layout ----

/// A screen's big title, with an optional subtitle and round icon buttons (.hdr).
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.sub, this.actions = const [], this.long = false});
  final String title;
  final String? sub;
  final List<Widget> actions;
  final bool long;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: long ? t.headlineSmall : t.displaySmall?.copyWith(height: 1.05)),
                if (sub != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(sub!, style: TextStyle(color: c.ink3, fontSize: 14)),
                  ),
              ],
            ),
          ),
          for (final a in actions) Padding(padding: const EdgeInsets.only(left: 8, bottom: 2), child: a),
        ],
      ),
    );
  }
}

/// A round 40px icon button with a border (.ibtn).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton(this.icon, {super.key, required this.onTap, this.tooltip});
  final String icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final b = Material(
      color: c.surface,
      shape: CircleBorder(side: BorderSide(color: c.line)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(child: HIcon(icon, size: 20, color: c.ink2)),
        ),
      ),
    );
    return tooltip == null ? b : Tooltip(message: tooltip!, child: b);
  }
}

/// A small grey section heading with an optional right-hand value (.sec-h).
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing, this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 8)});
  final String title;
  final Widget? trailing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: c.ink3, fontSize: 13.5, fontWeight: FontWeight.w700),
            ),
          ),
          if (trailing != null)
            DefaultTextStyle.merge(
              style: TextStyle(color: c.ink, fontSize: 13.5, fontWeight: FontWeight.w700),
              child: trailing!,
            ),
        ],
      ),
    );
  }
}

/// A white rounded card with a thin border (.card); tappable when [onTap] is set.
class HCard extends StatelessWidget {
  const HCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(16), this.radius = 18, this.color});
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: c.line),
    );
    return Material(
      color: color ?? c.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : _Pressable(
              onTap: onTap!,
              child: Padding(padding: padding, child: child),
            ),
    );
  }
}

/// Scales down slightly while pressed (.tcard:active), like the demo.
class _Pressable extends StatefulWidget {
  const _Pressable({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _down ? 0.985 : 1,
        duration: const Duration(milliseconds: 120),
        child: ColoredBox(color: _down ? Agnts.of(context).hover : Colors.transparent, child: widget.child),
      ),
    );
  }
}

/// A ticket or task as a card (.tcard): key and status, title, a meta line,
/// then either a live log line or the next action ("Review 3 files").
class TicketCard extends StatelessWidget {
  const TicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
    this.meta = const [],
    this.action,
    this.actionTone = Tone.info,
    this.live,
  });
  final Ticket ticket;
  final VoidCallback onTap;
  final List<Widget> meta;
  final String? action;
  final Tone actionTone;
  final String? live;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final l = AppLocalizations.of(context);
    final isTask = ticket.source_ == TicketSource_Enum.local;
    final actColor = switch (actionTone) {
      Tone.warn => c.warnInk,
      Tone.bad => c.badInk,
      _ => c.primaryInk,
    };
    return HCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ticket.key,
                  style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink3),
                ),
              ),
              ToneBadge(stateLabelOf(l, ticket.state, ticket.kind), stateTone(ticket.state)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            ticket.title,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, height: 1.3, color: c.ink),
          ),
          const SizedBox(height: 8),
          DefaultTextStyle.merge(
            style: TextStyle(fontSize: 13, color: c.ink3),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SourceChip(sourceLabel(l, ticket.source_), task: isTask),
                if (ticket.kind != TicketKind.code) KindChip(ticket),
                if ((ticket.openSuggestions ?? 0) > 0)
                  ToneBadge(AppLocalizations.of(context).followUpsOpenBadge(ticket.openSuggestions!), Tone.info, small: true),
                if (ticket.blockedBy?.isNotEmpty ?? false)
                  ToneBadge(AppLocalizations.of(context).relationsWaitingBadge, Tone.warn, small: true),
                if (ticket.repoName != null) Text(ticket.repoName!),
                ...meta,
              ],
            ),
          ),
          if (live != null && live!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Pulse(),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    live!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink2),
                  ),
                ),
              ],
            ),
          ] else if (action != null) ...[
            const SizedBox(height: 10),
            Divider(height: 1, color: c.line2),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    action!,
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: actColor),
                  ),
                ),
                HIcon('chevron', size: 16, color: actColor, stroke: 2.2),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// The state's label from the shared dictionaries. A report reads
/// "Writing" and "Done" where a change reads "Coding" and "Pushed".
String stateLabelOf(AppLocalizations l, TicketState s, [TicketKind? kind]) => switch (s) {
  TicketState.coding when kind != null && isReportKind(kind) => l.stateReportCoding,
  TicketState.pushing when kind != null && isReportKind(kind) => l.stateReportPushing,
  TicketState.done when kind != null && isReportKind(kind) => l.stateReportDone,
  TicketState.new_ => l.stateNew,
  TicketState.analyzing => l.stateAnalyzing,
  TicketState.waitingForAnswers => l.stateWaiting_for_answers,
  TicketState.coding => l.stateCoding,
  TicketState.testing => l.stateTesting,
  TicketState.waitingForReview => l.stateWaiting_for_review,
  TicketState.pushing => l.statePushing,
  TicketState.done => l.stateDone,
  TicketState.rejected => l.stateRejected,
  TicketState.failed => l.stateFailed,
  TicketState.rateLimited => l.stateRate_limited,
};

/// The pulsing dot of something running (.pulse).
class Pulse extends StatefulWidget {
  const Pulse({super.key, this.size = 8, this.color});
  final double size;
  final Color? color;

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final col = widget.color ?? Agnts.of(context).primary;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Opacity(
        opacity: 1 - 0.4 * _c.value,
        child: Transform.scale(
          scale: 1 - 0.45 * _c.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(color: col, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

// ---- Chips, search, segmented ----

/// One filter chip; black when selected (.chip).
class FilterChipH extends StatelessWidget {
  const FilterChipH({super.key, required this.label, required this.selected, required this.onTap, this.count, this.dot});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;
  final Color? dot;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final fg = selected ? c.surface : c.ink2;
    return Material(
      color: selected ? c.ink : c.surface,
      shape: StadiumBorder(side: BorderSide(color: selected ? c.ink : c.line4)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dot != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: dot, borderRadius: BorderRadius.circular(3)),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: fg),
              ),
              if (count != null) ...[
                const SizedBox(width: 4),
                Text(
                  '$count',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: fg.withValues(alpha: 0.7)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A horizontally scrolling row of chips (.chips).
class ChipRow extends StatelessWidget {
  const ChipRow({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
      child: Row(
        children: [
          for (final (i, w) in children.indexed)
            Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
              child: w,
            ),
        ],
      ),
    );
  }
}

/// The rounded search field (.search).
class SearchBox extends StatelessWidget {
  const SearchBox({super.key, required this.hint, required this.onChanged, this.controller});
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 16),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: HIcon('search', size: 18, color: c.ink3, stroke: 2),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 44),
          contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: c.line4),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: c.line4),
          ),
        ),
      ),
    );
  }
}

/// iOS-like segmented buttons (.seg); [full] stretches them to the width.
class Segmented<T> extends StatelessWidget {
  const Segmented({super.key, required this.options, required this.value, required this.onChanged, this.full = false});
  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;
  final bool full;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    Widget seg((T, String) o) {
      final on = o.$1 == value;
      final b = GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onChanged(o.$1);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minHeight: 34),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? c.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: on ? const [BoxShadow(color: Color(0x2616181D), blurRadius: 3, offset: Offset(0, 1))] : null,
          ),
          child: Text(
            o.$2,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: on ? c.ink : c.grayInk),
          ),
        ),
      );
      return full ? Expanded(child: b) : b;
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: c.hover, borderRadius: BorderRadius.circular(11)),
      child: Row(
        mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (final (i, o) in options.indexed) ...[if (i > 0) const SizedBox(width: 3), seg(o)],
        ],
      ),
    );
  }
}

// ---- Numbers ----

/// A tappable KPI tile (.kc): label, big number, note, optional bar or delta.
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.note,
    this.valueColor,
    this.delta,
    this.bar,
    this.barTone = Tone.info,
    this.onTap,
    this.mono = false,
  });
  final String label;
  final String value;
  final String? note;
  final Color? valueColor;
  final Widget? delta;
  final double? bar; // 0..1
  final Tone barTone;
  final VoidCallback? onTap;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return HCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: c.ink3, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            children: [
              Text(
                value,
                style: mono
                    ? TextStyle(fontFamily: AgntsFonts.mono, fontSize: 22, fontWeight: FontWeight.w700, color: valueColor ?? c.ink)
                    : TextStyle(
                        fontFamily: AgntsFonts.display,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        color: valueColor ?? c.ink,
                      ),
              ),
              if (delta != null) delta!,
            ],
          ),
          if (bar != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 2),
              child: Bar(value: bar!, tone: barTone, height: 6),
            ),
          if (note != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(note!, style: TextStyle(fontSize: 12.5, color: c.ink3)),
            ),
        ],
      ),
    );
  }
}

/// "+3%" / "−4%" (.delta): green when better.
class Delta extends StatelessWidget {
  const Delta(this.text, {super.key, required this.better});
  final String text;
  final bool? better; // null: no change

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final (bg, fg) = better == null
        ? (c.graySoft, c.grayInk)
        : better!
        ? (c.okSoft, c.okInk)
        : (c.badSoft, c.badInk);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9)),
      child: Text(
        text,
        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

/// A thin progress bar (.bar), amber or red by [tone].
class Bar extends StatelessWidget {
  const Bar({super.key, required this.value, this.tone = Tone.info, this.height = 8});
  final double value;
  final Tone tone;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: c.line2)),
            // Positioned.fill gives the fill the bar's full height; a plain
            // child of the Stack would be zero high.
            Positioned.fill(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: FractionallySizedBox(
                  widthFactor: value.clamp(0, 1).toDouble(),
                  heightFactor: 1,
                  child: ColoredBox(color: tone.solid(c)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A two-column grid of tiles with a gap (.kgrid, .facts).
class Grid2 extends StatelessWidget {
  const Grid2({super.key, required this.children, this.gap = 10});
  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: children[i]),
              SizedBox(width: gap),
              Expanded(child: i + 1 < children.length ? children[i + 1] : const SizedBox()),
            ],
          ),
        ),
      );
      if (i + 2 < children.length) rows.add(SizedBox(height: gap));
    }
    return Column(children: rows);
  }
}

/// A small fact tile: label over a bold value (.facts div).
class Fact extends StatelessWidget {
  const Fact(this.label, this.value, {super.key, this.tone});
  final String label;
  final String value;
  final Tone? tone; // ok/bad colour the value

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 12.5, color: c.ink3)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: tone == null ? c.ink : tone!.ink(c)),
          ),
        ],
      ),
    );
  }
}

// ---- Lists ----

/// A rounded group of rows with dividers (.list).
class ListGroup extends StatelessWidget {
  const ListGroup({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (i, w) in children.indexed) ...[if (i > 0) Divider(height: 1, color: c.line2), w],
        ],
      ),
    );
  }
}

/// One row (.li): title and small subtitle, a grey value, a chevron when tappable.
class ListRow extends StatelessWidget {
  const ListRow({super.key, required this.title, this.subtitle, this.value, this.leading, this.trailing, this.onTap, this.titleColor});
  final String title;
  final String? subtitle;
  final String? value;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final row = Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 15, color: titleColor ?? c.ink, fontWeight: titleColor != null ? FontWeight.w700 : null),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(subtitle!, style: TextStyle(fontSize: 13, color: c.ink3)),
                  ),
              ],
            ),
          ),
          if (value != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(value!, style: TextStyle(fontSize: 14, color: c.ink3)),
            ),
          if (trailing != null) Padding(padding: const EdgeInsets.only(left: 8), child: trailing!),
          if (onTap != null && trailing == null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: HIcon('chevron', size: 16, color: c.line3, stroke: 2.4),
            ),
        ],
      ),
    );
    return onTap == null ? row : InkWell(onTap: onTap, child: row);
  }
}

/// A collapsible card with a title, a grey count and a chevron (details.fold).
class Fold extends StatefulWidget {
  const Fold({super.key, required this.title, required this.child, this.hint, this.initiallyOpen = false});
  final String title;
  final String? hint;
  final Widget child;
  final bool initiallyOpen;

  @override
  State<Fold> createState() => _FoldState();
}

class _FoldState extends State<Fold> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  if (widget.hint != null) Text(widget.hint!, style: TextStyle(color: c.ink2)),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: HIcon('down', size: 18, color: c.ink3, stroke: 2.2),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.topCenter,
            child: _open
                ? Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 14), child: widget.child)
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// A tinted note with an info icon (.help, .help.warn/bad/ok).
class HelpBox extends StatelessWidget {
  const HelpBox(this.text, {super.key, this.tone = Tone.info, this.child, this.copyable = false});
  final String text;
  final Tone tone;
  final Widget? child;

  /// An error to paste elsewhere: a copy button, and the text selectable.
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final (bg, fg, border) = tone == Tone.info ? (c.help, c.primaryInk, c.ring) : (tone.soft(c), tone.ink(c), Colors.transparent);
    final style = TextStyle(fontSize: 14.5, color: fg);
    return Container(
      padding: EdgeInsets.fromLTRB(14, 12, copyable ? 6 : 14, 12),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: HIcon('info', size: 18, color: fg),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copyable ? SelectableText(text, style: style) : Text(text, style: style),
                if (child != null) Padding(padding: const EdgeInsets.only(top: 8), child: child!),
              ],
            ),
          ),
          if (copyable) CopyButton(text, color: fg),
        ],
      ),
    );
  }
}

/// A small copy icon: puts [text] on the clipboard and says so.
class CopyButton extends StatelessWidget {
  const CopyButton(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return IconButton(
      tooltip: l.formCopy,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      icon: Icon(Icons.copy_rounded, size: 18, color: color ?? Agnts.of(context).ink3),
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: text));
        if (!context.mounted) return;
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(l.formCopied), duration: const Duration(seconds: 2)));
      },
    );
  }
}

/// Monospace log lines on the dark code background (.log), with a blinking
/// cursor after the last line while [live].
class LogBox extends StatelessWidget {
  const LogBox({super.key, required this.lines, this.live = false, this.maxHeight = 260});
  final List<(String time, String text)> lines;
  final bool live;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    const style = TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, height: 1.65);
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(color: c.code, borderRadius: BorderRadius.circular(14)),
      child: SingleChildScrollView(
        reverse: true,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, (t, x)) in lines.indexed)
              Text.rich(
                TextSpan(
                  style: style.copyWith(color: c.codeInk),
                  children: [
                    if (t.isNotEmpty)
                      TextSpan(
                        text: '$t  ',
                        style: TextStyle(color: c.codeDim),
                      ),
                    TextSpan(text: x),
                    if (live && i == lines.length - 1)
                      const TextSpan(
                        text: '▍',
                        style: TextStyle(color: Color(0xFF8FA4F0)),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A centered empty-state message (.empty).
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, this.text, this.action});
  final String title;
  final String? text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: c.ink, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          if (text != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text!,
                textAlign: TextAlign.center,
                style: TextStyle(color: c.ink3),
              ),
            ),
          if (action != null) Padding(padding: const EdgeInsets.only(top: 14), child: action!),
        ],
      ),
    );
  }
}

// ---- Screen chrome ----

/// The detail screens' top bar (.navbar): a blue "‹ Back" on the left, a
/// centred mono title, optional actions on the right.
class DetailBar extends StatelessWidget implements PreferredSizeWidget {
  const DetailBar({super.key, required this.backLabel, this.title, this.actions = const [], this.onBack});
  final String backLabel;
  final String? title;
  final List<Widget> actions;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Container(
      color: c.bg,
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: SizedBox(
        height: 52,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (title != null)
              Text(
                title!,
                style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 14, color: c.ink2),
              ),
            Row(
              children: [
                const SizedBox(width: 4),
                TextButton(
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6), minimumSize: const Size(40, 40)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HIcon('back', size: 22, color: c.primary, stroke: 2.4),
                      Text(
                        backLabel,
                        style: TextStyle(color: c.primary, fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                for (final a in actions) Padding(padding: const EdgeInsets.only(right: 10), child: a),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The sticky bottom bar of a detail screen (.actionbar).
class ActionBar extends StatelessWidget {
  const ActionBar({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.line)),
      ),
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + MediaQuery.paddingOf(context).bottom),
      child: Row(
        children: [
          for (final (i, w) in children.indexed) ...[if (i > 0) const SizedBox(width: 8), w],
        ],
      ),
    );
  }
}

/// The square-ish floating "+" button (.fab).
class HFab extends StatelessWidget {
  const HFab({super.key, required this.onTap, required this.tooltip});
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: c.primary.withValues(alpha: 0.6), blurRadius: 30, offset: const Offset(0, 14), spreadRadius: -10)],
        ),
        child: Material(
          color: c.primary,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: SizedBox(
              width: 58,
              height: 58,
              child: Center(child: HIcon('plus', size: 26, color: c.onPrimary, stroke: 2.4)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pads a screen's scrolling content like the demo (16px sides, room at the bottom).
const screenPad = EdgeInsets.fromLTRB(16, 0, 16, 24);

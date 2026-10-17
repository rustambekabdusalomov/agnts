import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';
import '../activity/activity_screen.dart';
import '../assistant/assistant_data.dart' show assistantStatsProvider;
import '../assistant/assistant_stats.dart';
import '../tickets/spend.dart';
import 'export.dart';
import '../tickets/replay_eval.dart';

part 'analytics_tabs.dart';

/// Analytics for the last [days] days, compared with the period before.
final _analyticsFor = FutureProvider.family<Analytics, int>((ref, days) async {
  return (await requireApi(ref).getAnalyticsApi().getAnalytics(days: days)).data!;
});

/// Pull requests, cycle time and questions (the Delivery tab).
final _deliveryFor = FutureProvider.family<AnalyticsDelivery, int>((ref, days) async {
  return (await requireApi(ref).getAnalyticsApi().getAnalyticsDelivery(days: days)).data!;
});

/// CI health (the Quality tab's second half).
final _ciFor = FutureProvider.family<AnalyticsCI, int>((ref, days) async {
  return (await requireApi(ref).getAnalyticsApi().getAnalyticsCi(days: days)).data!;
});

/// Lessons, rules, follow-ups and reviewer notes (the Learning tab).
final _learningFor = FutureProvider.family<AnalyticsLearning, int>((ref, days) async {
  return (await requireApi(ref).getAnalyticsApi().getAnalyticsLearning(days: days)).data!;
});

/// The demo's soft blue (after changes, hourly activity); the theme has no token for it.
const _softBlue = Color(0xFF7F95E8);

/// The admin panel's peach for "waiting for review" in a ticket's time split.
const _peach = Color(0xFFE8A87F);

/// The Analytics page's tabs, then the activity log under "Events".
enum _Tab { overview, delivery, quality, learning, cost, repos, assistant, events }

/// Analytics tab: the admin panel's analytics tabs (overview, delivery,
/// quality, learning, cost, repositories and, for the owner, the
/// assistant) over 7, 30 or 90 days, and the activity log under "Events".
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  _Tab _tab = _Tab.overview;
  int _days = 30;

  void _about() {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.manalyticsAbout, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              Text(l.analyticsLede, style: TextStyle(fontSize: 15, color: c.ink2)),
              const SizedBox(height: 8),
              Text(l.manalyticsCompared(_days), style: TextStyle(fontSize: 14, color: c.ink3)),
            ],
          ),
        ),
      ),
    );
  }

  String _label(AppLocalizations l, _Tab t) => switch (t) {
    _Tab.overview => l.analyticsTabOverview,
    _Tab.delivery => l.analyticsTabDelivery,
    _Tab.quality => l.analyticsTabQuality,
    _Tab.learning => l.analyticsTabLearning,
    _Tab.cost => l.analyticsTabCost,
    _Tab.repos => l.analyticsTabRepos,
    _Tab.assistant => l.analyticsTabAssistant,
    _Tab.events => l.analyticsEvents,
  };

  /// The open tab's table as CSV, as the admin panel exports it; null while
  /// its data is not loaded (or for the assistant and events tabs).
  List<List<Object?>>? _csv() {
    final a = ref.read(_analyticsFor(_days)).value;
    switch (_tab) {
      case _Tab.delivery:
        return deliveryCsv(ref.read(_deliveryFor(_days)).value);
      case _Tab.learning:
        return learningCsv(ref.read(_learningFor(_days)).value);
      case _Tab.quality:
        return qualityCsv(a);
      case _Tab.repos:
        return reposCsv(a);
      case _Tab.overview || _Tab.cost:
        return daysCsv(a);
      case _Tab.assistant || _Tab.events:
        return null;
    }
  }

  Future<void> _export() async {
    final rows = _csv();
    if (rows == null) return;
    await saveTextFile(context, 'agnts-analytics-${_tab.name}-${_days}d.csv', toCsv(rows), 'text/csv');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // The Assistant tab is the workspace owner's: it shows people's rated questions.
    final owner = isOwner(ref.watch(currentWorkspaceProvider));
    final tabs = [
      for (final t in _Tab.values)
        if (t != _Tab.assistant || owner) t,
    ];
    final tab = tabs.contains(_tab) ? _tab : _Tab.overview;
    final canExport = tab != _Tab.events && tab != _Tab.assistant;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: l.analyticsTitle,
              actions: [
                if (canExport) RoundIconButton('file', tooltip: l.analyticsExportCsv, onTap: _export),
                RoundIconButton('info', tooltip: l.manalyticsAbout, onTap: _about),
              ],
            ),
            ChipRow(
              children: [for (final t in tabs) FilterChipH(label: _label(l, t), selected: t == tab, onTap: () => setState(() => _tab = t))],
            ),
            const SizedBox(height: 12),
            Expanded(child: tab == _Tab.events ? const ActivityFeed() : _body(context, tab)),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, _Tab tab) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final days = _days;
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(assistantStatsProvider);
        ref.invalidate(_deliveryFor(days));
        ref.invalidate(_ciFor(days));
        ref.invalidate(_learningFor(days));
        ref.invalidate(_analyticsFor(days));
        await ref.read(_analyticsFor(days).future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Segmented<int>(
              full: true,
              options: [
                for (final d in const [7, 30, 90]) (d, l.manalyticsDays(d)),
              ],
              value: days,
              onChanged: (d) => setState(() => _days = d),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
            child: Text(l.manalyticsCompared(days), style: TextStyle(fontSize: 12.5, color: c.ink3)),
          ),
          ..._tabContent(context, tab, days),
        ],
      ),
    );
  }

  List<Widget> _tabContent(BuildContext context, _Tab tab, int days) {
    final l = AppLocalizations.of(context);
    if (tab == _Tab.assistant) return [AssistantStatsSection(days: days)];
    if (tab == _Tab.learning) return _async(context, ref.watch(_learningFor(days)), (x) => _Learning(x).children(context));

    final main = ref.watch(_analyticsFor(days));
    final delivery = tab == _Tab.delivery ? ref.watch(_deliveryFor(days)) : null;
    // Delivery needs both; any failure or wait shows as the tab's.
    final AsyncValue<Analytics> value = switch (delivery) {
      AsyncError(:final error, :final stackTrace) => AsyncError(error, stackTrace),
      AsyncData() || null => main,
      _ => const AsyncLoading(),
    };
    return _async(context, value, (a) {
      if (_isEmpty(a)) return [_card(EmptyState(title: l.analyticsEmptyTitle, text: l.analyticsEmpty))];
      final v = _View(a, days, Localizations.localeOf(context).toString());
      return switch (tab) {
        _Tab.delivery => v.delivery(context, delivery!.requireValue),
        _Tab.quality => v.quality(context, ref.watch(_ciFor(days))),
        _Tab.cost => v.cost(context),
        _Tab.repos => v.repos(context),
        _ => v.overview(context),
      };
    });
  }

  List<Widget> _async<T>(BuildContext context, AsyncValue<T> value, List<Widget> Function(T) data) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return switch (value) {
      AsyncData(:final value) => data(value),
      AsyncError() => [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HelpBox(l.analyticsError, tone: Tone.bad),
        ),
      ],
      _ => [
        Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(l.analyticsLoading, style: TextStyle(color: c.ink3)),
            ],
          ),
        ),
      ],
    };
  }

  static bool _isEmpty(Analytics a) {
    final c = a.current;
    return c.picked + c.pushed + c.rejected + c.stopped + c.merged + c.closed == 0 &&
        a.models.isEmpty &&
        a.hours.every((h) => h == 0) &&
        a.spendByStage.isEmpty;
  }
}

// ---- Chart pieces ----

class ChartSeries {
  const ChartSeries(this.label, this.values, this.color, {this.area = false});
  final String label;
  final List<num> values;
  final Color color;
  final bool area;
}

class _Part {
  const _Part(this.label, this.v, this.color);
  final String label;
  final int v;
  final Color color;
}

class _HRow {
  const _HRow(this.l, this.v, [this.tone = Tone.info]);
  final String l;
  final num v;
  final Tone tone;
}

/// A small rounded colour square (.legend i).
class _Swatch extends StatelessWidget {
  const _Swatch(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
  );
}

/// Colour keys under a chart (.legend).
class ChartLegend extends StatelessWidget {
  const ChartLegend(this.items, {super.key});
  final List<(Color, String)> items;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 14,
        runSpacing: 6,
        children: [
          for (final (color, label) in items)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Swatch(color),
                const SizedBox(width: 5),
                Text(label, style: TextStyle(fontSize: 12.5, color: c.ink3)),
              ],
            ),
        ],
      ),
    );
  }
}

/// A label / value row with a divider (.mini-kv).
class _MiniKv extends StatelessWidget {
  const _MiniKv(this.label, this.value, {this.last = false});
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: c.line2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 14, color: c.ink)),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.ink),
          ),
        ],
      ),
    );
  }
}

/// Horizontal bars with a label and value above each (.hb).
class _HBars extends StatelessWidget {
  const _HBars(this.rows, {this.fmt});
  final List<_HRow> rows;
  final String Function(num)? fmt;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final max = rows.fold<num>(1, (m, r) => math.max(m, r.v));
    return Column(
      children: [
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(r.l, style: TextStyle(fontSize: 13.5, color: c.ink)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      fmt == null ? '${r.v}' : fmt!(r.v),
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 8,
                    color: c.line2,
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: math.max(0.02, r.v / max).clamp(0, 1).toDouble(),
                      heightFactor: 1,
                      child: ColoredBox(color: r.tone.solid(c)),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The ring chart with a big centre value (.donut).
class _Donut extends StatelessWidget {
  const _Donut({required this.parts, required this.center, required this.sub});
  final List<_Part> parts;
  final String center;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: CustomPaint(painter: _DonutPainter(parts, c.line2))),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                center,
                style: TextStyle(fontFamily: AgntsFonts.display, fontSize: 22, fontWeight: FontWeight.w700, color: c.ink, height: 1.1),
              ),
              Text(sub, style: TextStyle(fontSize: 11.5, color: c.ink3)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.parts, this.track);
  final List<_Part> parts;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 15.5;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: size.shortestSide / 2 - stroke / 2);
    final total = parts.fold<int>(0, (x, p) => x + p.v);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    if (total == 0) {
      canvas.drawArc(rect, 0, 2 * math.pi, false, paint..color = track);
      return;
    }
    var start = -math.pi / 2;
    for (final p in parts) {
      if (p.v == 0) continue;
      final sweep = 2 * math.pi * p.v / total;
      canvas.drawArc(rect, start, sweep, false, paint..color = p.color);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.parts != parts || old.track != track;
}

/// Shared axis drawing for the bar and line charts.
class _Axes {
  _Axes(this.size, this.top, this.grid, this.text, this.yLabel, this.labels, this.maxLabels);
  final Size size;
  final num top;
  final Color grid;
  final TextStyle text;
  final String Function(num) yLabel;
  final List<String> labels;
  final int maxLabels;

  static const pt = 10.0, pb = 22.0, pr = 4.0;
  late final double pl = () {
    var w = 0.0;
    for (var k = 0; k <= 4; k++) {
      w = math.max(w, _tp(yLabel(top * k / 4)).width);
    }
    return w + 8;
  }();

  double get plotH => size.height - pt - pb;
  double y(num v) => pt + plotH * (1 - v / top);

  TextPainter _tp(String s) => TextPainter(
    text: TextSpan(text: s, style: text),
    textDirection: TextDirection.ltr,
  )..layout();

  void drawGrid(Canvas canvas) {
    final line = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var k = 0; k <= 4; k++) {
      final yy = y(top * k / 4);
      canvas.drawLine(Offset(pl, yy), Offset(size.width - pr, yy), line);
      final tp = _tp(yLabel(top * k / 4));
      tp.paint(canvas, Offset(pl - 6 - tp.width, yy - tp.height / 2));
    }
  }

  /// Draws every n-th x label (and the last one) centred on [xOf].
  void drawXLabels(Canvas canvas, double Function(int) xOf) {
    final n = labels.length;
    if (n == 0) return;
    final every = (n / maxLabels).ceil();
    for (var i = 0; i < n; i++) {
      final isLast = i == n - 1;
      if (!(i % every == 0 || isLast)) continue;
      if (!isLast && n - 1 - i < every / 2) continue; // too close to the last label
      final tp = _tp(labels[i]);
      final x = (xOf(i) - tp.width / 2).clamp(0.0, size.width - tp.width);
      tp.paint(canvas, Offset(x, size.height - tp.height - 2));
    }
  }
}

int _niceTop(num max) {
  final t = (math.max(1, max) / 4).ceil() * 4;
  return t == 0 ? 4 : t;
}

/// Stacked vertical bars per label with a y-axis grid (chartBars).
class BarChart extends StatelessWidget {
  const BarChart({super.key, required this.series, required this.labels, required this.maxLabels, required this.height});
  final List<ChartSeries> series;
  final List<String> labels;
  final int maxLabels;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _BarPainter(series, labels, maxLabels, c.line2, TextStyle(fontSize: 11, color: c.ink3, fontFamily: AgntsFonts.sans)),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter(this.series, this.labels, this.maxLabels, this.grid, this.text);
  final List<ChartSeries> series;
  final List<String> labels;
  final int maxLabels;
  final Color grid;
  final TextStyle text;

  @override
  void paint(Canvas canvas, Size size) {
    final n = labels.length;
    num max = 0;
    for (var i = 0; i < n; i++) {
      max = math.max(max, series.fold<num>(0, (a, s) => a + (i < s.values.length ? s.values[i] : 0)));
    }
    final ax = _Axes(size, _niceTop(max), grid, text, (v) => '${v.round()}', labels, maxLabels);
    ax.drawGrid(canvas);
    if (n == 0) return;
    final bw = (size.width - ax.pl - _Axes.pr) / n;
    final gap = math.min(6.0, bw * 0.25);
    for (var i = 0; i < n; i++) {
      num acc = 0;
      final x = ax.pl + i * bw + gap / 2;
      for (final s in series) {
        final v = i < s.values.length ? s.values[i] : 0;
        if (v <= 0) continue;
        final rect = Rect.fromLTRB(x, ax.y(acc + v), x + bw - gap, ax.y(acc));
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), Paint()..color = s.color);
        acc += v;
      }
    }
    ax.drawXLabels(canvas, (i) => ax.pl + i * bw + bw / 2);
  }

  @override
  bool shouldRepaint(_BarPainter old) => true;
}

/// Lines (one optionally filled) over the same grid (chartLines).
class _LineChart extends StatelessWidget {
  const _LineChart({required this.series, required this.labels, required this.maxLabels, required this.fmt});
  final List<ChartSeries> series;
  final List<String> labels;
  final int maxLabels;
  final String Function(num) fmt;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: CustomPaint(
        painter: _LinePainter(series, labels, maxLabels, fmt, c.line2, TextStyle(fontSize: 11, color: c.ink3, fontFamily: AgntsFonts.sans)),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.series, this.labels, this.maxLabels, this.fmt, this.grid, this.text);
  final List<ChartSeries> series;
  final List<String> labels;
  final int maxLabels;
  final String Function(num) fmt;
  final Color grid;
  final TextStyle text;

  @override
  void paint(Canvas canvas, Size size) {
    final n = labels.length;
    // A NaN value is a day without data: the line breaks there.
    final max = series.expand((s) => s.values).where((v) => !v.isNaN).fold<num>(0, math.max);
    final ax = _Axes(size, _niceTop(max), grid, text, fmt, labels, maxLabels);
    ax.drawGrid(canvas);
    if (n == 0) return;
    double xOf(int i) => n == 1 ? ax.pl : ax.pl + i * (size.width - ax.pl - _Axes.pr) / (n - 1);
    for (final s in series) {
      // Runs of consecutive days with data.
      final runs = <List<Offset>>[[]];
      for (var i = 0; i < n && i < s.values.length; i++) {
        if (s.values[i].isNaN) {
          if (runs.last.isNotEmpty) runs.add([]);
          continue;
        }
        runs.last.add(Offset(xOf(i), ax.y(s.values[i])));
      }
      for (final pts in runs) {
        if (pts.isEmpty) continue;
        if (s.area && pts.length > 1) {
          final fill = Path()..moveTo(pts.first.dx, ax.y(0));
          for (final p in pts) {
            fill.lineTo(p.dx, p.dy);
          }
          fill
            ..lineTo(pts.last.dx, ax.y(0))
            ..close();
          canvas.drawPath(fill, Paint()..color = s.color.withValues(alpha: 0.12));
        }
        canvas.drawPath(
          Path()..addPolygon(pts, false),
          Paint()
            ..color = s.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4
            ..strokeJoin = StrokeJoin.round
            ..strokeCap = StrokeCap.round,
        );
        if (n <= 40) {
          for (final p in pts) {
            canvas.drawCircle(p, 3, Paint()..color = s.color);
          }
        }
      }
    }
    ax.drawXLabels(canvas, xOf);
  }

  @override
  bool shouldRepaint(_LinePainter old) => true;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';
import '../activity/activity_screen.dart';

/// Analytics for the last [days] days, compared with the period before.
final _analyticsFor = FutureProvider.family<Analytics, int>((ref, days) async {
  return (await requireApi(ref).getAnalyticsApi().getAnalytics(days: days)).data!;
});

/// The demo's soft blue (after changes, hourly activity); the theme has no token for it.
const _softBlue = Color(0xFF7F95E8);

enum _Tab { analytics, events }

/// Analytics tab: the dashboard (KPIs, charts, insights) and, under
/// "Events", the activity log.
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  _Tab _tab = _Tab.analytics;
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
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.manalyticsAbout, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text(l.analyticsLede, style: TextStyle(fontSize: 15, color: c.ink2)),
            const SizedBox(height: 8),
            Text(l.manalyticsCompared(_days), style: TextStyle(fontSize: 14, color: c.ink3)),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          PageHeader(title: l.analyticsTitle, actions: [RoundIconButton('info', tooltip: l.manalyticsAbout, onTap: _about)]),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Segmented<_Tab>(
              full: true,
              options: [(_Tab.analytics, l.analyticsTitle), (_Tab.events, l.analyticsEvents)],
              value: _tab,
              onChanged: (t) => setState(() => _tab = t),
            ),
          ),
          Expanded(
            child: IndexedStack(index: _tab.index, children: [
              _dashboard(context),
              const ActivityFeed(),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _dashboard(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final value = ref.watch(_analyticsFor(_days));
    return RefreshIndicator(
      onRefresh: () => ref.refresh(_analyticsFor(_days).future),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Segmented<int>(
              full: true,
              options: [for (final d in const [7, 30, 90]) (d, l.manalyticsDays(d))],
              value: _days,
              onChanged: (d) => setState(() => _days = d),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
            child: Text(l.manalyticsCompared(_days), style: TextStyle(fontSize: 12.5, color: c.ink3)),
          ),
          ...switch (value) {
            AsyncData(:final value) => _Dashboard(a: value, days: _days).children(context),
            AsyncError() => [
                Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: HelpBox(l.analyticsError, tone: Tone.bad)),
              ],
            _ => [
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(l.analyticsLoading, style: TextStyle(color: c.ink3)),
                  ]),
                ),
              ],
          },
        ],
      ),
    );
  }
}

// ---- Dashboard content ----

int _pct(num a, num b) => b == 0 ? 0 : (a / b * 100).round();

/// Builds the dashboard's sections from one analytics response.
class _Dashboard {
  const _Dashboard({required this.a, required this.days});
  final Analytics a;
  final int days;

  String _min(AppLocalizations l, num m) {
    final v = math.max(0, m.round());
    if (v < 60) return l.analyticsMinutes('$v');
    return l.analyticsHoursMinutes('${v ~/ 60}', '${v % 60}');
  }

  /// "+3%" / "−7%", green when the change is an improvement.
  Widget _delta(num cur, num prev, {required bool upIsGood}) {
    if (prev == 0) return const Delta('—', better: null);
    final d = ((cur - prev) / prev * 100).round();
    if (d == 0) return const Delta('0%', better: null);
    return Delta('${d > 0 ? '+' : '−'}${d.abs()}%', better: upIsGood ? d > 0 : d < 0);
  }

  Widget _card(Widget child) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: HCard(child: child));

  List<Widget> children(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final cur = a.current, prev = a.previous;
    final locale = Localizations.localeOf(context).toString();

    final empty = cur.picked + cur.pushed + cur.rejected + cur.stopped == 0 && a.models.isEmpty && a.hours.every((h) => h == 0);
    if (empty) {
      return [_card(EmptyState(title: l.analyticsEmptyTitle, text: l.analyticsEmpty))];
    }

    final fmt = days <= 7 ? DateFormat.E(locale) : DateFormat('d MMM', locale);
    final labels = [for (final d in a.perDay) fmt.format(DateTime(d.date.year, d.date.month, d.date.day))];
    final maxLabels = days > 30 ? 4 : days > 7 ? 5 : 7;
    final success = _pct(cur.pushed, cur.picked), first = _pct(cur.firstTry, cur.pushed);
    Text sub(String s) => Text(s, style: TextStyle(fontSize: 13.5, color: c.ink3));

    // KPIs
    final kpis = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Grid2(children: [
        KpiCard(
            label: l.analyticsKpiPushed,
            value: '${cur.pushed}',
            delta: _delta(cur.pushed, prev.pushed, upIsGood: true),
            note: l.analyticsKpiPushedNote('${cur.picked}')),
        KpiCard(
            label: l.analyticsKpiSuccess,
            value: '$success%',
            delta: _delta(success, _pct(prev.pushed, prev.picked), upIsGood: true),
            note: l.analyticsKpiSuccessNote),
        KpiCard(
            label: l.analyticsKpiFirstTry,
            value: '$first%',
            delta: _delta(first, _pct(prev.firstTry, prev.pushed), upIsGood: true),
            note: l.analyticsKpiFirstTryNote),
        KpiCard(
            label: l.analyticsKpiAgnts,
            value: _min(l, cur.agntsMin),
            delta: _delta(cur.agntsMin, prev.agntsMin, upIsGood: false),
            note: l.analyticsKpiAgntsNote),
        KpiCard(
            label: l.analyticsKpiWait,
            value: _min(l, cur.waitMin),
            delta: _delta(cur.waitMin, prev.waitMin, upIsGood: false),
            note: l.analyticsKpiWaitNote),
        KpiCard(
            label: l.analyticsKpiTurns,
            value: '${cur.turns.round()}',
            delta: _delta(cur.turns, prev.turns, upIsGood: false),
            note: l.analyticsKpiTurnsNote),
      ]),
    );

    // Throughput
    final throughput = [
      ChartSeries(l.analyticsPushed, [for (final d in a.perDay) d.pushed], c.primary),
      ChartSeries(l.analyticsRejected, [for (final d in a.perDay) d.rejected], c.line3),
      ChartSeries(l.analyticsStopped, [for (final d in a.perDay) d.stopped], c.bad),
    ];

    // Outcomes
    final outcomes = [
      _Part(l.analyticsFirstTry, cur.firstTry, c.ok),
      _Part(l.analyticsAfterChanges, cur.afterChanges, _softBlue),
      _Part(l.analyticsRejected, cur.rejected, c.line3),
      _Part(l.analyticsStopped, cur.stopped, c.bad),
    ];

    // Where the time goes
    final steps = [
      _HRow(stateLabelOf(l, TicketState.analyzing), a.steps['analyzing'] ?? 0),
      _HRow(stateLabelOf(l, TicketState.waitingForAnswers), a.steps['waiting_for_answers'] ?? 0, Tone.warn),
      _HRow(stateLabelOf(l, TicketState.coding), a.steps['coding'] ?? 0),
      _HRow(stateLabelOf(l, TicketState.testing), a.steps['testing'] ?? 0),
      _HRow(stateLabelOf(l, TicketState.waitingForReview), a.steps['waiting_for_review'] ?? 0, Tone.warn),
      _HRow(stateLabelOf(l, TicketState.pushing), a.steps['pushing'] ?? 0),
    ];

    // Why runs stop
    final stopsTotal = a.stops.values.fold<int>(0, (x, y) => x + y);
    final stops = [
      _HRow(l.analyticsStopTests, a.stops['tests'] ?? 0, Tone.bad),
      _HRow(l.analyticsStopLimit, a.stops['limit'] ?? 0, Tone.warn),
      _HRow(l.analyticsStopYou, a.stops['you'] ?? 0),
      _HRow(l.analyticsStopTurns, a.stops['turns'] ?? 0),
      _HRow(l.analyticsStopOther, a.stops['other'] ?? 0),
    ]..sort((x, y) => y.v.compareTo(x.v));

    // Models
    final totalRuns = a.models.fold<int>(0, (x, m) => x + m.runs);
    String modelName(String m) => const {'haiku': 'Haiku', 'sonnet': 'Sonnet', 'opus': 'Opus'}[m] ?? m;

    // Plan usage
    final known = a.perDay.where((d) => d.peakUsage != null).toList();
    final avgPeak = known.isEmpty ? 0 : (known.fold<num>(0, (x, d) => x + d.peakUsage!) / known.length * 100).round();
    final daysAbove = known.where((d) => d.peakUsage! >= 0.8).length;

    // Hours
    final hoursMax = a.hours.isEmpty ? 0 : a.hours.reduce(math.max);
    final busiest = a.hours.indexOf(hoursMax).toString().padLeft(2, '0');

    String mdLabel(String s) => switch (s) { 'found' => l.analyticsMdFound, 'missing' => l.analyticsMdMissing, _ => l.analyticsMdUnknown };
    String insight(AnalyticsInsightsInner i) {
      final v = i.values;
      return switch (i.kind) {
        AnalyticsInsightsInnerKindEnum.claudeMd => l.analyticsInsightClaudeMd(v['gain'] ?? '', v['repos'] ?? ''),
        AnalyticsInsightsInnerKindEnum.waiting => l.analyticsInsightWaiting(v['share'] ?? '', v['review'] ?? ''),
        AnalyticsInsightsInnerKindEnum.stopsTests => l.analyticsInsightStopsTests(v['n'] ?? ''),
        AnalyticsInsightsInnerKindEnum.stopsLimit => l.analyticsInsightStopsLimit(v['n'] ?? ''),
        AnalyticsInsightsInnerKindEnum.night => l.analyticsInsightNight(v['pct'] ?? ''),
        AnalyticsInsightsInnerKindEnum.mergeRate => l.analyticsInsightMergeRate(v['pct'] ?? '', v['closed'] ?? ''),
        AnalyticsInsightsInnerKindEnum.slowAnswers => l.analyticsInsightSlowAnswers(v['hours'] ?? ''),
        AnalyticsInsightsInnerKindEnum.followUpsNoise => l.analyticsInsightFollowUpsNoise(v['pct'] ?? ''),
        AnalyticsInsightsInnerKindEnum.flakyJob => l.analyticsInsightFlakyJob(v['job'] ?? '', v['repo'] ?? '', v['n'] ?? ''),
      };
    }

    Widget hint(String s) => Text(s, style: TextStyle(fontSize: 14, color: c.ink3));

    return [
      kpis,
      SectionHeader(l.analyticsThroughput),
      _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sub(l.analyticsThroughputSub),
        const SizedBox(height: 10),
        BarChart(series: throughput, labels: labels, maxLabels: maxLabels, height: 190),
        ChartLegend([for (final s in throughput) (s.color, s.label)]),
      ])),
      SectionHeader(l.analyticsOutcomes),
      _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sub(l.analyticsOutcomesSub),
        const SizedBox(height: 12),
        Row(children: [
          _Donut(parts: outcomes, center: '$success%', sub: l.analyticsDonutSub),
          const SizedBox(width: 14),
          Expanded(
            child: Column(children: [
              for (final o in outcomes)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    _Swatch(o.color),
                    const SizedBox(width: 7),
                    Expanded(child: Text(o.label, style: TextStyle(fontSize: 13.5, color: c.ink2))),
                    Text('${o.v}', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink)),
                  ]),
                ),
            ]),
          ),
        ]),
      ])),
      SectionHeader(l.analyticsSpeed),
      _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sub(l.analyticsSpeedSub),
        const SizedBox(height: 10),
        _LineChart(
          series: [
            ChartSeries(l.analyticsAgntsWorking, [for (final d in a.perDay) d.agntsMin], c.primary, area: true),
            ChartSeries(l.analyticsWaitingOnYou, [for (final d in a.perDay) d.waitMin], c.warn),
          ],
          labels: labels,
          maxLabels: maxLabels,
          fmt: (v) => _min(l, v),
        ),
        ChartLegend([(c.primary, l.analyticsAgntsWorking), (c.warn, l.analyticsWaitingOnYou)]),
      ])),
      SectionHeader(l.analyticsSteps),
      _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sub(l.analyticsStepsSub),
        const SizedBox(height: 6),
        _HBars(steps, fmt: (v) => _min(l, v)),
        ChartLegend([(c.primary, l.analyticsAgntsWorking), (c.warn, l.analyticsWaitingOnYou)]),
      ])),
      SectionHeader(l.analyticsStops, trailing: Text('$stopsTotal')),
      _card(stopsTotal == 0
          ? hint(l.manalyticsStopped(0))
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              sub(l.manalyticsStopped(stopsTotal)),
              const SizedBox(height: 6),
              _HBars(stops),
            ])),
      SectionHeader(l.analyticsModels),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: a.models.isEmpty
            ? HCard(child: hint(l.analyticsNoRuns))
            : ListGroup(children: [
                for (final m in a.models)
                  ListRow(
                    title: modelName(m.model),
                    subtitle: [
                      l.manalyticsShareOfRuns('${_pct(m.runs, totalRuns)}'),
                      l.manalyticsReachedReview('${_pct(m.reachedReview, m.runs)}'),
                      l.manalyticsTurns(m.avgTurns.round()),
                    ].join(' · '),
                    value: '${m.runs}',
                  ),
              ]),
      ),
      SectionHeader(l.analyticsUsage),
      _card(known.isEmpty
          ? hint(l.analyticsNoUsage)
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              sub(l.analyticsUsageSub),
              const SizedBox(height: 10),
              BarChart(
                series: [ChartSeries(l.analyticsSession, [for (final d in a.perDay) d.peakUsage == null ? 0 : (d.peakUsage! * 100).round()], c.primary)],
                labels: labels,
                maxLabels: maxLabels,
                height: 170,
              ),
              const SizedBox(height: 6),
              _MiniKv(l.analyticsAvgPeak, '$avgPeak%'),
              _MiniKv(l.analyticsDaysAbove, '$daysAbove', last: true),
            ])),
      SectionHeader(l.analyticsRepos),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: a.repos.isEmpty
            ? HCard(child: hint(l.analyticsNoRepos))
            : ListGroup(children: [
                for (final r in a.repos)
                  ListRow(
                    leading: SourceChip(r.kind == 'side' ? l.analyticsSrcTask : l.analyticsSrcJira, task: r.kind == 'side'),
                    title: r.name,
                    subtitle: [
                      l.manalyticsTickets(r.tickets),
                      l.manalyticsTurns(r.avgTurns.round()),
                      _min(l, r.agntsMin),
                      '${l.analyticsColClaudeMd}: ${mdLabel(r.claudeMd)}',
                    ].join(' · '),
                    trailing: Text(
                      r.finished == 0 ? '—' : '${_pct(r.done, r.finished)}%',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: r.finished == 0 ? c.ink3 : _pct(r.done, r.finished) >= 80 ? c.okInk : c.warnInk,
                      ),
                    ),
                    onTap: () => context.push('/repos/${r.repoId}?name=${Uri.encodeQueryComponent(r.name)}'),
                  ),
              ]),
      ),
      if (hoursMax > 0) ...[
        SectionHeader(l.analyticsHours),
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          sub(l.analyticsHoursSub(busiest)),
          const SizedBox(height: 10),
          BarChart(
            series: [ChartSeries(l.analyticsEvents, a.hours, _softBlue)],
            labels: [for (var i = 0; i < a.hours.length; i++) i.toString().padLeft(2, '0')],
            maxLabels: 6,
            height: 170,
          ),
        ])),
      ],
      SectionHeader(l.analyticsInsights),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: a.insights.isEmpty
            ? HCard(child: hint(l.analyticsNoInsights))
            : Column(children: [
                for (final (i, x) in a.insights.indexed) Padding(padding: EdgeInsets.only(top: i == 0 ? 0 : 10), child: HelpBox(insight(x))),
              ]),
      ),
    ];
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
  Widget build(BuildContext context) =>
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)));
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
      child: Wrap(spacing: 14, runSpacing: 6, children: [
        for (final (color, label) in items)
          Row(mainAxisSize: MainAxisSize.min, children: [
            _Swatch(color),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 12.5, color: c.ink3)),
          ]),
      ]),
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
      decoration: BoxDecoration(border: last ? null : Border(bottom: BorderSide(color: c.line2))),
      child: Row(children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: c.ink))),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.ink)),
      ]),
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
    return Column(children: [
      for (final r in rows)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(child: Text(r.l, style: TextStyle(fontSize: 13.5, color: c.ink))),
              const SizedBox(width: 10),
              Text(fmt == null ? '${r.v}' : fmt!(r.v), style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink)),
            ]),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 8,
                color: c.line2,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(widthFactor: math.max(0.02, r.v / max).clamp(0, 1).toDouble(), heightFactor: 1, child: ColoredBox(color: r.tone.solid(c))),
              ),
            ),
          ]),
        ),
    ]);
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
      child: Stack(alignment: Alignment.center, children: [
        Positioned.fill(child: CustomPaint(painter: _DonutPainter(parts, c.line2))),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text(center, style: TextStyle(fontFamily: AgntsFonts.display, fontSize: 22, fontWeight: FontWeight.w700, color: c.ink, height: 1.1)),
          Text(sub, style: TextStyle(fontSize: 11.5, color: c.ink3)),
        ]),
      ]),
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

  TextPainter _tp(String s) => TextPainter(text: TextSpan(text: s, style: text), textDirection: TextDirection.ltr)..layout();

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
    final max = series.expand((s) => s.values).fold<num>(0, math.max);
    final ax = _Axes(size, _niceTop(max), grid, text, fmt, labels, maxLabels);
    ax.drawGrid(canvas);
    if (n == 0) return;
    double xOf(int i) => n == 1 ? ax.pl : ax.pl + i * (size.width - ax.pl - _Axes.pr) / (n - 1);
    for (final s in series) {
      final pts = [for (var i = 0; i < n && i < s.values.length; i++) Offset(xOf(i), ax.y(s.values[i]))];
      if (pts.isEmpty) continue;
      final path = Path()..addPolygon(pts, false);
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
        path,
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
    ax.drawXLabels(canvas, xOf);
  }

  @override
  bool shouldRepaint(_LinePainter old) => true;
}

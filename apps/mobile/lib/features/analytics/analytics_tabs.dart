part of 'analytics_screen.dart';

// ---- Tab content ----
//
// Each tab mirrors the admin panel's (apps/admin/src/components/analytics):
// its KPIs as a two-column grid, its charts as cards, and its tables as
// list rows with the columns folded into a subtitle.

int _pct(num a, num b) => b == 0 ? 0 : (a / b * 100).round();

Widget _card(Widget child) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: HCard(child: child),
);

Widget _pad(Widget child) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: child);

/// Minutes as "12 min" or "3 h 5 min"; long spans as days and hours.
String _min(AppLocalizations l, num m) {
  final v = math.max(0, m.round());
  if (v < 60) return l.analyticsMinutes('$v');
  if (v < 48 * 60) return l.analyticsHoursMinutes('${v ~/ 60}', '${v % 60}');
  return l.analyticsDaysHours('${v ~/ 1440}', '${((v % 1440) / 60).round()}');
}

/// A spread's typical (median) value, or "—" without one.
String _p50(AppLocalizations l, Spread s) => s.p50 == null ? '—' : _min(l, s.p50!);

/// A spread's slowest-one-in-ten value, or "—".
String _p90(AppLocalizations l, Spread s) => s.p90 == null ? '—' : _min(l, s.p90!);

/// "+3%" / "−7%", green when the change is an improvement.
Widget _delta(num cur, num prev, {required bool upIsGood}) {
  if (prev == 0) return const Delta('—', better: null);
  final d = ((cur - prev) / prev * 100).round();
  if (d == 0) return const Delta('0%', better: null);
  return Delta('${d > 0 ? '+' : '−'}${d.abs()}%', better: upIsGood ? d > 0 : d < 0);
}

/// A card's subtitle (.sub).
Widget _sub(BuildContext context, String s) => Text(s, style: TextStyle(fontSize: 13.5, color: Agnts.of(context).ink3));

/// A card's empty line (.hint).
Widget _hint(BuildContext context, String s) => Text(s, style: TextStyle(fontSize: 14, color: Agnts.of(context).ink3));

/// A note under the KPI grid.
Widget _note(BuildContext context, String s) => Padding(
  padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
  child: Text(s, style: TextStyle(fontSize: 12.5, color: Agnts.of(context).ink3)),
);

/// A titled card: the heading above, the body inside.
List<Widget> _section(BuildContext context, String title, String? sub, List<Widget> body, {Widget? trailing}) => [
  SectionHeader(title, trailing: trailing),
  _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (sub != null) ...[_sub(context, sub), const SizedBox(height: 10)],
        ...body,
      ],
    ),
  ),
];

/// A titled list: the heading above, rows in a group (or a hint when empty).
List<Widget> _list(BuildContext context, String title, List<Widget> rows, {required String empty, String? sub, Widget? trailing}) => [
  SectionHeader(title, trailing: trailing),
  if (sub != null) Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 8), child: _sub(context, sub)),
  _pad(rows.isEmpty ? HCard(child: _hint(context, empty)) : ListGroup(children: rows)),
];

String _mdLabel(AppLocalizations l, String s) => switch (s) {
  'found' => l.analyticsMdFound,
  'missing' => l.analyticsMdMissing,
  _ => l.analyticsMdUnknown,
};

String _stageName(AppLocalizations l, String stage) => switch (stage) {
  'analyze' => l.spendStageAnalyze,
  'coding' => l.spendStageCoding,
  'retry' => l.spendStageRetry,
  'review' => l.spendStageReview,
  'preview' => l.spendStagePreview,
  'learn' => l.spendStageLearn,
  'helper' => l.spendStageHelper,
  _ => stage,
};

String _ciClass(AppLocalizations l, String c) => switch (c) {
  'code' => l.ciClass_code,
  'test' => l.ciClass_test,
  'config' => l.ciClass_config,
  'dependency' => l.ciClass_dependency,
  'infra' => l.ciClass_infra,
  'flaky' => l.ciClass_flaky,
  _ => l.analyticsCiUnknown,
};

String _followUpType(AppLocalizations l, String t) => switch (t) {
  'prerequisite' => l.followUpsType_prerequisite,
  'split' => l.followUpsType_split,
  'unfinished' => l.followUpsType_unfinished,
  'gap' => l.followUpsType_gap,
  _ => t,
};

String _followUpSource(AppLocalizations l, String s) => switch (s) {
  'analyze' => l.followUpsSource_analyze,
  'work' => l.followUpsSource_work,
  'review' => l.followUpsSource_review,
  'manual' => l.followUpsSource_manual,
  _ => s,
};

String _lessonCategory(AppLocalizations l, String c) => switch (c) {
  'pattern' => l.learnCategory_pattern,
  'architecture' => l.learnCategory_architecture,
  'algorithm' => l.learnCategory_algorithm,
  'library' => l.learnCategory_library,
  'language' => l.learnCategory_language,
  'testing' => l.learnCategory_testing,
  'security' => l.learnCategory_security,
  'performance' => l.learnCategory_performance,
  'tooling' => l.learnCategory_tooling,
  _ => l.learnCategory_other,
};

/// The tabs built from one analytics response.
class _View {
  _View(this.a, this.days, this.locale);
  final Analytics a;
  final int days;
  final String locale;

  late final List<String> labels = () {
    final fmt = days <= 7 ? DateFormat.E(locale) : DateFormat('d MMM', locale);
    return [for (final d in a.perDay) fmt.format(DateTime(d.date.year, d.date.month, d.date.day))];
  }();
  int get maxLabels => days > 30
      ? 4
      : days > 7
      ? 5
      : 7;

  String _tok(int n) => fmtTokens(n, locale);
  String _usd(double v) => fmtUsd(v, locale);

  // -- Overview: insights, headline numbers, throughput, outcomes, hours.

  List<Widget> overview(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final cur = a.current, prev = a.previous;
    final success = _pct(cur.pushed, cur.picked), first = _pct(cur.firstTry, cur.pushed);
    final perTicket = cur.pushed == 0 ? 0.0 : cur.spend.costUsd / cur.pushed;
    final prevPerTicket = prev.pushed == 0 ? 0.0 : prev.spend.costUsd / prev.pushed;

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

    final throughput = [
      ChartSeries(l.analyticsPushed, [for (final d in a.perDay) d.pushed], c.primary),
      ChartSeries(l.analyticsRejected, [for (final d in a.perDay) d.rejected], c.line3),
      ChartSeries(l.analyticsStopped, [for (final d in a.perDay) d.stopped], c.bad),
    ];
    final outcomes = [
      _Part(l.analyticsFirstTry, cur.firstTry, c.ok),
      _Part(l.analyticsAfterChanges, cur.afterChanges, _softBlue),
      _Part(l.analyticsRejected, cur.rejected, c.line3),
      _Part(l.analyticsStopped, cur.stopped, c.bad),
    ];
    final hoursMax = a.hours.isEmpty ? 0 : a.hours.reduce(math.max);
    final busiest = a.hours.indexOf(hoursMax).toString().padLeft(2, '0');

    return [
      SectionHeader(l.analyticsInsights, padding: const EdgeInsets.fromLTRB(20, 0, 20, 8)),
      _pad(
        a.insights.isEmpty
            ? HCard(child: _hint(context, l.analyticsNoInsights))
            : Column(
                children: [
                  for (final (i, x) in a.insights.indexed)
                    Padding(
                      padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
                      child: HelpBox(insight(x)),
                    ),
                ],
              ),
      ),
      const SizedBox(height: 14),
      _pad(
        Grid2(
          children: [
            KpiCard(
              label: l.analyticsKpiPushed,
              value: '${cur.pushed}',
              delta: _delta(cur.pushed, prev.pushed, upIsGood: true),
              note: l.analyticsKpiPushedNote('${cur.picked}'),
            ),
            KpiCard(
              label: l.analyticsKpiSuccess,
              value: '$success%',
              delta: _delta(success, _pct(prev.pushed, prev.picked), upIsGood: true),
              note: l.analyticsKpiSuccessNote,
            ),
            KpiCard(
              label: l.analyticsKpiFirstTry,
              value: '$first%',
              delta: _delta(first, _pct(prev.firstTry, prev.pushed), upIsGood: true),
              note: l.analyticsKpiFirstTryNote,
            ),
            KpiCard(
              label: l.analyticsKpiMerged,
              value: '${cur.merged}',
              delta: _delta(cur.merged, prev.merged, upIsGood: true),
              note: l.analyticsKpiMergedNote('${cur.closed}'),
            ),
            KpiCard(
              label: l.analyticsKpiWait,
              value: _min(l, cur.waitMin),
              delta: _delta(cur.waitMin, prev.waitMin, upIsGood: false),
              note: l.analyticsKpiWaitNote,
            ),
            KpiCard(
              label: l.analyticsKpiCostPerTicket,
              value: cur.pushed == 0 ? '—' : _usd(perTicket),
              delta: cur.pushed == 0 ? null : _delta(perTicket, prevPerTicket, upIsGood: false),
              note: l.analyticsKpiCostPerTicketNote,
            ),
          ],
        ),
      ),
      ..._section(context, l.analyticsThroughput, l.analyticsThroughputSub, [
        BarChart(series: throughput, labels: labels, maxLabels: maxLabels, height: 190),
        ChartLegend([for (final s in throughput) (s.color, s.label)]),
      ]),
      ..._section(context, l.analyticsOutcomes, l.analyticsOutcomesSub, [
        Row(
          children: [
            _Donut(parts: outcomes, center: '$success%', sub: l.analyticsDonutSub),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                children: [
                  for (final o in outcomes)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          _Swatch(o.color),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(o.label, style: TextStyle(fontSize: 13.5, color: c.ink2)),
                          ),
                          Text(
                            '${o.v}',
                            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ]),
      if (hoursMax > 0)
        ..._section(context, l.analyticsHours, l.analyticsHoursSub(busiest), [
          BarChart(
            series: [ChartSeries(l.analyticsEvents, a.hours, _softBlue)],
            labels: [for (var i = 0; i < a.hours.length; i++) i.toString().padLeft(2, '0')],
            maxLabels: 6,
            height: 170,
          ),
        ]),
    ];
  }

  // -- Delivery: pull requests, cycle time, questions and the slowest tickets.

  List<Widget> delivery(BuildContext context, AnalyticsDelivery d) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final cur = d.current, prev = d.previous;
    int rate(DeliveryPeriod p) => _pct(p.merged, p.merged + p.closed);
    Widget? spreadDelta(Spread cur, Spread prev) => cur.p50 == null ? null : _delta(cur.p50!, prev.p50 ?? 0, upIsGood: false);
    final stillOpen = math.max(0, cur.opened - cur.merged - cur.closed);
    final dLabels = () {
      final fmt = days <= 7 ? DateFormat.E(locale) : DateFormat('d MMM', locale);
      return [for (final x in d.perDay) fmt.format(DateTime(x.date.year, x.date.month, x.date.day))];
    }();
    final prSeries = [
      ChartSeries(l.analyticsPrMerged, [for (final x in d.perDay) x.merged], c.ok),
      ChartSeries(l.analyticsPrClosed, [for (final x in d.perDay) x.closed], c.line3),
    ];
    final steps = [
      _HRow(stateLabelOf(l, TicketState.analyzing), a.steps['analyzing'] ?? 0),
      _HRow(stateLabelOf(l, TicketState.waitingForAnswers), a.steps['waiting_for_answers'] ?? 0, Tone.warn),
      _HRow(stateLabelOf(l, TicketState.coding), a.steps['coding'] ?? 0),
      _HRow(stateLabelOf(l, TicketState.testing), a.steps['testing'] ?? 0),
      _HRow(stateLabelOf(l, TicketState.waitingForReview), a.steps['waiting_for_review'] ?? 0, Tone.warn),
      _HRow(stateLabelOf(l, TicketState.pushing), a.steps['pushing'] ?? 0),
    ];
    int openDays(DateTime at) => DateTime.now().difference(at).inDays;
    final splitColors = [
      (c.primary, l.analyticsAgntsWorking),
      (c.warn, l.analyticsSplitAnswers),
      (_peach, l.analyticsSplitReview),
      (c.line3, l.analyticsSplitQueue),
    ];

    return [
      _pad(
        Grid2(
          children: [
            KpiCard(
              label: l.analyticsKpiMergeRate,
              value: cur.merged + cur.closed == 0 ? '—' : '${rate(cur)}%',
              delta: cur.merged + cur.closed == 0 ? null : _delta(rate(cur), rate(prev), upIsGood: true),
              note: l.analyticsKpiMergeRateNote('${cur.merged}', '${cur.closed}'),
            ),
            KpiCard(
              label: l.analyticsKpiTimeToMerge,
              value: _p50(l, cur.mergeMin),
              delta: spreadDelta(cur.mergeMin, prev.mergeMin),
              note: l.analyticsKpiTimeToMergeNote,
            ),
            KpiCard(
              label: l.analyticsKpiCyclePushed,
              value: _p50(l, cur.pushedMin),
              delta: spreadDelta(cur.pushedMin, prev.pushedMin),
              note: l.analyticsKpiCyclePushedNote,
            ),
            KpiCard(
              label: l.analyticsKpiCycleMerged,
              value: _p50(l, cur.mergedMin),
              delta: spreadDelta(cur.mergedMin, prev.mergedMin),
              note: l.analyticsKpiCycleMergedNote,
            ),
            KpiCard(
              label: l.analyticsKpiAgnts,
              value: _min(l, a.current.agntsMin),
              delta: _delta(a.current.agntsMin, a.previous.agntsMin, upIsGood: false),
              note: l.analyticsKpiAgntsNote,
            ),
            KpiCard(
              label: l.analyticsKpiAnswer,
              value: _p50(l, cur.answerMin),
              delta: spreadDelta(cur.answerMin, prev.answerMin),
              note: l.analyticsKpiAnswerNote,
            ),
          ],
        ),
      ),
      _note(context, l.analyticsTypicalNote),
      ..._section(context, l.analyticsPrOutcomes, l.analyticsPrOutcomesSub, [
        Grid2(
          gap: 8,
          children: [
            Fact(l.analyticsPrOpened, '${cur.opened}'),
            Fact(l.analyticsPrMerged, '${cur.merged}'),
            Fact(l.analyticsPrClosed, '${cur.closed}'),
            Fact(l.analyticsPrOpen, '$stillOpen'),
          ],
        ),
        const SizedBox(height: 12),
        BarChart(series: prSeries, labels: dLabels, maxLabels: maxLabels, height: 170),
        ChartLegend([for (final s in prSeries) (s.color, s.label)]),
        if (cur.mergeMin.p90 != null) ...[
          const SizedBox(height: 10),
          _sub(context, l.analyticsMergeSpread(_p50(l, cur.mergeMin), _min(l, cur.mergeMin.p90!))),
        ],
      ]),
      ..._list(context, l.analyticsStale, sub: l.analyticsStaleSub, empty: l.analyticsNoStale, [
        for (final p in d.stale)
          ListRow(
            title: '${p.key} · ${p.title}',
            subtitle: p.repo,
            trailing: ToneBadge(l.analyticsOpenDays(openDays(p.openedAt)), Tone.warn, small: true),
            onTap: () => context.push('/tickets/${p.key}'),
          ),
      ]),
      ..._section(context, l.analyticsCycle, l.analyticsCycleSub, [
        _LineChart(
          series: [
            ChartSeries(l.analyticsCyclePushed, [for (final x in d.perDay) x.pushedMin ?? double.nan], c.primary),
            ChartSeries(l.analyticsCycleMerged, [for (final x in d.perDay) x.mergedMin ?? double.nan], _softBlue),
          ],
          labels: dLabels,
          maxLabels: maxLabels,
          fmt: (v) => _min(l, v),
        ),
        ChartLegend([(c.primary, l.analyticsCyclePushed), (_softBlue, l.analyticsCycleMerged)]),
        const SizedBox(height: 10),
        _sub(
          context,
          l.analyticsCycleSpread(_p50(l, cur.pushedMin), _p90(l, cur.pushedMin), _p50(l, cur.mergedMin), _p90(l, cur.mergedMin)),
        ),
      ]),
      ..._section(context, l.analyticsQuestions, l.analyticsQuestionsSub, [
        Grid2(
          gap: 8,
          children: [
            Fact(l.analyticsQuestionsAsked, '${cur.questions}'),
            Fact(l.analyticsQuestionsShare, '${_pct(cur.askedTickets, cur.analyzedTickets)}%'),
          ],
        ),
        const SizedBox(height: 6),
        _MiniKv(l.analyticsAnswerTypical, _p50(l, cur.answerMin)),
        _MiniKv(l.analyticsAnswerSlow, _p90(l, cur.answerMin)),
        _MiniKv(l.analyticsUnanswered, '${d.unanswered}', last: true),
      ]),
      ..._section(context, l.analyticsSlowest, l.analyticsSlowestSub, [
        if (d.slowest.isEmpty)
          _hint(context, l.analyticsNoSlowest)
        else ...[
          for (final x in d.slowest) _SlowRow(x, colors: [for (final s in splitColors) s.$1], fmt: (v) => _min(l, v)),
          ChartLegend(splitColors),
        ],
      ]),
      ..._section(context, l.analyticsSpeed, l.analyticsSpeedSub, [
        _LineChart(
          series: [
            ChartSeries(l.analyticsAgntsWorking, [for (final x in a.perDay) x.agntsMin], c.primary, area: true),
            ChartSeries(l.analyticsWaitingOnYou, [for (final x in a.perDay) x.waitMin], c.warn),
          ],
          labels: labels,
          maxLabels: maxLabels,
          fmt: (v) => _min(l, v),
        ),
        ChartLegend([(c.primary, l.analyticsAgntsWorking), (c.warn, l.analyticsWaitingOnYou)]),
      ]),
      ..._section(context, l.analyticsSteps, l.analyticsStepsSub, [
        _HBars(steps, fmt: (v) => _min(l, v)),
        ChartLegend([(c.primary, l.analyticsAgntsWorking), (c.warn, l.analyticsWaitingOnYou)]),
      ]),
    ];
  }

  // -- Quality: turns, why runs stop, quality per prompt version, CI health.

  List<Widget> quality(BuildContext context, AsyncValue<AnalyticsCI> ciValue) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final ci = ciValue.value;
    final stopsTotal = a.stops.values.fold<int>(0, (x, y) => x + y);
    final stops = [
      _HRow(l.analyticsStopTests, a.stops['tests'] ?? 0, Tone.bad),
      _HRow(l.analyticsStopLimit, a.stops['limit'] ?? 0, Tone.warn),
      _HRow(l.analyticsStopYou, a.stops['you'] ?? 0),
      _HRow(l.analyticsStopTurns, a.stops['turns'] ?? 0),
      _HRow(l.analyticsStopOther, a.stops['other'] ?? 0),
    ]..sort((x, y) => y.v.compareTo(x.v));
    String version(QualityStat v) => v.promptVersion.isEmpty ? l.analyticsVersionUnknown : v.promptVersion;
    final harness = a.quality.any((v) => v.guardBlocks != null);
    final skills = a.skills ?? const <SkillStat>[];
    String skillName(String s) => s.isEmpty ? l.harnessSettingsSkillNone : s.replaceFirst(RegExp('^agnts-method-'), '');
    int autoShare(CIPeriod p) => _pct(p.autoFixed, p.fixed);

    final classes = [
      for (final k in const ['code', 'test', 'config', 'dependency', 'infra', 'flaky', 'unknown'])
        if ((ci?.byClass[k] ?? 0) > 0)
          _HRow(
            _ciClass(l, k),
            ci!.byClass[k]!,
            k == 'code' || k == 'test'
                ? Tone.bad
                : k == 'flaky'
                ? Tone.warn
                : Tone.info,
          ),
    ]..sort((x, y) => y.v.compareTo(x.v));

    return [
      _pad(
        Grid2(
          children: [
            KpiCard(
              label: l.analyticsKpiTurns,
              value: '${a.current.turns.round()}',
              delta: _delta(a.current.turns, a.previous.turns, upIsGood: false),
              note: l.analyticsKpiTurnsNote,
            ),
            if (ci != null && ci.watching) ...[
              KpiCard(
                label: l.analyticsKpiCiSeen,
                value: '${ci.current.seen}',
                delta: _delta(ci.current.seen, ci.previous.seen, upIsGood: false),
                note: l.analyticsKpiCiSeenNote('${ci.current.new_}'),
              ),
              KpiCard(
                label: l.analyticsKpiCiAuto,
                value: ci.current.fixed == 0 ? '—' : '${autoShare(ci.current)}%',
                delta: ci.current.fixed == 0 ? null : _delta(autoShare(ci.current), autoShare(ci.previous), upIsGood: true),
                note: l.analyticsKpiCiAutoNote('${ci.current.autoFixed}', '${ci.current.fixed}'),
              ),
              KpiCard(
                label: l.analyticsKpiCiFix,
                value: _p50(l, ci.current.fixMin),
                delta: ci.current.fixMin.p50 == null ? null : _delta(ci.current.fixMin.p50!, ci.previous.fixMin.p50 ?? 0, upIsGood: false),
                note: l.analyticsKpiCiFixNote,
              ),
              KpiCard(
                label: l.analyticsKpiCiFlaky,
                value: '${ci.current.flaky}',
                delta: _delta(ci.current.flaky, ci.previous.flaky, upIsGood: false),
                note: l.analyticsKpiCiFlakyNote,
              ),
              KpiCard(label: l.analyticsKpiCiOwn, value: '${ci.current.ownFixes}', note: l.analyticsKpiCiOwnNote),
            ],
          ],
        ),
      ),
      ..._section(context, l.analyticsTurns, l.analyticsTurnsSub, [
        _LineChart(
          series: [
            ChartSeries(l.analyticsAvgTurns, [for (final d in a.perDay) d.turns], _softBlue, area: true),
          ],
          labels: labels,
          maxLabels: maxLabels,
          fmt: (v) => '${v.round()}',
        ),
      ]),
      ..._section(context, l.analyticsStops, l.analyticsStopsSub(stopsTotal), [
        if (stopsTotal == 0) _hint(context, l.manalyticsStopped(0)) else _HBars(stops),
      ]),
      ..._list(context, l.analyticsQuality, sub: l.analyticsQualitySub, empty: l.analyticsNoQuality, [
        for (final v in a.quality)
          ListRow(
            title: version(v),
            subtitle: [
              '${l.analyticsColTickets}: ${v.tickets}',
              '${l.analyticsColFirstPass}: ${v.done == 0 ? '—' : '${_pct(v.firstTry, v.done)}%'}',
              '${l.analyticsColRounds}: ${v.reachedReview == 0 ? '—' : v.changeRounds.toStringAsFixed(1)}',
              '${l.analyticsColFixes}: ${v.fixAttempts.toStringAsFixed(1)}',
              '${l.analyticsColSerious}: ${v.reachedReview == 0 ? '—' : '${_pct(v.serious, v.reachedReview)}%'}',
              '${l.analyticsColFootprint}: ${v.footprintHit == null ? '—' : '${(v.footprintHit! * 100).round()}%'}',
              '${l.analyticsColRedFlags}: ${v.redFlags}',
              '${l.analyticsColSelfFixes}: ${v.selfFixes}',
              '${l.analyticsRejected}: ${v.rejected}',
            ].join(' · '),
          ),
      ]),
      if (harness && a.quality.isNotEmpty)
        ..._list(context, l.harnessSettingsQualityTitle, sub: l.harnessSettingsQualitySub, empty: l.analyticsNoQuality, [
          for (final v in a.quality)
            ListRow(
              title: version(v),
              subtitle: [
                '${l.harnessSettingsColBlocks}: ${v.guardBlocks ?? 0}',
                '${l.harnessSettingsColStopSaves}: ${v.stopSaves ?? 0}',
                '${l.harnessSettingsColStalls}: ${v.stalls ?? 0}',
                '${l.harnessSettingsColProven}: ${(v.proofDue ?? 0) == 0 ? '—' : l.harnessSettingsXOfY('${v.proven ?? 0}', '${v.proofDue}')}',
                '${l.harnessSettingsColAdopted}: ${(v.findings ?? 0) == 0 ? '—' : '${_pct(v.adopted ?? 0, v.findings!)}%'}',
                '${l.harnessSettingsColTokens}: ${v.done == 0 || (v.tokens ?? 0) == 0 ? '—' : _tok(v.tokens!.round())}',
                '${l.harnessSettingsColFactCheck}: ${(v.factCheck ?? 0) == 0 ? '—' : '${_pct(v.factCheckFirst ?? 0, v.factCheck!)}% (${l.harnessSettingsVsAll('${v.done == 0 ? 0 : _pct(v.firstTry, v.done)}')})'}',
              ].join(' · '),
            ),
        ]),
      if (skills.any((x) => x.skill.isNotEmpty))
        ..._list(context, l.harnessSettingsSkillsTitle, sub: l.harnessSettingsSkillsSub, empty: l.analyticsNoQuality, [
          for (final x in skills)
            ListRow(
              title: skillName(x.skill),
              subtitle: [
                '${l.harnessSettingsColSkillTickets}: ${x.tickets}',
                '${l.harnessSettingsColLoaded}: ${x.skill.isEmpty ? '—' : '${_pct(x.loaded, x.tickets)}%'}',
                '${l.harnessSettingsColSkillFirstTry}: ${x.done == 0 ? '—' : '${_pct(x.firstTry, x.done)}%'}',
                '${l.harnessSettingsColLoadedFirstTry}: ${x.skill.isEmpty || x.loadedDone == 0 ? '—' : '${_pct(x.loadedFirstTry, x.loadedDone)}%'}',
                '${l.harnessSettingsColTargeted}: ${x.tickets == 0 ? '—' : (x.findings / x.tickets).toStringAsFixed(2)}',
                '${l.harnessSettingsColTokens}: ${x.done == 0 || x.tokens == 0 ? '—' : _tok(x.tokens.round())}',
              ].join(' · '),
            ),
        ]),
      // How replayed tickets did on newer prompt versions.
      _pad(const Padding(padding: EdgeInsets.only(top: 14), child: ReplayEvalCard())),
      // CI health: loading, not set up, or the charts and flakiest jobs.
      if (ciValue.isLoading && ci == null)
        _note(context, l.analyticsLoading)
      else if (ci != null && !ci.watching)
        ..._section(context, l.analyticsCiTitle, l.analyticsCiOffSub, [
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(onPressed: () => context.push('/ci'), child: Text(l.analyticsCiSetUp)),
          ),
        ])
      else if (ci != null) ...[
        ..._section(context, l.analyticsCiTitle, l.analyticsCiSub('${ci.open}'), [
          BarChart(
            series: [
              ChartSeries(l.analyticsCiNew, [for (final d in ci.perDay) d.new_], c.bad),
              ChartSeries(l.analyticsCiFixed, [for (final d in ci.perDay) d.fixed], c.ok),
            ],
            labels: [
              for (final d in ci.perDay)
                (days <= 7 ? DateFormat.E(locale) : DateFormat('d MMM', locale)).format(DateTime(d.date.year, d.date.month, d.date.day)),
            ],
            maxLabels: maxLabels,
            height: 170,
          ),
          ChartLegend([(c.bad, l.analyticsCiNew), (c.ok, l.analyticsCiFixed)]),
        ], trailing: TextButton(onPressed: () => context.push('/ci'), child: Text(l.analyticsCiOpen))),
        ..._section(context, l.analyticsCiClasses, l.analyticsCiClassesSub, [
          if (classes.isEmpty) _hint(context, l.analyticsCiNone) else _HBars(classes),
        ]),
        ..._list(context, l.analyticsCiFlakiest, sub: l.analyticsCiFlakiestSub, empty: l.analyticsCiNoFlaky, [
          for (final j in ci.flakiest)
            ListRow(
              title: j.workflow.isEmpty ? j.job : '${j.workflow} / ${j.job}',
              subtitle: '${j.repo} · ${j.title} · ${l.analyticsColFailures}: ${j.failures}',
              trailing: ToneBadge('${j.flaky}', Tone.warn, small: true),
              onTap: () => context.push('/ci/${j.id}'),
            ),
        ]),
      ],
    ];
  }

  // -- Cost: tokens and their API-price cost, by day, stage and model.

  List<Widget> cost(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final cur = a.current, prev = a.previous;
    final perTicket = cur.pushed == 0 ? 0.0 : cur.spend.costUsd / cur.pushed;
    final prevPerTicket = prev.pushed == 0 ? 0.0 : prev.spend.costUsd / prev.pushed;
    final known = a.perDay.where((d) => d.peakUsage != null).toList();
    final avgPeak = known.isEmpty ? 0 : (known.fold<num>(0, (x, d) => x + d.peakUsage!) / known.length * 100).round();
    final daysAbove = known.where((d) => d.peakUsage! >= 0.8).length;
    final spendTop = a.spendByStage.fold<int>(1, (m, s) => math.max(m, ioTokens(s.spend)));
    final totalRuns = a.models.fold<int>(0, (x, m) => x + m.runs);
    Iterable<StageSpend> ofModel(String m) => a.spendByStage.where((s) => modelLabel(s.model) == modelLabel(m));

    return [
      _pad(
        Grid2(
          children: [
            KpiCard(
              label: l.analyticsSpendCost,
              value: _usd(cur.spend.costUsd),
              delta: _delta(cur.spend.costUsd, prev.spend.costUsd, upIsGood: false),
              note: l.analyticsKpiCostNote,
            ),
            KpiCard(
              label: l.analyticsKpiCostPerTicket,
              value: cur.pushed == 0 ? '—' : _usd(perTicket),
              delta: cur.pushed == 0 ? null : _delta(perTicket, prevPerTicket, upIsGood: false),
              note: l.analyticsKpiCostPerTicketNote,
            ),
            KpiCard(
              label: l.analyticsSpendTokens,
              value: _tok(ioTokens(cur.spend)),
              delta: _delta(ioTokens(cur.spend), ioTokens(prev.spend), upIsGood: false),
              note: l.spendCache(_tok(cur.spend.cacheRead), _tok(cur.spend.cacheWrite)),
            ),
            KpiCard(label: l.analyticsAvgPeak, value: known.isEmpty ? '—' : '$avgPeak%', note: l.analyticsKpiDaysAboveNote('$daysAbove')),
          ],
        ),
      ),
      _note(context, l.spendCostNote),
      ..._section(context, l.analyticsSpend, l.analyticsSpendSub, [
        _LineChart(
          series: [
            ChartSeries(l.spendInput, [for (final d in a.perDay) d.spend.input], c.primary, area: true),
            ChartSeries(l.spendOutput, [for (final d in a.perDay) d.spend.output], _softBlue),
          ],
          labels: labels,
          maxLabels: maxLabels,
          fmt: (v) => _tok(v.round()),
        ),
        ChartLegend([(c.primary, l.spendInput), (_softBlue, l.spendOutput)]),
      ]),
      ..._section(context, l.analyticsSpendStages, l.analyticsSpendStagesSub, [
        if (a.spendByStage.isEmpty)
          _hint(context, l.analyticsNoSpend)
        else
          for (final s in a.spendByStage)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: _stageName(l, s.stage.name)),
                              TextSpan(
                                text: ' · ${modelLabel(s.model)}',
                                style: TextStyle(color: c.ink3),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        _tok(ioTokens(s.spend)),
                        style: TextStyle(fontWeight: FontWeight.w700, color: c.ink),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Bar(value: ioTokens(s.spend) / spendTop),
                  const SizedBox(height: 4),
                  Text(
                    '${l.spendCalls(s.calls)} · ${s.partial && s.spend.costUsd == 0 ? '—' : _usd(s.spend.costUsd)}',
                    style: TextStyle(fontSize: 12.5, color: c.ink3),
                  ),
                ],
              ),
            ),
      ]),
      ..._list(context, l.analyticsModels, sub: l.analyticsModelsSub, empty: l.analyticsNoRuns, [
        for (final m in a.models)
          ListRow(
            title: modelLabel(m.model),
            subtitle: [
              l.manalyticsShareOfRuns('${_pct(m.runs, totalRuns)}'),
              l.manalyticsReachedReview('${_pct(m.reachedReview, m.runs)}'),
              l.manalyticsTurns(m.avgTurns.round()),
              _tok(ofModel(m.model).fold<int>(0, (x, s) => x + ioTokens(s.spend))),
              _usd(ofModel(m.model).fold<double>(0, (x, s) => x + s.spend.costUsd)),
            ].join(' · '),
            value: '${m.runs}',
          ),
      ]),
      ..._section(context, l.analyticsUsage, known.isEmpty ? null : l.analyticsUsageSub, [
        if (known.isEmpty)
          _hint(context, l.analyticsNoUsage)
        else ...[
          BarChart(
            series: [
              ChartSeries(l.analyticsSession, [
                for (final d in a.perDay) d.peakUsage == null ? 0 : (d.peakUsage! * 100).round(),
              ], c.primary),
            ],
            labels: labels,
            maxLabels: maxLabels,
            height: 170,
          ),
          const SizedBox(height: 6),
          _MiniKv(l.analyticsAvgPeak, '$avgPeak%'),
          _MiniKv(l.analyticsDaysAbove, '$daysAbove', last: true),
        ],
      ]),
    ];
  }

  // -- Repositories: where agnts works best and where it struggles.

  List<Widget> repos(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    String srcLabel(String kind) => switch (kind) {
      'side' => l.analyticsSrcTask,
      'plane' => l.analyticsSrcPlane,
      _ => l.analyticsSrcJira,
    };
    return _list(context, l.analyticsRepos, sub: l.analyticsReposSub, empty: l.analyticsNoRepos, [
      for (final r in a.repos)
        ListRow(
          leading: SourceChip(srcLabel(r.kind), task: r.kind == 'side'),
          title: r.name,
          subtitle: [
            l.manalyticsTickets(r.tickets),
            '${l.analyticsColMergeRate}: ${r.merged + r.closed == 0 ? '—' : '${_pct(r.merged, r.merged + r.closed)}%'}',
            l.manalyticsTurns(r.avgTurns.round()),
            _min(l, r.agntsMin),
            '${l.analyticsColQuestions}: ${r.analyzed == 0 ? '—' : (r.asked / r.analyzed).toStringAsFixed(1)}',
            '${l.analyticsColCi}: ${r.ciFailures}',
            '${l.analyticsColClaudeMd}: ${_mdLabel(l, r.claudeMd)}',
          ].join(' · '),
          trailing: Text(
            r.finished == 0 ? '—' : '${_pct(r.done, r.finished)}%',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: r.finished == 0
                  ? c.ink3
                  : _pct(r.done, r.finished) >= 80
                  ? c.okInk
                  : c.warnInk,
            ),
          ),
          onTap: () => context.push('/repos/${r.repoId}?name=${Uri.encodeQueryComponent(r.name)}'),
        ),
    ]);
  }
}

/// The Learning tab: lessons, rules, reflections, follow-ups and reviewers.
class _Learning {
  const _Learning(this.x);
  final AnalyticsLearning x;

  List<Widget> children(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final cur = x.current, prev = x.previous;
    int rate(int accepted, int dismissed) => _pct(accepted, accepted + dismissed);
    return [
      _pad(
        Grid2(
          children: [
            KpiCard(
              label: l.analyticsKpiLessons,
              value: '${cur.lessons}',
              delta: _delta(cur.lessons, prev.lessons, upIsGood: true),
              note: l.analyticsKpiLessonsNote('${cur.lessonsLearned}'),
            ),
            KpiCard(
              label: l.analyticsKpiRulesLearned,
              value: '${cur.rulesAdopted}',
              delta: _delta(cur.rulesAdopted, prev.rulesAdopted, upIsGood: true),
              note: l.analyticsKpiRulesLearnedNote('${cur.rulesSuggested}'),
            ),
            KpiCard(label: l.analyticsKpiRulesManual, value: '${cur.rulesManual}', note: l.analyticsKpiRulesManualNote),
            KpiCard(
              label: l.analyticsKpiReflections,
              value: '${cur.reflections}',
              note: l.analyticsKpiReflectionsNote('${cur.reflectionRules}'),
            ),
            KpiCard(
              label: l.analyticsKpiFollowUps,
              value: cur.accepted + cur.dismissed == 0 ? '—' : '${rate(cur.accepted, cur.dismissed)}%',
              delta: cur.accepted + cur.dismissed == 0
                  ? null
                  : _delta(rate(cur.accepted, cur.dismissed), rate(prev.accepted, prev.dismissed), upIsGood: true),
              note: l.analyticsKpiFollowUpsNote('${cur.followUps}'),
            ),
            KpiCard(
              label: l.analyticsKpiReviewerNotes,
              value: '${cur.reviewerNotes}',
              delta: _delta(cur.reviewerNotes, prev.reviewerNotes, upIsGood: false),
              note: l.analyticsKpiReviewerNotesNote,
            ),
          ],
        ),
      ),
      _note(context, l.analyticsLearningNote),
      ..._list(context, l.analyticsFollowUps, sub: l.analyticsFollowUpsSub, empty: l.analyticsNoFollowUps, [
        for (final t in x.followUpTypes)
          ListRow(
            title: _followUpType(l, t.name),
            subtitle: [
              '${l.analyticsColSuggested}: ${t.suggested}',
              '${l.analyticsColAccepted}: ${t.accepted}',
              '${l.analyticsColDismissed}: ${t.dismissed}',
              '${l.analyticsColOpen}: ${t.suggested - t.accepted - t.dismissed}',
            ].join(' · '),
            trailing: Text(
              t.accepted + t.dismissed == 0 ? '—' : '${rate(t.accepted, t.dismissed)}%',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: t.accepted + t.dismissed == 0
                    ? c.ink3
                    : rate(t.accepted, t.dismissed) >= 50
                    ? c.okInk
                    : c.warnInk,
              ),
            ),
          ),
      ]),
      ..._section(context, l.analyticsFollowUpSources, l.analyticsFollowUpSourcesSub, [
        if (x.followUpSources.isEmpty)
          _hint(context, l.analyticsNoFollowUps)
        else
          _HBars([for (final s in x.followUpSources) _HRow(_followUpSource(l, s.name), s.suggested)]),
      ]),
      ..._section(context, l.analyticsLessons, l.analyticsLessonsSub('${cur.lessonsLearned}'), [
        if (x.lessons.isEmpty)
          _hint(context, l.analyticsNoLessons)
        else
          _HBars([for (final s in x.lessons) _HRow(_lessonCategory(l, s.category), s.created)]),
      ], trailing: TextButton(onPressed: () => context.push('/learn'), child: Text(l.analyticsOpenLearn))),
      ..._list(
        context,
        l.analyticsReviewers,
        sub: l.analyticsReviewersSub,
        empty: l.analyticsNoReviewers,
        trailing: TextButton(onPressed: () => context.push('/rules'), child: Text(l.analyticsOpenRules)),
        [
          for (final r in x.reviewers)
            ListRow(
              title: r.login,
              subtitle: [
                '${l.analyticsColRereview}: ${r.rereview}',
                '${l.analyticsColDismissedNotes}: ${r.dismissed}',
                '${l.analyticsColManual}: ${r.manual}',
                if (r.repos.isNotEmpty) r.repos.join(', '),
              ].join(' · '),
            ),
        ],
      ),
    ];
  }
}

/// One of the slowest tickets: key, title, total time and where it went.
class _SlowRow extends StatelessWidget {
  const _SlowRow(this.x, {required this.colors, required this.fmt});
  final SlowTicket x;
  final List<Color> colors; // agnts, answers, review, queue
  final String Function(num) fmt;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final total = math.max<num>(1, x.cycleMin);
    final parts = [x.agntsMin, x.answersMin, x.reviewMin, x.queueMin];
    return InkWell(
      onTap: () => context.push('/tickets/${x.key}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: x.key,
                          style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13, color: c.ink),
                        ),
                        TextSpan(
                          text: ' · ${x.title}',
                          style: TextStyle(color: c.ink3),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13.5),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  fmt(x.cycleMin),
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink),
                ),
                if (x.merged) ...[const SizedBox(width: 6), ToneBadge(l.analyticsPrMerged, Tone.ok, small: true)],
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 10,
                child: ColoredBox(
                  color: c.line2,
                  child: Row(
                    children: [
                      for (final (i, v) in parts.indexed)
                        if (v > 0)
                          Flexible(
                            flex: math.max(1, (1000 * v / total).round()),
                            child: ColoredBox(color: colors[i], child: const SizedBox.expand()),
                          ),
                      // The rest of the bar when the parts add up to less than the total.
                      if (parts.fold<num>(0, (a, b) => a + b) < total)
                        Flexible(
                          flex: math.max(1, (1000 * (total - parts.fold<num>(0, (a, b) => a + b)) / total).round()),
                          child: const SizedBox.expand(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- CSV exports, one table per tab (as the admin panel exports them) ----

String _date(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Overview and Cost: one row per day.
List<List<Object?>>? daysCsv(Analytics? a) => a == null
    ? null
    : [
        [
          'date',
          'picked',
          'pushed',
          'rejected',
          'stopped',
          'agnts_minutes',
          'waiting_minutes',
          'avg_turns',
          'peak_usage_pct',
          'input_tokens',
          'output_tokens',
          'cache_read_tokens',
          'cache_write_tokens',
          'cost_usd',
        ],
        for (final d in a.perDay)
          [
            _date(d.date),
            d.picked,
            d.pushed,
            d.rejected,
            d.stopped,
            d.agntsMin.toStringAsFixed(1),
            d.waitMin.toStringAsFixed(1),
            d.turns.toStringAsFixed(1),
            d.peakUsage == null ? '' : (d.peakUsage! * 100).round(),
            d.spend.input,
            d.spend.output,
            d.spend.cacheRead,
            d.spend.cacheWrite,
            d.spend.costUsd.toStringAsFixed(4),
          ],
      ];

/// Delivery: one row per day.
List<List<Object?>>? deliveryCsv(AnalyticsDelivery? d) => d == null
    ? null
    : [
        ['date', 'merged', 'closed_unmerged', 'median_picked_to_pushed_min', 'median_picked_to_merged_min'],
        for (final r in d.perDay) [_date(r.date), r.merged, r.closed, r.pushedMin?.toStringAsFixed(1), r.mergedMin?.toStringAsFixed(1)],
      ];

/// Learning: one row per follow-up type and source.
List<List<Object?>>? learningCsv(AnalyticsLearning? l) => l == null
    ? null
    : [
        ['kind', 'name', 'suggested', 'accepted', 'dismissed'],
        for (final c in l.followUpTypes) ['follow_up_type', c.name, c.suggested, c.accepted, c.dismissed],
        for (final c in l.followUpSources) ['follow_up_source', c.name, c.suggested, c.accepted, c.dismissed],
      ];

/// Quality: one row per prompt version.
List<List<Object?>>? qualityCsv(Analytics? a) => a == null
    ? null
    : [
        [
          'prompt_version',
          'tickets',
          'reached_review',
          'done',
          'first_try',
          'rejected',
          'change_rounds',
          'fix_attempts',
          'serious',
          'footprint_hit',
          'red_flags',
          'self_fixes',
          'guard_blocks',
          'stop_saves',
          'stalls',
          'proof_due',
          'proven',
          'findings',
          'adopted',
          'tokens_per_done',
          'fact_check',
          'fact_check_first_try',
        ],
        for (final v in a.quality)
          [
            v.promptVersion,
            v.tickets,
            v.reachedReview,
            v.done,
            v.firstTry,
            v.rejected,
            v.changeRounds.toStringAsFixed(2),
            v.fixAttempts.toStringAsFixed(2),
            v.serious,
            v.footprintHit?.toStringAsFixed(2),
            v.redFlags,
            v.selfFixes,
            v.guardBlocks,
            v.stopSaves,
            v.stalls,
            v.proofDue,
            v.proven,
            v.findings,
            v.adopted,
            v.tokens?.toStringAsFixed(0),
            v.factCheck,
            v.factCheckFirst,
          ],
      ];

/// Repositories: one row per repository.
List<List<Object?>>? reposCsv(Analytics? a) => a == null
    ? null
    : [
        [
          'repository',
          'source',
          'tickets',
          'done',
          'finished',
          'merged',
          'closed_unmerged',
          'avg_turns',
          'agnts_minutes',
          'questions',
          'analyzed',
          'ci_failures',
          'claude_md',
        ],
        for (final r in a.repos)
          [
            r.name,
            r.kind,
            r.tickets,
            r.done,
            r.finished,
            r.merged,
            r.closed,
            r.avgTurns.toStringAsFixed(1),
            r.agntsMin.toStringAsFixed(1),
            r.asked,
            r.analyzed,
            r.ciFailures,
            r.claudeMd,
          ],
      ];

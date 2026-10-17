import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../swagger/swagger_logic.dart';
import '../swagger/swagger_test_screen.dart' show methodColor;

/// Tone per verdict, as in the admin panel.
Tone verdictTone(ApiCaseVerdictEnum v) => switch (v) {
  ApiCaseVerdictEnum.pass => Tone.ok,
  ApiCaseVerdictEnum.fail => Tone.bad,
  ApiCaseVerdictEnum.blocked => Tone.warn,
  ApiCaseVerdictEnum.skipped => Tone.gray,
};

String verdictLabel(AppLocalizations l, ApiCaseVerdictEnum v) => switch (v) {
  ApiCaseVerdictEnum.pass => l.swaggerVerdict_pass,
  ApiCaseVerdictEnum.fail => l.swaggerVerdict_fail,
  ApiCaseVerdictEnum.blocked => l.swaggerVerdict_blocked,
  ApiCaseVerdictEnum.skipped => l.swaggerVerdict_skipped,
};

/// Failures first, then blocked, passed and skipped.
const verdictOrder = [ApiCaseVerdictEnum.fail, ApiCaseVerdictEnum.blocked, ApiCaseVerdictEnum.pass, ApiCaseVerdictEnum.skipped];

/// The counts of a run as badges.
class ApiCountBadges extends StatelessWidget {
  const ApiCountBadges(this.counts, {super.key});
  final ApiCounts counts;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Wrap(spacing: 6, runSpacing: 6, children: [
      ToneBadge(l.swaggerCount_pass('${counts.passed}'), Tone.ok, small: true),
      ToneBadge(l.swaggerCount_fail('${counts.failed}'), Tone.bad, small: true),
      if (counts.skipped > 0) ToneBadge(l.swaggerCount_skipped('${counts.skipped}'), Tone.gray, small: true),
      if (counts.blocked > 0) ToneBadge(l.swaggerCount_blocked('${counts.blocked}'), Tone.warn, small: true),
    ]);
  }
}

/// A Swagger test's results on the ticket screen: the counts, what is new
/// since the last run, and the failures. The details and the follow-ups
/// are on the results screen.
class ApiResultsFold extends ConsumerWidget {
  const ApiResultsFold({super.key, required this.ticketKey});
  final String ticketKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final r = ref.watch(apiResultsProvider(ticketKey)).value;
    if (r == null || r.runId == null || r.counts == null) return const SizedBox.shrink();
    return Fold(
      title: l.swaggerTab,
      hint: '${r.counts!.passed}/${r.cases.length}',
      initiallyOpen: true,
      child: ApiResultsBody(results: r, limit: 5, onMore: () => context.push('/tickets/$ticketKey/api-results')),
    );
  }
}

/// The counts, new failures and failing cases.
class ApiResultsBody extends StatelessWidget {
  const ApiResultsBody({super.key, required this.results, this.limit, this.onMore, this.ticketKey});
  final SwaggerResults results;
  final int? limit;
  final VoidCallback? onMore;

  /// With it, a case opens the requests behind it.
  final String? ticketKey;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final r = results;
    final hint = TextStyle(fontSize: 13, color: c.ink3, height: 1.4);
    final cases = [...r.cases]..sort((a, b) => verdictOrder.indexOf(a.verdict).compareTo(verdictOrder.indexOf(b.verdict)));
    final failing = cases.where((x) => x.verdict == ApiCaseVerdictEnum.fail || x.verdict == ApiCaseVerdictEnum.blocked).toList();
    final shown = limit == null ? cases : failing.take(limit!).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(r.test.baseUrl, style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text(r.test.writeEnabled ? l.swaggerModeWrite : l.swaggerModeRead, style: hint),
      const SizedBox(height: 10),
      if (r.counts != null) ApiCountBadges(r.counts!),
      if (r.summary != null) ...[const SizedBox(height: 8), Text(r.summary!)],
      if (r.previous != null) ...[
        const SizedBox(height: 8),
        Text(
          r.newFailures.isEmpty ? l.swaggerNoNewFailures : '${l.swaggerNewFailures(r.newFailures.length)}: ${r.newFailures.join('; ')}',
          style: hint.copyWith(color: r.newFailures.isEmpty ? c.ink3 : c.badInk),
        ),
      ],
      const SizedBox(height: 8),
      if (failing.isEmpty && limit != null) Text(l.swaggerAllPassed, style: hint),
      for (final x in shown)
        _CaseRow(
          x,
          onTap: ticketKey == null || x.requests.isEmpty ? null : () => showApiRequestsSheet(context, ticketKey!, x.requests.take(3).toList(), title: x.case_),
        ),
      if (onMore != null && limit != null && (failing.length > limit! || cases.length > failing.length))
        Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: onMore, child: Text(l.swaggerTab))),
    ]);
  }
}

class _CaseRow extends StatelessWidget {
  const _CaseRow(this.x, {this.onTap});
  final ApiCase x;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 6, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
          ToneBadge(verdictLabel(l, x.verdict), verdictTone(x.verdict), small: true),
          if (x.source_ == ApiCaseSource_Enum.schema) ToneBadge(l.swaggerAgntsCheck, Tone.info, small: true),
          Text(x.operation, style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 2),
        Text(x.case_, style: const TextStyle(fontWeight: FontWeight.w600)),
        if (x.expected != null) Text(l.swaggerExpected(x.expected!), style: TextStyle(fontSize: 13, color: c.ink3)),
        if (x.reason != null) Text(x.reason!, style: TextStyle(fontSize: 13, color: c.ink2)),
        if (x.requests.isNotEmpty)
          Text(x.requests.join(', '), style: TextStyle(fontSize: 12, color: onTap == null ? c.ink3 : c.primary, fontFamily: 'monospace')),
      ]),
    );
    return onTap == null ? row : InkWell(onTap: onTap, child: row);
  }
}


/// One request's exchange (query key: ticket, request id).
final apiRequestProvider = FutureProvider.autoDispose.family<ApiExchange, (String, String)>((ref, k) async {
  return (await requireApi(ref).getSwaggerApi().getApiRequest(key: k.$1, requestId: k.$2)).data!;
});

/// The requests behind a case (or one request): method, URL, status and
/// time, the request and the response, and a curl to copy.
Future<void> showApiRequestsSheet(BuildContext context, String ticketKey, List<String> ids, {String? title}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
    builder: (ctx) {
      final l = AppLocalizations.of(ctx);
      return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Row(children: [
            Expanded(
              child: Text(
                title ?? l.mqualityRequestTitle(ids.join(', ')),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
            ),
            RoundIconButton('close', tooltip: l.navClose, onTap: () => Navigator.pop(ctx)),
          ]),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [for (final id in ids) Padding(padding: const EdgeInsets.only(bottom: 12), child: ApiExchangeView(ticketKey: ticketKey, id: id))],
          ),
        ),
      ]);
    },
  );
}

/// One exchange, loaded when shown.
class ApiExchangeView extends ConsumerWidget {
  const ApiExchangeView({super.key, required this.ticketKey, required this.id});
  final String ticketKey;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return switch (ref.watch(apiRequestProvider((ticketKey, id)))) {
      AsyncData(value: final e) => HCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text(e.id, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink3)),
              ToneBadge(e.status == 0 ? l.swaggerNoResponse : '${e.status}', statusTone(e.status), small: true),
              Text('${e.ms} ms', style: TextStyle(fontSize: 12.5, color: c.ink3)),
            ]),
            const SizedBox(height: 6),
            Text.rich(TextSpan(children: [
              TextSpan(
                text: '${e.method} ',
                style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, fontWeight: FontWeight.w700, color: methodColor(c, e.method)),
              ),
              TextSpan(text: e.url, style: const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5)),
            ])),
            if (e.case_ != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(e.case_!, style: TextStyle(fontSize: 13, color: c.ink2))),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: curlOf(e)));
                  if (context.mounted) showSnack(context, l.swaggerCopied);
                },
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: Text(l.swaggerCopyCurl),
              ),
            ),
            Fold(
              title: l.swaggerRequestLabel,
              child: _Code([
                for (final h in (e.requestHeaders ?? const <String, String>{}).entries) '${h.key}: ${h.value}',
                if ((e.requestBody ?? '').isNotEmpty) '\n${prettyBody(e.requestBody)}',
              ].join('\n')),
            ),
            const SizedBox(height: 8),
            Fold(
              title: l.swaggerResponseLabel,
              initiallyOpen: true,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _Code([
                  for (final h in (e.responseHeaders ?? const <String, String>{}).entries) '${h.key}: ${h.value}',
                  '\n${prettyBody(e.responseBody).isNotEmpty ? prettyBody(e.responseBody) : (e.error ?? '')}',
                ].join('\n')),
                if (e.truncated == true) Padding(padding: const EdgeInsets.only(top: 6), child: Text(l.swaggerTruncated, style: TextStyle(fontSize: 12.5, color: c.ink3))),
              ]),
            ),
          ]),
        ),
      AsyncError(:final error) => HelpBox(errorMessage(error, l.commonError), tone: Tone.bad),
      _ => Padding(padding: const EdgeInsets.all(12), child: Text(l.swaggerLoading, style: TextStyle(color: c.ink3))),
    };
  }
}

/// Monospace text on the code background, selectable and scrollable.
class _Code extends StatelessWidget {
  const _Code(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Container(
      constraints: const BoxConstraints(maxHeight: 320),
      decoration: BoxDecoration(color: c.code, borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: SelectableText(text.trim(), style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 11.5, height: 1.5, color: c.codeInk)),
      ),
    );
  }
}

/// Every case of a Swagger test's latest run, failures first, and the whole
/// request log; each opens the request and response behind it. Run it
/// again, file the failures as a Bug ticket, or keep it as a suite. Push
/// notifications about a finished test open here.
class ApiResultsScreen extends ConsumerStatefulWidget {
  const ApiResultsScreen({super.key, required this.ticketKey});
  final String ticketKey;

  @override
  ConsumerState<ApiResultsScreen> createState() => _ApiResultsScreenState();
}

class _ApiResultsScreenState extends ConsumerState<ApiResultsScreen> {
  bool _requests = false;
  bool _busy = false;
  final _token = TextEditingController();

  String get key => widget.ticketKey;

  @override
  void initState() {
    super.initState();
    _token.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _token.dispose();
    super.dispose();
  }

  Future<T?> _run<T>(Future<T> Function() action) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      return await action();
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
      return null;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _rerun() async {
    final l = AppLocalizations.of(context);
    final api = ref.read(apiProvider)!.getSwaggerApi();
    final t = (await _run(() => api.rerunSwaggerTest(key: key, swaggerRerunInput: SwaggerRerunInput(token: _token.text.isEmpty ? null : _token.text))))?.data;
    if (t == null || !mounted) return;
    _token.clear();
    ref.invalidate(ticketProvider(key));
    ref.invalidate(apiResultsProvider(key));
    ref.invalidate(ticketsProvider);
    if (t.key != key) {
      showSnack(context, l.swaggerRerunNew(t.key));
      context.push('/tickets/${t.key}');
    } else {
      showSnack(context, l.swaggerRerunStarted);
    }
  }

  Future<void> _bug(SwaggerResults r, Ticket ticket) async {
    final l = AppLocalizations.of(context);
    final api = ref.read(apiProvider)!.getTasksApi();
    final t = (await _run(() => api.createTask(
              taskCreate: TaskCreate(
                kind: TicketKindChoice.bug,
                repoId: ticket.repoId,
                title: l.swaggerBugTitle(key),
                description: bugDescription(l.swaggerBugIntro(key, r.test.baseUrl), r.cases),
                priority: TaskCreatePriorityEnum.medium,
                afterApprove: TaskCreateAfterApproveEnum.pr,
                start: TaskCreateStartEnum.code,
              ),
            )))
        ?.data;
    if (t == null || !mounted) return;
    ref.invalidate(ticketsProvider);
    showSnack(context, l.swaggerBugCreated(t.key));
    context.push('/tickets/${t.key}');
  }

  Future<void> _saveSuite(Ticket ticket) async {
    final l = AppLocalizations.of(context);
    final saved = await showModalBottomSheet<SwaggerSuite>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _SaveSuiteSheet(ticketKey: key, name: ticket.title),
    );
    if (saved == null || !mounted) return;
    ref.invalidate(apiResultsProvider(key));
    showSnack(context, l.swaggerSuiteSaved(saved.name));
    context.push('/swagger-suites');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final res = ref.watch(apiResultsProvider(key));
    final ticket = ref.watch(ticketProvider(key)).value?.ticket;
    final canEdit = ref.watch(canEditProvider);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(
        backLabel: l.navBack,
        title: '$key · ${l.swaggerTab}',
        onBack: () => context.canPop() ? context.pop() : context.go('/tickets/$key'),
      ),
      body: AsyncBody<SwaggerResults>(
        value: res,
        onRefresh: () {
          ref.invalidate(ticketProvider(key));
          return ref.refresh(apiResultsProvider(key).future);
        },
        builder: (r) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            if (r.runId == null)
              Text(l.swaggerNoRun, style: TextStyle(color: c.ink3))
            else ...[
              Segmented<bool>(
                full: true,
                options: [(false, l.swaggerTab), (true, '${l.swaggerRequestsTab} ${r.requests.length}')],
                value: _requests,
                onChanged: (v) => setState(() => _requests = v),
              ),
              const SizedBox(height: 12),
              if (!_requests)
                HCard(child: ApiResultsBody(results: r, ticketKey: key))
              else
                ListGroup(children: [
                  for (final q in r.requests)
                    ListRow(
                      leading: ToneBadge(q.status == 0 ? l.swaggerNoResponse : '${q.status}', statusTone(q.status), small: true),
                      title: '${q.method} ${q.url}',
                      subtitle: [q.id, ?q.case_, '${q.ms} ms'].join(' · '),
                      onTap: () => showApiRequestsSheet(context, key, [q.id]),
                    ),
                ]),
              if (r.notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Fold(
                  title: l.swaggerAgntsNotes,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [for (final n in r.notes) Text('• $n')]),
                ),
              ],
            ],
            if (canEdit && ticket != null) ..._actions(l, c, r, ticket),
            const SizedBox(height: 12),
            TextButton(onPressed: () => context.push('/tickets/$key'), child: Text(key)),
          ],
        ),
      ),
    );
  }

  List<Widget> _actions(AppLocalizations l, Agnts c, SwaggerResults r, Ticket ticket) {
    const rerunnable = [TicketState.waitingForReview, TicketState.failed, TicketState.done, TicketState.rejected];
    final closed = ticket.state == TicketState.done || ticket.state == TicketState.rejected;
    final auth = r.test.authKind != ApiAuthKind.none;
    final tokenNeeded = auth && (closed || !r.test.hasToken);
    final failures = r.cases.any((x) => x.verdict == ApiCaseVerdictEnum.fail);
    final canSuite = r.runId != null && r.test.suiteId == null;
    return [
      const SizedBox(height: 16),
      if (rerunnable.contains(ticket.state)) ...[
        if (auth) ...[
          TextField(
            controller: _token,
            obscureText: true,
            autocorrect: false,
            style: const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13),
            decoration: InputDecoration(hintText: tokenNeeded ? l.swaggerRerunTokenNeeded : l.swaggerRerunToken),
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton(onPressed: _busy || (tokenNeeded && _token.text.isEmpty) ? null : _rerun, child: Text(l.swaggerRerun)),
        const SizedBox(height: 8),
      ],
      if (failures) ...[
        FilledButton(onPressed: _busy ? null : () => _bug(r, ticket), child: Text(l.swaggerCreateBug)),
        const SizedBox(height: 8),
      ],
      if (canSuite)
        OutlinedButton(onPressed: _busy ? null : () => _saveSuite(ticket), child: Text(l.swaggerSaveSuite))
      else if (r.test.suiteId != null)
        OutlinedButton(onPressed: () => context.push('/swagger-suites'), child: Text(l.swaggerSuites)),
    ];
  }
}

/// Keep the test as a suite that runs again on a schedule or after deploys.
class _SaveSuiteSheet extends ConsumerStatefulWidget {
  const _SaveSuiteSheet({required this.ticketKey, required this.name});
  final String ticketKey;
  final String name;

  @override
  ConsumerState<_SaveSuiteSheet> createState() => _SaveSuiteSheetState();
}

class _SaveSuiteSheetState extends ConsumerState<_SaveSuiteSheet> {
  late final _name = TextEditingController(text: widget.name);
  var _schedule = SwaggerSuiteInputScheduleEnum.daily;
  var _hour = 6;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final s = (await ref.read(apiProvider)!.getSwaggerApi().createSwaggerSuite(
                swaggerSuiteInput: SwaggerSuiteInput(fromTicket: widget.ticketKey, name: _name.text.trim(), schedule: _schedule, hour: _hour, enabled: true),
              ))
          .data;
      if (mounted) Navigator.pop(context, s);
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final timed = _schedule == SwaggerSuiteInputScheduleEnum.daily || _schedule == SwaggerSuiteInputScheduleEnum.weekly;
    final label = TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink2);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Text(l.swaggerSaveSuite, style: Theme.of(context).textTheme.titleLarge)),
          RoundIconButton('close', tooltip: l.navClose, onTap: () => Navigator.pop(context)),
        ]),
        const SizedBox(height: 4),
        Text(l.swaggerSaveSuiteHint, style: TextStyle(fontSize: 13, color: c.ink3, height: 1.35)),
        const SizedBox(height: 14),
        Text(l.swaggerSuiteName, style: label),
        const SizedBox(height: 6),
        TextField(controller: _name, maxLength: 100, onChanged: (_) => setState(() {}), decoration: const InputDecoration(counterText: '')),
        const SizedBox(height: 12),
        Text(l.swaggerSchedule, style: label),
        const SizedBox(height: 6),
        DropdownButtonFormField<SwaggerSuiteInputScheduleEnum>(
          initialValue: _schedule,
          isExpanded: true,
          items: [for (final v in SwaggerSuiteInputScheduleEnum.values) DropdownMenuItem(value: v, child: Text(scheduleLabel(l, v.value)))],
          onChanged: (v) => setState(() => _schedule = v ?? _schedule),
        ),
        if (timed) ...[
          const SizedBox(height: 12),
          Text('${l.swaggerHourUtc}: ${l.mqualityHourAt(_hour.toString().padLeft(2, '0'))}', style: label),
          Slider(value: _hour.toDouble(), min: 0, max: 23, divisions: 23, onChanged: (v) => setState(() => _hour = v.round())),
        ],
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: HelpBox(_error!, tone: Tone.bad)),
        const SizedBox(height: 14),
        FilledButton(onPressed: _busy || _name.text.trim().isEmpty ? null : _save, child: Text(l.swaggerSaveSuite)),
      ]),
    );
  }
}

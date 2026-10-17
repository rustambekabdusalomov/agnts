import 'package:agnts_api/agnts_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'swagger_logic.dart';
import 'swagger_test_screen.dart';

/// Saved Swagger test suites.
final swaggerSuitesProvider = FutureProvider<List<SwaggerSuite>>((ref) async {
  return (await requireApi(ref).getSwaggerApi().listSwaggerSuites()).data ?? const [];
});

/// Saved Swagger test suites: their schedule, last and next run, and the
/// deploy hook that runs them after each deploy; plus a new one-off test.
/// Opened from More.
class SwaggerSuitesScreen extends ConsumerWidget {
  const SwaggerSuitesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final suites = ref.watch(swaggerSuitesProvider);
    final canEdit = ref.watch(canEditProvider);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(backLabel: l.navBack, onBack: () => context.canPop() ? context.pop() : context.go('/more')),
      floatingActionButton: canEdit
          ? HFab(
              tooltip: l.mqualityNewTest,
              onTap: () async {
                final key = await Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => const SwaggerTestScreen()));
                if (key != null && context.mounted) {
                  ref.invalidate(ticketsProvider);
                  context.push('/tickets/$key');
                }
              },
            )
          : null,
      body: AsyncBody<List<SwaggerSuite>>(
        value: suites,
        onRefresh: () => ref.refresh(swaggerSuitesProvider.future),
        builder: (list) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            PageHeader(title: l.swaggerSuites, sub: l.swaggerSuitesLede, long: true),
            if (list.isEmpty)
              EmptyState(title: l.swaggerSuitesEmpty)
            else
              for (final s in list) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 10), child: SuiteCard(s, canEdit: canEdit)),
          ],
        ),
      ),
    );
  }
}

/// One suite: what it tests, its schedule and runs, and its tools.
class SuiteCard extends ConsumerStatefulWidget {
  const SuiteCard(this.s, {super.key, required this.canEdit});
  final SwaggerSuite s;
  final bool canEdit;

  @override
  ConsumerState<SuiteCard> createState() => _SuiteCardState();
}

class _SuiteCardState extends ConsumerState<SuiteCard> {
  final _token = TextEditingController();
  String? _hook;
  bool _busy = false;

  SwaggerSuite get s => widget.s;
  SwaggerApi get _api => ref.read(apiProvider)!.getSwaggerApi();

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

  Future<T?> _run<T>(Future<T> Function() action, {String? done}) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final r = await action();
      ref.invalidate(swaggerSuitesProvider);
      if (done != null && mounted) showSnack(context, done);
      return r;
    } catch (e) {
      if (mounted) {
        final busy = e is DioException && e.response?.statusCode == 409;
        showSnack(context, busy ? l.swaggerBusy : errorMessage(e, l.commonError));
      }
      return null;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _update(SwaggerSuiteInput input, {String? done}) => _run(() => _api.updateSwaggerSuite(id: s.id, swaggerSuiteInput: input), done: done);

  Future<void> _runNow() async {
    final l = AppLocalizations.of(context);
    final t = (await _run(() => _api.runSwaggerSuite(id: s.id)))?.data;
    if (t == null || !mounted) return;
    ref.invalidate(ticketsProvider);
    showSnack(context, l.swaggerRunStarted(t.key));
    context.push('/tickets/${t.key}');
  }

  Future<void> _rotateHook() async {
    final r = (await _run(() => _api.rotateSwaggerSuiteHook(id: s.id)))?.data;
    if (r != null && mounted) setState(() => _hook = r.url);
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(l.swaggerDeleteConfirm(s.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.mobileCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: c.bad),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.swaggerDeleteSuite),
          ),
        ],
      ),
    );
    if (ok == true) await _run(() => _api.deleteSwaggerSuite(id: s.id), done: l.mqualitySuiteDeleted);
  }

  Future<void> _pickHour() async {
    final h = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => SafeArea(
        child: SizedBox(
          height: 320,
          child: ListView(children: [
            for (var i = 0; i < 24; i++)
              ListTile(
                title: Text(AppLocalizations.of(ctx).mqualityHourAt(i.toString().padLeft(2, '0'))),
                trailing: i == s.hour ? const Icon(Icons.check_rounded) : null,
                onTap: () => Navigator.pop(ctx, i),
              ),
          ]),
        ),
      ),
    );
    if (h != null && h != s.hour) await _update(SwaggerSuiteInput(hour: h));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final hint = TextStyle(fontSize: 13, color: c.ink3, height: 1.35);
    final timed = s.schedule == SwaggerSuiteScheduleEnum.daily || s.schedule == SwaggerSuiteScheduleEnum.weekly;
    final hour = l.mqualityHourAt(s.hour.toString().padLeft(2, '0'));
    final locked = _busy || !widget.canEdit;
    String ago(DateTime at) {
      final d = DateTime.now().difference(at);
      return d.inMinutes < 1 ? l.mmoreJustNow : l.mmoreAgo(shortDuration(d));
    }

    return HCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Text(s.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.ink))),
          if (!s.enabled) ToneBadge(l.swaggerPaused, Tone.gray, small: true),
        ]),
        const SizedBox(height: 4),
        Text(s.baseUrl, style: const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5)),
        Text(
          [
            '${s.operations}',
            s.writeEnabled ? l.swaggerModeWrite : l.swaggerModeRead,
            authKindLabel(l, s.authKind),
          ].join(' · '),
          style: hint,
        ),
        const SizedBox(height: 10),
        Grid2(children: [
          Fact(l.swaggerColSchedule, scheduleLabel(l, s.schedule.value) + (timed ? ' · $hour' : '')),
          Fact(l.swaggerLastRun, s.lastRunAt == null ? l.swaggerNever : ago(s.lastRunAt!)),
          if (s.enabled && s.nextRunAt != null) Fact(l.swaggerNextRun, MaterialLocalizations.of(context).formatShortDate(s.nextRunAt!.toLocal())),
        ]),
        if (s.lastTicketKey != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: () => context.push('/tickets/${s.lastTicketKey}'), child: Text(s.lastTicketKey!)),
          ),
        if (widget.canEdit) ...[
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            FilledButton(onPressed: locked ? null : _runNow, child: Text(l.swaggerRunNow)),
            OutlinedButton(
              onPressed: locked ? null : () => _update(SwaggerSuiteInput(enabled: !s.enabled)),
              child: Text(s.enabled ? l.swaggerPause : l.swaggerResume),
            ),
            OutlinedButton(onPressed: locked ? null : _rotateHook, child: Text(s.hookSet ? l.swaggerHookRotate : l.swaggerHookCreate)),
          ]),
          const SizedBox(height: 12),
          Text(l.swaggerSchedule, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink2)),
          const SizedBox(height: 6),
          DropdownButtonFormField<SwaggerSuiteScheduleEnum>(
            key: ValueKey(s.schedule),
            initialValue: s.schedule,
            isExpanded: true,
            items: [
              for (final v in SwaggerSuiteScheduleEnum.values) DropdownMenuItem(value: v, child: Text(scheduleLabel(l, v.value))),
            ],
            onChanged: locked
                ? null
                : (v) {
                    if (v != null && v != s.schedule) _update(SwaggerSuiteInput(schedule: SwaggerSuiteInputScheduleEnum.values.byName(v.name)));
                  },
          ),
          if (timed) ...[
            const SizedBox(height: 8),
            ListRow(title: l.swaggerHourUtc, value: hour, onTap: locked ? null : _pickHour),
          ],
          if (s.authKind != ApiAuthKind.none) ...[
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _token,
                  enabled: !locked,
                  obscureText: true,
                  autocorrect: false,
                  style: const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13),
                  decoration: InputDecoration(hintText: l.swaggerSuiteToken),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: locked || _token.text.isEmpty
                    ? null
                    : () async {
                        await _update(SwaggerSuiteInput(token: _token.text), done: l.mqualityTokenSaved);
                        _token.clear();
                      },
                child: Text(l.swaggerSetToken),
              ),
            ]),
          ],
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: locked ? null : _delete,
              style: TextButton.styleFrom(foregroundColor: c.badInk),
              child: Text(l.swaggerDeleteSuite),
            ),
          ),
        ],
        if (_hook != null) ...[
          const SizedBox(height: 8),
          HelpBox(
            l.swaggerHookHint,
            child: Row(children: [
              Expanded(child: SelectableText(l.swaggerHookExample(_hook!), style: const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12))),
              CopyButton(l.swaggerHookExample(_hook!)),
            ]),
          ),
        ],
      ]),
    );
  }
}

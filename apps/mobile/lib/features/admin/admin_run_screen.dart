import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';
import 'package:dio/dio.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';
import '../tickets/spend.dart' show fmtTokens, fmtUsd;
import 'admin_runs_data.dart';
import 'admin_runs_screen.dart' show RunRow;

enum _Tab { timeline, prompt, result }

/// One invocation as Claude Code (or Codex) ran it. This is customer
/// content: the server logs every read, so the transcript is fetched once
/// per visit (reloading is a new, logged read) and the prompt only once its
/// tab is opened.
class AdminRunScreen extends ConsumerStatefulWidget {
  const AdminRunScreen({super.key, required this.id});
  final int id;

  @override
  ConsumerState<AdminRunScreen> createState() => _AdminRunScreenState();
}

class _AdminRunScreenState extends ConsumerState<AdminRunScreen> {
  _Tab _tab = _Tab.timeline;
  bool _promptOpened = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final run = ref.watch(platformRunProvider(widget.id));
    // Once opened, the prompt stays loaded while the screen is: switching
    // tabs must not read (and log) it again.
    if (_promptOpened) ref.watch(platformRunPromptProvider(widget.id));
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(backLabel: l.runsBack, onBack: () => context.canPop() ? context.pop() : context.go('/admin/runs')),
      body: switch (run) {
        AsyncData(:final value) => _body(context, value),
        AsyncError(:final error) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            HelpBox(
              error is DioException && error.response?.statusCode == 404 ? l.runsNotFound : errorMessage(error, l.commonError),
              tone: Tone.bad,
            ),
          ],
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _body(BuildContext context, RunTranscriptDetail d) {
    final l = AppLocalizations.of(context);
    final loc = Localizations.localeOf(context).toLanguageTag();
    final t = d.transcript;
    final status = t.status.value;
    final result = d.events.reversed.where((e) => e.k == 'result').firstOrNull;
    String when(DateTime? at) => at == null
        ? '—'
        : '${MaterialLocalizations.of(context).formatShortDate(at.toLocal())} ${TimeOfDay.fromDateTime(at.toLocal()).format(context)}';

    final head = <Widget>[
      PageHeader(title: '${runTitle(t)} · ${purposeLabel(l, t.purpose)}', sub: t.workspace),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: HelpBox(l.runsBanner, tone: Tone.warn),
      ),
      if (d.unreadable == true)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: HelpBox(l.runsUnreadable, tone: Tone.bad),
        ),
      if (t.truncated)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: HelpBox(l.runsTruncated, tone: Tone.warn),
        ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Grid2(
          children: [
            Fact(
              l.runsColOutcome,
              statusLabel(l, status) + (t.stalls > 0 ? ' · ⚠ ${t.stalls}' : ''),
              tone: runFailed(status)
                  ? Tone.bad
                  : status == 'done'
                  ? Tone.ok
                  : null,
            ),
            Fact(l.runsColCost, fmtUsd(t.costUsd.toDouble(), loc)),
            Fact(
              l.runsColModel,
              [if (t.engine == RunTranscriptEngineEnum.codex) l.runsE_codex, t.model].where((s) => s.isNotEmpty).join(' · '),
            ),
            Fact(
              l.runsColPurpose,
              [purposeLabel(l, t.purpose), if ((t.modelStage?.isNotEmpty ?? false) && t.modelStage != t.purpose) t.modelStage!].join(' · '),
            ),
            Fact(l.runsColDuration, durText(runDuration(t))),
            Fact(l.runsColTurns, '${t.turns}'),
            Fact(l.runsColTools, l.runsToolsTitle('${t.toolCalls}', '${t.toolErrors}'), tone: t.toolErrors > 0 ? Tone.bad : null),
            Fact(l.runsTokens, l.runsTokensVal(fmtTokens(t.inputTokens, loc), fmtTokens(t.outputTokens, loc))),
            Fact(l.runsStartedAt, when(t.startedAt)),
            Fact(l.runsFinishedAt, when(t.finishedAt)),
            Fact(l.runsAccount, [t.claudeAccount ?? '—', if (t.claudeUser != null) t.claudeUser!].join(' · ')),
            Fact(l.runsSize, '${(t.storedBytes / 1024).toStringAsFixed(1)} / ${(t.rawBytes / 1024).toStringAsFixed(1)} KB'),
          ],
        ),
      ),
      if (t.exitReason.isNotEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: HelpBox('${l.runsExitReason}: ${t.exitReason}', tone: runFailed(status) ? Tone.bad : Tone.info, copyable: true),
        ),
      if (status == 'running')
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: HelpBox(
            l.runsRunningNote,
            child: OutlinedButton(onPressed: () => ref.invalidate(platformRunProvider(widget.id)), child: Text(l.runsReload)),
          ),
        ),
      if (d.siblings.isNotEmpty) ...[
        SectionHeader(l.runsSiblings),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListGroup(
            children: [for (final s in d.siblings) RunRow(s, current: true, onTap: () => context.pushReplacement('/admin/runs/${s.id}'))],
          ),
        ),
      ],
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
        child: Segmented<_Tab>(
          full: true,
          options: [(_Tab.timeline, l.runsTab_timeline), (_Tab.prompt, l.runsTab_prompt), (_Tab.result, l.runsTab_result)],
          value: _tab,
          onChanged: (x) => setState(() {
            _tab = x;
            if (x == _Tab.prompt) _promptOpened = true;
          }),
        ),
      ),
    ];

    return switch (_tab) {
      _Tab.timeline => RunTimeline(events: d.events, header: head),
      _Tab.prompt => ListView(padding: const EdgeInsets.only(bottom: 24), children: [...head, _prompt(context)]),
      _Tab.result => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          ...head,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: result == null
                ? EmptyState(title: l.runsNoResult)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Grid2(
                        children: [
                          Fact(l.runsSubtype, result.subtype ?? '—', tone: result.error == true ? Tone.bad : null),
                          Fact(l.runsColCost, result.cost == null ? '—' : fmtUsd(result.cost!.toDouble(), loc)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      CodeBlock(result.text?.isNotEmpty ?? false ? result.text! : l.runsNoOutput, error: result.error == true, copy: true),
                    ],
                  ),
          ),
        ],
      ),
    };
  }

  Widget _prompt(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (!_promptOpened) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: switch (ref.watch(platformRunPromptProvider(widget.id))) {
        AsyncData(:final value) => CodeBlock(value.isEmpty ? l.runsNoPrompt : value, copy: value.isNotEmpty),
        AsyncError(:final error) => HelpBox(errorMessage(error, l.commonError), tone: Tone.bad),
        _ => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      },
    );
  }
}

/// The timeline under [header]: tool calls paired with their results
/// (folded, failures in red), text, and agnts's notes. Long transcripts show
/// [page] items at a time, and "Next error" jumps between failures.
class RunTimeline extends StatefulWidget {
  const RunTimeline({super.key, required this.events, this.header = const [], this.page = 300});
  final List<RunTranscriptEvent> events;
  final List<Widget> header;
  final int page;

  @override
  State<RunTimeline> createState() => _RunTimelineState();
}

class _RunTimelineState extends State<RunTimeline> {
  late List<RunItem> _items = runTimeline(widget.events);
  late int _shown = widget.page;
  final _keys = <int, GlobalKey>{};
  final _open = <int>{};
  int _nextError = 0;

  @override
  void didUpdateWidget(RunTimeline old) {
    super.didUpdateWidget(old);
    if (!identical(old.events, widget.events)) _items = runTimeline(widget.events);
  }

  List<int> get _errors => [
    for (final (i, it) in _items.indexed)
      if (it.error) i,
  ];

  Future<void> _jump() async {
    final errs = _errors;
    if (errs.isEmpty) return;
    final i = errs[_nextError % errs.length];
    _nextError++;
    setState(() {
      if (i >= _shown) _shown = i + 1;
      _open.add(i);
    });
    await WidgetsBinding.instance.endOfFrame;
    final ctx = _keys[i]?.currentContext;
    if (ctx != null && ctx.mounted) await Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 250), alignment: 0.1);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final errs = _errors.length;
    final shown = _items.take(_shown).toList();
    // A Column, not a lazy list: "Next error" needs every shown item built
    // to scroll to it, and shown items are capped by [page].
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...widget.header,
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(l.runsEventsCount(widget.events.length), style: TextStyle(fontSize: 13, color: c.ink3)),
                ),
                errs == 0
                    ? Text(l.runsNoErrors, style: TextStyle(fontSize: 13, color: c.ink3))
                    : TextButton(
                        style: TextButton.styleFrom(foregroundColor: c.badInk),
                        onPressed: _jump,
                        child: Text(l.runsNextError('$errs')),
                      ),
              ],
            ),
          ),
          if (_items.isEmpty) EmptyState(title: l.runsNoEvents),
          for (final (i, it) in shown.indexed)
            Padding(
              key: _keys.putIfAbsent(i, GlobalKey.new),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: switch (it) {
                ToolItem() => _ToolCard(
                  it,
                  open: _open.contains(i),
                  onToggle: () => setState(() => _open.contains(i) ? _open.remove(i) : _open.add(i)),
                ),
                LineItem() => _Line(it),
              },
            ),
          if (_items.length > _shown)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: OutlinedButton(
                onPressed: () => setState(() => _shown += widget.page),
                child: Text(l.runsShowMore('${(_items.length - _shown).clamp(0, widget.page)}')),
              ),
            ),
        ],
      ),
    );
  }
}

/// A tool call: name, summary and how it ended; open, its input and output.
class _ToolCard extends StatelessWidget {
  const _ToolCard(this.it, {required this.open, required this.onToggle});
  final ToolItem it;
  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final r = it.result;
    final input = inputText(it.call.input);
    final state = r == null
        ? null
        : [
            r.error == true ? '✗ ${l.runsToolFailed}' : '✓ ${l.runsToolOk}',
            if (r.exitCode != null) l.runsExitCode('${r.exitCode}'),
          ].join(' · ');
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: it.error ? c.bad : c.line),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 44,
                    child: Text(
                      clock(it.at),
                      style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink3),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          it.call.name ?? l.runsKTool,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.ink),
                        ),
                        if (it.call.summary?.isNotEmpty ?? false)
                          Text(
                            it.call.summary!,
                            maxLines: open ? null : 2,
                            overflow: open ? null : TextOverflow.ellipsis,
                            style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink2),
                          ),
                        if (state != null)
                          Text(
                            state,
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: it.error ? c.badInk : c.okInk),
                          ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: HIcon('down', size: 16, color: c.ink3),
                  ),
                ],
              ),
            ),
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (input.isNotEmpty) ...[_Label(l.runsInput, cut: it.call.cut), CodeBlock(input, copy: true), const SizedBox(height: 8)],
                  if (r != null) ...[
                    _Label(l.runsOutput, cut: r.cut),
                    CodeBlock(
                      r.output?.isNotEmpty ?? false ? r.output! : l.runsNoOutput,
                      error: r.error == true,
                      copy: r.output?.isNotEmpty ?? false,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {this.cut});
  final String text;
  final int? cut;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        [text, if (cut != null) l.runsCutNote((cut! / 1024).toStringAsFixed(1))].join(' · '),
        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink3),
      ),
    );
  }
}

/// Text Claude wrote, the result, or one of agnts's small lines.
class _Line extends StatelessWidget {
  const _Line(this.it);
  final LineItem it;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final e = it.ev;
    final time = SizedBox(
      width: 44,
      child: Text(
        clock(e.t),
        style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink3),
      ),
    );
    switch (e.k) {
      case 'text':
        return HCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              time,
              // Plain text, as written: never rendered as markdown or HTML.
              Expanded(
                child: SelectableText(e.text ?? '', style: TextStyle(fontSize: 14, height: 1.45, color: c.ink)),
              ),
            ],
          ),
        );
      case 'result':
      case 'tool_result':
        return HelpBox(
          [
            e.k == 'result' ? l.runsKResult : l.runsKToolResult,
            e.subtype ?? '',
            e.text ?? e.output ?? '',
          ].where((s) => s.isNotEmpty).join(' · '),
          tone: it.error ? Tone.bad : Tone.ok,
        );
      default:
        final label = switch (e.k) {
          'init' => l.runsKInit,
          'rate_limit' => l.runsKRateLimit,
          'note' => l.runsKNote,
          _ => e.k,
        };
        final detail = e.text ?? e.status ?? [e.model, e.sessionId].whereType<String>().join(' · ');
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              time,
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: label,
                        style: TextStyle(fontWeight: FontWeight.w700, color: e.k == 'note' ? c.warnInk : c.ink2),
                      ),
                      if (detail.isNotEmpty) TextSpan(text: '  $detail'),
                    ],
                  ),
                  style: TextStyle(fontSize: 13, color: c.ink3),
                ),
              ),
            ],
          ),
        );
    }
  }
}

/// Monospace text on the code background, selectable, red when it failed.
class CodeBlock extends StatelessWidget {
  const CodeBlock(this.text, {super.key, this.error = false, this.copy = false});
  final String text;
  final bool error;
  final bool copy;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.code,
        borderRadius: BorderRadius.circular(12),
        border: error ? Border.all(color: c.bad) : null,
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12, 10, copy ? 40 : 12, 10),
            child: SelectableText(
              text,
              style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, height: 1.55, color: error ? const Color(0xFFFFB4AB) : c.codeInk),
            ),
          ),
          if (copy) Positioned(top: 0, right: 0, child: CopyButton(text, color: c.codeDim)),
        ],
      ),
    );
  }
}

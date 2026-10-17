import 'package:agnts_api/agnts_api.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../rules/rule_sheet.dart' show FormField2;
import 'swagger_logic.dart';

/// The server's error code for a failed call ("spec_needs_login"), if any.
String? _code(Object e) {
  if (e is DioException) {
    final d = e.response?.data;
    if (d is Map && d['code'] is String) return d['code'] as String;
  }
  return null;
}

/// The Swagger test form: read a spec (URL, docs page or file), pick the
/// base URL, the endpoints and the auth, and create the ticket. Pops with
/// the new ticket's key.
class SwaggerTestScreen extends ConsumerStatefulWidget {
  const SwaggerTestScreen({super.key, this.repoId});
  final int? repoId;

  @override
  ConsumerState<SwaggerTestScreen> createState() => _SwaggerTestScreenState();
}

enum _SpecAuthMode { login, token }

class _SwaggerTestScreenState extends ConsumerState<SwaggerTestScreen> {
  final _specUrl = TextEditingController();
  final _baseUrl = TextEditingController();
  final _notes = TextEditingController();
  final _authName = TextEditingController();
  final _token = TextEditingController();
  final _search = TextEditingController();
  // The sign-in a spec URL behind auth needs: sent with the fetch only.
  final _specUser = TextEditingController();
  final _specPass = TextEditingController();
  final _specAuthName = TextEditingController();
  final _specToken = TextEditingController();
  bool _specAuthOpen = false;
  _SpecAuthMode _specAuthMode = _SpecAuthMode.login;
  ApiAuthKind _specAuthKind = ApiAuthKind.bearer;
  bool _reusedSpecAuth = false;

  SwaggerSpec? _spec;
  String? _specFile;
  Set<String> _ticked = {};
  ApiAuthKind _authKind = ApiAuthKind.none;
  bool _write = false;
  bool _notProduction = false;
  late int? _repoId = widget.repoId;
  double _rate = 5;
  double _maxRequests = 300;
  SwaggerTestCreateStartEnum _start = SwaggerTestCreateStartEnum.code;
  bool _reading = false;
  bool _creating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    for (final t in [_specUrl, _baseUrl, _search, _notes]) {
      t.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final t in [_specUrl, _baseUrl, _notes, _authName, _token, _search, _specUser, _specPass, _specAuthName, _specToken]) {
      t.dispose();
    }
    super.dispose();
  }

  bool get _named => _authKind == ApiAuthKind.header || _authKind == ApiAuthKind.query;

  Future<void> _read({String? url, String? file}) async {
    final l = AppLocalizations.of(context);
    final usingToken = _specAuthOpen && _specAuthMode == _SpecAuthMode.token && _specToken.text.isNotEmpty;
    final usingLogin = _specAuthOpen && _specAuthMode == _SpecAuthMode.login && _specUser.text.trim().isNotEmpty;
    final auth = usingToken && file == null
        ? SwaggerAuthInput(
            kind: _specAuthKind,
            name: _specAuthKind == ApiAuthKind.header || _specAuthKind == ApiAuthKind.query ? _specAuthName.text.trim() : null,
            value: _specToken.text,
          )
        : null;
    setState(() {
      _reading = true;
      _error = null;
    });
    try {
      final s = (await ref.read(apiProvider)!.getSwaggerApi().readSwaggerSpec(
                swaggerSpecInput: SwaggerSpecInput(
                  url: file == null ? (url ?? _specUrl.text).trim() : null,
                  spec: file,
                  auth: auth,
                  login: usingLogin && file == null ? SwaggerSpecInputLogin(username: _specUser.text.trim(), password: _specPass.text) : null,
                ),
              ))
          .data!;
      setState(() {
        _spec = s;
        if (s.choices.isNotEmpty) return;
        // Nothing ticked: the "What to test" text decides, unless endpoints are picked.
        _ticked = {};
        _baseUrl.text = s.servers.firstOrNull?.url ?? '';
        _reusedSpecAuth = false;
        if (auth?.value != null) {
          // The API most likely takes the token its spec took.
          _authKind = auth!.kind;
          _authName.text = auth.name ?? '';
          _token.text = auth.value!;
          _reusedSpecAuth = true;
          return;
        }
        // The first scheme agnts can use picks the auth form.
        final sc = s.securitySchemes.where((x) => x.authKind != null).firstOrNull;
        _authKind = sc?.authKind ?? ApiAuthKind.none;
        _authName.text = sc?.param ?? '';
      });
    } catch (e) {
      setState(() {
        _spec = null;
        switch (_code(e)) {
          case 'spec_needs_login':
            final asked = !_specAuthOpen || _specAuthMode != _SpecAuthMode.login || _specUser.text.trim().isEmpty;
            _specAuthOpen = true;
            _specAuthMode = _SpecAuthMode.login;
            _error = asked ? l.swaggerSpecLoginNeeded : errorMessage(e, l.commonError);
          case 'spec_needs_auth':
            final asked = !_specAuthOpen;
            if (asked) _specAuthMode = _SpecAuthMode.token;
            _specAuthOpen = true;
            _error = asked ? l.swaggerSpecAuthNeeded : errorMessage(e, l.commonError);
          default:
            _error = errorMessage(e, l.commonError);
        }
      });
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  Future<void> _upload() async {
    final l = AppLocalizations.of(context);
    try {
      final fs = await FilePicker.pickFiles();
      final f = fs.firstOrNull;
      if (f == null) return;
      final text = await f.xFile.readAsString();
      _specUrl.clear();
      setState(() => _specFile = f.name);
      await _read(file: text);
    } catch (_) {
      if (mounted) setState(() => _error = l.commonError);
    }
  }

  Future<void> _create() async {
    final l = AppLocalizations.of(context);
    final s = _spec;
    String? err;
    if (s == null || s.choices.isNotEmpty) {
      err = l.swaggerNeedSpec;
    } else if (_ticked.isEmpty && _notes.text.trim().isEmpty) {
      err = l.swaggerWhatToTestNeeded;
    } else if (_authKind != ApiAuthKind.none && _token.text.isEmpty) {
      err = l.swaggerNeedToken;
    } else if (_write && !_notProduction) {
      err = l.swaggerWriteConfirmNeeded;
    }
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    setState(() {
      _creating = true;
      _error = null;
    });
    try {
      final t = (await ref.read(apiProvider)!.getSwaggerApi().createSwaggerTest(
                swaggerTestCreate: SwaggerTestCreate(
                  specUrl: s!.specRef != null ? null : s.url,
                  specRef: s.specRef,
                  baseUrl: _baseUrl.text.trim(),
                  operations: _ticked.isEmpty ? null : _ticked.toList(),
                  writeEnabled: _write,
                  notProduction: _write && _notProduction,
                  auth: SwaggerAuthInput(
                    kind: _authKind,
                    name: _named ? _authName.text.trim() : null,
                    value: _token.text.isEmpty ? null : _token.text,
                  ),
                  repoId: _repoId,
                  notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
                  rateLimit: _rate.round(),
                  maxRequests: _maxRequests.round(),
                  start: _start,
                ),
              ))
          .data!;
      if (!mounted) return;
      showSnack(context, l.swaggerCreated(t.key));
      Navigator.pop(context, t.key);
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final hint = TextStyle(fontSize: 13, color: c.ink3, height: 1.35);
    final mono = const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13);
    final s = _spec;
    final ready = s != null && s.choices.isEmpty;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(backLabel: l.navBack, title: l.mqualityNewTest),
      bottomNavigationBar: ActionBar(children: [
        Expanded(
          child: FilledButton(
            onPressed: _creating || _reading || !ready ? null : _create,
            child: Text(_start == SwaggerTestCreateStartEnum.code ? l.swaggerCreateStart : l.swaggerCreate),
          ),
        ),
      ]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text(l.swaggerFormSub, style: hint),
          const SizedBox(height: 14),
          FormField2(
            label: l.swaggerSpecUrl,
            help: _reading ? l.swaggerSpecReading : (_specFile != null ? l.mqualitySpecFile(_specFile!) : l.swaggerSpecHint),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              TextField(
                controller: _specUrl,
                keyboardType: TextInputType.url,
                autocorrect: false,
                style: mono,
                textInputAction: TextInputAction.go,
                onSubmitted: (_) => _specUrl.text.trim().isEmpty ? null : _read(),
                decoration: InputDecoration(hintText: l.swaggerSpecUrlPh),
              ),
              const SizedBox(height: 8),
              Row(children: [
                FilledButton.tonal(onPressed: _reading || _specUrl.text.trim().isEmpty ? null : () => _read(), child: Text(l.swaggerSpecRead)),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: _reading ? null : _upload, child: Text(l.swaggerSpecUpload)),
              ]),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _specAuthOpen,
                title: Text(l.swaggerSpecAuth, style: const TextStyle(fontSize: 14)),
                onChanged: (v) => setState(() => _specAuthOpen = v ?? false),
              ),
              if (_specAuthOpen) _specAuthBox(l, c, hint, mono),
            ]),
          ),
          if (s != null && s.choices.isNotEmpty)
            FormField2(
              label: l.swaggerSpecChoose,
              child: ListGroup(children: [
                for (final ch in s.choices)
                  ListRow(
                    title: ch.name?.isNotEmpty == true ? ch.name! : ch.url,
                    subtitle: ch.url,
                    onTap: () {
                      _specUrl.text = ch.url;
                      _read(url: ch.url);
                    },
                  ),
              ]),
            ),
          if (ready) ..._form(l, c, s, hint, mono),
          if (_error != null) HelpBox(_error!, tone: Tone.bad),
        ],
      ),
    );
  }

  Widget _specAuthBox(AppLocalizations l, Agnts c, TextStyle hint, TextStyle mono) {
    final named = _specAuthKind == ApiAuthKind.header || _specAuthKind == ApiAuthKind.query;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.line), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Segmented<_SpecAuthMode>(
          full: true,
          options: [(_SpecAuthMode.login, l.swaggerSpecAuthLogin), (_SpecAuthMode.token, l.swaggerSpecAuthToken)],
          value: _specAuthMode,
          onChanged: (v) => setState(() => _specAuthMode = v),
        ),
        const SizedBox(height: 10),
        if (_specAuthMode == _SpecAuthMode.login) ...[
          TextField(controller: _specUser, autocorrect: false, decoration: InputDecoration(hintText: l.swaggerSpecLogin)),
          const SizedBox(height: 8),
          TextField(controller: _specPass, obscureText: true, autocorrect: false, decoration: InputDecoration(hintText: l.swaggerSpecPassword)),
          const SizedBox(height: 6),
          Text(l.swaggerSpecLoginHint, style: hint),
        ] else ...[
          DropdownButtonFormField<ApiAuthKind>(
            initialValue: _specAuthKind,
            isExpanded: true,
            items: [
              for (final k in ApiAuthKind.values.where((k) => k != ApiAuthKind.none)) DropdownMenuItem(value: k, child: Text(authKindLabel(l, k))),
            ],
            onChanged: (v) => setState(() => _specAuthKind = v ?? _specAuthKind),
          ),
          if (named) ...[
            const SizedBox(height: 8),
            TextField(controller: _specAuthName, style: mono, autocorrect: false, decoration: InputDecoration(hintText: l.swaggerAuthName)),
          ],
          const SizedBox(height: 8),
          TextField(
            controller: _specToken,
            obscureText: true,
            autocorrect: false,
            style: mono,
            decoration: InputDecoration(hintText: _specAuthKind == ApiAuthKind.basic ? l.swaggerAuthValueBasic : l.swaggerAuthValue),
          ),
          const SizedBox(height: 6),
          Text(l.swaggerSpecAuthHint, style: hint),
        ],
      ]),
    );
  }

  List<Widget> _form(AppLocalizations l, Agnts c, SwaggerSpec s, TextStyle hint, TextStyle mono) {
    final ops = s.operations;
    final groups = byTag(ops.where((o) => opMatches(o, _search.text)).toList());
    final schemes = s.securitySchemes.map((x) => x.name).join(', ');
    final repos = (ref.watch(reposProvider).value ?? const <Repository>[]).where((r) => r.archivedAt == null).toList();
    void setAll(bool on) => setState(() {
          final next = {..._ticked};
          for (final (_, list) in groups) {
            for (final o in list) {
              on ? next.add(opKey(o)) : next.remove(opKey(o));
            }
          }
          _ticked = next;
        });
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Text(
          l.swaggerSpecFound(s.title ?? 'API', s.version ?? '', ops.length, s.format ?? ''),
          style: TextStyle(fontWeight: FontWeight.w700, color: c.ink),
        ),
      ),
      FormField2(
        label: l.swaggerBaseUrl,
        help: l.swaggerBaseUrlHint,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextField(controller: _baseUrl, keyboardType: TextInputType.url, autocorrect: false, style: mono.copyWith(fontWeight: FontWeight.w600)),
          if (s.servers.length > 1) ...[
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final sv in s.servers)
                FilterChipH(label: sv.description?.isNotEmpty == true ? sv.description! : sv.url, selected: _baseUrl.text == sv.url, onTap: () => _baseUrl.text = sv.url),
            ]),
          ],
        ]),
      ),
      FormField2(
        label: l.swaggerWhatToTest,
        help: l.swaggerWhatToTestHint,
        child: TextField(controller: _notes, minLines: 3, maxLines: 8, maxLength: 20000, decoration: InputDecoration(hintText: l.swaggerWhatToTestPh, counterText: '')),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Fold(
          title: l.swaggerEndpointsOptional,
          hint: _ticked.isEmpty ? null : l.swaggerEndpointsCount('${_ticked.length}', '${ops.length}'),
          initiallyOpen: _ticked.isNotEmpty,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(_ticked.isEmpty ? l.swaggerNoneTicked : l.swaggerEndpointsOptionalHint, style: hint),
            const SizedBox(height: 8),
            TextField(controller: _search, decoration: InputDecoration(hintText: l.swaggerSearch, isDense: true)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, children: [
              TextButton(
                onPressed: () => setState(() {
                  _ticked = {
                    ..._ticked,
                    for (final (_, list) in groups)
                      for (final o in list)
                        if (o.default_) opKey(o),
                  };
                }),
                child: Text(l.swaggerSuggested),
              ),
              TextButton(onPressed: () => setAll(true), child: Text(l.swaggerAll)),
              TextButton(onPressed: () => setAll(false), child: Text(l.swaggerNone)),
            ]),
            for (final (tag, list) in groups) ...[
              if (tag.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 2),
                  child: Text(tag.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.ink3)),
                ),
              for (final o in list) _OpTile(o, ticked: _ticked.contains(opKey(o)), onChanged: (on) => setState(() {
                    final next = {..._ticked};
                    on ? next.add(opKey(o)) : next.remove(opKey(o));
                    _ticked = next;
                  })),
            ],
          ]),
        ),
      ),
      FormField2(
        label: l.swaggerAuth,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          DropdownButtonFormField<ApiAuthKind>(
            key: ValueKey(_authKind),
            initialValue: _authKind,
            isExpanded: true,
            items: [for (final k in ApiAuthKind.values) DropdownMenuItem(value: k, child: Text(authKindLabel(l, k)))],
            onChanged: (v) => setState(() => _authKind = v ?? _authKind),
          ),
          if (schemes.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(l.swaggerAuthFromSpec(schemes), style: hint)),
          if (_named) ...[
            const SizedBox(height: 8),
            TextField(controller: _authName, style: mono, autocorrect: false, decoration: InputDecoration(hintText: l.swaggerAuthName)),
          ],
          if (_authKind != ApiAuthKind.none) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _token,
              obscureText: true,
              autocorrect: false,
              style: mono,
              decoration: InputDecoration(hintText: _authKind == ApiAuthKind.basic ? l.swaggerAuthValueBasic : l.swaggerAuthValue),
            ),
            if (_reusedSpecAuth) Padding(padding: const EdgeInsets.only(top: 6), child: Text(l.swaggerSpecAuthReused, style: hint)),
            Padding(padding: const EdgeInsets.only(top: 6), child: Text(l.swaggerAuthHint, style: hint)),
          ],
        ]),
      ),
      FormField2(
        label: l.swaggerWrite,
        help: _write ? l.swaggerWriteOnHint : l.swaggerWriteOffHint,
        child: Segmented<bool>(
          full: true,
          options: [(false, l.swaggerWriteOff), (true, l.swaggerWriteOn)],
          value: _write,
          onChanged: (v) => setState(() => _write = v),
        ),
      ),
      if (_write)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(_baseUrl.text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.badInk)),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _notProduction,
              title: Text(l.swaggerWriteConfirm(_baseUrl.text), style: const TextStyle(fontSize: 14)),
              onChanged: (v) => setState(() => _notProduction = v ?? false),
            ),
          ]),
        ),
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.swaggerReadOnlyNote, style: hint),
          const SizedBox(height: 6),
          Text(l.swaggerLockoutNote, style: hint),
        ]),
      ),
      FormField2(
        label: l.swaggerRepository,
        help: l.swaggerRepositoryHint,
        child: DropdownButtonFormField<int?>(
          initialValue: _repoId,
          isExpanded: true,
          items: [
            DropdownMenuItem<int?>(value: null, child: Text(l.swaggerNoRepo)),
            for (final r in repos) DropdownMenuItem<int?>(value: r.id, child: Text(r.name)),
          ],
          onChanged: (v) => setState(() => _repoId = v),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Fold(
          title: l.swaggerLimits,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('${l.swaggerRate}: ${_rate.round()}', style: hint),
            Slider(value: _rate, min: 1, max: 20, divisions: 19, onChanged: (v) => setState(() => _rate = v)),
            Text('${l.swaggerMaxRequests}: ${_maxRequests.round()}', style: hint),
            Slider(value: _maxRequests, min: 10, max: 1000, divisions: 99, onChanged: (v) => setState(() => _maxRequests = v)),
          ]),
        ),
      ),
      FormField2(
        label: l.swaggerStart,
        help: l.swaggerClaudeOnly,
        child: Segmented<SwaggerTestCreateStartEnum>(
          full: true,
          options: [(SwaggerTestCreateStartEnum.code, l.swaggerStartNow), (SwaggerTestCreateStartEnum.queue, l.swaggerStartQueue)],
          value: _start,
          onChanged: (v) => setState(() => _start = v),
        ),
      ),
    ];
  }
}

/// One endpoint to tick, with why it starts unticked.
class _OpTile extends StatelessWidget {
  const _OpTile(this.o, {required this.ticked, required this.onChanged});
  final SwaggerOperation o;
  final bool ticked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final why = o.sideEffect != null ? l.swaggerUntickedSideEffect(o.sideEffect!) : (o.deprecated == true ? l.swaggerUntickedDeprecated : null);
    return InkWell(
      onTap: () => onChanged(!ticked),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Checkbox(value: ticked, visualDensity: VisualDensity.compact, onChanged: (v) => onChanged(v ?? false)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text.rich(TextSpan(children: [
                  TextSpan(text: '${o.method} ', style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 11.5, fontWeight: FontWeight.w700, color: methodColor(c, o.method))),
                  TextSpan(
                    text: o.path,
                    style: TextStyle(
                      fontFamily: AgntsFonts.mono,
                      fontSize: 12.5,
                      decoration: o.deprecated == true ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ])),
                if (o.summary != null && o.summary!.isNotEmpty) Text(o.summary!, style: TextStyle(fontSize: 13, color: c.ink3)),
                if (why != null) Text(why, style: TextStyle(fontSize: 12.5, color: c.ink3)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

/// The colour of an HTTP method's label, as in the admin panel.
Color methodColor(Agnts c, String method) => switch (method.toUpperCase()) {
  'GET' => c.okInk,
  'POST' => c.warnInk,
  'PUT' || 'PATCH' => c.primaryInk,
  'DELETE' => c.badInk,
  _ => c.ink2,
};

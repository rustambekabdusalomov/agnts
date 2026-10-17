import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'manage_logic.dart';
import 'manage_widgets.dart';

/// A repository picked for import: what the new one starts from.
typedef RepoPreset = ({String name, String cloneUrl, String defaultBranch});

/// Opens the repository form; [repo] null adds one, prefilled from [preset].
Future<void> openRepoEditor(BuildContext context, {Repository? repo, RepoPreset? preset}) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => RepoEditorScreen(repo: repo, preset: preset)));

enum _EnvEdit { keep, replace, clear }

/// Add or edit a repository (RepoDrawer): where it lives, how tickets
/// reach it, its checks, toolchains, previews and run settings.
class RepoEditorScreen extends ConsumerStatefulWidget {
  const RepoEditorScreen({super.key, this.repo, this.preset});
  final Repository? repo;
  final RepoPreset? preset;

  @override
  ConsumerState<RepoEditorScreen> createState() => _RepoEditorScreenState();
}

class _RepoEditorScreenState extends ConsumerState<RepoEditorScreen> {
  late final Repository? r = widget.repo;
  late final _name = TextEditingController(text: r?.name ?? widget.preset?.name ?? '');
  late final _cloneUrl = TextEditingController(text: r?.cloneUrl ?? widget.preset?.cloneUrl ?? '');
  late final _jira = TextEditingController(text: r?.jiraProject ?? '');
  late final _plane = TextEditingController(text: r?.planeProject ?? '');
  late final _prefix = TextEditingController(text: r?.taskPrefix ?? '');
  late final _branch = TextEditingController(
    text: r?.defaultBranch ?? ((widget.preset?.defaultBranch ?? '').isEmpty ? 'main' : widget.preset!.defaultBranch),
  );
  late final _branchTmpl = TextEditingController(text: r?.branchTemplate ?? '');
  late final _commitTmpl = TextEditingController(text: r?.commitTemplate ?? '');
  late final _build = TextEditingController(text: r?.buildCmd ?? '');
  late final _lint = TextEditingController(text: r?.lintCmd ?? '');
  late final _test = TextEditingController(text: r?.testCmd ?? '');
  late final _instructions = TextEditingController(text: r?.instructions ?? '');
  late final _deploy = TextEditingController(text: r?.deployWorkflow ?? '');
  late final _pvCommand = TextEditingController(text: r?.preview?.command ?? '');
  late final _pvPort = TextEditingController(text: (r?.preview?.port ?? 0) > 0 ? '${r!.preview!.port}' : '');
  late final _pvReady = TextEditingController(text: (r?.preview?.readyPath ?? '').isEmpty ? '/' : r!.preview!.readyPath);
  late final _pvRoutes = TextEditingController(text: (r?.preview?.routes ?? const []).join('\n'));
  late final _pvUi = TextEditingController(text: (r?.preview?.uiPaths ?? const []).join('\n'));
  late final _pvLogin = TextEditingController(text: r?.preview?.login ?? '');
  final _pvEnv = TextEditingController();
  late final _image = TextEditingController(text: r?.runnerImage ?? '');
  final _buildEnv = TextEditingController();
  final _toolDraft = TextEditingController();

  late List<Toolchain> _toolchains = [...?r?.toolchains];
  late bool _override = r?.toolchainsOverride ?? false;
  late int _memoryMb = r?.memoryMb ?? 0;
  late var _envEdit = (r?.preview?.envSet ?? false) ? _EnvEdit.keep : _EnvEdit.replace;
  late var _buildEnvEdit = (r?.buildEnvSet ?? false) ? _EnvEdit.keep : _EnvEdit.replace;
  List<String>? _notes;
  String _toolError = '';
  String _detect = '';
  bool _detectError = false;
  bool _detecting = false;
  bool _filled = false;
  String _error = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // A repository picked for import: scan it right away.
    if (r == null && (widget.preset?.cloneUrl ?? '').isNotEmpty) WidgetsBinding.instance.addPostFrameCallback((_) => _runDetect(false));
  }

  @override
  void dispose() {
    for (final c in [
      _name, _cloneUrl, _jira, _plane, _prefix, _branch, _branchTmpl, _commitTmpl, _build, _lint, _test, _instructions, _deploy,
      _pvCommand, _pvPort, _pvReady, _pvRoutes, _pvUi, _pvLogin, _pvEnv, _image, _buildEnv, _toolDraft,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _addTool() {
    final l = AppLocalizations.of(context);
    if (_toolDraft.text.trim().isEmpty) return;
    final t = parseToolchain(_toolDraft.text);
    if (t == null) {
      setState(() => _toolError = l.reposToolchainBad);
      return;
    }
    setState(() {
      _toolError = '';
      _toolchains = withToolchain(_toolchains, t);
      _override = true;
      _toolDraft.clear();
    });
  }

  Future<void> _runDetect(bool deep) async {
    final l = AppLocalizations.of(context);
    if (r == null && _cloneUrl.text.trim().isEmpty) {
      setState(() {
        _detectError = true;
        _detect = l.reposDetectNeedsUrl;
      });
      return;
    }
    setState(() {
      _detecting = true;
      _detectError = false;
      _detect = l.reposDetecting;
    });
    try {
      final branch = _branch.text.trim();
      final url = _cloneUrl.text.trim();
      final det = (await ref.read(apiProvider)!.getReposApi().detectRepo(
                repoDetectInput: RepoDetectInput(
                  id: r?.id,
                  cloneUrl: url.isEmpty ? null : url,
                  defaultBranch: branch.isEmpty ? null : branch,
                  deep: deep,
                ),
              ))
          .data!;
      if (!mounted) return;
      setState(() {
        _toolchains = [...det.toolchains];
        _override = false;
        _notes = det.notes;
        final found = det.toolchains.map(toolchainSpec).join(', ');
        _detect = found.isEmpty ? l.reposDetectNothing : l.reposDetectDone(found);
        if (det.source_ == RepoDetectionSource_Enum.claude) _detect += ' ${l.reposDetectByClaude}';
        // Detection fills the check commands that are still empty; it never overwrites.
        var any = false;
        for (final (c, v) in [(_build, det.buildCmd), (_lint, det.lintCmd), (_test, det.testCmd)]) {
          if (v.isNotEmpty && c.text.trim().isEmpty) {
            c.text = v;
            any = true;
          }
        }
        _filled = any;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _detectError = true;
          _detect = errorMessage(e, l.commonError);
        });
      }
    } finally {
      if (mounted) setState(() => _detecting = false);
    }
  }

  String? _envValue(_EnvEdit mode, TextEditingController c, bool wasSet) => switch (mode) {
        _EnvEdit.clear => '',
        _EnvEdit.replace when c.text.trim().isNotEmpty || wasSet => c.text,
        _ => null,
      };

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (_name.text.trim().isEmpty || _cloneUrl.text.trim().isEmpty) {
      setState(() => _error = l.mmanageFillAll);
      return;
    }
    final body = RepositoryInput(
      name: _name.text.trim(),
      cloneUrl: _cloneUrl.text.trim(),
      defaultBranch: _branch.text.trim().isEmpty ? null : _branch.text.trim(),
      branchTemplate: _branchTmpl.text.trim(),
      commitTemplate: _commitTmpl.text.trim(),
      buildCmd: _build.text.trim(),
      lintCmd: _lint.text.trim(),
      testCmd: _test.text.trim(),
      instructions: _instructions.text,
      jiraProject: _jira.text.trim(),
      planeProject: _plane.text.trim().toUpperCase(),
      taskPrefix: _prefix.text.trim(),
      deployWorkflow: isGitHubUrl(_cloneUrl.text) ? _deploy.text.trim() : '',
      preview: RepoPreviewInput(
        command: _pvCommand.text.trim(),
        port: int.tryParse(_pvPort.text.trim()) ?? 0,
        readyPath: _pvReady.text.trim().isEmpty ? '/' : _pvReady.text.trim(),
        routes: lines(_pvRoutes.text),
        uiPaths: lines(_pvUi.text),
        login: _pvLogin.text.trim(),
        env: _envValue(_envEdit, _pvEnv, r?.preview?.envSet ?? false),
      ),
      toolchains: _toolchains,
      toolchainsOverride: _override,
      runnerImage: _image.text.trim(),
      memoryMb: _memoryMb,
      buildEnv: _envValue(_buildEnvEdit, _buildEnv, r?.buildEnvSet ?? false),
    );
    setState(() {
      _busy = true;
      _error = '';
    });
    try {
      final api = ref.read(apiProvider)!.getReposApi();
      if (r == null) {
        await api.createRepo(repositoryInput: body);
      } else {
        await api.updateRepo(id: r!.id, repositoryInput: body);
      }
      ref.invalidate(reposProvider);
      ref.invalidate(repoGroupsProvider);
      if (!mounted) return;
      showSnack(context, l.reposSaved);
      Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _envField({
    required AppLocalizations l,
    required _EnvEdit mode,
    required ValueChanged<_EnvEdit> onMode,
    required TextEditingController c,
    required bool wasSet,
    required String setText,
    required String replace,
    required String clear,
    required String cleared,
    required String hint,
  }) {
    final grey = TextStyle(fontSize: 13, color: Agnts.of(context).ink3);
    if (wasSet && mode == _EnvEdit.keep) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(setText, style: grey),
        Wrap(spacing: 8, children: [
          TextButton(onPressed: () => onMode(_EnvEdit.replace), child: Text(replace)),
          TextButton(onPressed: () => onMode(_EnvEdit.clear), child: Text(clear)),
        ]),
      ]);
    }
    if (mode == _EnvEdit.clear) {
      return Row(children: [
        Expanded(child: Text(cleared, style: grey)),
        TextButton(onPressed: () => onMode(_EnvEdit.keep), child: Text(l.formCancel)),
      ]);
    }
    return ManageInput(controller: c, mono: true, minLines: 3, maxLines: 8, hint: hint);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final grey = TextStyle(fontSize: 12.5, color: c.ink3);
    final prefix = (_prefix.text.isEmpty ? 'VIS' : _prefix.text).toUpperCase();
    final commitEx = commitExample(_commitTmpl.text, taskPrefix: _prefix.text);
    Widget ph(List<(String, String)> list) => Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Fold(
            title: l.reposPlaceholders,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (final (k, v) in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text.rich(TextSpan(children: [
                    TextSpan(text: '$k  ', style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink2)),
                    TextSpan(text: v, style: grey),
                  ])),
                ),
            ]),
          ),
        );
    void rebuild(String _) => setState(() {});

    return Scaffold(
      appBar: DetailBar(backLabel: l.reposTitle, title: r?.name),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r?.name ?? l.reposAdd, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(l.reposDrawerSub, style: TextStyle(fontSize: 13.5, color: c.ink3)),
          ]),
        ),
        HCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            ManageField(label: l.reposName, child: ManageInput(controller: _name, maxLength: 100)),
            ManageField(
              label: l.reposCloneUrl,
              help: l.reposCloneHelp,
              child: ManageInput(controller: _cloneUrl, mono: true, keyboardType: TextInputType.url, hint: 'https://github.com/you/repo.git', onChanged: rebuild),
            ),
            ManageField(label: l.reposJiraProject, help: l.reposJiraHelp, child: ManageInput(controller: _jira, mono: true, hint: 'PAY', maxLength: 20)),
            ManageField(label: l.reposPlaneProject, help: l.reposPlaneHelp, child: ManageInput(controller: _plane, mono: true, hint: 'WEB', maxLength: 12)),
            ManageField(
              label: l.reposTaskPrefix,
              help: l.reposTaskPrefixHelp(prefix),
              child: ManageInput(controller: _prefix, mono: true, hint: 'VIS', maxLength: 8, onChanged: rebuild),
            ),
            ManageField(label: l.reposBranch, help: l.reposBranchHelp, child: ManageInput(controller: _branch, mono: true)),
            ManageField(
              label: l.reposBranchTemplate,
              help: '${l.reposBranchTemplateHelp('{key}', '{number}', branchDefault)}\n'
                  '${l.reposBranchTemplateExample(branchExample(_branchTmpl.text, branchPrefix: r?.branchPrefix ?? '', taskPrefix: _prefix.text))}',
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                ManageInput(controller: _branchTmpl, mono: true, hint: branchDefault, maxLength: 100, onChanged: rebuild),
                ph([
                  ('{prefix}', l.reposPhPrefix),
                  ('{type}', l.reposPhType),
                  ('{key}', l.reposPhKey),
                  ('{number}', l.reposPhNumber),
                  ('{slug}', l.reposPhSlug),
                  ('{user}', l.reposPhUser),
                ]),
              ]),
            ),
            ManageField(
              label: l.reposCommitTemplate,
              help: [l.reposCommitTemplateHelp, if (commitEx.isNotEmpty) l.reposCommitTemplateExample(commitEx)].join('\n'),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                ManageInput(controller: _commitTmpl, mono: true, hint: commitPlaceholder, maxLength: 200, onChanged: rebuild),
                ph([
                  ('{number}', l.reposPhNumber),
                  ('{key}', l.reposPhKey),
                  ('{type}', l.reposPhCommitType),
                  ('{scope}', l.reposPhScope),
                  ('{subject}', l.reposPhSubject),
                  ('{title}', l.reposPhTitle),
                ]),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        // Toolchains, with Detect (a file scan) and Ask Claude (README and CI files).
        HCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            CardTitle(l.reposToolchains, sub: l.reposToolchainsHelp),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final t in _toolchains)
                InputChip(
                  label: Text('${toolchainSpec(t)}${t.dir != null ? '  ${t.dir}/' : ''}', style: const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5)),
                  tooltip: t.source_ == null ? null : l.reposToolchainFrom(t.source_!),
                  deleteButtonTooltipMessage: l.reposToolchainRemove(t.tool),
                  onDeleted: () => setState(() {
                    _toolchains = _toolchains.where((x) => x.tool != t.tool).toList();
                    _override = true;
                  }),
                ),
              if (_toolchains.isEmpty) Text(l.reposToolchainsNone, style: grey),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: ManageInput(controller: _toolDraft, mono: true, hint: l.reposToolchainPh)),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: _addTool, child: Text(l.reposToolchainAdd)),
            ]),
            if (_toolError.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: ErrorLine(_toolError)),
            const SizedBox(height: 6),
            Text(_override ? l.reposToolchainsManual : l.reposToolchainsAuto, style: grey),
            Wrap(spacing: 8, children: [
              TextButton(onPressed: _detecting ? null : () => _runDetect(false), child: Text(l.reposDetect)),
              Tooltip(
                message: l.reposDetectDeepHelp,
                child: TextButton(onPressed: _detecting ? null : () => _runDetect(true), child: Text(l.reposDetectDeep)),
              ),
              if (_override)
                TextButton(
                  onPressed: _detecting
                      ? null
                      : () {
                          setState(() => _override = false);
                          _runDetect(false);
                        },
                  child: Text(l.reposToolchainsBackToAuto),
                ),
            ]),
            if (_detect.isNotEmpty) Text(_detect, style: TextStyle(fontSize: 13, color: _detectError ? c.badInk : c.ink3)),
            if ((_notes ?? r?.toolchainNotes ?? const []).isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(l.reposNotes, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink2)),
              for (final n in _notes ?? r?.toolchainNotes ?? const <String>[]) Text('• $n', style: grey),
            ],
          ]),
        ),
        const SizedBox(height: 12),
        HCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            ManageField(label: l.reposBuild, child: ManageInput(controller: _build, mono: true, hint: l.reposCmdAuto)),
            ManageField(label: l.reposLint, child: ManageInput(controller: _lint, mono: true, hint: l.reposCmdAuto)),
            ManageField(
              label: l.reposTest,
              help: [l.reposTestHelp, if (_filled) l.reposDetectFilled].join('\n'),
              child: ManageInput(controller: _test, mono: true, hint: l.reposCmdAuto),
            ),
            if (isGitHubUrl(_cloneUrl.text))
              ManageField(
                label: l.reposDeployWorkflow,
                help: l.reposDeployWorkflowHelp,
                child: ManageInput(controller: _deploy, mono: true, hint: 'deploy.yml', maxLength: 200),
              ),
            ManageField(
              label: l.reposInstructions,
              help: l.reposInstructionsHelp,
              child: ManageInput(controller: _instructions, minLines: 3, maxLines: 10, maxLength: 20000),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        // Previews: how agnts starts the app to take screenshots.
        HCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            CardTitle(l.previewRepoTitle, sub: l.previewRepoHelp),
            ManageField(
              label: l.previewRepoCommand,
              help: l.previewRepoCommandHelp,
              child: ManageInput(
                controller: _pvCommand,
                mono: true,
                hint: 'npm ci && npm run dev -- --host 127.0.0.1 --port 5173',
                maxLength: 1000,
                onChanged: rebuild,
              ),
            ),
            if (_pvCommand.text.trim().isNotEmpty) ...[
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: ManageField(label: l.previewRepoPort, child: ManageInput(controller: _pvPort, mono: true, hint: '5173', keyboardType: TextInputType.number)),
                ),
                const SizedBox(width: 10),
                Expanded(child: ManageField(label: l.previewRepoReady, child: ManageInput(controller: _pvReady, mono: true, hint: '/'))),
              ]),
              ManageField(
                label: l.previewRepoUiPaths,
                help: l.previewRepoUiPathsHelp,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  ManageInput(controller: _pvUi, mono: true, minLines: 2, maxLines: 6, hint: 'src/**/*.vue'),
                  Wrap(spacing: 6, children: [
                    for (final e in uiPresets.entries)
                      ActionChip(label: Text(e.key), onPressed: () => setState(() => _pvUi.text = e.value.join('\n'))),
                  ]),
                ]),
              ),
              ManageField(
                label: l.previewRepoRoutes,
                help: l.previewRepoRoutesHelp,
                child: ManageInput(controller: _pvRoutes, mono: true, minLines: 2, maxLines: 6, hint: '/'),
              ),
              ManageField(
                label: l.previewRepoLogin,
                help: l.previewRepoLoginHelp,
                child: ManageInput(controller: _pvLogin, minLines: 2, maxLines: 6, hint: l.previewRepoLoginPh, maxLength: 2000),
              ),
              ManageField(
                label: l.previewRepoEnv,
                help: _envEdit == _EnvEdit.replace ? l.previewRepoEnvHelp : null,
                child: _envField(
                  l: l,
                  mode: _envEdit,
                  onMode: (m) => setState(() => _envEdit = m),
                  c: _pvEnv,
                  wasSet: r?.preview?.envSet ?? false,
                  setText: l.previewRepoEnvSet((r?.preview?.envNames ?? const []).join(', ')),
                  replace: l.previewRepoEnvReplace,
                  clear: l.previewRepoEnvClear,
                  cleared: l.previewRepoEnvCleared,
                  hint: 'VITE_API_URL=https://staging.example.com',
                ),
              ),
            ],
          ]),
        ),
        const SizedBox(height: 12),
        Fold(
          title: l.reposAdvanced,
          initiallyOpen: (r?.runnerImage ?? '').isNotEmpty || (r?.memoryMb ?? 0) > 0 || (r?.buildEnvSet ?? false),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            ManageField(
              label: l.reposRunnerImage,
              help: l.reposRunnerImageHelp,
              child: ManageInput(controller: _image, mono: true, hint: 'agnts-runner-android:latest', maxLength: 255),
            ),
            ManageField(
              label: l.reposMemory,
              help: l.reposMemoryHelp,
              child: Row(children: [
                IconButton.outlined(
                  tooltip: l.formDecrease,
                  onPressed: _memoryMb <= 0 ? null : () => setState(() => _memoryMb = (_memoryMb - 1024).clamp(0, 16384)),
                  icon: const Icon(Icons.remove_rounded),
                ),
                Expanded(
                  child: Text(memoryGb(_memoryMb) ?? l.reposMemoryDefault, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: c.ink)),
                ),
                IconButton.outlined(
                  tooltip: l.formIncrease,
                  onPressed: _memoryMb >= 16384 ? null : () => setState(() => _memoryMb = (_memoryMb + 1024).clamp(0, 16384)),
                  icon: const Icon(Icons.add_rounded),
                ),
              ]),
            ),
            ManageField(
              label: l.reposBuildEnv,
              help: _buildEnvEdit == _EnvEdit.replace ? l.reposBuildEnvHelp : null,
              child: _envField(
                l: l,
                mode: _buildEnvEdit,
                onMode: (m) => setState(() => _buildEnvEdit = m),
                c: _buildEnv,
                wasSet: r?.buildEnvSet ?? false,
                setText: l.reposBuildEnvSet((r?.buildEnvNames ?? const []).join(', ')),
                replace: l.reposBuildEnvReplace,
                clear: l.reposBuildEnvClear,
                cleared: l.reposBuildEnvCleared,
                hint: 'NPM_TOKEN=...',
              ),
            ),
          ]),
        ),
        if (r != null) ...[
          const SizedBox(height: 12),
          HCard(
            child: KvRow(
              'CLAUDE.md',
              switch (r!.claudeMd) {
                RepositoryClaudeMdEnum.found => l.reposClaudeFound,
                RepositoryClaudeMdEnum.missing => l.reposClaudeMissing,
                _ => l.reposClaudeUnknown,
              },
            ),
          ),
        ],
        const SizedBox(height: 14),
        if (_error.isNotEmpty) ErrorLine(_error),
      ]),
      bottomNavigationBar: ActionBar(children: [
        Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(l.formCancel))),
        Expanded(child: FilledButton(onPressed: _busy ? null : _save, child: Text(r != null ? l.formSave : l.reposAdd))),
      ]),
    );
  }
}

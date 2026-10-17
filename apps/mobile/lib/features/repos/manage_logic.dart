import 'package:agnts_api/agnts_api.dart';

final _tool = RegExp(r'^[a-z][a-z0-9-]{0,39}$');
final _version = RegExp(r'^[A-Za-z0-9][A-Za-z0-9.+_-]{0,63}$');

/// Reads "tool@version" (version defaults to latest), or null when invalid.
Toolchain? parseToolchain(String s) {
  final parts = s.trim().toLowerCase().split('@');
  final tool = parts.first;
  final v = parts.length > 1 && parts[1].isNotEmpty ? parts.sublist(1).join('@') : 'latest';
  if (!_tool.hasMatch(tool) || !_version.hasMatch(v)) return null;
  return Toolchain(tool: tool, version: v, source_: 'manual');
}

/// tool@version, as mise takes it.
String toolchainSpec(Toolchain t) => '${t.tool}@${t.version}';

/// Adds a toolchain, replacing one for the same tool.
List<Toolchain> withToolchain(List<Toolchain> list, Toolchain t) => [...list.where((x) => x.tool != t.tool), t];

/// Non-empty trimmed lines.
List<String> lines(String v) => [
      for (final x in v.split('\n'))
        if (x.trim().isNotEmpty) x.trim(),
    ];

/// The branch name format's default.
const branchDefault = '{prefix}{key}';
const commitPlaceholder = '[{number}] {type}({scope}): {subject}';

/// An example branch name for the format, as the web shows it.
String branchExample(String template, {required String branchPrefix, required String taskPrefix}) {
  final p = (taskPrefix.isEmpty ? 'VIS' : taskPrefix).toUpperCase();
  return (template.trim().isEmpty ? branchDefault : template.trim())
      .replaceAll('{prefix}', branchPrefix.isEmpty ? 'agnts/' : branchPrefix)
      .replaceAll('{type}', 'feature')
      .replaceAll('{key}', '$p-42')
      .replaceAll('{number}', 'AMANAT-2288')
      .replaceAll('{slug}', 'add-login-page')
      .replaceAll('{user}', 'jane');
}

/// An example commit message for the format; empty without one.
String commitExample(String template, {required String taskPrefix}) {
  final p = (taskPrefix.isEmpty ? 'VIS' : taskPrefix).toUpperCase();
  return template
      .trim()
      .replaceAll('{number}', 'AMANAT-2288')
      .replaceAll('{key}', '$p-42')
      .replaceAll('{type}', 'chore')
      .replaceAll('{scope}', 'deps')
      .replaceAll('{subject}', 'bump protos to v1.63.0')
      .replaceAll('{title}', 'Update protos');
}

/// Globs for the usual front-end layouts; a change touching one gets a preview.
const uiPresets = <String, List<String>>{
  'Vue / Vite': ['src/**/*.{vue,ts,js,css,scss}'],
  'React': ['src/**/*.{tsx,jsx,ts,css,scss}'],
  'Next.js': ['app/**/*.{tsx,jsx,ts,css}', 'pages/**/*.{tsx,jsx}', 'components/**/*.{tsx,jsx,css}'],
  'Angular': ['src/**/*.{ts,html,scss,css}'],
};

/// Whether a clone URL is on github.com (the deploy workflow is GitHub-only).
bool isGitHubUrl(String url) => RegExp(r'^https://github\.com/', caseSensitive: false).hasMatch(url.trim());

/// What people remember a repository by, for the search box.
String repoHaystack(Repository r) => [
      r.name,
      r.cloneUrl,
      r.stack ?? '',
      r.jiraProject,
      r.planeProject ?? '',
      r.provider.value,
      for (final g in r.groups ?? const <RepoGroupRef>[]) g.name,
    ].join(' ').toLowerCase();

/// "4 GB", or null for the server default (0).
String? memoryGb(int mb) => mb == 0 ? null : '${(mb / 1024).toStringAsFixed(mb % 1024 == 0 ? 0 : 1)} GB';

/// Moves item [i] by [d] places; the list stays as is at an edge.
List<T> moved<T>(List<T> list, int i, int d) {
  final j = i + d;
  if (j < 0 || j >= list.length) return list;
  final out = [...list];
  final t = out[i];
  out[i] = out[j];
  out[j] = t;
  return out;
}

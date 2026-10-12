// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RepositoryCWProxy {
  Repository id(int id);

  Repository name(String name);

  Repository kind(RepositoryKindEnum kind);

  Repository provider(RepositoryProviderEnum provider);

  Repository cloneUrl(String cloneUrl);

  Repository defaultBranch(String defaultBranch);

  Repository buildCmd(String buildCmd);

  Repository lintCmd(String lintCmd);

  Repository testCmd(String testCmd);

  Repository branchPrefix(String branchPrefix);

  Repository taskPrefix(String taskPrefix);

  Repository instructions(String instructions);

  Repository jiraProject(String jiraProject);

  Repository planeProject(String? planeProject);

  Repository claudeMd(RepositoryClaudeMdEnum claudeMd);

  Repository openTickets(int openTickets);

  Repository deployWorkflow(String? deployWorkflow);

  Repository archivedAt(DateTime? archivedAt);

  Repository preview(RepoPreview? preview);

  Repository stack(String? stack);

  Repository toolchains(List<Toolchain>? toolchains);

  Repository toolchainsOverride(bool? toolchainsOverride);

  Repository toolchainsDetectedAt(DateTime? toolchainsDetectedAt);

  Repository toolchainNotes(List<String>? toolchainNotes);

  Repository runnerImage(String? runnerImage);

  Repository memoryMb(int? memoryMb);

  Repository buildEnvSet(bool? buildEnvSet);

  Repository buildEnvNames(List<String>? buildEnvNames);

  Repository harness(RepoHarness? harness);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Repository(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Repository(...).copyWith(id: 12, name: "My name")
  /// ````
  Repository call({
    int id,
    String name,
    RepositoryKindEnum kind,
    RepositoryProviderEnum provider,
    String cloneUrl,
    String defaultBranch,
    String buildCmd,
    String lintCmd,
    String testCmd,
    String branchPrefix,
    String taskPrefix,
    String instructions,
    String jiraProject,
    String? planeProject,
    RepositoryClaudeMdEnum claudeMd,
    int openTickets,
    String? deployWorkflow,
    DateTime? archivedAt,
    RepoPreview? preview,
    String? stack,
    List<Toolchain>? toolchains,
    bool? toolchainsOverride,
    DateTime? toolchainsDetectedAt,
    List<String>? toolchainNotes,
    String? runnerImage,
    int? memoryMb,
    bool? buildEnvSet,
    List<String>? buildEnvNames,
    RepoHarness? harness,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRepository.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRepository.copyWith.fieldName(...)`
class _$RepositoryCWProxyImpl implements _$RepositoryCWProxy {
  const _$RepositoryCWProxyImpl(this._value);

  final Repository _value;

  @override
  Repository id(int id) => this(id: id);

  @override
  Repository name(String name) => this(name: name);

  @override
  Repository kind(RepositoryKindEnum kind) => this(kind: kind);

  @override
  Repository provider(RepositoryProviderEnum provider) =>
      this(provider: provider);

  @override
  Repository cloneUrl(String cloneUrl) => this(cloneUrl: cloneUrl);

  @override
  Repository defaultBranch(String defaultBranch) =>
      this(defaultBranch: defaultBranch);

  @override
  Repository buildCmd(String buildCmd) => this(buildCmd: buildCmd);

  @override
  Repository lintCmd(String lintCmd) => this(lintCmd: lintCmd);

  @override
  Repository testCmd(String testCmd) => this(testCmd: testCmd);

  @override
  Repository branchPrefix(String branchPrefix) =>
      this(branchPrefix: branchPrefix);

  @override
  Repository taskPrefix(String taskPrefix) => this(taskPrefix: taskPrefix);

  @override
  Repository instructions(String instructions) =>
      this(instructions: instructions);

  @override
  Repository jiraProject(String jiraProject) => this(jiraProject: jiraProject);

  @override
  Repository planeProject(String? planeProject) =>
      this(planeProject: planeProject);

  @override
  Repository claudeMd(RepositoryClaudeMdEnum claudeMd) =>
      this(claudeMd: claudeMd);

  @override
  Repository openTickets(int openTickets) => this(openTickets: openTickets);

  @override
  Repository deployWorkflow(String? deployWorkflow) =>
      this(deployWorkflow: deployWorkflow);

  @override
  Repository archivedAt(DateTime? archivedAt) => this(archivedAt: archivedAt);

  @override
  Repository preview(RepoPreview? preview) => this(preview: preview);

  @override
  Repository stack(String? stack) => this(stack: stack);

  @override
  Repository toolchains(List<Toolchain>? toolchains) =>
      this(toolchains: toolchains);

  @override
  Repository toolchainsOverride(bool? toolchainsOverride) =>
      this(toolchainsOverride: toolchainsOverride);

  @override
  Repository toolchainsDetectedAt(DateTime? toolchainsDetectedAt) =>
      this(toolchainsDetectedAt: toolchainsDetectedAt);

  @override
  Repository toolchainNotes(List<String>? toolchainNotes) =>
      this(toolchainNotes: toolchainNotes);

  @override
  Repository runnerImage(String? runnerImage) => this(runnerImage: runnerImage);

  @override
  Repository memoryMb(int? memoryMb) => this(memoryMb: memoryMb);

  @override
  Repository buildEnvSet(bool? buildEnvSet) => this(buildEnvSet: buildEnvSet);

  @override
  Repository buildEnvNames(List<String>? buildEnvNames) =>
      this(buildEnvNames: buildEnvNames);

  @override
  Repository harness(RepoHarness? harness) => this(harness: harness);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Repository(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Repository(...).copyWith(id: 12, name: "My name")
  /// ````
  Repository call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? provider = const $CopyWithPlaceholder(),
    Object? cloneUrl = const $CopyWithPlaceholder(),
    Object? defaultBranch = const $CopyWithPlaceholder(),
    Object? buildCmd = const $CopyWithPlaceholder(),
    Object? lintCmd = const $CopyWithPlaceholder(),
    Object? testCmd = const $CopyWithPlaceholder(),
    Object? branchPrefix = const $CopyWithPlaceholder(),
    Object? taskPrefix = const $CopyWithPlaceholder(),
    Object? instructions = const $CopyWithPlaceholder(),
    Object? jiraProject = const $CopyWithPlaceholder(),
    Object? planeProject = const $CopyWithPlaceholder(),
    Object? claudeMd = const $CopyWithPlaceholder(),
    Object? openTickets = const $CopyWithPlaceholder(),
    Object? deployWorkflow = const $CopyWithPlaceholder(),
    Object? archivedAt = const $CopyWithPlaceholder(),
    Object? preview = const $CopyWithPlaceholder(),
    Object? stack = const $CopyWithPlaceholder(),
    Object? toolchains = const $CopyWithPlaceholder(),
    Object? toolchainsOverride = const $CopyWithPlaceholder(),
    Object? toolchainsDetectedAt = const $CopyWithPlaceholder(),
    Object? toolchainNotes = const $CopyWithPlaceholder(),
    Object? runnerImage = const $CopyWithPlaceholder(),
    Object? memoryMb = const $CopyWithPlaceholder(),
    Object? buildEnvSet = const $CopyWithPlaceholder(),
    Object? buildEnvNames = const $CopyWithPlaceholder(),
    Object? harness = const $CopyWithPlaceholder(),
  }) {
    return Repository(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as RepositoryKindEnum,
      provider: provider == const $CopyWithPlaceholder()
          ? _value.provider
          // ignore: cast_nullable_to_non_nullable
          : provider as RepositoryProviderEnum,
      cloneUrl: cloneUrl == const $CopyWithPlaceholder()
          ? _value.cloneUrl
          // ignore: cast_nullable_to_non_nullable
          : cloneUrl as String,
      defaultBranch: defaultBranch == const $CopyWithPlaceholder()
          ? _value.defaultBranch
          // ignore: cast_nullable_to_non_nullable
          : defaultBranch as String,
      buildCmd: buildCmd == const $CopyWithPlaceholder()
          ? _value.buildCmd
          // ignore: cast_nullable_to_non_nullable
          : buildCmd as String,
      lintCmd: lintCmd == const $CopyWithPlaceholder()
          ? _value.lintCmd
          // ignore: cast_nullable_to_non_nullable
          : lintCmd as String,
      testCmd: testCmd == const $CopyWithPlaceholder()
          ? _value.testCmd
          // ignore: cast_nullable_to_non_nullable
          : testCmd as String,
      branchPrefix: branchPrefix == const $CopyWithPlaceholder()
          ? _value.branchPrefix
          // ignore: cast_nullable_to_non_nullable
          : branchPrefix as String,
      taskPrefix: taskPrefix == const $CopyWithPlaceholder()
          ? _value.taskPrefix
          // ignore: cast_nullable_to_non_nullable
          : taskPrefix as String,
      instructions: instructions == const $CopyWithPlaceholder()
          ? _value.instructions
          // ignore: cast_nullable_to_non_nullable
          : instructions as String,
      jiraProject: jiraProject == const $CopyWithPlaceholder()
          ? _value.jiraProject
          // ignore: cast_nullable_to_non_nullable
          : jiraProject as String,
      planeProject: planeProject == const $CopyWithPlaceholder()
          ? _value.planeProject
          // ignore: cast_nullable_to_non_nullable
          : planeProject as String?,
      claudeMd: claudeMd == const $CopyWithPlaceholder()
          ? _value.claudeMd
          // ignore: cast_nullable_to_non_nullable
          : claudeMd as RepositoryClaudeMdEnum,
      openTickets: openTickets == const $CopyWithPlaceholder()
          ? _value.openTickets
          // ignore: cast_nullable_to_non_nullable
          : openTickets as int,
      deployWorkflow: deployWorkflow == const $CopyWithPlaceholder()
          ? _value.deployWorkflow
          // ignore: cast_nullable_to_non_nullable
          : deployWorkflow as String?,
      archivedAt: archivedAt == const $CopyWithPlaceholder()
          ? _value.archivedAt
          // ignore: cast_nullable_to_non_nullable
          : archivedAt as DateTime?,
      preview: preview == const $CopyWithPlaceholder()
          ? _value.preview
          // ignore: cast_nullable_to_non_nullable
          : preview as RepoPreview?,
      stack: stack == const $CopyWithPlaceholder()
          ? _value.stack
          // ignore: cast_nullable_to_non_nullable
          : stack as String?,
      toolchains: toolchains == const $CopyWithPlaceholder()
          ? _value.toolchains
          // ignore: cast_nullable_to_non_nullable
          : toolchains as List<Toolchain>?,
      toolchainsOverride: toolchainsOverride == const $CopyWithPlaceholder()
          ? _value.toolchainsOverride
          // ignore: cast_nullable_to_non_nullable
          : toolchainsOverride as bool?,
      toolchainsDetectedAt: toolchainsDetectedAt == const $CopyWithPlaceholder()
          ? _value.toolchainsDetectedAt
          // ignore: cast_nullable_to_non_nullable
          : toolchainsDetectedAt as DateTime?,
      toolchainNotes: toolchainNotes == const $CopyWithPlaceholder()
          ? _value.toolchainNotes
          // ignore: cast_nullable_to_non_nullable
          : toolchainNotes as List<String>?,
      runnerImage: runnerImage == const $CopyWithPlaceholder()
          ? _value.runnerImage
          // ignore: cast_nullable_to_non_nullable
          : runnerImage as String?,
      memoryMb: memoryMb == const $CopyWithPlaceholder()
          ? _value.memoryMb
          // ignore: cast_nullable_to_non_nullable
          : memoryMb as int?,
      buildEnvSet: buildEnvSet == const $CopyWithPlaceholder()
          ? _value.buildEnvSet
          // ignore: cast_nullable_to_non_nullable
          : buildEnvSet as bool?,
      buildEnvNames: buildEnvNames == const $CopyWithPlaceholder()
          ? _value.buildEnvNames
          // ignore: cast_nullable_to_non_nullable
          : buildEnvNames as List<String>?,
      harness: harness == const $CopyWithPlaceholder()
          ? _value.harness
          // ignore: cast_nullable_to_non_nullable
          : harness as RepoHarness?,
    );
  }
}

extension $RepositoryCopyWith on Repository {
  /// Returns a callable class that can be used as follows: `instanceOfRepository.copyWith(...)` or like so:`instanceOfRepository.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RepositoryCWProxy get copyWith => _$RepositoryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Repository _$RepositoryFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Repository',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'name',
        'kind',
        'provider',
        'cloneUrl',
        'defaultBranch',
        'buildCmd',
        'lintCmd',
        'testCmd',
        'branchPrefix',
        'taskPrefix',
        'instructions',
        'jiraProject',
        'claudeMd',
        'openTickets',
      ],
    );
    final val = Repository(
      id: $checkedConvert('id', (v) => (v as num).toInt()),
      name: $checkedConvert('name', (v) => v as String),
      kind: $checkedConvert(
        'kind',
        (v) => $enumDecode(_$RepositoryKindEnumEnumMap, v),
      ),
      provider: $checkedConvert(
        'provider',
        (v) => $enumDecode(_$RepositoryProviderEnumEnumMap, v),
      ),
      cloneUrl: $checkedConvert('cloneUrl', (v) => v as String),
      defaultBranch: $checkedConvert('defaultBranch', (v) => v as String),
      buildCmd: $checkedConvert('buildCmd', (v) => v as String),
      lintCmd: $checkedConvert('lintCmd', (v) => v as String),
      testCmd: $checkedConvert('testCmd', (v) => v as String),
      branchPrefix: $checkedConvert('branchPrefix', (v) => v as String),
      taskPrefix: $checkedConvert('taskPrefix', (v) => v as String),
      instructions: $checkedConvert('instructions', (v) => v as String),
      jiraProject: $checkedConvert('jiraProject', (v) => v as String),
      planeProject: $checkedConvert('planeProject', (v) => v as String?),
      claudeMd: $checkedConvert(
        'claudeMd',
        (v) => $enumDecode(_$RepositoryClaudeMdEnumEnumMap, v),
      ),
      openTickets: $checkedConvert('openTickets', (v) => (v as num).toInt()),
      deployWorkflow: $checkedConvert('deployWorkflow', (v) => v as String?),
      archivedAt: $checkedConvert(
        'archivedAt',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      preview: $checkedConvert(
        'preview',
        (v) =>
            v == null ? null : RepoPreview.fromJson(v as Map<String, dynamic>),
      ),
      stack: $checkedConvert('stack', (v) => v as String?),
      toolchains: $checkedConvert(
        'toolchains',
        (v) => (v as List<dynamic>?)
            ?.map((e) => Toolchain.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      toolchainsOverride: $checkedConvert(
        'toolchainsOverride',
        (v) => v as bool?,
      ),
      toolchainsDetectedAt: $checkedConvert(
        'toolchainsDetectedAt',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      toolchainNotes: $checkedConvert(
        'toolchainNotes',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      runnerImage: $checkedConvert('runnerImage', (v) => v as String?),
      memoryMb: $checkedConvert('memoryMb', (v) => (v as num?)?.toInt()),
      buildEnvSet: $checkedConvert('buildEnvSet', (v) => v as bool?),
      buildEnvNames: $checkedConvert(
        'buildEnvNames',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      harness: $checkedConvert(
        'harness',
        (v) =>
            v == null ? null : RepoHarness.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
);

Map<String, dynamic> _$RepositoryToJson(Repository instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'kind': _$RepositoryKindEnumEnumMap[instance.kind]!,
      'provider': _$RepositoryProviderEnumEnumMap[instance.provider]!,
      'cloneUrl': instance.cloneUrl,
      'defaultBranch': instance.defaultBranch,
      'buildCmd': instance.buildCmd,
      'lintCmd': instance.lintCmd,
      'testCmd': instance.testCmd,
      'branchPrefix': instance.branchPrefix,
      'taskPrefix': instance.taskPrefix,
      'instructions': instance.instructions,
      'jiraProject': instance.jiraProject,
      'planeProject': ?instance.planeProject,
      'claudeMd': _$RepositoryClaudeMdEnumEnumMap[instance.claudeMd]!,
      'openTickets': instance.openTickets,
      'deployWorkflow': ?instance.deployWorkflow,
      'archivedAt': ?instance.archivedAt?.toIso8601String(),
      'preview': ?instance.preview?.toJson(),
      'stack': ?instance.stack,
      'toolchains': ?instance.toolchains?.map((e) => e.toJson()).toList(),
      'toolchainsOverride': ?instance.toolchainsOverride,
      'toolchainsDetectedAt': ?instance.toolchainsDetectedAt?.toIso8601String(),
      'toolchainNotes': ?instance.toolchainNotes,
      'runnerImage': ?instance.runnerImage,
      'memoryMb': ?instance.memoryMb,
      'buildEnvSet': ?instance.buildEnvSet,
      'buildEnvNames': ?instance.buildEnvNames,
      'harness': ?instance.harness?.toJson(),
    };

const _$RepositoryKindEnumEnumMap = {
  RepositoryKindEnum.jira: 'jira',
  RepositoryKindEnum.plane: 'plane',
  RepositoryKindEnum.side: 'side',
};

const _$RepositoryProviderEnumEnumMap = {
  RepositoryProviderEnum.github: 'github',
  RepositoryProviderEnum.gitlab: 'gitlab',
};

const _$RepositoryClaudeMdEnumEnumMap = {
  RepositoryClaudeMdEnum.found: 'found',
  RepositoryClaudeMdEnum.missing: 'missing',
  RepositoryClaudeMdEnum.unknown: 'unknown',
};

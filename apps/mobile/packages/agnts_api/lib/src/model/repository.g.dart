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

  Repository claudeMd(RepositoryClaudeMdEnum claudeMd);

  Repository openTickets(int openTickets);

  Repository deployWorkflow(String? deployWorkflow);

  Repository archivedAt(DateTime? archivedAt);

  Repository preview(RepoPreview? preview);

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
    RepositoryClaudeMdEnum claudeMd,
    int openTickets,
    String? deployWorkflow,
    DateTime? archivedAt,
    RepoPreview? preview,
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
    Object? claudeMd = const $CopyWithPlaceholder(),
    Object? openTickets = const $CopyWithPlaceholder(),
    Object? deployWorkflow = const $CopyWithPlaceholder(),
    Object? archivedAt = const $CopyWithPlaceholder(),
    Object? preview = const $CopyWithPlaceholder(),
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
      'claudeMd': _$RepositoryClaudeMdEnumEnumMap[instance.claudeMd]!,
      'openTickets': instance.openTickets,
      'deployWorkflow': ?instance.deployWorkflow,
      'archivedAt': ?instance.archivedAt?.toIso8601String(),
      'preview': ?instance.preview?.toJson(),
    };

const _$RepositoryKindEnumEnumMap = {
  RepositoryKindEnum.jira: 'jira',
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

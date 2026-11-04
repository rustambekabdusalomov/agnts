// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RepositoryInputCWProxy {
  RepositoryInput name(String name);

  RepositoryInput kind(RepositoryInputKindEnum? kind);

  RepositoryInput cloneUrl(String cloneUrl);

  RepositoryInput defaultBranch(String? defaultBranch);

  RepositoryInput buildCmd(String? buildCmd);

  RepositoryInput lintCmd(String? lintCmd);

  RepositoryInput testCmd(String? testCmd);

  RepositoryInput branchPrefix(String? branchPrefix);

  RepositoryInput branchTemplate(String? branchTemplate);

  RepositoryInput commitTemplate(String? commitTemplate);

  RepositoryInput prTemplate(String? prTemplate);

  RepositoryInput taskPrefix(String? taskPrefix);

  RepositoryInput instructions(String? instructions);

  RepositoryInput jiraProject(String? jiraProject);

  RepositoryInput planeProject(String? planeProject);

  RepositoryInput deployWorkflow(String? deployWorkflow);

  RepositoryInput preview(RepoPreviewInput? preview);

  RepositoryInput toolchains(List<Toolchain>? toolchains);

  RepositoryInput toolchainsOverride(bool? toolchainsOverride);

  RepositoryInput runnerImage(String? runnerImage);

  RepositoryInput memoryMb(int? memoryMb);

  RepositoryInput buildEnv(String? buildEnv);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepositoryInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepositoryInput(...).copyWith(id: 12, name: "My name")
  /// ````
  RepositoryInput call({
    String name,
    RepositoryInputKindEnum? kind,
    String cloneUrl,
    String? defaultBranch,
    String? buildCmd,
    String? lintCmd,
    String? testCmd,
    String? branchPrefix,
    String? branchTemplate,
    String? commitTemplate,
    String? prTemplate,
    String? taskPrefix,
    String? instructions,
    String? jiraProject,
    String? planeProject,
    String? deployWorkflow,
    RepoPreviewInput? preview,
    List<Toolchain>? toolchains,
    bool? toolchainsOverride,
    String? runnerImage,
    int? memoryMb,
    String? buildEnv,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRepositoryInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRepositoryInput.copyWith.fieldName(...)`
class _$RepositoryInputCWProxyImpl implements _$RepositoryInputCWProxy {
  const _$RepositoryInputCWProxyImpl(this._value);

  final RepositoryInput _value;

  @override
  RepositoryInput name(String name) => this(name: name);

  @override
  RepositoryInput kind(RepositoryInputKindEnum? kind) => this(kind: kind);

  @override
  RepositoryInput cloneUrl(String cloneUrl) => this(cloneUrl: cloneUrl);

  @override
  RepositoryInput defaultBranch(String? defaultBranch) =>
      this(defaultBranch: defaultBranch);

  @override
  RepositoryInput buildCmd(String? buildCmd) => this(buildCmd: buildCmd);

  @override
  RepositoryInput lintCmd(String? lintCmd) => this(lintCmd: lintCmd);

  @override
  RepositoryInput testCmd(String? testCmd) => this(testCmd: testCmd);

  @override
  RepositoryInput branchPrefix(String? branchPrefix) =>
      this(branchPrefix: branchPrefix);

  @override
  RepositoryInput branchTemplate(String? branchTemplate) =>
      this(branchTemplate: branchTemplate);

  @override
  RepositoryInput commitTemplate(String? commitTemplate) =>
      this(commitTemplate: commitTemplate);

  @override
  RepositoryInput prTemplate(String? prTemplate) =>
      this(prTemplate: prTemplate);

  @override
  RepositoryInput taskPrefix(String? taskPrefix) =>
      this(taskPrefix: taskPrefix);

  @override
  RepositoryInput instructions(String? instructions) =>
      this(instructions: instructions);

  @override
  RepositoryInput jiraProject(String? jiraProject) =>
      this(jiraProject: jiraProject);

  @override
  RepositoryInput planeProject(String? planeProject) =>
      this(planeProject: planeProject);

  @override
  RepositoryInput deployWorkflow(String? deployWorkflow) =>
      this(deployWorkflow: deployWorkflow);

  @override
  RepositoryInput preview(RepoPreviewInput? preview) => this(preview: preview);

  @override
  RepositoryInput toolchains(List<Toolchain>? toolchains) =>
      this(toolchains: toolchains);

  @override
  RepositoryInput toolchainsOverride(bool? toolchainsOverride) =>
      this(toolchainsOverride: toolchainsOverride);

  @override
  RepositoryInput runnerImage(String? runnerImage) =>
      this(runnerImage: runnerImage);

  @override
  RepositoryInput memoryMb(int? memoryMb) => this(memoryMb: memoryMb);

  @override
  RepositoryInput buildEnv(String? buildEnv) => this(buildEnv: buildEnv);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepositoryInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepositoryInput(...).copyWith(id: 12, name: "My name")
  /// ````
  RepositoryInput call({
    Object? name = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? cloneUrl = const $CopyWithPlaceholder(),
    Object? defaultBranch = const $CopyWithPlaceholder(),
    Object? buildCmd = const $CopyWithPlaceholder(),
    Object? lintCmd = const $CopyWithPlaceholder(),
    Object? testCmd = const $CopyWithPlaceholder(),
    Object? branchPrefix = const $CopyWithPlaceholder(),
    Object? branchTemplate = const $CopyWithPlaceholder(),
    Object? commitTemplate = const $CopyWithPlaceholder(),
    Object? prTemplate = const $CopyWithPlaceholder(),
    Object? taskPrefix = const $CopyWithPlaceholder(),
    Object? instructions = const $CopyWithPlaceholder(),
    Object? jiraProject = const $CopyWithPlaceholder(),
    Object? planeProject = const $CopyWithPlaceholder(),
    Object? deployWorkflow = const $CopyWithPlaceholder(),
    Object? preview = const $CopyWithPlaceholder(),
    Object? toolchains = const $CopyWithPlaceholder(),
    Object? toolchainsOverride = const $CopyWithPlaceholder(),
    Object? runnerImage = const $CopyWithPlaceholder(),
    Object? memoryMb = const $CopyWithPlaceholder(),
    Object? buildEnv = const $CopyWithPlaceholder(),
  }) {
    return RepositoryInput(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as RepositoryInputKindEnum?,
      cloneUrl: cloneUrl == const $CopyWithPlaceholder()
          ? _value.cloneUrl
          // ignore: cast_nullable_to_non_nullable
          : cloneUrl as String,
      defaultBranch: defaultBranch == const $CopyWithPlaceholder()
          ? _value.defaultBranch
          // ignore: cast_nullable_to_non_nullable
          : defaultBranch as String?,
      buildCmd: buildCmd == const $CopyWithPlaceholder()
          ? _value.buildCmd
          // ignore: cast_nullable_to_non_nullable
          : buildCmd as String?,
      lintCmd: lintCmd == const $CopyWithPlaceholder()
          ? _value.lintCmd
          // ignore: cast_nullable_to_non_nullable
          : lintCmd as String?,
      testCmd: testCmd == const $CopyWithPlaceholder()
          ? _value.testCmd
          // ignore: cast_nullable_to_non_nullable
          : testCmd as String?,
      branchPrefix: branchPrefix == const $CopyWithPlaceholder()
          ? _value.branchPrefix
          // ignore: cast_nullable_to_non_nullable
          : branchPrefix as String?,
      branchTemplate: branchTemplate == const $CopyWithPlaceholder()
          ? _value.branchTemplate
          // ignore: cast_nullable_to_non_nullable
          : branchTemplate as String?,
      commitTemplate: commitTemplate == const $CopyWithPlaceholder()
          ? _value.commitTemplate
          // ignore: cast_nullable_to_non_nullable
          : commitTemplate as String?,
      prTemplate: prTemplate == const $CopyWithPlaceholder()
          ? _value.prTemplate
          // ignore: cast_nullable_to_non_nullable
          : prTemplate as String?,
      taskPrefix: taskPrefix == const $CopyWithPlaceholder()
          ? _value.taskPrefix
          // ignore: cast_nullable_to_non_nullable
          : taskPrefix as String?,
      instructions: instructions == const $CopyWithPlaceholder()
          ? _value.instructions
          // ignore: cast_nullable_to_non_nullable
          : instructions as String?,
      jiraProject: jiraProject == const $CopyWithPlaceholder()
          ? _value.jiraProject
          // ignore: cast_nullable_to_non_nullable
          : jiraProject as String?,
      planeProject: planeProject == const $CopyWithPlaceholder()
          ? _value.planeProject
          // ignore: cast_nullable_to_non_nullable
          : planeProject as String?,
      deployWorkflow: deployWorkflow == const $CopyWithPlaceholder()
          ? _value.deployWorkflow
          // ignore: cast_nullable_to_non_nullable
          : deployWorkflow as String?,
      preview: preview == const $CopyWithPlaceholder()
          ? _value.preview
          // ignore: cast_nullable_to_non_nullable
          : preview as RepoPreviewInput?,
      toolchains: toolchains == const $CopyWithPlaceholder()
          ? _value.toolchains
          // ignore: cast_nullable_to_non_nullable
          : toolchains as List<Toolchain>?,
      toolchainsOverride: toolchainsOverride == const $CopyWithPlaceholder()
          ? _value.toolchainsOverride
          // ignore: cast_nullable_to_non_nullable
          : toolchainsOverride as bool?,
      runnerImage: runnerImage == const $CopyWithPlaceholder()
          ? _value.runnerImage
          // ignore: cast_nullable_to_non_nullable
          : runnerImage as String?,
      memoryMb: memoryMb == const $CopyWithPlaceholder()
          ? _value.memoryMb
          // ignore: cast_nullable_to_non_nullable
          : memoryMb as int?,
      buildEnv: buildEnv == const $CopyWithPlaceholder()
          ? _value.buildEnv
          // ignore: cast_nullable_to_non_nullable
          : buildEnv as String?,
    );
  }
}

extension $RepositoryInputCopyWith on RepositoryInput {
  /// Returns a callable class that can be used as follows: `instanceOfRepositoryInput.copyWith(...)` or like so:`instanceOfRepositoryInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RepositoryInputCWProxy get copyWith => _$RepositoryInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepositoryInput _$RepositoryInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RepositoryInput', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['name', 'cloneUrl']);
      final val = RepositoryInput(
        name: $checkedConvert('name', (v) => v as String),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecodeNullable(_$RepositoryInputKindEnumEnumMap, v),
        ),
        cloneUrl: $checkedConvert('cloneUrl', (v) => v as String),
        defaultBranch: $checkedConvert('defaultBranch', (v) => v as String?),
        buildCmd: $checkedConvert('buildCmd', (v) => v as String?),
        lintCmd: $checkedConvert('lintCmd', (v) => v as String?),
        testCmd: $checkedConvert('testCmd', (v) => v as String?),
        branchPrefix: $checkedConvert('branchPrefix', (v) => v as String?),
        branchTemplate: $checkedConvert('branchTemplate', (v) => v as String?),
        commitTemplate: $checkedConvert('commitTemplate', (v) => v as String?),
        prTemplate: $checkedConvert('prTemplate', (v) => v as String?),
        taskPrefix: $checkedConvert('taskPrefix', (v) => v as String?),
        instructions: $checkedConvert('instructions', (v) => v as String?),
        jiraProject: $checkedConvert('jiraProject', (v) => v as String?),
        planeProject: $checkedConvert('planeProject', (v) => v as String?),
        deployWorkflow: $checkedConvert('deployWorkflow', (v) => v as String?),
        preview: $checkedConvert(
          'preview',
          (v) => v == null
              ? null
              : RepoPreviewInput.fromJson(v as Map<String, dynamic>),
        ),
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
        runnerImage: $checkedConvert('runnerImage', (v) => v as String?),
        memoryMb: $checkedConvert('memoryMb', (v) => (v as num?)?.toInt()),
        buildEnv: $checkedConvert('buildEnv', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$RepositoryInputToJson(RepositoryInput instance) =>
    <String, dynamic>{
      'name': instance.name,
      'kind': ?_$RepositoryInputKindEnumEnumMap[instance.kind],
      'cloneUrl': instance.cloneUrl,
      'defaultBranch': ?instance.defaultBranch,
      'buildCmd': ?instance.buildCmd,
      'lintCmd': ?instance.lintCmd,
      'testCmd': ?instance.testCmd,
      'branchPrefix': ?instance.branchPrefix,
      'branchTemplate': ?instance.branchTemplate,
      'commitTemplate': ?instance.commitTemplate,
      'prTemplate': ?instance.prTemplate,
      'taskPrefix': ?instance.taskPrefix,
      'instructions': ?instance.instructions,
      'jiraProject': ?instance.jiraProject,
      'planeProject': ?instance.planeProject,
      'deployWorkflow': ?instance.deployWorkflow,
      'preview': ?instance.preview?.toJson(),
      'toolchains': ?instance.toolchains?.map((e) => e.toJson()).toList(),
      'toolchainsOverride': ?instance.toolchainsOverride,
      'runnerImage': ?instance.runnerImage,
      'memoryMb': ?instance.memoryMb,
      'buildEnv': ?instance.buildEnv,
    };

const _$RepositoryInputKindEnumEnumMap = {
  RepositoryInputKindEnum.jira: 'jira',
  RepositoryInputKindEnum.plane: 'plane',
  RepositoryInputKindEnum.side: 'side',
};

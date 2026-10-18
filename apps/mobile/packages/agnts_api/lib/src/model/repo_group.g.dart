// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_group.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RepoGroupCWProxy {
  RepoGroup id(int id);

  RepoGroup name(String name);

  RepoGroup description(String description);

  RepoGroup instructions(String instructions);

  RepoGroup taskPrefix(String taskPrefix);

  RepoGroup branchTemplate(String branchTemplate);

  RepoGroup commitTemplate(String commitTemplate);

  RepoGroup members(List<RepoGroupMember> members);

  RepoGroup warnings(List<String> warnings);

  RepoGroup createdAt(DateTime createdAt);

  RepoGroup updatedAt(DateTime updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoGroup(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoGroup(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoGroup call({
    int id,
    String name,
    String description,
    String instructions,
    String taskPrefix,
    String branchTemplate,
    String commitTemplate,
    List<RepoGroupMember> members,
    List<String> warnings,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRepoGroup.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRepoGroup.copyWith.fieldName(...)`
class _$RepoGroupCWProxyImpl implements _$RepoGroupCWProxy {
  const _$RepoGroupCWProxyImpl(this._value);

  final RepoGroup _value;

  @override
  RepoGroup id(int id) => this(id: id);

  @override
  RepoGroup name(String name) => this(name: name);

  @override
  RepoGroup description(String description) => this(description: description);

  @override
  RepoGroup instructions(String instructions) =>
      this(instructions: instructions);

  @override
  RepoGroup taskPrefix(String taskPrefix) => this(taskPrefix: taskPrefix);

  @override
  RepoGroup branchTemplate(String branchTemplate) =>
      this(branchTemplate: branchTemplate);

  @override
  RepoGroup commitTemplate(String commitTemplate) =>
      this(commitTemplate: commitTemplate);

  @override
  RepoGroup members(List<RepoGroupMember> members) => this(members: members);

  @override
  RepoGroup warnings(List<String> warnings) => this(warnings: warnings);

  @override
  RepoGroup createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  RepoGroup updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoGroup(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoGroup(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoGroup call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? instructions = const $CopyWithPlaceholder(),
    Object? taskPrefix = const $CopyWithPlaceholder(),
    Object? branchTemplate = const $CopyWithPlaceholder(),
    Object? commitTemplate = const $CopyWithPlaceholder(),
    Object? members = const $CopyWithPlaceholder(),
    Object? warnings = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return RepoGroup(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String,
      instructions: instructions == const $CopyWithPlaceholder()
          ? _value.instructions
          // ignore: cast_nullable_to_non_nullable
          : instructions as String,
      taskPrefix: taskPrefix == const $CopyWithPlaceholder()
          ? _value.taskPrefix
          // ignore: cast_nullable_to_non_nullable
          : taskPrefix as String,
      branchTemplate: branchTemplate == const $CopyWithPlaceholder()
          ? _value.branchTemplate
          // ignore: cast_nullable_to_non_nullable
          : branchTemplate as String,
      commitTemplate: commitTemplate == const $CopyWithPlaceholder()
          ? _value.commitTemplate
          // ignore: cast_nullable_to_non_nullable
          : commitTemplate as String,
      members: members == const $CopyWithPlaceholder()
          ? _value.members
          // ignore: cast_nullable_to_non_nullable
          : members as List<RepoGroupMember>,
      warnings: warnings == const $CopyWithPlaceholder()
          ? _value.warnings
          // ignore: cast_nullable_to_non_nullable
          : warnings as List<String>,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
    );
  }
}

extension $RepoGroupCopyWith on RepoGroup {
  /// Returns a callable class that can be used as follows: `instanceOfRepoGroup.copyWith(...)` or like so:`instanceOfRepoGroup.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RepoGroupCWProxy get copyWith => _$RepoGroupCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepoGroup _$RepoGroupFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RepoGroup', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'name',
      'description',
      'instructions',
      'taskPrefix',
      'branchTemplate',
      'commitTemplate',
      'members',
      'warnings',
      'createdAt',
      'updatedAt',
    ],
  );
  final val = RepoGroup(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    name: $checkedConvert('name', (v) => v as String),
    description: $checkedConvert('description', (v) => v as String),
    instructions: $checkedConvert('instructions', (v) => v as String),
    taskPrefix: $checkedConvert('taskPrefix', (v) => v as String),
    branchTemplate: $checkedConvert('branchTemplate', (v) => v as String),
    commitTemplate: $checkedConvert('commitTemplate', (v) => v as String),
    members: $checkedConvert(
      'members',
      (v) => (v as List<dynamic>)
          .map((e) => RepoGroupMember.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    warnings: $checkedConvert(
      'warnings',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$RepoGroupToJson(RepoGroup instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'instructions': instance.instructions,
  'taskPrefix': instance.taskPrefix,
  'branchTemplate': instance.branchTemplate,
  'commitTemplate': instance.commitTemplate,
  'members': instance.members.map((e) => e.toJson()).toList(),
  'warnings': instance.warnings,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

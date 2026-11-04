// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_group_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RepoGroupInputCWProxy {
  RepoGroupInput name(String name);

  RepoGroupInput description(String? description);

  RepoGroupInput instructions(String? instructions);

  RepoGroupInput taskPrefix(String? taskPrefix);

  RepoGroupInput branchTemplate(String? branchTemplate);

  RepoGroupInput commitTemplate(String? commitTemplate);

  RepoGroupInput prTemplate(String? prTemplate);

  RepoGroupInput members(List<RepoGroupInputMembersInner> members);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoGroupInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoGroupInput(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoGroupInput call({
    String name,
    String? description,
    String? instructions,
    String? taskPrefix,
    String? branchTemplate,
    String? commitTemplate,
    String? prTemplate,
    List<RepoGroupInputMembersInner> members,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRepoGroupInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRepoGroupInput.copyWith.fieldName(...)`
class _$RepoGroupInputCWProxyImpl implements _$RepoGroupInputCWProxy {
  const _$RepoGroupInputCWProxyImpl(this._value);

  final RepoGroupInput _value;

  @override
  RepoGroupInput name(String name) => this(name: name);

  @override
  RepoGroupInput description(String? description) =>
      this(description: description);

  @override
  RepoGroupInput instructions(String? instructions) =>
      this(instructions: instructions);

  @override
  RepoGroupInput taskPrefix(String? taskPrefix) => this(taskPrefix: taskPrefix);

  @override
  RepoGroupInput branchTemplate(String? branchTemplate) =>
      this(branchTemplate: branchTemplate);

  @override
  RepoGroupInput commitTemplate(String? commitTemplate) =>
      this(commitTemplate: commitTemplate);

  @override
  RepoGroupInput prTemplate(String? prTemplate) => this(prTemplate: prTemplate);

  @override
  RepoGroupInput members(List<RepoGroupInputMembersInner> members) =>
      this(members: members);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoGroupInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoGroupInput(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoGroupInput call({
    Object? name = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? instructions = const $CopyWithPlaceholder(),
    Object? taskPrefix = const $CopyWithPlaceholder(),
    Object? branchTemplate = const $CopyWithPlaceholder(),
    Object? commitTemplate = const $CopyWithPlaceholder(),
    Object? prTemplate = const $CopyWithPlaceholder(),
    Object? members = const $CopyWithPlaceholder(),
  }) {
    return RepoGroupInput(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      instructions: instructions == const $CopyWithPlaceholder()
          ? _value.instructions
          // ignore: cast_nullable_to_non_nullable
          : instructions as String?,
      taskPrefix: taskPrefix == const $CopyWithPlaceholder()
          ? _value.taskPrefix
          // ignore: cast_nullable_to_non_nullable
          : taskPrefix as String?,
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
      members: members == const $CopyWithPlaceholder()
          ? _value.members
          // ignore: cast_nullable_to_non_nullable
          : members as List<RepoGroupInputMembersInner>,
    );
  }
}

extension $RepoGroupInputCopyWith on RepoGroupInput {
  /// Returns a callable class that can be used as follows: `instanceOfRepoGroupInput.copyWith(...)` or like so:`instanceOfRepoGroupInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RepoGroupInputCWProxy get copyWith => _$RepoGroupInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepoGroupInput _$RepoGroupInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RepoGroupInput', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['name', 'members']);
      final val = RepoGroupInput(
        name: $checkedConvert('name', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String?),
        instructions: $checkedConvert('instructions', (v) => v as String?),
        taskPrefix: $checkedConvert('taskPrefix', (v) => v as String?),
        branchTemplate: $checkedConvert('branchTemplate', (v) => v as String?),
        commitTemplate: $checkedConvert('commitTemplate', (v) => v as String?),
        prTemplate: $checkedConvert('prTemplate', (v) => v as String?),
        members: $checkedConvert(
          'members',
          (v) => (v as List<dynamic>)
              .map(
                (e) => RepoGroupInputMembersInner.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$RepoGroupInputToJson(RepoGroupInput instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': ?instance.description,
      'instructions': ?instance.instructions,
      'taskPrefix': ?instance.taskPrefix,
      'branchTemplate': ?instance.branchTemplate,
      'commitTemplate': ?instance.commitTemplate,
      'prTemplate': ?instance.prTemplate,
      'members': instance.members.map((e) => e.toJson()).toList(),
    };

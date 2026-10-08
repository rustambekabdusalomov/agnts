// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkspaceSummaryCWProxy {
  WorkspaceSummary id(int id);

  WorkspaceSummary slug(String slug);

  WorkspaceSummary name(String name);

  WorkspaceSummary role(WorkspaceRole role);

  WorkspaceSummary members(int members);

  WorkspaceSummary plan(String plan);

  WorkspaceSummary slots(int slots);

  WorkspaceSummary suspended(bool? suspended);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkspaceSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkspaceSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkspaceSummary call({
    int id,
    String slug,
    String name,
    WorkspaceRole role,
    int members,
    String plan,
    int slots,
    bool? suspended,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkspaceSummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkspaceSummary.copyWith.fieldName(...)`
class _$WorkspaceSummaryCWProxyImpl implements _$WorkspaceSummaryCWProxy {
  const _$WorkspaceSummaryCWProxyImpl(this._value);

  final WorkspaceSummary _value;

  @override
  WorkspaceSummary id(int id) => this(id: id);

  @override
  WorkspaceSummary slug(String slug) => this(slug: slug);

  @override
  WorkspaceSummary name(String name) => this(name: name);

  @override
  WorkspaceSummary role(WorkspaceRole role) => this(role: role);

  @override
  WorkspaceSummary members(int members) => this(members: members);

  @override
  WorkspaceSummary plan(String plan) => this(plan: plan);

  @override
  WorkspaceSummary slots(int slots) => this(slots: slots);

  @override
  WorkspaceSummary suspended(bool? suspended) => this(suspended: suspended);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkspaceSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkspaceSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkspaceSummary call({
    Object? id = const $CopyWithPlaceholder(),
    Object? slug = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? members = const $CopyWithPlaceholder(),
    Object? plan = const $CopyWithPlaceholder(),
    Object? slots = const $CopyWithPlaceholder(),
    Object? suspended = const $CopyWithPlaceholder(),
  }) {
    return WorkspaceSummary(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      slug: slug == const $CopyWithPlaceholder()
          ? _value.slug
          // ignore: cast_nullable_to_non_nullable
          : slug as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as WorkspaceRole,
      members: members == const $CopyWithPlaceholder()
          ? _value.members
          // ignore: cast_nullable_to_non_nullable
          : members as int,
      plan: plan == const $CopyWithPlaceholder()
          ? _value.plan
          // ignore: cast_nullable_to_non_nullable
          : plan as String,
      slots: slots == const $CopyWithPlaceholder()
          ? _value.slots
          // ignore: cast_nullable_to_non_nullable
          : slots as int,
      suspended: suspended == const $CopyWithPlaceholder()
          ? _value.suspended
          // ignore: cast_nullable_to_non_nullable
          : suspended as bool?,
    );
  }
}

extension $WorkspaceSummaryCopyWith on WorkspaceSummary {
  /// Returns a callable class that can be used as follows: `instanceOfWorkspaceSummary.copyWith(...)` or like so:`instanceOfWorkspaceSummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkspaceSummaryCWProxy get copyWith => _$WorkspaceSummaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkspaceSummary _$WorkspaceSummaryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WorkspaceSummary', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'slug',
          'name',
          'role',
          'members',
          'plan',
          'slots',
        ],
      );
      final val = WorkspaceSummary(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        slug: $checkedConvert('slug', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        role: $checkedConvert(
          'role',
          (v) => $enumDecode(_$WorkspaceRoleEnumMap, v),
        ),
        members: $checkedConvert('members', (v) => (v as num).toInt()),
        plan: $checkedConvert('plan', (v) => v as String),
        slots: $checkedConvert('slots', (v) => (v as num).toInt()),
        suspended: $checkedConvert('suspended', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$WorkspaceSummaryToJson(WorkspaceSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'name': instance.name,
      'role': _$WorkspaceRoleEnumMap[instance.role]!,
      'members': instance.members,
      'plan': instance.plan,
      'slots': instance.slots,
      'suspended': ?instance.suspended,
    };

const _$WorkspaceRoleEnumMap = {
  WorkspaceRole.owner: 'owner',
  WorkspaceRole.user: 'user',
  WorkspaceRole.viewer: 'viewer',
};

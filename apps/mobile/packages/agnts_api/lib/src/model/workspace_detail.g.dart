// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_detail.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkspaceDetailCWProxy {
  WorkspaceDetail id(int id);

  WorkspaceDetail slug(String slug);

  WorkspaceDetail name(String name);

  WorkspaceDetail role(WorkspaceRole role);

  WorkspaceDetail ownerId(int ownerId);

  WorkspaceDetail plan(String plan);

  WorkspaceDetail slots(int slots);

  WorkspaceDetail memberLimit(int memberLimit);

  WorkspaceDetail members(int members);

  WorkspaceDetail claudeMode(WorkspaceDetailClaudeModeEnum claudeMode);

  WorkspaceDetail claudeFallback(bool claudeFallback);

  WorkspaceDetail defaultMemberId(int? defaultMemberId);

  WorkspaceDetail creditsBalance(int creditsBalance);

  WorkspaceDetail trialEndsAt(DateTime? trialEndsAt);

  WorkspaceDetail suspended(bool? suspended);

  WorkspaceDetail deletedAt(DateTime? deletedAt);

  WorkspaceDetail createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkspaceDetail(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkspaceDetail(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkspaceDetail call({
    int id,
    String slug,
    String name,
    WorkspaceRole role,
    int ownerId,
    String plan,
    int slots,
    int memberLimit,
    int members,
    WorkspaceDetailClaudeModeEnum claudeMode,
    bool claudeFallback,
    int? defaultMemberId,
    int creditsBalance,
    DateTime? trialEndsAt,
    bool? suspended,
    DateTime? deletedAt,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkspaceDetail.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkspaceDetail.copyWith.fieldName(...)`
class _$WorkspaceDetailCWProxyImpl implements _$WorkspaceDetailCWProxy {
  const _$WorkspaceDetailCWProxyImpl(this._value);

  final WorkspaceDetail _value;

  @override
  WorkspaceDetail id(int id) => this(id: id);

  @override
  WorkspaceDetail slug(String slug) => this(slug: slug);

  @override
  WorkspaceDetail name(String name) => this(name: name);

  @override
  WorkspaceDetail role(WorkspaceRole role) => this(role: role);

  @override
  WorkspaceDetail ownerId(int ownerId) => this(ownerId: ownerId);

  @override
  WorkspaceDetail plan(String plan) => this(plan: plan);

  @override
  WorkspaceDetail slots(int slots) => this(slots: slots);

  @override
  WorkspaceDetail memberLimit(int memberLimit) =>
      this(memberLimit: memberLimit);

  @override
  WorkspaceDetail members(int members) => this(members: members);

  @override
  WorkspaceDetail claudeMode(WorkspaceDetailClaudeModeEnum claudeMode) =>
      this(claudeMode: claudeMode);

  @override
  WorkspaceDetail claudeFallback(bool claudeFallback) =>
      this(claudeFallback: claudeFallback);

  @override
  WorkspaceDetail defaultMemberId(int? defaultMemberId) =>
      this(defaultMemberId: defaultMemberId);

  @override
  WorkspaceDetail creditsBalance(int creditsBalance) =>
      this(creditsBalance: creditsBalance);

  @override
  WorkspaceDetail trialEndsAt(DateTime? trialEndsAt) =>
      this(trialEndsAt: trialEndsAt);

  @override
  WorkspaceDetail suspended(bool? suspended) => this(suspended: suspended);

  @override
  WorkspaceDetail deletedAt(DateTime? deletedAt) => this(deletedAt: deletedAt);

  @override
  WorkspaceDetail createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkspaceDetail(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkspaceDetail(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkspaceDetail call({
    Object? id = const $CopyWithPlaceholder(),
    Object? slug = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? ownerId = const $CopyWithPlaceholder(),
    Object? plan = const $CopyWithPlaceholder(),
    Object? slots = const $CopyWithPlaceholder(),
    Object? memberLimit = const $CopyWithPlaceholder(),
    Object? members = const $CopyWithPlaceholder(),
    Object? claudeMode = const $CopyWithPlaceholder(),
    Object? claudeFallback = const $CopyWithPlaceholder(),
    Object? defaultMemberId = const $CopyWithPlaceholder(),
    Object? creditsBalance = const $CopyWithPlaceholder(),
    Object? trialEndsAt = const $CopyWithPlaceholder(),
    Object? suspended = const $CopyWithPlaceholder(),
    Object? deletedAt = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return WorkspaceDetail(
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
      ownerId: ownerId == const $CopyWithPlaceholder()
          ? _value.ownerId
          // ignore: cast_nullable_to_non_nullable
          : ownerId as int,
      plan: plan == const $CopyWithPlaceholder()
          ? _value.plan
          // ignore: cast_nullable_to_non_nullable
          : plan as String,
      slots: slots == const $CopyWithPlaceholder()
          ? _value.slots
          // ignore: cast_nullable_to_non_nullable
          : slots as int,
      memberLimit: memberLimit == const $CopyWithPlaceholder()
          ? _value.memberLimit
          // ignore: cast_nullable_to_non_nullable
          : memberLimit as int,
      members: members == const $CopyWithPlaceholder()
          ? _value.members
          // ignore: cast_nullable_to_non_nullable
          : members as int,
      claudeMode: claudeMode == const $CopyWithPlaceholder()
          ? _value.claudeMode
          // ignore: cast_nullable_to_non_nullable
          : claudeMode as WorkspaceDetailClaudeModeEnum,
      claudeFallback: claudeFallback == const $CopyWithPlaceholder()
          ? _value.claudeFallback
          // ignore: cast_nullable_to_non_nullable
          : claudeFallback as bool,
      defaultMemberId: defaultMemberId == const $CopyWithPlaceholder()
          ? _value.defaultMemberId
          // ignore: cast_nullable_to_non_nullable
          : defaultMemberId as int?,
      creditsBalance: creditsBalance == const $CopyWithPlaceholder()
          ? _value.creditsBalance
          // ignore: cast_nullable_to_non_nullable
          : creditsBalance as int,
      trialEndsAt: trialEndsAt == const $CopyWithPlaceholder()
          ? _value.trialEndsAt
          // ignore: cast_nullable_to_non_nullable
          : trialEndsAt as DateTime?,
      suspended: suspended == const $CopyWithPlaceholder()
          ? _value.suspended
          // ignore: cast_nullable_to_non_nullable
          : suspended as bool?,
      deletedAt: deletedAt == const $CopyWithPlaceholder()
          ? _value.deletedAt
          // ignore: cast_nullable_to_non_nullable
          : deletedAt as DateTime?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $WorkspaceDetailCopyWith on WorkspaceDetail {
  /// Returns a callable class that can be used as follows: `instanceOfWorkspaceDetail.copyWith(...)` or like so:`instanceOfWorkspaceDetail.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkspaceDetailCWProxy get copyWith => _$WorkspaceDetailCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkspaceDetail _$WorkspaceDetailFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WorkspaceDetail', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'slug',
          'name',
          'role',
          'ownerId',
          'plan',
          'slots',
          'memberLimit',
          'members',
          'claudeMode',
          'claudeFallback',
          'creditsBalance',
          'createdAt',
        ],
      );
      final val = WorkspaceDetail(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        slug: $checkedConvert('slug', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        role: $checkedConvert(
          'role',
          (v) => $enumDecode(_$WorkspaceRoleEnumMap, v),
        ),
        ownerId: $checkedConvert('ownerId', (v) => (v as num).toInt()),
        plan: $checkedConvert('plan', (v) => v as String),
        slots: $checkedConvert('slots', (v) => (v as num).toInt()),
        memberLimit: $checkedConvert('memberLimit', (v) => (v as num).toInt()),
        members: $checkedConvert('members', (v) => (v as num).toInt()),
        claudeMode: $checkedConvert(
          'claudeMode',
          (v) => $enumDecode(_$WorkspaceDetailClaudeModeEnumEnumMap, v),
        ),
        claudeFallback: $checkedConvert('claudeFallback', (v) => v as bool),
        defaultMemberId: $checkedConvert(
          'defaultMemberId',
          (v) => (v as num?)?.toInt(),
        ),
        creditsBalance: $checkedConvert(
          'creditsBalance',
          (v) => (v as num).toInt(),
        ),
        trialEndsAt: $checkedConvert(
          'trialEndsAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        suspended: $checkedConvert('suspended', (v) => v as bool?),
        deletedAt: $checkedConvert(
          'deletedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$WorkspaceDetailToJson(
  WorkspaceDetail instance,
) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'name': instance.name,
  'role': _$WorkspaceRoleEnumMap[instance.role]!,
  'ownerId': instance.ownerId,
  'plan': instance.plan,
  'slots': instance.slots,
  'memberLimit': instance.memberLimit,
  'members': instance.members,
  'claudeMode': _$WorkspaceDetailClaudeModeEnumEnumMap[instance.claudeMode]!,
  'claudeFallback': instance.claudeFallback,
  'defaultMemberId': ?instance.defaultMemberId,
  'creditsBalance': instance.creditsBalance,
  'trialEndsAt': ?instance.trialEndsAt?.toIso8601String(),
  'suspended': ?instance.suspended,
  'deletedAt': ?instance.deletedAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$WorkspaceRoleEnumMap = {
  WorkspaceRole.owner: 'owner',
  WorkspaceRole.user: 'user',
  WorkspaceRole.viewer: 'viewer',
};

const _$WorkspaceDetailClaudeModeEnumEnumMap = {
  WorkspaceDetailClaudeModeEnum.shared: 'shared',
  WorkspaceDetailClaudeModeEnum.member: 'member',
};

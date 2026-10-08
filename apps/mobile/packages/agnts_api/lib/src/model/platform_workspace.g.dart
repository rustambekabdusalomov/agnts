// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_workspace.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlatformWorkspaceCWProxy {
  PlatformWorkspace id(int id);

  PlatformWorkspace slug(String slug);

  PlatformWorkspace name(String name);

  PlatformWorkspace owner(String? owner);

  PlatformWorkspace plan(String plan);

  PlatformWorkspace slots(int slots);

  PlatformWorkspace memberLimit(int memberLimit);

  PlatformWorkspace members(int members);

  PlatformWorkspace creditsBalance(int creditsBalance);

  PlatformWorkspace running(int running);

  PlatformWorkspace suspended(bool? suspended);

  PlatformWorkspace deletedAt(DateTime? deletedAt);

  PlatformWorkspace createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlatformWorkspace(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlatformWorkspace(...).copyWith(id: 12, name: "My name")
  /// ````
  PlatformWorkspace call({
    int id,
    String slug,
    String name,
    String? owner,
    String plan,
    int slots,
    int memberLimit,
    int members,
    int creditsBalance,
    int running,
    bool? suspended,
    DateTime? deletedAt,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPlatformWorkspace.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPlatformWorkspace.copyWith.fieldName(...)`
class _$PlatformWorkspaceCWProxyImpl implements _$PlatformWorkspaceCWProxy {
  const _$PlatformWorkspaceCWProxyImpl(this._value);

  final PlatformWorkspace _value;

  @override
  PlatformWorkspace id(int id) => this(id: id);

  @override
  PlatformWorkspace slug(String slug) => this(slug: slug);

  @override
  PlatformWorkspace name(String name) => this(name: name);

  @override
  PlatformWorkspace owner(String? owner) => this(owner: owner);

  @override
  PlatformWorkspace plan(String plan) => this(plan: plan);

  @override
  PlatformWorkspace slots(int slots) => this(slots: slots);

  @override
  PlatformWorkspace memberLimit(int memberLimit) =>
      this(memberLimit: memberLimit);

  @override
  PlatformWorkspace members(int members) => this(members: members);

  @override
  PlatformWorkspace creditsBalance(int creditsBalance) =>
      this(creditsBalance: creditsBalance);

  @override
  PlatformWorkspace running(int running) => this(running: running);

  @override
  PlatformWorkspace suspended(bool? suspended) => this(suspended: suspended);

  @override
  PlatformWorkspace deletedAt(DateTime? deletedAt) =>
      this(deletedAt: deletedAt);

  @override
  PlatformWorkspace createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlatformWorkspace(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlatformWorkspace(...).copyWith(id: 12, name: "My name")
  /// ````
  PlatformWorkspace call({
    Object? id = const $CopyWithPlaceholder(),
    Object? slug = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? owner = const $CopyWithPlaceholder(),
    Object? plan = const $CopyWithPlaceholder(),
    Object? slots = const $CopyWithPlaceholder(),
    Object? memberLimit = const $CopyWithPlaceholder(),
    Object? members = const $CopyWithPlaceholder(),
    Object? creditsBalance = const $CopyWithPlaceholder(),
    Object? running = const $CopyWithPlaceholder(),
    Object? suspended = const $CopyWithPlaceholder(),
    Object? deletedAt = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return PlatformWorkspace(
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
      owner: owner == const $CopyWithPlaceholder()
          ? _value.owner
          // ignore: cast_nullable_to_non_nullable
          : owner as String?,
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
      creditsBalance: creditsBalance == const $CopyWithPlaceholder()
          ? _value.creditsBalance
          // ignore: cast_nullable_to_non_nullable
          : creditsBalance as int,
      running: running == const $CopyWithPlaceholder()
          ? _value.running
          // ignore: cast_nullable_to_non_nullable
          : running as int,
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

extension $PlatformWorkspaceCopyWith on PlatformWorkspace {
  /// Returns a callable class that can be used as follows: `instanceOfPlatformWorkspace.copyWith(...)` or like so:`instanceOfPlatformWorkspace.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlatformWorkspaceCWProxy get copyWith =>
      _$PlatformWorkspaceCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlatformWorkspace _$PlatformWorkspaceFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PlatformWorkspace', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'slug',
          'name',
          'plan',
          'slots',
          'memberLimit',
          'members',
          'creditsBalance',
          'running',
          'createdAt',
        ],
      );
      final val = PlatformWorkspace(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        slug: $checkedConvert('slug', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        owner: $checkedConvert('owner', (v) => v as String?),
        plan: $checkedConvert('plan', (v) => v as String),
        slots: $checkedConvert('slots', (v) => (v as num).toInt()),
        memberLimit: $checkedConvert('memberLimit', (v) => (v as num).toInt()),
        members: $checkedConvert('members', (v) => (v as num).toInt()),
        creditsBalance: $checkedConvert(
          'creditsBalance',
          (v) => (v as num).toInt(),
        ),
        running: $checkedConvert('running', (v) => (v as num).toInt()),
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

Map<String, dynamic> _$PlatformWorkspaceToJson(PlatformWorkspace instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'name': instance.name,
      'owner': ?instance.owner,
      'plan': instance.plan,
      'slots': instance.slots,
      'memberLimit': instance.memberLimit,
      'members': instance.members,
      'creditsBalance': instance.creditsBalance,
      'running': instance.running,
      'suspended': ?instance.suspended,
      'deletedAt': ?instance.deletedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

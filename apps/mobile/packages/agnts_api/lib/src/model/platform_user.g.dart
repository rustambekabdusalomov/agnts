// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_user.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlatformUserCWProxy {
  PlatformUser user(User user);

  PlatformUser hasPassword(bool hasPassword);

  PlatformUser lastSignInAt(DateTime? lastSignInAt);

  PlatformUser workspaces(List<WorkspaceSummary> workspaces);

  PlatformUser freeCredits(FreeCredits? freeCredits);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlatformUser(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlatformUser(...).copyWith(id: 12, name: "My name")
  /// ````
  PlatformUser call({
    User user,
    bool hasPassword,
    DateTime? lastSignInAt,
    List<WorkspaceSummary> workspaces,
    FreeCredits? freeCredits,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPlatformUser.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPlatformUser.copyWith.fieldName(...)`
class _$PlatformUserCWProxyImpl implements _$PlatformUserCWProxy {
  const _$PlatformUserCWProxyImpl(this._value);

  final PlatformUser _value;

  @override
  PlatformUser user(User user) => this(user: user);

  @override
  PlatformUser hasPassword(bool hasPassword) => this(hasPassword: hasPassword);

  @override
  PlatformUser lastSignInAt(DateTime? lastSignInAt) =>
      this(lastSignInAt: lastSignInAt);

  @override
  PlatformUser workspaces(List<WorkspaceSummary> workspaces) =>
      this(workspaces: workspaces);

  @override
  PlatformUser freeCredits(FreeCredits? freeCredits) =>
      this(freeCredits: freeCredits);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlatformUser(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlatformUser(...).copyWith(id: 12, name: "My name")
  /// ````
  PlatformUser call({
    Object? user = const $CopyWithPlaceholder(),
    Object? hasPassword = const $CopyWithPlaceholder(),
    Object? lastSignInAt = const $CopyWithPlaceholder(),
    Object? workspaces = const $CopyWithPlaceholder(),
    Object? freeCredits = const $CopyWithPlaceholder(),
  }) {
    return PlatformUser(
      user: user == const $CopyWithPlaceholder()
          ? _value.user
          // ignore: cast_nullable_to_non_nullable
          : user as User,
      hasPassword: hasPassword == const $CopyWithPlaceholder()
          ? _value.hasPassword
          // ignore: cast_nullable_to_non_nullable
          : hasPassword as bool,
      lastSignInAt: lastSignInAt == const $CopyWithPlaceholder()
          ? _value.lastSignInAt
          // ignore: cast_nullable_to_non_nullable
          : lastSignInAt as DateTime?,
      workspaces: workspaces == const $CopyWithPlaceholder()
          ? _value.workspaces
          // ignore: cast_nullable_to_non_nullable
          : workspaces as List<WorkspaceSummary>,
      freeCredits: freeCredits == const $CopyWithPlaceholder()
          ? _value.freeCredits
          // ignore: cast_nullable_to_non_nullable
          : freeCredits as FreeCredits?,
    );
  }
}

extension $PlatformUserCopyWith on PlatformUser {
  /// Returns a callable class that can be used as follows: `instanceOfPlatformUser.copyWith(...)` or like so:`instanceOfPlatformUser.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlatformUserCWProxy get copyWith => _$PlatformUserCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlatformUser _$PlatformUserFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PlatformUser', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['user', 'hasPassword', 'workspaces']);
  final val = PlatformUser(
    user: $checkedConvert(
      'user',
      (v) => User.fromJson(v as Map<String, dynamic>),
    ),
    hasPassword: $checkedConvert('hasPassword', (v) => v as bool),
    lastSignInAt: $checkedConvert(
      'lastSignInAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    workspaces: $checkedConvert(
      'workspaces',
      (v) => (v as List<dynamic>)
          .map((e) => WorkspaceSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    freeCredits: $checkedConvert(
      'freeCredits',
      (v) => v == null ? null : FreeCredits.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$PlatformUserToJson(PlatformUser instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
      'hasPassword': instance.hasPassword,
      'lastSignInAt': ?instance.lastSignInAt?.toIso8601String(),
      'workspaces': instance.workspaces.map((e) => e.toJson()).toList(),
      'freeCredits': ?instance.freeCredits?.toJson(),
    };

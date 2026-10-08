// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UserCWProxy {
  User id(int id);

  User username(String username);

  User displayName(String? displayName);

  User email(String? email);

  User emailVerified(bool? emailVerified);

  User isAdmin(bool? isAdmin);

  User hasTotp(bool? hasTotp);

  User lastWorkspace(String? lastWorkspace);

  User workspaces(List<WorkspaceSummary>? workspaces);

  User createdAt(DateTime? createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `User(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// User(...).copyWith(id: 12, name: "My name")
  /// ````
  User call({
    int id,
    String username,
    String? displayName,
    String? email,
    bool? emailVerified,
    bool? isAdmin,
    bool? hasTotp,
    String? lastWorkspace,
    List<WorkspaceSummary>? workspaces,
    DateTime? createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUser.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUser.copyWith.fieldName(...)`
class _$UserCWProxyImpl implements _$UserCWProxy {
  const _$UserCWProxyImpl(this._value);

  final User _value;

  @override
  User id(int id) => this(id: id);

  @override
  User username(String username) => this(username: username);

  @override
  User displayName(String? displayName) => this(displayName: displayName);

  @override
  User email(String? email) => this(email: email);

  @override
  User emailVerified(bool? emailVerified) => this(emailVerified: emailVerified);

  @override
  User isAdmin(bool? isAdmin) => this(isAdmin: isAdmin);

  @override
  User hasTotp(bool? hasTotp) => this(hasTotp: hasTotp);

  @override
  User lastWorkspace(String? lastWorkspace) =>
      this(lastWorkspace: lastWorkspace);

  @override
  User workspaces(List<WorkspaceSummary>? workspaces) =>
      this(workspaces: workspaces);

  @override
  User createdAt(DateTime? createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `User(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// User(...).copyWith(id: 12, name: "My name")
  /// ````
  User call({
    Object? id = const $CopyWithPlaceholder(),
    Object? username = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? emailVerified = const $CopyWithPlaceholder(),
    Object? isAdmin = const $CopyWithPlaceholder(),
    Object? hasTotp = const $CopyWithPlaceholder(),
    Object? lastWorkspace = const $CopyWithPlaceholder(),
    Object? workspaces = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return User(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      username: username == const $CopyWithPlaceholder()
          ? _value.username
          // ignore: cast_nullable_to_non_nullable
          : username as String,
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String?,
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String?,
      emailVerified: emailVerified == const $CopyWithPlaceholder()
          ? _value.emailVerified
          // ignore: cast_nullable_to_non_nullable
          : emailVerified as bool?,
      isAdmin: isAdmin == const $CopyWithPlaceholder()
          ? _value.isAdmin
          // ignore: cast_nullable_to_non_nullable
          : isAdmin as bool?,
      hasTotp: hasTotp == const $CopyWithPlaceholder()
          ? _value.hasTotp
          // ignore: cast_nullable_to_non_nullable
          : hasTotp as bool?,
      lastWorkspace: lastWorkspace == const $CopyWithPlaceholder()
          ? _value.lastWorkspace
          // ignore: cast_nullable_to_non_nullable
          : lastWorkspace as String?,
      workspaces: workspaces == const $CopyWithPlaceholder()
          ? _value.workspaces
          // ignore: cast_nullable_to_non_nullable
          : workspaces as List<WorkspaceSummary>?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime?,
    );
  }
}

extension $UserCopyWith on User {
  /// Returns a callable class that can be used as follows: `instanceOfUser.copyWith(...)` or like so:`instanceOfUser.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UserCWProxy get copyWith => _$UserCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) =>
    $checkedCreate('User', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'username']);
      final val = User(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        username: $checkedConvert('username', (v) => v as String),
        displayName: $checkedConvert('displayName', (v) => v as String?),
        email: $checkedConvert('email', (v) => v as String?),
        emailVerified: $checkedConvert('emailVerified', (v) => v as bool?),
        isAdmin: $checkedConvert('isAdmin', (v) => v as bool?),
        hasTotp: $checkedConvert('hasTotp', (v) => v as bool?),
        lastWorkspace: $checkedConvert('lastWorkspace', (v) => v as String?),
        workspaces: $checkedConvert(
          'workspaces',
          (v) => (v as List<dynamic>?)
              ?.map((e) => WorkspaceSummary.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'displayName': ?instance.displayName,
  'email': ?instance.email,
  'emailVerified': ?instance.emailVerified,
  'isAdmin': ?instance.isAdmin,
  'hasTotp': ?instance.hasTotp,
  'lastWorkspace': ?instance.lastWorkspace,
  'workspaces': ?instance.workspaces?.map((e) => e.toJson()).toList(),
  'createdAt': ?instance.createdAt?.toIso8601String(),
};

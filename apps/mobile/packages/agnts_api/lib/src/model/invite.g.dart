// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$InviteCWProxy {
  Invite id(int id);

  Invite email(String email);

  Invite role(WorkspaceRole role);

  Invite invitedBy(String? invitedBy);

  Invite expiresAt(DateTime expiresAt);

  Invite createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Invite(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Invite(...).copyWith(id: 12, name: "My name")
  /// ````
  Invite call({
    int id,
    String email,
    WorkspaceRole role,
    String? invitedBy,
    DateTime expiresAt,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfInvite.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfInvite.copyWith.fieldName(...)`
class _$InviteCWProxyImpl implements _$InviteCWProxy {
  const _$InviteCWProxyImpl(this._value);

  final Invite _value;

  @override
  Invite id(int id) => this(id: id);

  @override
  Invite email(String email) => this(email: email);

  @override
  Invite role(WorkspaceRole role) => this(role: role);

  @override
  Invite invitedBy(String? invitedBy) => this(invitedBy: invitedBy);

  @override
  Invite expiresAt(DateTime expiresAt) => this(expiresAt: expiresAt);

  @override
  Invite createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Invite(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Invite(...).copyWith(id: 12, name: "My name")
  /// ````
  Invite call({
    Object? id = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? invitedBy = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return Invite(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as WorkspaceRole,
      invitedBy: invitedBy == const $CopyWithPlaceholder()
          ? _value.invitedBy
          // ignore: cast_nullable_to_non_nullable
          : invitedBy as String?,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $InviteCopyWith on Invite {
  /// Returns a callable class that can be used as follows: `instanceOfInvite.copyWith(...)` or like so:`instanceOfInvite.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$InviteCWProxy get copyWith => _$InviteCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Invite _$InviteFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('Invite', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'email', 'role', 'expiresAt', 'createdAt'],
  );
  final val = Invite(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    email: $checkedConvert('email', (v) => v as String),
    role: $checkedConvert(
      'role',
      (v) => $enumDecode(_$WorkspaceRoleEnumMap, v),
    ),
    invitedBy: $checkedConvert('invitedBy', (v) => v as String?),
    expiresAt: $checkedConvert('expiresAt', (v) => DateTime.parse(v as String)),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$InviteToJson(Invite instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'role': _$WorkspaceRoleEnumMap[instance.role]!,
  'invitedBy': ?instance.invitedBy,
  'expiresAt': instance.expiresAt.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$WorkspaceRoleEnumMap = {
  WorkspaceRole.owner: 'owner',
  WorkspaceRole.user: 'user',
  WorkspaceRole.viewer: 'viewer',
};

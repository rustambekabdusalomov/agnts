// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MemberCWProxy {
  Member userId(int userId);

  Member username(String username);

  Member displayName(String? displayName);

  Member email(String? email);

  Member role(WorkspaceRole role);

  Member joinedAt(DateTime joinedAt);

  Member claudeConnected(bool claudeConnected);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Member(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Member(...).copyWith(id: 12, name: "My name")
  /// ````
  Member call({
    int userId,
    String username,
    String? displayName,
    String? email,
    WorkspaceRole role,
    DateTime joinedAt,
    bool claudeConnected,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMember.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMember.copyWith.fieldName(...)`
class _$MemberCWProxyImpl implements _$MemberCWProxy {
  const _$MemberCWProxyImpl(this._value);

  final Member _value;

  @override
  Member userId(int userId) => this(userId: userId);

  @override
  Member username(String username) => this(username: username);

  @override
  Member displayName(String? displayName) => this(displayName: displayName);

  @override
  Member email(String? email) => this(email: email);

  @override
  Member role(WorkspaceRole role) => this(role: role);

  @override
  Member joinedAt(DateTime joinedAt) => this(joinedAt: joinedAt);

  @override
  Member claudeConnected(bool claudeConnected) =>
      this(claudeConnected: claudeConnected);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Member(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Member(...).copyWith(id: 12, name: "My name")
  /// ````
  Member call({
    Object? userId = const $CopyWithPlaceholder(),
    Object? username = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? joinedAt = const $CopyWithPlaceholder(),
    Object? claudeConnected = const $CopyWithPlaceholder(),
  }) {
    return Member(
      userId: userId == const $CopyWithPlaceholder()
          ? _value.userId
          // ignore: cast_nullable_to_non_nullable
          : userId as int,
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
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as WorkspaceRole,
      joinedAt: joinedAt == const $CopyWithPlaceholder()
          ? _value.joinedAt
          // ignore: cast_nullable_to_non_nullable
          : joinedAt as DateTime,
      claudeConnected: claudeConnected == const $CopyWithPlaceholder()
          ? _value.claudeConnected
          // ignore: cast_nullable_to_non_nullable
          : claudeConnected as bool,
    );
  }
}

extension $MemberCopyWith on Member {
  /// Returns a callable class that can be used as follows: `instanceOfMember.copyWith(...)` or like so:`instanceOfMember.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MemberCWProxy get copyWith => _$MemberCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Member _$MemberFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Member',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'userId',
        'username',
        'role',
        'joinedAt',
        'claudeConnected',
      ],
    );
    final val = Member(
      userId: $checkedConvert('userId', (v) => (v as num).toInt()),
      username: $checkedConvert('username', (v) => v as String),
      displayName: $checkedConvert('displayName', (v) => v as String?),
      email: $checkedConvert('email', (v) => v as String?),
      role: $checkedConvert(
        'role',
        (v) => $enumDecode(_$WorkspaceRoleEnumMap, v),
      ),
      joinedAt: $checkedConvert('joinedAt', (v) => DateTime.parse(v as String)),
      claudeConnected: $checkedConvert('claudeConnected', (v) => v as bool),
    );
    return val;
  },
);

Map<String, dynamic> _$MemberToJson(Member instance) => <String, dynamic>{
  'userId': instance.userId,
  'username': instance.username,
  'displayName': ?instance.displayName,
  'email': ?instance.email,
  'role': _$WorkspaceRoleEnumMap[instance.role]!,
  'joinedAt': instance.joinedAt.toIso8601String(),
  'claudeConnected': instance.claudeConnected,
};

const _$WorkspaceRoleEnumMap = {
  WorkspaceRole.owner: 'owner',
  WorkspaceRole.user: 'user',
  WorkspaceRole.viewer: 'viewer',
};

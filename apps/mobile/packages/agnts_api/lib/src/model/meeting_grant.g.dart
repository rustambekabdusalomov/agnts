// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_grant.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingGrantCWProxy {
  MeetingGrant url(String url);

  MeetingGrant token(String token);

  MeetingGrant identity(String identity);

  MeetingGrant seat(String? seat);

  MeetingGrant role(MeetingGrantRoleEnum role);

  MeetingGrant rights(MeetingRights rights);

  MeetingGrant sessionId(int sessionId);

  MeetingGrant name(String name);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingGrant(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingGrant(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingGrant call({
    String url,
    String token,
    String identity,
    String? seat,
    MeetingGrantRoleEnum role,
    MeetingRights rights,
    int sessionId,
    String name,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingGrant.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingGrant.copyWith.fieldName(...)`
class _$MeetingGrantCWProxyImpl implements _$MeetingGrantCWProxy {
  const _$MeetingGrantCWProxyImpl(this._value);

  final MeetingGrant _value;

  @override
  MeetingGrant url(String url) => this(url: url);

  @override
  MeetingGrant token(String token) => this(token: token);

  @override
  MeetingGrant identity(String identity) => this(identity: identity);

  @override
  MeetingGrant seat(String? seat) => this(seat: seat);

  @override
  MeetingGrant role(MeetingGrantRoleEnum role) => this(role: role);

  @override
  MeetingGrant rights(MeetingRights rights) => this(rights: rights);

  @override
  MeetingGrant sessionId(int sessionId) => this(sessionId: sessionId);

  @override
  MeetingGrant name(String name) => this(name: name);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingGrant(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingGrant(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingGrant call({
    Object? url = const $CopyWithPlaceholder(),
    Object? token = const $CopyWithPlaceholder(),
    Object? identity = const $CopyWithPlaceholder(),
    Object? seat = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? rights = const $CopyWithPlaceholder(),
    Object? sessionId = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
  }) {
    return MeetingGrant(
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      token: token == const $CopyWithPlaceholder()
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String,
      identity: identity == const $CopyWithPlaceholder()
          ? _value.identity
          // ignore: cast_nullable_to_non_nullable
          : identity as String,
      seat: seat == const $CopyWithPlaceholder()
          ? _value.seat
          // ignore: cast_nullable_to_non_nullable
          : seat as String?,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as MeetingGrantRoleEnum,
      rights: rights == const $CopyWithPlaceholder()
          ? _value.rights
          // ignore: cast_nullable_to_non_nullable
          : rights as MeetingRights,
      sessionId: sessionId == const $CopyWithPlaceholder()
          ? _value.sessionId
          // ignore: cast_nullable_to_non_nullable
          : sessionId as int,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
    );
  }
}

extension $MeetingGrantCopyWith on MeetingGrant {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingGrant.copyWith(...)` or like so:`instanceOfMeetingGrant.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingGrantCWProxy get copyWith => _$MeetingGrantCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingGrant _$MeetingGrantFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MeetingGrant', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'url',
          'token',
          'identity',
          'role',
          'rights',
          'sessionId',
          'name',
        ],
      );
      final val = MeetingGrant(
        url: $checkedConvert('url', (v) => v as String),
        token: $checkedConvert('token', (v) => v as String),
        identity: $checkedConvert('identity', (v) => v as String),
        seat: $checkedConvert('seat', (v) => v as String?),
        role: $checkedConvert(
          'role',
          (v) => $enumDecode(_$MeetingGrantRoleEnumEnumMap, v),
        ),
        rights: $checkedConvert(
          'rights',
          (v) => MeetingRights.fromJson(v as Map<String, dynamic>),
        ),
        sessionId: $checkedConvert('sessionId', (v) => (v as num).toInt()),
        name: $checkedConvert('name', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$MeetingGrantToJson(MeetingGrant instance) =>
    <String, dynamic>{
      'url': instance.url,
      'token': instance.token,
      'identity': instance.identity,
      'seat': ?instance.seat,
      'role': _$MeetingGrantRoleEnumEnumMap[instance.role]!,
      'rights': instance.rights.toJson(),
      'sessionId': instance.sessionId,
      'name': instance.name,
    };

const _$MeetingGrantRoleEnumEnumMap = {
  MeetingGrantRoleEnum.host: 'host',
  MeetingGrantRoleEnum.cohost: 'cohost',
  MeetingGrantRoleEnum.member: 'member',
  MeetingGrantRoleEnum.guest: 'guest',
};

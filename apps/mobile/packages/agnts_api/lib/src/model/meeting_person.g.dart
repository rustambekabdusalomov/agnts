// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_person.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingPersonCWProxy {
  MeetingPerson key(String key);

  MeetingPerson name(String name);

  MeetingPerson role(MeetingPersonRoleEnum role);

  MeetingPerson identities(List<String> identities);

  MeetingPerson email(String? email);

  MeetingPerson knocked(bool knocked);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingPerson(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingPerson(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingPerson call({
    String key,
    String name,
    MeetingPersonRoleEnum role,
    List<String> identities,
    String? email,
    bool knocked,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingPerson.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingPerson.copyWith.fieldName(...)`
class _$MeetingPersonCWProxyImpl implements _$MeetingPersonCWProxy {
  const _$MeetingPersonCWProxyImpl(this._value);

  final MeetingPerson _value;

  @override
  MeetingPerson key(String key) => this(key: key);

  @override
  MeetingPerson name(String name) => this(name: name);

  @override
  MeetingPerson role(MeetingPersonRoleEnum role) => this(role: role);

  @override
  MeetingPerson identities(List<String> identities) =>
      this(identities: identities);

  @override
  MeetingPerson email(String? email) => this(email: email);

  @override
  MeetingPerson knocked(bool knocked) => this(knocked: knocked);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingPerson(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingPerson(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingPerson call({
    Object? key = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? identities = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? knocked = const $CopyWithPlaceholder(),
  }) {
    return MeetingPerson(
      key: key == const $CopyWithPlaceholder()
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as MeetingPersonRoleEnum,
      identities: identities == const $CopyWithPlaceholder()
          ? _value.identities
          // ignore: cast_nullable_to_non_nullable
          : identities as List<String>,
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String?,
      knocked: knocked == const $CopyWithPlaceholder()
          ? _value.knocked
          // ignore: cast_nullable_to_non_nullable
          : knocked as bool,
    );
  }
}

extension $MeetingPersonCopyWith on MeetingPerson {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingPerson.copyWith(...)` or like so:`instanceOfMeetingPerson.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingPersonCWProxy get copyWith => _$MeetingPersonCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingPerson _$MeetingPersonFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MeetingPerson', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['key', 'name', 'role', 'identities', 'knocked'],
      );
      final val = MeetingPerson(
        key: $checkedConvert('key', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        role: $checkedConvert(
          'role',
          (v) => $enumDecode(_$MeetingPersonRoleEnumEnumMap, v),
        ),
        identities: $checkedConvert(
          'identities',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        email: $checkedConvert('email', (v) => v as String?),
        knocked: $checkedConvert('knocked', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$MeetingPersonToJson(MeetingPerson instance) =>
    <String, dynamic>{
      'key': instance.key,
      'name': instance.name,
      'role': _$MeetingPersonRoleEnumEnumMap[instance.role]!,
      'identities': instance.identities,
      'email': ?instance.email,
      'knocked': instance.knocked,
    };

const _$MeetingPersonRoleEnumEnumMap = {
  MeetingPersonRoleEnum.host: 'host',
  MeetingPersonRoleEnum.cohost: 'cohost',
  MeetingPersonRoleEnum.member: 'member',
  MeetingPersonRoleEnum.guest: 'guest',
};

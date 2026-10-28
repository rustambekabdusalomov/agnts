// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_knock.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingKnockCWProxy {
  MeetingKnock id(int id);

  MeetingKnock name(String name);

  MeetingKnock email(String? email);

  MeetingKnock guest(bool guest);

  MeetingKnock at(DateTime at);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingKnock(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingKnock(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingKnock call({
    int id,
    String name,
    String? email,
    bool guest,
    DateTime at,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingKnock.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingKnock.copyWith.fieldName(...)`
class _$MeetingKnockCWProxyImpl implements _$MeetingKnockCWProxy {
  const _$MeetingKnockCWProxyImpl(this._value);

  final MeetingKnock _value;

  @override
  MeetingKnock id(int id) => this(id: id);

  @override
  MeetingKnock name(String name) => this(name: name);

  @override
  MeetingKnock email(String? email) => this(email: email);

  @override
  MeetingKnock guest(bool guest) => this(guest: guest);

  @override
  MeetingKnock at(DateTime at) => this(at: at);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingKnock(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingKnock(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingKnock call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? guest = const $CopyWithPlaceholder(),
    Object? at = const $CopyWithPlaceholder(),
  }) {
    return MeetingKnock(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String?,
      guest: guest == const $CopyWithPlaceholder()
          ? _value.guest
          // ignore: cast_nullable_to_non_nullable
          : guest as bool,
      at: at == const $CopyWithPlaceholder()
          ? _value.at
          // ignore: cast_nullable_to_non_nullable
          : at as DateTime,
    );
  }
}

extension $MeetingKnockCopyWith on MeetingKnock {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingKnock.copyWith(...)` or like so:`instanceOfMeetingKnock.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingKnockCWProxy get copyWith => _$MeetingKnockCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingKnock _$MeetingKnockFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MeetingKnock', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'name', 'guest', 'at']);
      final val = MeetingKnock(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        name: $checkedConvert('name', (v) => v as String),
        email: $checkedConvert('email', (v) => v as String?),
        guest: $checkedConvert('guest', (v) => v as bool),
        at: $checkedConvert('at', (v) => DateTime.parse(v as String)),
      );
      return val;
    });

Map<String, dynamic> _$MeetingKnockToJson(MeetingKnock instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': ?instance.email,
      'guest': instance.guest,
      'at': instance.at.toIso8601String(),
    };

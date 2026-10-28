// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_attendee.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingAttendeeCWProxy {
  MeetingAttendee person(String person);

  MeetingAttendee name(String name);

  MeetingAttendee guest(bool guest);

  MeetingAttendee email(String? email);

  MeetingAttendee firstIn(DateTime firstIn);

  MeetingAttendee lastOut(DateTime? lastOut);

  MeetingAttendee seconds(int seconds);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingAttendee(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingAttendee(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingAttendee call({
    String person,
    String name,
    bool guest,
    String? email,
    DateTime firstIn,
    DateTime? lastOut,
    int seconds,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingAttendee.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingAttendee.copyWith.fieldName(...)`
class _$MeetingAttendeeCWProxyImpl implements _$MeetingAttendeeCWProxy {
  const _$MeetingAttendeeCWProxyImpl(this._value);

  final MeetingAttendee _value;

  @override
  MeetingAttendee person(String person) => this(person: person);

  @override
  MeetingAttendee name(String name) => this(name: name);

  @override
  MeetingAttendee guest(bool guest) => this(guest: guest);

  @override
  MeetingAttendee email(String? email) => this(email: email);

  @override
  MeetingAttendee firstIn(DateTime firstIn) => this(firstIn: firstIn);

  @override
  MeetingAttendee lastOut(DateTime? lastOut) => this(lastOut: lastOut);

  @override
  MeetingAttendee seconds(int seconds) => this(seconds: seconds);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingAttendee(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingAttendee(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingAttendee call({
    Object? person = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? guest = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? firstIn = const $CopyWithPlaceholder(),
    Object? lastOut = const $CopyWithPlaceholder(),
    Object? seconds = const $CopyWithPlaceholder(),
  }) {
    return MeetingAttendee(
      person: person == const $CopyWithPlaceholder()
          ? _value.person
          // ignore: cast_nullable_to_non_nullable
          : person as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      guest: guest == const $CopyWithPlaceholder()
          ? _value.guest
          // ignore: cast_nullable_to_non_nullable
          : guest as bool,
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String?,
      firstIn: firstIn == const $CopyWithPlaceholder()
          ? _value.firstIn
          // ignore: cast_nullable_to_non_nullable
          : firstIn as DateTime,
      lastOut: lastOut == const $CopyWithPlaceholder()
          ? _value.lastOut
          // ignore: cast_nullable_to_non_nullable
          : lastOut as DateTime?,
      seconds: seconds == const $CopyWithPlaceholder()
          ? _value.seconds
          // ignore: cast_nullable_to_non_nullable
          : seconds as int,
    );
  }
}

extension $MeetingAttendeeCopyWith on MeetingAttendee {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingAttendee.copyWith(...)` or like so:`instanceOfMeetingAttendee.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingAttendeeCWProxy get copyWith => _$MeetingAttendeeCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingAttendee _$MeetingAttendeeFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MeetingAttendee', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['person', 'name', 'guest', 'firstIn', 'seconds'],
      );
      final val = MeetingAttendee(
        person: $checkedConvert('person', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        guest: $checkedConvert('guest', (v) => v as bool),
        email: $checkedConvert('email', (v) => v as String?),
        firstIn: $checkedConvert('firstIn', (v) => DateTime.parse(v as String)),
        lastOut: $checkedConvert(
          'lastOut',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        seconds: $checkedConvert('seconds', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$MeetingAttendeeToJson(MeetingAttendee instance) =>
    <String, dynamic>{
      'person': instance.person,
      'name': instance.name,
      'guest': instance.guest,
      'email': ?instance.email,
      'firstIn': instance.firstIn.toIso8601String(),
      'lastOut': ?instance.lastOut?.toIso8601String(),
      'seconds': instance.seconds,
    };

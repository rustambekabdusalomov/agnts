// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_invitee.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingInviteeCWProxy {
  MeetingInvitee id(int id);

  MeetingInvitee userId(int? userId);

  MeetingInvitee email(String email);

  MeetingInvitee name(String name);

  MeetingInvitee rsvp(MeetingInviteeRsvpEnum rsvp);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingInvitee(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingInvitee(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingInvitee call({
    int id,
    int? userId,
    String email,
    String name,
    MeetingInviteeRsvpEnum rsvp,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingInvitee.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingInvitee.copyWith.fieldName(...)`
class _$MeetingInviteeCWProxyImpl implements _$MeetingInviteeCWProxy {
  const _$MeetingInviteeCWProxyImpl(this._value);

  final MeetingInvitee _value;

  @override
  MeetingInvitee id(int id) => this(id: id);

  @override
  MeetingInvitee userId(int? userId) => this(userId: userId);

  @override
  MeetingInvitee email(String email) => this(email: email);

  @override
  MeetingInvitee name(String name) => this(name: name);

  @override
  MeetingInvitee rsvp(MeetingInviteeRsvpEnum rsvp) => this(rsvp: rsvp);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingInvitee(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingInvitee(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingInvitee call({
    Object? id = const $CopyWithPlaceholder(),
    Object? userId = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? rsvp = const $CopyWithPlaceholder(),
  }) {
    return MeetingInvitee(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      userId: userId == const $CopyWithPlaceholder()
          ? _value.userId
          // ignore: cast_nullable_to_non_nullable
          : userId as int?,
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      rsvp: rsvp == const $CopyWithPlaceholder()
          ? _value.rsvp
          // ignore: cast_nullable_to_non_nullable
          : rsvp as MeetingInviteeRsvpEnum,
    );
  }
}

extension $MeetingInviteeCopyWith on MeetingInvitee {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingInvitee.copyWith(...)` or like so:`instanceOfMeetingInvitee.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingInviteeCWProxy get copyWith => _$MeetingInviteeCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingInvitee _$MeetingInviteeFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MeetingInvitee', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'email', 'name', 'rsvp']);
      final val = MeetingInvitee(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        userId: $checkedConvert('userId', (v) => (v as num?)?.toInt()),
        email: $checkedConvert('email', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        rsvp: $checkedConvert(
          'rsvp',
          (v) => $enumDecode(_$MeetingInviteeRsvpEnumEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MeetingInviteeToJson(MeetingInvitee instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': ?instance.userId,
      'email': instance.email,
      'name': instance.name,
      'rsvp': _$MeetingInviteeRsvpEnumEnumMap[instance.rsvp]!,
    };

const _$MeetingInviteeRsvpEnumEnumMap = {
  MeetingInviteeRsvpEnum.none: 'none',
  MeetingInviteeRsvpEnum.true_: 'true',
  MeetingInviteeRsvpEnum.false_: 'false',
  MeetingInviteeRsvpEnum.maybe: 'maybe',
};

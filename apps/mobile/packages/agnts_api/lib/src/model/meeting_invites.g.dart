// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_invites.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingInvitesCWProxy {
  MeetingInvites users(List<int>? users);

  MeetingInvites emails(List<String>? emails);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingInvites(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingInvites(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingInvites call({List<int>? users, List<String>? emails});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingInvites.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingInvites.copyWith.fieldName(...)`
class _$MeetingInvitesCWProxyImpl implements _$MeetingInvitesCWProxy {
  const _$MeetingInvitesCWProxyImpl(this._value);

  final MeetingInvites _value;

  @override
  MeetingInvites users(List<int>? users) => this(users: users);

  @override
  MeetingInvites emails(List<String>? emails) => this(emails: emails);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingInvites(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingInvites(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingInvites call({
    Object? users = const $CopyWithPlaceholder(),
    Object? emails = const $CopyWithPlaceholder(),
  }) {
    return MeetingInvites(
      users: users == const $CopyWithPlaceholder()
          ? _value.users
          // ignore: cast_nullable_to_non_nullable
          : users as List<int>?,
      emails: emails == const $CopyWithPlaceholder()
          ? _value.emails
          // ignore: cast_nullable_to_non_nullable
          : emails as List<String>?,
    );
  }
}

extension $MeetingInvitesCopyWith on MeetingInvites {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingInvites.copyWith(...)` or like so:`instanceOfMeetingInvites.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingInvitesCWProxy get copyWith => _$MeetingInvitesCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingInvites _$MeetingInvitesFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MeetingInvites', json, ($checkedConvert) {
      final val = MeetingInvites(
        users: $checkedConvert(
          'users',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
        emails: $checkedConvert(
          'emails',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MeetingInvitesToJson(MeetingInvites instance) =>
    <String, dynamic>{'users': ?instance.users, 'emails': ?instance.emails};

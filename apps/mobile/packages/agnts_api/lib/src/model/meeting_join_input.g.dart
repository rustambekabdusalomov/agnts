// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_join_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingJoinInputCWProxy {
  MeetingJoinInput name(String? name);

  MeetingJoinInput googleCredential(String? googleCredential);

  MeetingJoinInput invite(String? invite);

  MeetingJoinInput device(String? device);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingJoinInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingJoinInput(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingJoinInput call({
    String? name,
    String? googleCredential,
    String? invite,
    String? device,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingJoinInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingJoinInput.copyWith.fieldName(...)`
class _$MeetingJoinInputCWProxyImpl implements _$MeetingJoinInputCWProxy {
  const _$MeetingJoinInputCWProxyImpl(this._value);

  final MeetingJoinInput _value;

  @override
  MeetingJoinInput name(String? name) => this(name: name);

  @override
  MeetingJoinInput googleCredential(String? googleCredential) =>
      this(googleCredential: googleCredential);

  @override
  MeetingJoinInput invite(String? invite) => this(invite: invite);

  @override
  MeetingJoinInput device(String? device) => this(device: device);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingJoinInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingJoinInput(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingJoinInput call({
    Object? name = const $CopyWithPlaceholder(),
    Object? googleCredential = const $CopyWithPlaceholder(),
    Object? invite = const $CopyWithPlaceholder(),
    Object? device = const $CopyWithPlaceholder(),
  }) {
    return MeetingJoinInput(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      googleCredential: googleCredential == const $CopyWithPlaceholder()
          ? _value.googleCredential
          // ignore: cast_nullable_to_non_nullable
          : googleCredential as String?,
      invite: invite == const $CopyWithPlaceholder()
          ? _value.invite
          // ignore: cast_nullable_to_non_nullable
          : invite as String?,
      device: device == const $CopyWithPlaceholder()
          ? _value.device
          // ignore: cast_nullable_to_non_nullable
          : device as String?,
    );
  }
}

extension $MeetingJoinInputCopyWith on MeetingJoinInput {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingJoinInput.copyWith(...)` or like so:`instanceOfMeetingJoinInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingJoinInputCWProxy get copyWith => _$MeetingJoinInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingJoinInput _$MeetingJoinInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MeetingJoinInput', json, ($checkedConvert) {
      final val = MeetingJoinInput(
        name: $checkedConvert('name', (v) => v as String?),
        googleCredential: $checkedConvert(
          'googleCredential',
          (v) => v as String?,
        ),
        invite: $checkedConvert('invite', (v) => v as String?),
        device: $checkedConvert('device', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$MeetingJoinInputToJson(MeetingJoinInput instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'googleCredential': ?instance.googleCredential,
      'invite': ?instance.invite,
      'device': ?instance.device,
    };

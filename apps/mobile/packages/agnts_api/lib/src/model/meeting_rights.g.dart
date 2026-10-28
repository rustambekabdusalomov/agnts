// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_rights.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingRightsCWProxy {
  MeetingRights publish(bool publish);

  MeetingRights screenShare(bool screenShare);

  MeetingRights chat(bool chat);

  MeetingRights admit(bool admit);

  MeetingRights moderate(bool moderate);

  MeetingRights record(bool record);

  MeetingRights manageCohosts(bool manageCohosts);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingRights(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingRights(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingRights call({
    bool publish,
    bool screenShare,
    bool chat,
    bool admit,
    bool moderate,
    bool record,
    bool manageCohosts,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingRights.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingRights.copyWith.fieldName(...)`
class _$MeetingRightsCWProxyImpl implements _$MeetingRightsCWProxy {
  const _$MeetingRightsCWProxyImpl(this._value);

  final MeetingRights _value;

  @override
  MeetingRights publish(bool publish) => this(publish: publish);

  @override
  MeetingRights screenShare(bool screenShare) => this(screenShare: screenShare);

  @override
  MeetingRights chat(bool chat) => this(chat: chat);

  @override
  MeetingRights admit(bool admit) => this(admit: admit);

  @override
  MeetingRights moderate(bool moderate) => this(moderate: moderate);

  @override
  MeetingRights record(bool record) => this(record: record);

  @override
  MeetingRights manageCohosts(bool manageCohosts) =>
      this(manageCohosts: manageCohosts);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingRights(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingRights(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingRights call({
    Object? publish = const $CopyWithPlaceholder(),
    Object? screenShare = const $CopyWithPlaceholder(),
    Object? chat = const $CopyWithPlaceholder(),
    Object? admit = const $CopyWithPlaceholder(),
    Object? moderate = const $CopyWithPlaceholder(),
    Object? record = const $CopyWithPlaceholder(),
    Object? manageCohosts = const $CopyWithPlaceholder(),
  }) {
    return MeetingRights(
      publish: publish == const $CopyWithPlaceholder()
          ? _value.publish
          // ignore: cast_nullable_to_non_nullable
          : publish as bool,
      screenShare: screenShare == const $CopyWithPlaceholder()
          ? _value.screenShare
          // ignore: cast_nullable_to_non_nullable
          : screenShare as bool,
      chat: chat == const $CopyWithPlaceholder()
          ? _value.chat
          // ignore: cast_nullable_to_non_nullable
          : chat as bool,
      admit: admit == const $CopyWithPlaceholder()
          ? _value.admit
          // ignore: cast_nullable_to_non_nullable
          : admit as bool,
      moderate: moderate == const $CopyWithPlaceholder()
          ? _value.moderate
          // ignore: cast_nullable_to_non_nullable
          : moderate as bool,
      record: record == const $CopyWithPlaceholder()
          ? _value.record
          // ignore: cast_nullable_to_non_nullable
          : record as bool,
      manageCohosts: manageCohosts == const $CopyWithPlaceholder()
          ? _value.manageCohosts
          // ignore: cast_nullable_to_non_nullable
          : manageCohosts as bool,
    );
  }
}

extension $MeetingRightsCopyWith on MeetingRights {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingRights.copyWith(...)` or like so:`instanceOfMeetingRights.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingRightsCWProxy get copyWith => _$MeetingRightsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingRights _$MeetingRightsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MeetingRights', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'publish',
          'screenShare',
          'chat',
          'admit',
          'moderate',
          'record',
          'manageCohosts',
        ],
      );
      final val = MeetingRights(
        publish: $checkedConvert('publish', (v) => v as bool),
        screenShare: $checkedConvert('screenShare', (v) => v as bool),
        chat: $checkedConvert('chat', (v) => v as bool),
        admit: $checkedConvert('admit', (v) => v as bool),
        moderate: $checkedConvert('moderate', (v) => v as bool),
        record: $checkedConvert('record', (v) => v as bool),
        manageCohosts: $checkedConvert('manageCohosts', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$MeetingRightsToJson(MeetingRights instance) =>
    <String, dynamic>{
      'publish': instance.publish,
      'screenShare': instance.screenShare,
      'chat': instance.chat,
      'admit': instance.admit,
      'moderate': instance.moderate,
      'record': instance.record,
      'manageCohosts': instance.manageCohosts,
    };

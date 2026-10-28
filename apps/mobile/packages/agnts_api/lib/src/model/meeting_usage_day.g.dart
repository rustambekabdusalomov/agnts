// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_usage_day.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingUsageDayCWProxy {
  MeetingUsageDay day(DateTime day);

  MeetingUsageDay sessions(int sessions);

  MeetingUsageDay participantMinutes(int participantMinutes);

  MeetingUsageDay recordingMinutes(int recordingMinutes);

  MeetingUsageDay recordingBytes(int recordingBytes);

  MeetingUsageDay transcribedMinutes(int transcribedMinutes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingUsageDay(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingUsageDay(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingUsageDay call({
    DateTime day,
    int sessions,
    int participantMinutes,
    int recordingMinutes,
    int recordingBytes,
    int transcribedMinutes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingUsageDay.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingUsageDay.copyWith.fieldName(...)`
class _$MeetingUsageDayCWProxyImpl implements _$MeetingUsageDayCWProxy {
  const _$MeetingUsageDayCWProxyImpl(this._value);

  final MeetingUsageDay _value;

  @override
  MeetingUsageDay day(DateTime day) => this(day: day);

  @override
  MeetingUsageDay sessions(int sessions) => this(sessions: sessions);

  @override
  MeetingUsageDay participantMinutes(int participantMinutes) =>
      this(participantMinutes: participantMinutes);

  @override
  MeetingUsageDay recordingMinutes(int recordingMinutes) =>
      this(recordingMinutes: recordingMinutes);

  @override
  MeetingUsageDay recordingBytes(int recordingBytes) =>
      this(recordingBytes: recordingBytes);

  @override
  MeetingUsageDay transcribedMinutes(int transcribedMinutes) =>
      this(transcribedMinutes: transcribedMinutes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingUsageDay(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingUsageDay(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingUsageDay call({
    Object? day = const $CopyWithPlaceholder(),
    Object? sessions = const $CopyWithPlaceholder(),
    Object? participantMinutes = const $CopyWithPlaceholder(),
    Object? recordingMinutes = const $CopyWithPlaceholder(),
    Object? recordingBytes = const $CopyWithPlaceholder(),
    Object? transcribedMinutes = const $CopyWithPlaceholder(),
  }) {
    return MeetingUsageDay(
      day: day == const $CopyWithPlaceholder()
          ? _value.day
          // ignore: cast_nullable_to_non_nullable
          : day as DateTime,
      sessions: sessions == const $CopyWithPlaceholder()
          ? _value.sessions
          // ignore: cast_nullable_to_non_nullable
          : sessions as int,
      participantMinutes: participantMinutes == const $CopyWithPlaceholder()
          ? _value.participantMinutes
          // ignore: cast_nullable_to_non_nullable
          : participantMinutes as int,
      recordingMinutes: recordingMinutes == const $CopyWithPlaceholder()
          ? _value.recordingMinutes
          // ignore: cast_nullable_to_non_nullable
          : recordingMinutes as int,
      recordingBytes: recordingBytes == const $CopyWithPlaceholder()
          ? _value.recordingBytes
          // ignore: cast_nullable_to_non_nullable
          : recordingBytes as int,
      transcribedMinutes: transcribedMinutes == const $CopyWithPlaceholder()
          ? _value.transcribedMinutes
          // ignore: cast_nullable_to_non_nullable
          : transcribedMinutes as int,
    );
  }
}

extension $MeetingUsageDayCopyWith on MeetingUsageDay {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingUsageDay.copyWith(...)` or like so:`instanceOfMeetingUsageDay.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingUsageDayCWProxy get copyWith => _$MeetingUsageDayCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingUsageDay _$MeetingUsageDayFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MeetingUsageDay', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'day',
          'sessions',
          'participantMinutes',
          'recordingMinutes',
          'recordingBytes',
          'transcribedMinutes',
        ],
      );
      final val = MeetingUsageDay(
        day: $checkedConvert('day', (v) => DateTime.parse(v as String)),
        sessions: $checkedConvert('sessions', (v) => (v as num).toInt()),
        participantMinutes: $checkedConvert(
          'participantMinutes',
          (v) => (v as num).toInt(),
        ),
        recordingMinutes: $checkedConvert(
          'recordingMinutes',
          (v) => (v as num).toInt(),
        ),
        recordingBytes: $checkedConvert(
          'recordingBytes',
          (v) => (v as num).toInt(),
        ),
        transcribedMinutes: $checkedConvert(
          'transcribedMinutes',
          (v) => (v as num).toInt(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MeetingUsageDayToJson(MeetingUsageDay instance) =>
    <String, dynamic>{
      'day': instance.day.toIso8601String(),
      'sessions': instance.sessions,
      'participantMinutes': instance.participantMinutes,
      'recordingMinutes': instance.recordingMinutes,
      'recordingBytes': instance.recordingBytes,
      'transcribedMinutes': instance.transcribedMinutes,
    };

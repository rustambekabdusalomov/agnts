// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_recording.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingRecordingCWProxy {
  MeetingRecording id(int id);

  MeetingRecording startedAt(DateTime startedAt);

  MeetingRecording endedAt(DateTime? endedAt);

  MeetingRecording seconds(int seconds);

  MeetingRecording bytes(int bytes);

  MeetingRecording status(MeetingRecordingStatusEnum status);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingRecording(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingRecording(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingRecording call({
    int id,
    DateTime startedAt,
    DateTime? endedAt,
    int seconds,
    int bytes,
    MeetingRecordingStatusEnum status,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingRecording.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingRecording.copyWith.fieldName(...)`
class _$MeetingRecordingCWProxyImpl implements _$MeetingRecordingCWProxy {
  const _$MeetingRecordingCWProxyImpl(this._value);

  final MeetingRecording _value;

  @override
  MeetingRecording id(int id) => this(id: id);

  @override
  MeetingRecording startedAt(DateTime startedAt) => this(startedAt: startedAt);

  @override
  MeetingRecording endedAt(DateTime? endedAt) => this(endedAt: endedAt);

  @override
  MeetingRecording seconds(int seconds) => this(seconds: seconds);

  @override
  MeetingRecording bytes(int bytes) => this(bytes: bytes);

  @override
  MeetingRecording status(MeetingRecordingStatusEnum status) =>
      this(status: status);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingRecording(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingRecording(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingRecording call({
    Object? id = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
    Object? endedAt = const $CopyWithPlaceholder(),
    Object? seconds = const $CopyWithPlaceholder(),
    Object? bytes = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
  }) {
    return MeetingRecording(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      startedAt: startedAt == const $CopyWithPlaceholder()
          ? _value.startedAt
          // ignore: cast_nullable_to_non_nullable
          : startedAt as DateTime,
      endedAt: endedAt == const $CopyWithPlaceholder()
          ? _value.endedAt
          // ignore: cast_nullable_to_non_nullable
          : endedAt as DateTime?,
      seconds: seconds == const $CopyWithPlaceholder()
          ? _value.seconds
          // ignore: cast_nullable_to_non_nullable
          : seconds as int,
      bytes: bytes == const $CopyWithPlaceholder()
          ? _value.bytes
          // ignore: cast_nullable_to_non_nullable
          : bytes as int,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as MeetingRecordingStatusEnum,
    );
  }
}

extension $MeetingRecordingCopyWith on MeetingRecording {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingRecording.copyWith(...)` or like so:`instanceOfMeetingRecording.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingRecordingCWProxy get copyWith => _$MeetingRecordingCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingRecording _$MeetingRecordingFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MeetingRecording', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['id', 'startedAt', 'seconds', 'bytes', 'status'],
      );
      final val = MeetingRecording(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        startedAt: $checkedConvert(
          'startedAt',
          (v) => DateTime.parse(v as String),
        ),
        endedAt: $checkedConvert(
          'endedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        seconds: $checkedConvert('seconds', (v) => (v as num).toInt()),
        bytes: $checkedConvert('bytes', (v) => (v as num).toInt()),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$MeetingRecordingStatusEnumEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MeetingRecordingToJson(MeetingRecording instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': ?instance.endedAt?.toIso8601String(),
      'seconds': instance.seconds,
      'bytes': instance.bytes,
      'status': _$MeetingRecordingStatusEnumEnumMap[instance.status]!,
    };

const _$MeetingRecordingStatusEnumEnumMap = {
  MeetingRecordingStatusEnum.active: 'active',
  MeetingRecordingStatusEnum.ready: 'ready',
};

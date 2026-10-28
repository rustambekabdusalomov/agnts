// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_transcript_hit.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingTranscriptHitCWProxy {
  MeetingTranscriptHit meetingId(int meetingId);

  MeetingTranscriptHit meetingTitle(String meetingTitle);

  MeetingTranscriptHit sessionId(int sessionId);

  MeetingTranscriptHit startedAt(DateTime startedAt);

  MeetingTranscriptHit segment(MeetingSegment segment);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingTranscriptHit(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingTranscriptHit(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingTranscriptHit call({
    int meetingId,
    String meetingTitle,
    int sessionId,
    DateTime startedAt,
    MeetingSegment segment,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingTranscriptHit.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingTranscriptHit.copyWith.fieldName(...)`
class _$MeetingTranscriptHitCWProxyImpl
    implements _$MeetingTranscriptHitCWProxy {
  const _$MeetingTranscriptHitCWProxyImpl(this._value);

  final MeetingTranscriptHit _value;

  @override
  MeetingTranscriptHit meetingId(int meetingId) => this(meetingId: meetingId);

  @override
  MeetingTranscriptHit meetingTitle(String meetingTitle) =>
      this(meetingTitle: meetingTitle);

  @override
  MeetingTranscriptHit sessionId(int sessionId) => this(sessionId: sessionId);

  @override
  MeetingTranscriptHit startedAt(DateTime startedAt) =>
      this(startedAt: startedAt);

  @override
  MeetingTranscriptHit segment(MeetingSegment segment) =>
      this(segment: segment);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingTranscriptHit(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingTranscriptHit(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingTranscriptHit call({
    Object? meetingId = const $CopyWithPlaceholder(),
    Object? meetingTitle = const $CopyWithPlaceholder(),
    Object? sessionId = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
    Object? segment = const $CopyWithPlaceholder(),
  }) {
    return MeetingTranscriptHit(
      meetingId: meetingId == const $CopyWithPlaceholder()
          ? _value.meetingId
          // ignore: cast_nullable_to_non_nullable
          : meetingId as int,
      meetingTitle: meetingTitle == const $CopyWithPlaceholder()
          ? _value.meetingTitle
          // ignore: cast_nullable_to_non_nullable
          : meetingTitle as String,
      sessionId: sessionId == const $CopyWithPlaceholder()
          ? _value.sessionId
          // ignore: cast_nullable_to_non_nullable
          : sessionId as int,
      startedAt: startedAt == const $CopyWithPlaceholder()
          ? _value.startedAt
          // ignore: cast_nullable_to_non_nullable
          : startedAt as DateTime,
      segment: segment == const $CopyWithPlaceholder()
          ? _value.segment
          // ignore: cast_nullable_to_non_nullable
          : segment as MeetingSegment,
    );
  }
}

extension $MeetingTranscriptHitCopyWith on MeetingTranscriptHit {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingTranscriptHit.copyWith(...)` or like so:`instanceOfMeetingTranscriptHit.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingTranscriptHitCWProxy get copyWith =>
      _$MeetingTranscriptHitCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingTranscriptHit _$MeetingTranscriptHitFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MeetingTranscriptHit', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'meetingId',
      'meetingTitle',
      'sessionId',
      'startedAt',
      'segment',
    ],
  );
  final val = MeetingTranscriptHit(
    meetingId: $checkedConvert('meetingId', (v) => (v as num).toInt()),
    meetingTitle: $checkedConvert('meetingTitle', (v) => v as String),
    sessionId: $checkedConvert('sessionId', (v) => (v as num).toInt()),
    startedAt: $checkedConvert('startedAt', (v) => DateTime.parse(v as String)),
    segment: $checkedConvert(
      'segment',
      (v) => MeetingSegment.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$MeetingTranscriptHitToJson(
  MeetingTranscriptHit instance,
) => <String, dynamic>{
  'meetingId': instance.meetingId,
  'meetingTitle': instance.meetingTitle,
  'sessionId': instance.sessionId,
  'startedAt': instance.startedAt.toIso8601String(),
  'segment': instance.segment.toJson(),
};

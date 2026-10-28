// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_transcript.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingTranscriptCWProxy {
  MeetingTranscript segments(List<MeetingSegment> segments);

  MeetingTranscript speakers(bool speakers);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingTranscript(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingTranscript(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingTranscript call({List<MeetingSegment> segments, bool speakers});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingTranscript.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingTranscript.copyWith.fieldName(...)`
class _$MeetingTranscriptCWProxyImpl implements _$MeetingTranscriptCWProxy {
  const _$MeetingTranscriptCWProxyImpl(this._value);

  final MeetingTranscript _value;

  @override
  MeetingTranscript segments(List<MeetingSegment> segments) =>
      this(segments: segments);

  @override
  MeetingTranscript speakers(bool speakers) => this(speakers: speakers);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingTranscript(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingTranscript(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingTranscript call({
    Object? segments = const $CopyWithPlaceholder(),
    Object? speakers = const $CopyWithPlaceholder(),
  }) {
    return MeetingTranscript(
      segments: segments == const $CopyWithPlaceholder()
          ? _value.segments
          // ignore: cast_nullable_to_non_nullable
          : segments as List<MeetingSegment>,
      speakers: speakers == const $CopyWithPlaceholder()
          ? _value.speakers
          // ignore: cast_nullable_to_non_nullable
          : speakers as bool,
    );
  }
}

extension $MeetingTranscriptCopyWith on MeetingTranscript {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingTranscript.copyWith(...)` or like so:`instanceOfMeetingTranscript.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingTranscriptCWProxy get copyWith =>
      _$MeetingTranscriptCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingTranscript _$MeetingTranscriptFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MeetingTranscript', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['segments', 'speakers']);
      final val = MeetingTranscript(
        segments: $checkedConvert(
          'segments',
          (v) => (v as List<dynamic>)
              .map((e) => MeetingSegment.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        speakers: $checkedConvert('speakers', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$MeetingTranscriptToJson(MeetingTranscript instance) =>
    <String, dynamic>{
      'segments': instance.segments.map((e) => e.toJson()).toList(),
      'speakers': instance.speakers,
    };

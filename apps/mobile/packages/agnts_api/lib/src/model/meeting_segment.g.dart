// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_segment.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingSegmentCWProxy {
  MeetingSegment startMs(int startMs);

  MeetingSegment endMs(int endMs);

  MeetingSegment name(String name);

  MeetingSegment text(String text);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingSegment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingSegment(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingSegment call({int startMs, int endMs, String name, String text});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingSegment.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingSegment.copyWith.fieldName(...)`
class _$MeetingSegmentCWProxyImpl implements _$MeetingSegmentCWProxy {
  const _$MeetingSegmentCWProxyImpl(this._value);

  final MeetingSegment _value;

  @override
  MeetingSegment startMs(int startMs) => this(startMs: startMs);

  @override
  MeetingSegment endMs(int endMs) => this(endMs: endMs);

  @override
  MeetingSegment name(String name) => this(name: name);

  @override
  MeetingSegment text(String text) => this(text: text);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingSegment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingSegment(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingSegment call({
    Object? startMs = const $CopyWithPlaceholder(),
    Object? endMs = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? text = const $CopyWithPlaceholder(),
  }) {
    return MeetingSegment(
      startMs: startMs == const $CopyWithPlaceholder()
          ? _value.startMs
          // ignore: cast_nullable_to_non_nullable
          : startMs as int,
      endMs: endMs == const $CopyWithPlaceholder()
          ? _value.endMs
          // ignore: cast_nullable_to_non_nullable
          : endMs as int,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      text: text == const $CopyWithPlaceholder()
          ? _value.text
          // ignore: cast_nullable_to_non_nullable
          : text as String,
    );
  }
}

extension $MeetingSegmentCopyWith on MeetingSegment {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingSegment.copyWith(...)` or like so:`instanceOfMeetingSegment.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingSegmentCWProxy get copyWith => _$MeetingSegmentCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingSegment _$MeetingSegmentFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MeetingSegment', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['startMs', 'endMs', 'name', 'text'],
      );
      final val = MeetingSegment(
        startMs: $checkedConvert('startMs', (v) => (v as num).toInt()),
        endMs: $checkedConvert('endMs', (v) => (v as num).toInt()),
        name: $checkedConvert('name', (v) => v as String),
        text: $checkedConvert('text', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$MeetingSegmentToJson(MeetingSegment instance) =>
    <String, dynamic>{
      'startMs': instance.startMs,
      'endMs': instance.endMs,
      'name': instance.name,
      'text': instance.text,
    };

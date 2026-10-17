// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_transcript_detail.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RunTranscriptDetailCWProxy {
  RunTranscriptDetail transcript(RunTranscript transcript);

  RunTranscriptDetail events(List<RunTranscriptEvent> events);

  RunTranscriptDetail siblings(List<RunTranscript> siblings);

  RunTranscriptDetail unreadable(bool? unreadable);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RunTranscriptDetail(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RunTranscriptDetail(...).copyWith(id: 12, name: "My name")
  /// ````
  RunTranscriptDetail call({
    RunTranscript transcript,
    List<RunTranscriptEvent> events,
    List<RunTranscript> siblings,
    bool? unreadable,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRunTranscriptDetail.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRunTranscriptDetail.copyWith.fieldName(...)`
class _$RunTranscriptDetailCWProxyImpl implements _$RunTranscriptDetailCWProxy {
  const _$RunTranscriptDetailCWProxyImpl(this._value);

  final RunTranscriptDetail _value;

  @override
  RunTranscriptDetail transcript(RunTranscript transcript) =>
      this(transcript: transcript);

  @override
  RunTranscriptDetail events(List<RunTranscriptEvent> events) =>
      this(events: events);

  @override
  RunTranscriptDetail siblings(List<RunTranscript> siblings) =>
      this(siblings: siblings);

  @override
  RunTranscriptDetail unreadable(bool? unreadable) =>
      this(unreadable: unreadable);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RunTranscriptDetail(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RunTranscriptDetail(...).copyWith(id: 12, name: "My name")
  /// ````
  RunTranscriptDetail call({
    Object? transcript = const $CopyWithPlaceholder(),
    Object? events = const $CopyWithPlaceholder(),
    Object? siblings = const $CopyWithPlaceholder(),
    Object? unreadable = const $CopyWithPlaceholder(),
  }) {
    return RunTranscriptDetail(
      transcript: transcript == const $CopyWithPlaceholder()
          ? _value.transcript
          // ignore: cast_nullable_to_non_nullable
          : transcript as RunTranscript,
      events: events == const $CopyWithPlaceholder()
          ? _value.events
          // ignore: cast_nullable_to_non_nullable
          : events as List<RunTranscriptEvent>,
      siblings: siblings == const $CopyWithPlaceholder()
          ? _value.siblings
          // ignore: cast_nullable_to_non_nullable
          : siblings as List<RunTranscript>,
      unreadable: unreadable == const $CopyWithPlaceholder()
          ? _value.unreadable
          // ignore: cast_nullable_to_non_nullable
          : unreadable as bool?,
    );
  }
}

extension $RunTranscriptDetailCopyWith on RunTranscriptDetail {
  /// Returns a callable class that can be used as follows: `instanceOfRunTranscriptDetail.copyWith(...)` or like so:`instanceOfRunTranscriptDetail.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RunTranscriptDetailCWProxy get copyWith =>
      _$RunTranscriptDetailCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RunTranscriptDetail _$RunTranscriptDetailFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RunTranscriptDetail', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['transcript', 'events', 'siblings']);
  final val = RunTranscriptDetail(
    transcript: $checkedConvert(
      'transcript',
      (v) => RunTranscript.fromJson(v as Map<String, dynamic>),
    ),
    events: $checkedConvert(
      'events',
      (v) => (v as List<dynamic>)
          .map((e) => RunTranscriptEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    siblings: $checkedConvert(
      'siblings',
      (v) => (v as List<dynamic>)
          .map((e) => RunTranscript.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    unreadable: $checkedConvert('unreadable', (v) => v as bool?),
  );
  return val;
});

Map<String, dynamic> _$RunTranscriptDetailToJson(
  RunTranscriptDetail instance,
) => <String, dynamic>{
  'transcript': instance.transcript.toJson(),
  'events': instance.events.map((e) => e.toJson()).toList(),
  'siblings': instance.siblings.map((e) => e.toJson()).toList(),
  'unreadable': ?instance.unreadable,
};

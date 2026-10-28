// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_live.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingLiveCWProxy {
  MeetingLive sessionId(int sessionId);

  MeetingLive startedAt(DateTime startedAt);

  MeetingLive inCall(int inCall);

  MeetingLive recording(bool recording);

  MeetingLive notes(bool notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingLive(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingLive(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingLive call({
    int sessionId,
    DateTime startedAt,
    int inCall,
    bool recording,
    bool notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingLive.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingLive.copyWith.fieldName(...)`
class _$MeetingLiveCWProxyImpl implements _$MeetingLiveCWProxy {
  const _$MeetingLiveCWProxyImpl(this._value);

  final MeetingLive _value;

  @override
  MeetingLive sessionId(int sessionId) => this(sessionId: sessionId);

  @override
  MeetingLive startedAt(DateTime startedAt) => this(startedAt: startedAt);

  @override
  MeetingLive inCall(int inCall) => this(inCall: inCall);

  @override
  MeetingLive recording(bool recording) => this(recording: recording);

  @override
  MeetingLive notes(bool notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingLive(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingLive(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingLive call({
    Object? sessionId = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
    Object? inCall = const $CopyWithPlaceholder(),
    Object? recording = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return MeetingLive(
      sessionId: sessionId == const $CopyWithPlaceholder()
          ? _value.sessionId
          // ignore: cast_nullable_to_non_nullable
          : sessionId as int,
      startedAt: startedAt == const $CopyWithPlaceholder()
          ? _value.startedAt
          // ignore: cast_nullable_to_non_nullable
          : startedAt as DateTime,
      inCall: inCall == const $CopyWithPlaceholder()
          ? _value.inCall
          // ignore: cast_nullable_to_non_nullable
          : inCall as int,
      recording: recording == const $CopyWithPlaceholder()
          ? _value.recording
          // ignore: cast_nullable_to_non_nullable
          : recording as bool,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as bool,
    );
  }
}

extension $MeetingLiveCopyWith on MeetingLive {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingLive.copyWith(...)` or like so:`instanceOfMeetingLive.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingLiveCWProxy get copyWith => _$MeetingLiveCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingLive _$MeetingLiveFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MeetingLive', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'sessionId',
          'startedAt',
          'inCall',
          'recording',
          'notes',
        ],
      );
      final val = MeetingLive(
        sessionId: $checkedConvert('sessionId', (v) => (v as num).toInt()),
        startedAt: $checkedConvert(
          'startedAt',
          (v) => DateTime.parse(v as String),
        ),
        inCall: $checkedConvert('inCall', (v) => (v as num).toInt()),
        recording: $checkedConvert('recording', (v) => v as bool),
        notes: $checkedConvert('notes', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$MeetingLiveToJson(MeetingLive instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'startedAt': instance.startedAt.toIso8601String(),
      'inCall': instance.inCall,
      'recording': instance.recording,
      'notes': instance.notes,
    };

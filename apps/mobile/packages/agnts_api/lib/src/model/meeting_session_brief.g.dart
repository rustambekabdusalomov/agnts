// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_session_brief.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingSessionBriefCWProxy {
  MeetingSessionBrief id(int id);

  MeetingSessionBrief startedAt(DateTime startedAt);

  MeetingSessionBrief connectedAt(DateTime? connectedAt);

  MeetingSessionBrief endedAt(DateTime? endedAt);

  MeetingSessionBrief notesStatus(MeetingNotesStatus notesStatus);

  MeetingSessionBrief notesError(String notesError);

  MeetingSessionBrief documentId(int? documentId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingSessionBrief(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingSessionBrief(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingSessionBrief call({
    int id,
    DateTime startedAt,
    DateTime? connectedAt,
    DateTime? endedAt,
    MeetingNotesStatus notesStatus,
    String notesError,
    int? documentId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingSessionBrief.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingSessionBrief.copyWith.fieldName(...)`
class _$MeetingSessionBriefCWProxyImpl implements _$MeetingSessionBriefCWProxy {
  const _$MeetingSessionBriefCWProxyImpl(this._value);

  final MeetingSessionBrief _value;

  @override
  MeetingSessionBrief id(int id) => this(id: id);

  @override
  MeetingSessionBrief startedAt(DateTime startedAt) =>
      this(startedAt: startedAt);

  @override
  MeetingSessionBrief connectedAt(DateTime? connectedAt) =>
      this(connectedAt: connectedAt);

  @override
  MeetingSessionBrief endedAt(DateTime? endedAt) => this(endedAt: endedAt);

  @override
  MeetingSessionBrief notesStatus(MeetingNotesStatus notesStatus) =>
      this(notesStatus: notesStatus);

  @override
  MeetingSessionBrief notesError(String notesError) =>
      this(notesError: notesError);

  @override
  MeetingSessionBrief documentId(int? documentId) =>
      this(documentId: documentId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingSessionBrief(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingSessionBrief(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingSessionBrief call({
    Object? id = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
    Object? connectedAt = const $CopyWithPlaceholder(),
    Object? endedAt = const $CopyWithPlaceholder(),
    Object? notesStatus = const $CopyWithPlaceholder(),
    Object? notesError = const $CopyWithPlaceholder(),
    Object? documentId = const $CopyWithPlaceholder(),
  }) {
    return MeetingSessionBrief(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      startedAt: startedAt == const $CopyWithPlaceholder()
          ? _value.startedAt
          // ignore: cast_nullable_to_non_nullable
          : startedAt as DateTime,
      connectedAt: connectedAt == const $CopyWithPlaceholder()
          ? _value.connectedAt
          // ignore: cast_nullable_to_non_nullable
          : connectedAt as DateTime?,
      endedAt: endedAt == const $CopyWithPlaceholder()
          ? _value.endedAt
          // ignore: cast_nullable_to_non_nullable
          : endedAt as DateTime?,
      notesStatus: notesStatus == const $CopyWithPlaceholder()
          ? _value.notesStatus
          // ignore: cast_nullable_to_non_nullable
          : notesStatus as MeetingNotesStatus,
      notesError: notesError == const $CopyWithPlaceholder()
          ? _value.notesError
          // ignore: cast_nullable_to_non_nullable
          : notesError as String,
      documentId: documentId == const $CopyWithPlaceholder()
          ? _value.documentId
          // ignore: cast_nullable_to_non_nullable
          : documentId as int?,
    );
  }
}

extension $MeetingSessionBriefCopyWith on MeetingSessionBrief {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingSessionBrief.copyWith(...)` or like so:`instanceOfMeetingSessionBrief.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingSessionBriefCWProxy get copyWith =>
      _$MeetingSessionBriefCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingSessionBrief _$MeetingSessionBriefFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MeetingSessionBrief', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['id', 'startedAt', 'notesStatus', 'notesError'],
      );
      final val = MeetingSessionBrief(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        startedAt: $checkedConvert(
          'startedAt',
          (v) => DateTime.parse(v as String),
        ),
        connectedAt: $checkedConvert(
          'connectedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        endedAt: $checkedConvert(
          'endedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        notesStatus: $checkedConvert(
          'notesStatus',
          (v) => $enumDecode(_$MeetingNotesStatusEnumMap, v),
        ),
        notesError: $checkedConvert('notesError', (v) => v as String),
        documentId: $checkedConvert('documentId', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$MeetingSessionBriefToJson(
  MeetingSessionBrief instance,
) => <String, dynamic>{
  'id': instance.id,
  'startedAt': instance.startedAt.toIso8601String(),
  'connectedAt': ?instance.connectedAt?.toIso8601String(),
  'endedAt': ?instance.endedAt?.toIso8601String(),
  'notesStatus': _$MeetingNotesStatusEnumMap[instance.notesStatus]!,
  'notesError': instance.notesError,
  'documentId': ?instance.documentId,
};

const _$MeetingNotesStatusEnumMap = {
  MeetingNotesStatus.none: 'none',
  MeetingNotesStatus.recording: 'recording',
  MeetingNotesStatus.queued: 'queued',
  MeetingNotesStatus.transcribing: 'transcribing',
  MeetingNotesStatus.writing: 'writing',
  MeetingNotesStatus.done: 'done',
  MeetingNotesStatus.failed: 'failed',
};

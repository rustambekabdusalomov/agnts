// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_session_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingSessionSummaryCWProxy {
  MeetingSessionSummary id(int id);

  MeetingSessionSummary meetingId(int meetingId);

  MeetingSessionSummary meetingCode(String meetingCode);

  MeetingSessionSummary meetingTitle(String meetingTitle);

  MeetingSessionSummary startedAt(DateTime startedAt);

  MeetingSessionSummary endedAt(DateTime? endedAt);

  MeetingSessionSummary people(int people);

  MeetingSessionSummary recordings(int recordings);

  MeetingSessionSummary actionItems(int actionItems);

  MeetingSessionSummary notesStatus(MeetingNotesStatus notesStatus);

  MeetingSessionSummary notesError(String notesError);

  MeetingSessionSummary documentId(int? documentId);

  MeetingSessionSummary documentTitle(String documentTitle);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingSessionSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingSessionSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingSessionSummary call({
    int id,
    int meetingId,
    String meetingCode,
    String meetingTitle,
    DateTime startedAt,
    DateTime? endedAt,
    int people,
    int recordings,
    int actionItems,
    MeetingNotesStatus notesStatus,
    String notesError,
    int? documentId,
    String documentTitle,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingSessionSummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingSessionSummary.copyWith.fieldName(...)`
class _$MeetingSessionSummaryCWProxyImpl
    implements _$MeetingSessionSummaryCWProxy {
  const _$MeetingSessionSummaryCWProxyImpl(this._value);

  final MeetingSessionSummary _value;

  @override
  MeetingSessionSummary id(int id) => this(id: id);

  @override
  MeetingSessionSummary meetingId(int meetingId) => this(meetingId: meetingId);

  @override
  MeetingSessionSummary meetingCode(String meetingCode) =>
      this(meetingCode: meetingCode);

  @override
  MeetingSessionSummary meetingTitle(String meetingTitle) =>
      this(meetingTitle: meetingTitle);

  @override
  MeetingSessionSummary startedAt(DateTime startedAt) =>
      this(startedAt: startedAt);

  @override
  MeetingSessionSummary endedAt(DateTime? endedAt) => this(endedAt: endedAt);

  @override
  MeetingSessionSummary people(int people) => this(people: people);

  @override
  MeetingSessionSummary recordings(int recordings) =>
      this(recordings: recordings);

  @override
  MeetingSessionSummary actionItems(int actionItems) =>
      this(actionItems: actionItems);

  @override
  MeetingSessionSummary notesStatus(MeetingNotesStatus notesStatus) =>
      this(notesStatus: notesStatus);

  @override
  MeetingSessionSummary notesError(String notesError) =>
      this(notesError: notesError);

  @override
  MeetingSessionSummary documentId(int? documentId) =>
      this(documentId: documentId);

  @override
  MeetingSessionSummary documentTitle(String documentTitle) =>
      this(documentTitle: documentTitle);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingSessionSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingSessionSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingSessionSummary call({
    Object? id = const $CopyWithPlaceholder(),
    Object? meetingId = const $CopyWithPlaceholder(),
    Object? meetingCode = const $CopyWithPlaceholder(),
    Object? meetingTitle = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
    Object? endedAt = const $CopyWithPlaceholder(),
    Object? people = const $CopyWithPlaceholder(),
    Object? recordings = const $CopyWithPlaceholder(),
    Object? actionItems = const $CopyWithPlaceholder(),
    Object? notesStatus = const $CopyWithPlaceholder(),
    Object? notesError = const $CopyWithPlaceholder(),
    Object? documentId = const $CopyWithPlaceholder(),
    Object? documentTitle = const $CopyWithPlaceholder(),
  }) {
    return MeetingSessionSummary(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      meetingId: meetingId == const $CopyWithPlaceholder()
          ? _value.meetingId
          // ignore: cast_nullable_to_non_nullable
          : meetingId as int,
      meetingCode: meetingCode == const $CopyWithPlaceholder()
          ? _value.meetingCode
          // ignore: cast_nullable_to_non_nullable
          : meetingCode as String,
      meetingTitle: meetingTitle == const $CopyWithPlaceholder()
          ? _value.meetingTitle
          // ignore: cast_nullable_to_non_nullable
          : meetingTitle as String,
      startedAt: startedAt == const $CopyWithPlaceholder()
          ? _value.startedAt
          // ignore: cast_nullable_to_non_nullable
          : startedAt as DateTime,
      endedAt: endedAt == const $CopyWithPlaceholder()
          ? _value.endedAt
          // ignore: cast_nullable_to_non_nullable
          : endedAt as DateTime?,
      people: people == const $CopyWithPlaceholder()
          ? _value.people
          // ignore: cast_nullable_to_non_nullable
          : people as int,
      recordings: recordings == const $CopyWithPlaceholder()
          ? _value.recordings
          // ignore: cast_nullable_to_non_nullable
          : recordings as int,
      actionItems: actionItems == const $CopyWithPlaceholder()
          ? _value.actionItems
          // ignore: cast_nullable_to_non_nullable
          : actionItems as int,
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
      documentTitle: documentTitle == const $CopyWithPlaceholder()
          ? _value.documentTitle
          // ignore: cast_nullable_to_non_nullable
          : documentTitle as String,
    );
  }
}

extension $MeetingSessionSummaryCopyWith on MeetingSessionSummary {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingSessionSummary.copyWith(...)` or like so:`instanceOfMeetingSessionSummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingSessionSummaryCWProxy get copyWith =>
      _$MeetingSessionSummaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingSessionSummary _$MeetingSessionSummaryFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MeetingSessionSummary', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'meetingId',
      'meetingCode',
      'meetingTitle',
      'startedAt',
      'people',
      'recordings',
      'actionItems',
      'notesStatus',
      'notesError',
      'documentTitle',
    ],
  );
  final val = MeetingSessionSummary(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    meetingId: $checkedConvert('meetingId', (v) => (v as num).toInt()),
    meetingCode: $checkedConvert('meetingCode', (v) => v as String),
    meetingTitle: $checkedConvert('meetingTitle', (v) => v as String),
    startedAt: $checkedConvert('startedAt', (v) => DateTime.parse(v as String)),
    endedAt: $checkedConvert(
      'endedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    people: $checkedConvert('people', (v) => (v as num).toInt()),
    recordings: $checkedConvert('recordings', (v) => (v as num).toInt()),
    actionItems: $checkedConvert('actionItems', (v) => (v as num).toInt()),
    notesStatus: $checkedConvert(
      'notesStatus',
      (v) => $enumDecode(_$MeetingNotesStatusEnumMap, v),
    ),
    notesError: $checkedConvert('notesError', (v) => v as String),
    documentId: $checkedConvert('documentId', (v) => (v as num?)?.toInt()),
    documentTitle: $checkedConvert('documentTitle', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$MeetingSessionSummaryToJson(
  MeetingSessionSummary instance,
) => <String, dynamic>{
  'id': instance.id,
  'meetingId': instance.meetingId,
  'meetingCode': instance.meetingCode,
  'meetingTitle': instance.meetingTitle,
  'startedAt': instance.startedAt.toIso8601String(),
  'endedAt': ?instance.endedAt?.toIso8601String(),
  'people': instance.people,
  'recordings': instance.recordings,
  'actionItems': instance.actionItems,
  'notesStatus': _$MeetingNotesStatusEnumMap[instance.notesStatus]!,
  'notesError': instance.notesError,
  'documentId': ?instance.documentId,
  'documentTitle': instance.documentTitle,
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

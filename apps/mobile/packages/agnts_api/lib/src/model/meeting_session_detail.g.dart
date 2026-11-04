// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_session_detail.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingSessionDetailCWProxy {
  MeetingSessionDetail id(int id);

  MeetingSessionDetail meeting(Meeting meeting);

  MeetingSessionDetail uploaded(bool uploaded);

  MeetingSessionDetail people(List<int> people);

  MeetingSessionDetail startedAt(DateTime startedAt);

  MeetingSessionDetail endedAt(DateTime? endedAt);

  MeetingSessionDetail notesStatus(MeetingNotesStatus notesStatus);

  MeetingSessionDetail notesError(String notesError);

  MeetingSessionDetail documentId(int? documentId);

  MeetingSessionDetail attendees(List<MeetingAttendee> attendees);

  MeetingSessionDetail recordings(List<MeetingRecording> recordings);

  MeetingSessionDetail actionItems(List<MeetingActionItem> actionItems);

  MeetingSessionDetail messages(int messages);

  MeetingSessionDetail canManage(bool canManage);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingSessionDetail(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingSessionDetail(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingSessionDetail call({
    int id,
    Meeting meeting,
    bool uploaded,
    List<int> people,
    DateTime startedAt,
    DateTime? endedAt,
    MeetingNotesStatus notesStatus,
    String notesError,
    int? documentId,
    List<MeetingAttendee> attendees,
    List<MeetingRecording> recordings,
    List<MeetingActionItem> actionItems,
    int messages,
    bool canManage,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingSessionDetail.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingSessionDetail.copyWith.fieldName(...)`
class _$MeetingSessionDetailCWProxyImpl
    implements _$MeetingSessionDetailCWProxy {
  const _$MeetingSessionDetailCWProxyImpl(this._value);

  final MeetingSessionDetail _value;

  @override
  MeetingSessionDetail id(int id) => this(id: id);

  @override
  MeetingSessionDetail meeting(Meeting meeting) => this(meeting: meeting);

  @override
  MeetingSessionDetail uploaded(bool uploaded) => this(uploaded: uploaded);

  @override
  MeetingSessionDetail people(List<int> people) => this(people: people);

  @override
  MeetingSessionDetail startedAt(DateTime startedAt) =>
      this(startedAt: startedAt);

  @override
  MeetingSessionDetail endedAt(DateTime? endedAt) => this(endedAt: endedAt);

  @override
  MeetingSessionDetail notesStatus(MeetingNotesStatus notesStatus) =>
      this(notesStatus: notesStatus);

  @override
  MeetingSessionDetail notesError(String notesError) =>
      this(notesError: notesError);

  @override
  MeetingSessionDetail documentId(int? documentId) =>
      this(documentId: documentId);

  @override
  MeetingSessionDetail attendees(List<MeetingAttendee> attendees) =>
      this(attendees: attendees);

  @override
  MeetingSessionDetail recordings(List<MeetingRecording> recordings) =>
      this(recordings: recordings);

  @override
  MeetingSessionDetail actionItems(List<MeetingActionItem> actionItems) =>
      this(actionItems: actionItems);

  @override
  MeetingSessionDetail messages(int messages) => this(messages: messages);

  @override
  MeetingSessionDetail canManage(bool canManage) => this(canManage: canManage);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingSessionDetail(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingSessionDetail(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingSessionDetail call({
    Object? id = const $CopyWithPlaceholder(),
    Object? meeting = const $CopyWithPlaceholder(),
    Object? uploaded = const $CopyWithPlaceholder(),
    Object? people = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
    Object? endedAt = const $CopyWithPlaceholder(),
    Object? notesStatus = const $CopyWithPlaceholder(),
    Object? notesError = const $CopyWithPlaceholder(),
    Object? documentId = const $CopyWithPlaceholder(),
    Object? attendees = const $CopyWithPlaceholder(),
    Object? recordings = const $CopyWithPlaceholder(),
    Object? actionItems = const $CopyWithPlaceholder(),
    Object? messages = const $CopyWithPlaceholder(),
    Object? canManage = const $CopyWithPlaceholder(),
  }) {
    return MeetingSessionDetail(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      meeting: meeting == const $CopyWithPlaceholder()
          ? _value.meeting
          // ignore: cast_nullable_to_non_nullable
          : meeting as Meeting,
      uploaded: uploaded == const $CopyWithPlaceholder()
          ? _value.uploaded
          // ignore: cast_nullable_to_non_nullable
          : uploaded as bool,
      people: people == const $CopyWithPlaceholder()
          ? _value.people
          // ignore: cast_nullable_to_non_nullable
          : people as List<int>,
      startedAt: startedAt == const $CopyWithPlaceholder()
          ? _value.startedAt
          // ignore: cast_nullable_to_non_nullable
          : startedAt as DateTime,
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
      attendees: attendees == const $CopyWithPlaceholder()
          ? _value.attendees
          // ignore: cast_nullable_to_non_nullable
          : attendees as List<MeetingAttendee>,
      recordings: recordings == const $CopyWithPlaceholder()
          ? _value.recordings
          // ignore: cast_nullable_to_non_nullable
          : recordings as List<MeetingRecording>,
      actionItems: actionItems == const $CopyWithPlaceholder()
          ? _value.actionItems
          // ignore: cast_nullable_to_non_nullable
          : actionItems as List<MeetingActionItem>,
      messages: messages == const $CopyWithPlaceholder()
          ? _value.messages
          // ignore: cast_nullable_to_non_nullable
          : messages as int,
      canManage: canManage == const $CopyWithPlaceholder()
          ? _value.canManage
          // ignore: cast_nullable_to_non_nullable
          : canManage as bool,
    );
  }
}

extension $MeetingSessionDetailCopyWith on MeetingSessionDetail {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingSessionDetail.copyWith(...)` or like so:`instanceOfMeetingSessionDetail.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingSessionDetailCWProxy get copyWith =>
      _$MeetingSessionDetailCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingSessionDetail _$MeetingSessionDetailFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MeetingSessionDetail', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'meeting',
      'uploaded',
      'people',
      'startedAt',
      'notesStatus',
      'notesError',
      'attendees',
      'recordings',
      'actionItems',
      'messages',
      'canManage',
    ],
  );
  final val = MeetingSessionDetail(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    meeting: $checkedConvert(
      'meeting',
      (v) => Meeting.fromJson(v as Map<String, dynamic>),
    ),
    uploaded: $checkedConvert('uploaded', (v) => v as bool),
    people: $checkedConvert(
      'people',
      (v) => (v as List<dynamic>).map((e) => (e as num).toInt()).toList(),
    ),
    startedAt: $checkedConvert('startedAt', (v) => DateTime.parse(v as String)),
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
    attendees: $checkedConvert(
      'attendees',
      (v) => (v as List<dynamic>)
          .map((e) => MeetingAttendee.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    recordings: $checkedConvert(
      'recordings',
      (v) => (v as List<dynamic>)
          .map((e) => MeetingRecording.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    actionItems: $checkedConvert(
      'actionItems',
      (v) => (v as List<dynamic>)
          .map((e) => MeetingActionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    messages: $checkedConvert('messages', (v) => (v as num).toInt()),
    canManage: $checkedConvert('canManage', (v) => v as bool),
  );
  return val;
});

Map<String, dynamic> _$MeetingSessionDetailToJson(
  MeetingSessionDetail instance,
) => <String, dynamic>{
  'id': instance.id,
  'meeting': instance.meeting.toJson(),
  'uploaded': instance.uploaded,
  'people': instance.people,
  'startedAt': instance.startedAt.toIso8601String(),
  'endedAt': ?instance.endedAt?.toIso8601String(),
  'notesStatus': _$MeetingNotesStatusEnumMap[instance.notesStatus]!,
  'notesError': instance.notesError,
  'documentId': ?instance.documentId,
  'attendees': instance.attendees.map((e) => e.toJson()).toList(),
  'recordings': instance.recordings.map((e) => e.toJson()).toList(),
  'actionItems': instance.actionItems.map((e) => e.toJson()).toList(),
  'messages': instance.messages,
  'canManage': instance.canManage,
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

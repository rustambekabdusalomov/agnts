// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_call.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingCallCWProxy {
  MeetingCall meeting(Meeting meeting);

  MeetingCall sessionId(int sessionId);

  MeetingCall me(MeetingPerson me);

  MeetingCall rights(MeetingRights rights);

  MeetingCall canAdmit(bool canAdmit);

  MeetingCall people(List<MeetingPerson> people);

  MeetingCall knocks(List<MeetingKnock> knocks);

  MeetingCall recording(bool recording);

  MeetingCall notes(bool notes);

  MeetingCall notesStatus(MeetingNotesStatus? notesStatus);

  MeetingCall recordingAvailable(bool recordingAvailable);

  MeetingCall notesAvailable(bool notesAvailable);

  MeetingCall guestsQuiet(bool guestsQuiet);

  MeetingCall workspace(String? workspace);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingCall(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingCall(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingCall call({
    Meeting meeting,
    int sessionId,
    MeetingPerson me,
    MeetingRights rights,
    bool canAdmit,
    List<MeetingPerson> people,
    List<MeetingKnock> knocks,
    bool recording,
    bool notes,
    MeetingNotesStatus? notesStatus,
    bool recordingAvailable,
    bool notesAvailable,
    bool guestsQuiet,
    String? workspace,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingCall.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingCall.copyWith.fieldName(...)`
class _$MeetingCallCWProxyImpl implements _$MeetingCallCWProxy {
  const _$MeetingCallCWProxyImpl(this._value);

  final MeetingCall _value;

  @override
  MeetingCall meeting(Meeting meeting) => this(meeting: meeting);

  @override
  MeetingCall sessionId(int sessionId) => this(sessionId: sessionId);

  @override
  MeetingCall me(MeetingPerson me) => this(me: me);

  @override
  MeetingCall rights(MeetingRights rights) => this(rights: rights);

  @override
  MeetingCall canAdmit(bool canAdmit) => this(canAdmit: canAdmit);

  @override
  MeetingCall people(List<MeetingPerson> people) => this(people: people);

  @override
  MeetingCall knocks(List<MeetingKnock> knocks) => this(knocks: knocks);

  @override
  MeetingCall recording(bool recording) => this(recording: recording);

  @override
  MeetingCall notes(bool notes) => this(notes: notes);

  @override
  MeetingCall notesStatus(MeetingNotesStatus? notesStatus) =>
      this(notesStatus: notesStatus);

  @override
  MeetingCall recordingAvailable(bool recordingAvailable) =>
      this(recordingAvailable: recordingAvailable);

  @override
  MeetingCall notesAvailable(bool notesAvailable) =>
      this(notesAvailable: notesAvailable);

  @override
  MeetingCall guestsQuiet(bool guestsQuiet) => this(guestsQuiet: guestsQuiet);

  @override
  MeetingCall workspace(String? workspace) => this(workspace: workspace);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingCall(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingCall(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingCall call({
    Object? meeting = const $CopyWithPlaceholder(),
    Object? sessionId = const $CopyWithPlaceholder(),
    Object? me = const $CopyWithPlaceholder(),
    Object? rights = const $CopyWithPlaceholder(),
    Object? canAdmit = const $CopyWithPlaceholder(),
    Object? people = const $CopyWithPlaceholder(),
    Object? knocks = const $CopyWithPlaceholder(),
    Object? recording = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? notesStatus = const $CopyWithPlaceholder(),
    Object? recordingAvailable = const $CopyWithPlaceholder(),
    Object? notesAvailable = const $CopyWithPlaceholder(),
    Object? guestsQuiet = const $CopyWithPlaceholder(),
    Object? workspace = const $CopyWithPlaceholder(),
  }) {
    return MeetingCall(
      meeting: meeting == const $CopyWithPlaceholder()
          ? _value.meeting
          // ignore: cast_nullable_to_non_nullable
          : meeting as Meeting,
      sessionId: sessionId == const $CopyWithPlaceholder()
          ? _value.sessionId
          // ignore: cast_nullable_to_non_nullable
          : sessionId as int,
      me: me == const $CopyWithPlaceholder()
          ? _value.me
          // ignore: cast_nullable_to_non_nullable
          : me as MeetingPerson,
      rights: rights == const $CopyWithPlaceholder()
          ? _value.rights
          // ignore: cast_nullable_to_non_nullable
          : rights as MeetingRights,
      canAdmit: canAdmit == const $CopyWithPlaceholder()
          ? _value.canAdmit
          // ignore: cast_nullable_to_non_nullable
          : canAdmit as bool,
      people: people == const $CopyWithPlaceholder()
          ? _value.people
          // ignore: cast_nullable_to_non_nullable
          : people as List<MeetingPerson>,
      knocks: knocks == const $CopyWithPlaceholder()
          ? _value.knocks
          // ignore: cast_nullable_to_non_nullable
          : knocks as List<MeetingKnock>,
      recording: recording == const $CopyWithPlaceholder()
          ? _value.recording
          // ignore: cast_nullable_to_non_nullable
          : recording as bool,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as bool,
      notesStatus: notesStatus == const $CopyWithPlaceholder()
          ? _value.notesStatus
          // ignore: cast_nullable_to_non_nullable
          : notesStatus as MeetingNotesStatus?,
      recordingAvailable: recordingAvailable == const $CopyWithPlaceholder()
          ? _value.recordingAvailable
          // ignore: cast_nullable_to_non_nullable
          : recordingAvailable as bool,
      notesAvailable: notesAvailable == const $CopyWithPlaceholder()
          ? _value.notesAvailable
          // ignore: cast_nullable_to_non_nullable
          : notesAvailable as bool,
      guestsQuiet: guestsQuiet == const $CopyWithPlaceholder()
          ? _value.guestsQuiet
          // ignore: cast_nullable_to_non_nullable
          : guestsQuiet as bool,
      workspace: workspace == const $CopyWithPlaceholder()
          ? _value.workspace
          // ignore: cast_nullable_to_non_nullable
          : workspace as String?,
    );
  }
}

extension $MeetingCallCopyWith on MeetingCall {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingCall.copyWith(...)` or like so:`instanceOfMeetingCall.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingCallCWProxy get copyWith => _$MeetingCallCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingCall _$MeetingCallFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MeetingCall', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'meeting',
          'sessionId',
          'me',
          'rights',
          'canAdmit',
          'people',
          'knocks',
          'recording',
          'notes',
          'recordingAvailable',
          'notesAvailable',
          'guestsQuiet',
        ],
      );
      final val = MeetingCall(
        meeting: $checkedConvert(
          'meeting',
          (v) => Meeting.fromJson(v as Map<String, dynamic>),
        ),
        sessionId: $checkedConvert('sessionId', (v) => (v as num).toInt()),
        me: $checkedConvert(
          'me',
          (v) => MeetingPerson.fromJson(v as Map<String, dynamic>),
        ),
        rights: $checkedConvert(
          'rights',
          (v) => MeetingRights.fromJson(v as Map<String, dynamic>),
        ),
        canAdmit: $checkedConvert('canAdmit', (v) => v as bool),
        people: $checkedConvert(
          'people',
          (v) => (v as List<dynamic>)
              .map((e) => MeetingPerson.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        knocks: $checkedConvert(
          'knocks',
          (v) => (v as List<dynamic>)
              .map((e) => MeetingKnock.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        recording: $checkedConvert('recording', (v) => v as bool),
        notes: $checkedConvert('notes', (v) => v as bool),
        notesStatus: $checkedConvert(
          'notesStatus',
          (v) => $enumDecodeNullable(_$MeetingNotesStatusEnumMap, v),
        ),
        recordingAvailable: $checkedConvert(
          'recordingAvailable',
          (v) => v as bool,
        ),
        notesAvailable: $checkedConvert('notesAvailable', (v) => v as bool),
        guestsQuiet: $checkedConvert('guestsQuiet', (v) => v as bool),
        workspace: $checkedConvert('workspace', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$MeetingCallToJson(MeetingCall instance) =>
    <String, dynamic>{
      'meeting': instance.meeting.toJson(),
      'sessionId': instance.sessionId,
      'me': instance.me.toJson(),
      'rights': instance.rights.toJson(),
      'canAdmit': instance.canAdmit,
      'people': instance.people.map((e) => e.toJson()).toList(),
      'knocks': instance.knocks.map((e) => e.toJson()).toList(),
      'recording': instance.recording,
      'notes': instance.notes,
      'notesStatus': ?_$MeetingNotesStatusEnumMap[instance.notesStatus],
      'recordingAvailable': instance.recordingAvailable,
      'notesAvailable': instance.notesAvailable,
      'guestsQuiet': instance.guestsQuiet,
      'workspace': ?instance.workspace,
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

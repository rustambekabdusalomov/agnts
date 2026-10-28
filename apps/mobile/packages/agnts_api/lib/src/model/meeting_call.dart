//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/meeting_rights.dart';
import 'package:agnts_api/src/model/meeting.dart';
import 'package:agnts_api/src/model/meeting_notes_status.dart';
import 'package:agnts_api/src/model/meeting_person.dart';
import 'package:agnts_api/src/model/meeting_knock.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_call.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingCall {
  /// Returns a new [MeetingCall] instance.
  MeetingCall({

    required  this.meeting,

    required  this.sessionId,

    required  this.me,

    required  this.rights,

    required  this.canAdmit,

    required  this.people,

    required  this.knocks,

    required  this.recording,

    required  this.notes,

     this.notesStatus,

    required  this.recordingAvailable,

    required  this.notesAvailable,

    required  this.guestsQuiet,

     this.workspace,
  });

  @JsonKey(
    
    name: r'meeting',
    required: true,
    includeIfNull: false,
  )


  final Meeting meeting;



  @JsonKey(
    
    name: r'sessionId',
    required: true,
    includeIfNull: false,
  )


  final int sessionId;



  @JsonKey(
    
    name: r'me',
    required: true,
    includeIfNull: false,
  )


  final MeetingPerson me;



  @JsonKey(
    
    name: r'rights',
    required: true,
    includeIfNull: false,
  )


  final MeetingRights rights;



  @JsonKey(
    
    name: r'canAdmit',
    required: true,
    includeIfNull: false,
  )


  final bool canAdmit;



  @JsonKey(
    
    name: r'people',
    required: true,
    includeIfNull: false,
  )


  final List<MeetingPerson> people;



  @JsonKey(
    
    name: r'knocks',
    required: true,
    includeIfNull: false,
  )


  final List<MeetingKnock> knocks;



  @JsonKey(
    
    name: r'recording',
    required: true,
    includeIfNull: false,
  )


  final bool recording;



  @JsonKey(
    
    name: r'notes',
    required: true,
    includeIfNull: false,
  )


  final bool notes;



  @JsonKey(
    
    name: r'notesStatus',
    required: false,
    includeIfNull: false,
  )


  final MeetingNotesStatus? notesStatus;



  @JsonKey(
    
    name: r'recordingAvailable',
    required: true,
    includeIfNull: false,
  )


  final bool recordingAvailable;



  @JsonKey(
    
    name: r'notesAvailable',
    required: true,
    includeIfNull: false,
  )


  final bool notesAvailable;



  @JsonKey(
    
    name: r'guestsQuiet',
    required: true,
    includeIfNull: false,
  )


  final bool guestsQuiet;



      /// The workspace's slug, for members
  @JsonKey(
    
    name: r'workspace',
    required: false,
    includeIfNull: false,
  )


  final String? workspace;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingCall &&
      other.meeting == meeting &&
      other.sessionId == sessionId &&
      other.me == me &&
      other.rights == rights &&
      other.canAdmit == canAdmit &&
      other.people == people &&
      other.knocks == knocks &&
      other.recording == recording &&
      other.notes == notes &&
      other.notesStatus == notesStatus &&
      other.recordingAvailable == recordingAvailable &&
      other.notesAvailable == notesAvailable &&
      other.guestsQuiet == guestsQuiet &&
      other.workspace == workspace;

    @override
    int get hashCode =>
        meeting.hashCode +
        sessionId.hashCode +
        me.hashCode +
        rights.hashCode +
        canAdmit.hashCode +
        people.hashCode +
        knocks.hashCode +
        recording.hashCode +
        notes.hashCode +
        notesStatus.hashCode +
        recordingAvailable.hashCode +
        notesAvailable.hashCode +
        guestsQuiet.hashCode +
        workspace.hashCode;

  factory MeetingCall.fromJson(Map<String, dynamic> json) => _$MeetingCallFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingCallToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


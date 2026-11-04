//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/meeting.dart';
import 'package:agnts_api/src/model/meeting_recording.dart';
import 'package:agnts_api/src/model/meeting_notes_status.dart';
import 'package:agnts_api/src/model/meeting_action_item.dart';
import 'package:agnts_api/src/model/meeting_attendee.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_session_detail.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingSessionDetail {
  /// Returns a new [MeetingSessionDetail] instance.
  MeetingSessionDetail({

    required  this.id,

    required  this.meeting,

    required  this.uploaded,

    required  this.people,

    required  this.startedAt,

     this.endedAt,

    required  this.notesStatus,

    required  this.notesError,

     this.documentId,

    required  this.attendees,

    required  this.recordings,

    required  this.actionItems,

    required  this.messages,

    required  this.canManage,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'meeting',
    required: true,
    includeIfNull: false,
  )


  final Meeting meeting;



      /// A recording a host uploaded, not a call: it has no attendance
  @JsonKey(
    
    name: r'uploaded',
    required: true,
    includeIfNull: false,
  )


  final bool uploaded;



      /// An uploaded recording: the members the uploader said are in it
  @JsonKey(
    
    name: r'people',
    required: true,
    includeIfNull: false,
  )


  final List<int> people;



  @JsonKey(
    
    name: r'startedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime startedAt;



  @JsonKey(
    
    name: r'endedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? endedAt;



  @JsonKey(
    
    name: r'notesStatus',
    required: true,
    includeIfNull: false,
  )


  final MeetingNotesStatus notesStatus;



  @JsonKey(
    
    name: r'notesError',
    required: true,
    includeIfNull: false,
  )


  final String notesError;



  @JsonKey(
    
    name: r'documentId',
    required: false,
    includeIfNull: false,
  )


  final int? documentId;



  @JsonKey(
    
    name: r'attendees',
    required: true,
    includeIfNull: false,
  )


  final List<MeetingAttendee> attendees;



  @JsonKey(
    
    name: r'recordings',
    required: true,
    includeIfNull: false,
  )


  final List<MeetingRecording> recordings;



  @JsonKey(
    
    name: r'actionItems',
    required: true,
    includeIfNull: false,
  )


  final List<MeetingActionItem> actionItems;



      /// Chat messages
  @JsonKey(
    
    name: r'messages',
    required: true,
    includeIfNull: false,
  )


  final int messages;



  @JsonKey(
    
    name: r'canManage',
    required: true,
    includeIfNull: false,
  )


  final bool canManage;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingSessionDetail &&
      other.id == id &&
      other.meeting == meeting &&
      other.uploaded == uploaded &&
      other.people == people &&
      other.startedAt == startedAt &&
      other.endedAt == endedAt &&
      other.notesStatus == notesStatus &&
      other.notesError == notesError &&
      other.documentId == documentId &&
      other.attendees == attendees &&
      other.recordings == recordings &&
      other.actionItems == actionItems &&
      other.messages == messages &&
      other.canManage == canManage;

    @override
    int get hashCode =>
        id.hashCode +
        meeting.hashCode +
        uploaded.hashCode +
        people.hashCode +
        startedAt.hashCode +
        endedAt.hashCode +
        notesStatus.hashCode +
        notesError.hashCode +
        documentId.hashCode +
        attendees.hashCode +
        recordings.hashCode +
        actionItems.hashCode +
        messages.hashCode +
        canManage.hashCode;

  factory MeetingSessionDetail.fromJson(Map<String, dynamic> json) => _$MeetingSessionDetailFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingSessionDetailToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


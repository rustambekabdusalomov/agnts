//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/meeting_notes_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_session_summary.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingSessionSummary {
  /// Returns a new [MeetingSessionSummary] instance.
  MeetingSessionSummary({

    required  this.id,

    required  this.meetingId,

    required  this.meetingCode,

    required  this.meetingTitle,

    required  this.startedAt,

     this.endedAt,

    required  this.people,

    required  this.recordings,

    required  this.actionItems,

    required  this.notesStatus,

    required  this.notesError,

     this.documentId,

    required  this.documentTitle,

    required  this.uploaded,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'meetingId',
    required: true,
    includeIfNull: false,
  )


  final int meetingId;



  @JsonKey(
    
    name: r'meetingCode',
    required: true,
    includeIfNull: false,
  )


  final String meetingCode;



  @JsonKey(
    
    name: r'meetingTitle',
    required: true,
    includeIfNull: false,
  )


  final String meetingTitle;



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
    
    name: r'people',
    required: true,
    includeIfNull: false,
  )


  final int people;



  @JsonKey(
    
    name: r'recordings',
    required: true,
    includeIfNull: false,
  )


  final int recordings;



  @JsonKey(
    
    name: r'actionItems',
    required: true,
    includeIfNull: false,
  )


  final int actionItems;



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
    
    name: r'documentTitle',
    required: true,
    includeIfNull: false,
  )


  final String documentTitle;



      /// A recording a host uploaded, not a call
  @JsonKey(
    
    name: r'uploaded',
    required: true,
    includeIfNull: false,
  )


  final bool uploaded;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingSessionSummary &&
      other.id == id &&
      other.meetingId == meetingId &&
      other.meetingCode == meetingCode &&
      other.meetingTitle == meetingTitle &&
      other.startedAt == startedAt &&
      other.endedAt == endedAt &&
      other.people == people &&
      other.recordings == recordings &&
      other.actionItems == actionItems &&
      other.notesStatus == notesStatus &&
      other.notesError == notesError &&
      other.documentId == documentId &&
      other.documentTitle == documentTitle &&
      other.uploaded == uploaded;

    @override
    int get hashCode =>
        id.hashCode +
        meetingId.hashCode +
        meetingCode.hashCode +
        meetingTitle.hashCode +
        startedAt.hashCode +
        endedAt.hashCode +
        people.hashCode +
        recordings.hashCode +
        actionItems.hashCode +
        notesStatus.hashCode +
        notesError.hashCode +
        documentId.hashCode +
        documentTitle.hashCode +
        uploaded.hashCode;

  factory MeetingSessionSummary.fromJson(Map<String, dynamic> json) => _$MeetingSessionSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingSessionSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


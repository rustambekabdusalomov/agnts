//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/meeting_notes_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_session_brief.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingSessionBrief {
  /// Returns a new [MeetingSessionBrief] instance.
  MeetingSessionBrief({

    required  this.id,

    required  this.startedAt,

     this.connectedAt,

     this.endedAt,

    required  this.notesStatus,

    required  this.notesError,

     this.documentId,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'startedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime startedAt;



  @JsonKey(
    
    name: r'connectedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? connectedAt;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingSessionBrief &&
      other.id == id &&
      other.startedAt == startedAt &&
      other.connectedAt == connectedAt &&
      other.endedAt == endedAt &&
      other.notesStatus == notesStatus &&
      other.notesError == notesError &&
      other.documentId == documentId;

    @override
    int get hashCode =>
        id.hashCode +
        startedAt.hashCode +
        connectedAt.hashCode +
        endedAt.hashCode +
        notesStatus.hashCode +
        notesError.hashCode +
        documentId.hashCode;

  factory MeetingSessionBrief.fromJson(Map<String, dynamic> json) => _$MeetingSessionBriefFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingSessionBriefToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


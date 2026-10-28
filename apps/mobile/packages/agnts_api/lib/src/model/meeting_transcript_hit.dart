//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/meeting_segment.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_transcript_hit.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingTranscriptHit {
  /// Returns a new [MeetingTranscriptHit] instance.
  MeetingTranscriptHit({

    required  this.meetingId,

    required  this.meetingTitle,

    required  this.sessionId,

    required  this.startedAt,

    required  this.segment,
  });

  @JsonKey(
    
    name: r'meetingId',
    required: true,
    includeIfNull: false,
  )


  final int meetingId;



  @JsonKey(
    
    name: r'meetingTitle',
    required: true,
    includeIfNull: false,
  )


  final String meetingTitle;



  @JsonKey(
    
    name: r'sessionId',
    required: true,
    includeIfNull: false,
  )


  final int sessionId;



  @JsonKey(
    
    name: r'startedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime startedAt;



  @JsonKey(
    
    name: r'segment',
    required: true,
    includeIfNull: false,
  )


  final MeetingSegment segment;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingTranscriptHit &&
      other.meetingId == meetingId &&
      other.meetingTitle == meetingTitle &&
      other.sessionId == sessionId &&
      other.startedAt == startedAt &&
      other.segment == segment;

    @override
    int get hashCode =>
        meetingId.hashCode +
        meetingTitle.hashCode +
        sessionId.hashCode +
        startedAt.hashCode +
        segment.hashCode;

  factory MeetingTranscriptHit.fromJson(Map<String, dynamic> json) => _$MeetingTranscriptHitFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingTranscriptHitToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


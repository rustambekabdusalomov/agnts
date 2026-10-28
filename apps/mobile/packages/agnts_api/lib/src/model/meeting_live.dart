//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_live.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingLive {
  /// Returns a new [MeetingLive] instance.
  MeetingLive({

    required  this.sessionId,

    required  this.startedAt,

    required  this.inCall,

    required  this.recording,

    required  this.notes,
  });

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



      /// People in the call now
  @JsonKey(
    
    name: r'inCall',
    required: true,
    includeIfNull: false,
  )


  final int inCall;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingLive &&
      other.sessionId == sessionId &&
      other.startedAt == startedAt &&
      other.inCall == inCall &&
      other.recording == recording &&
      other.notes == notes;

    @override
    int get hashCode =>
        sessionId.hashCode +
        startedAt.hashCode +
        inCall.hashCode +
        recording.hashCode +
        notes.hashCode;

  factory MeetingLive.fromJson(Map<String, dynamic> json) => _$MeetingLiveFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingLiveToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


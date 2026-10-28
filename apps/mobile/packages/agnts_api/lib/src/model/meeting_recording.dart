//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_recording.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingRecording {
  /// Returns a new [MeetingRecording] instance.
  MeetingRecording({

    required  this.id,

    required  this.startedAt,

     this.endedAt,

    required  this.seconds,

    required  this.bytes,

    required  this.status,
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
    
    name: r'endedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? endedAt;



  @JsonKey(
    
    name: r'seconds',
    required: true,
    includeIfNull: false,
  )


  final int seconds;



  @JsonKey(
    
    name: r'bytes',
    required: true,
    includeIfNull: false,
  )


  final int bytes;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final MeetingRecordingStatusEnum status;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingRecording &&
      other.id == id &&
      other.startedAt == startedAt &&
      other.endedAt == endedAt &&
      other.seconds == seconds &&
      other.bytes == bytes &&
      other.status == status;

    @override
    int get hashCode =>
        id.hashCode +
        startedAt.hashCode +
        endedAt.hashCode +
        seconds.hashCode +
        bytes.hashCode +
        status.hashCode;

  factory MeetingRecording.fromJson(Map<String, dynamic> json) => _$MeetingRecordingFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingRecordingToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum MeetingRecordingStatusEnum {
@JsonValue(r'active')
active(r'active'),
@JsonValue(r'ready')
ready(r'ready');

const MeetingRecordingStatusEnum(this.value);

final String value;

@override
String toString() => value;
}



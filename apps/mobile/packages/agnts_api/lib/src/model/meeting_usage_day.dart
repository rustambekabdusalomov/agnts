//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_usage_day.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingUsageDay {
  /// Returns a new [MeetingUsageDay] instance.
  MeetingUsageDay({

    required  this.day,

    required  this.sessions,

    required  this.participantMinutes,

    required  this.recordingMinutes,

    required  this.recordingBytes,

    required  this.transcribedMinutes,
  });

  @JsonKey(
    
    name: r'day',
    required: true,
    includeIfNull: false,
  )


  final DateTime day;



  @JsonKey(
    
    name: r'sessions',
    required: true,
    includeIfNull: false,
  )


  final int sessions;



  @JsonKey(
    
    name: r'participantMinutes',
    required: true,
    includeIfNull: false,
  )


  final int participantMinutes;



  @JsonKey(
    
    name: r'recordingMinutes',
    required: true,
    includeIfNull: false,
  )


  final int recordingMinutes;



  @JsonKey(
    
    name: r'recordingBytes',
    required: true,
    includeIfNull: false,
  )


  final int recordingBytes;



  @JsonKey(
    
    name: r'transcribedMinutes',
    required: true,
    includeIfNull: false,
  )


  final int transcribedMinutes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingUsageDay &&
      other.day == day &&
      other.sessions == sessions &&
      other.participantMinutes == participantMinutes &&
      other.recordingMinutes == recordingMinutes &&
      other.recordingBytes == recordingBytes &&
      other.transcribedMinutes == transcribedMinutes;

    @override
    int get hashCode =>
        day.hashCode +
        sessions.hashCode +
        participantMinutes.hashCode +
        recordingMinutes.hashCode +
        recordingBytes.hashCode +
        transcribedMinutes.hashCode;

  factory MeetingUsageDay.fromJson(Map<String, dynamic> json) => _$MeetingUsageDayFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingUsageDayToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


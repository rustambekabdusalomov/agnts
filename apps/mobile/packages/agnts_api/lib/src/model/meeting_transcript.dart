//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/meeting_segment.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_transcript.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingTranscript {
  /// Returns a new [MeetingTranscript] instance.
  MeetingTranscript({

    required  this.segments,

    required  this.speakers,
  });

  @JsonKey(
    
    name: r'segments',
    required: true,
    includeIfNull: false,
  )


  final List<MeetingSegment> segments;



      /// The segments name who spoke
  @JsonKey(
    
    name: r'speakers',
    required: true,
    includeIfNull: false,
  )


  final bool speakers;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingTranscript &&
      other.segments == segments &&
      other.speakers == speakers;

    @override
    int get hashCode =>
        segments.hashCode +
        speakers.hashCode;

  factory MeetingTranscript.fromJson(Map<String, dynamic> json) => _$MeetingTranscriptFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingTranscriptToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


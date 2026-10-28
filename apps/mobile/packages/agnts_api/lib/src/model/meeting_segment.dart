//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_segment.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingSegment {
  /// Returns a new [MeetingSegment] instance.
  MeetingSegment({

    required  this.startMs,

    required  this.endMs,

    required  this.name,

    required  this.text,
  });

  @JsonKey(
    
    name: r'startMs',
    required: true,
    includeIfNull: false,
  )


  final int startMs;



  @JsonKey(
    
    name: r'endMs',
    required: true,
    includeIfNull: false,
  )


  final int endMs;



      /// Who spoke; empty when the audio did not say
  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'text',
    required: true,
    includeIfNull: false,
  )


  final String text;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingSegment &&
      other.startMs == startMs &&
      other.endMs == endMs &&
      other.name == name &&
      other.text == text;

    @override
    int get hashCode =>
        startMs.hashCode +
        endMs.hashCode +
        name.hashCode +
        text.hashCode;

  factory MeetingSegment.fromJson(Map<String, dynamic> json) => _$MeetingSegmentFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingSegmentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


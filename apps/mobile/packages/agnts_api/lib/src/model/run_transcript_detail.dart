//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/run_transcript.dart';
import 'package:agnts_api/src/model/run_transcript_event.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'run_transcript_detail.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RunTranscriptDetail {
  /// Returns a new [RunTranscriptDetail] instance.
  RunTranscriptDetail({

    required  this.transcript,

    required  this.events,

    required  this.siblings,

     this.unreadable,
  });

  @JsonKey(
    
    name: r'transcript',
    required: true,
    includeIfNull: false,
  )


  final RunTranscript transcript;



  @JsonKey(
    
    name: r'events',
    required: true,
    includeIfNull: false,
  )


  final List<RunTranscriptEvent> events;



      /// The run's other invocations (first pass, fix attempts, second opinion), oldest first
  @JsonKey(
    
    name: r'siblings',
    required: true,
    includeIfNull: false,
  )


  final List<RunTranscript> siblings;



      /// Part of the stored body could not be read; events holds what could
  @JsonKey(
    
    name: r'unreadable',
    required: false,
    includeIfNull: false,
  )


  final bool? unreadable;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RunTranscriptDetail &&
      other.transcript == transcript &&
      other.events == events &&
      other.siblings == siblings &&
      other.unreadable == unreadable;

    @override
    int get hashCode =>
        transcript.hashCode +
        events.hashCode +
        siblings.hashCode +
        unreadable.hashCode;

  factory RunTranscriptDetail.fromJson(Map<String, dynamic> json) => _$RunTranscriptDetailFromJson(json);

  Map<String, dynamic> toJson() => _$RunTranscriptDetailToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


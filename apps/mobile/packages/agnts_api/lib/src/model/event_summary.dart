//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/step_duration.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_summary.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventSummary {
  /// Returns a new [EventSummary] instance.
  EventSummary({

    required  this.runsStarted,

    required  this.reachedReview,

    required  this.avgTurns,

    required  this.stops,

    required  this.errors,

    required  this.steps,
  });

  @JsonKey(
    
    name: r'runsStarted',
    required: true,
    includeIfNull: false,
  )


  final int runsStarted;



  @JsonKey(
    
    name: r'reachedReview',
    required: true,
    includeIfNull: false,
  )


  final int reachedReview;



  @JsonKey(
    
    name: r'avgTurns',
    required: true,
    includeIfNull: false,
  )


  final int avgTurns;



  @JsonKey(
    
    name: r'stops',
    required: true,
    includeIfNull: false,
  )


  final int stops;



  @JsonKey(
    
    name: r'errors',
    required: true,
    includeIfNull: false,
  )


  final int errors;



  @JsonKey(
    
    name: r'steps',
    required: true,
    includeIfNull: false,
  )


  final List<StepDuration> steps;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EventSummary &&
      other.runsStarted == runsStarted &&
      other.reachedReview == reachedReview &&
      other.avgTurns == avgTurns &&
      other.stops == stops &&
      other.errors == errors &&
      other.steps == steps;

    @override
    int get hashCode =>
        runsStarted.hashCode +
        reachedReview.hashCode +
        avgTurns.hashCode +
        stops.hashCode +
        errors.hashCode +
        steps.hashCode;

  factory EventSummary.fromJson(Map<String, dynamic> json) => _$EventSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$EventSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


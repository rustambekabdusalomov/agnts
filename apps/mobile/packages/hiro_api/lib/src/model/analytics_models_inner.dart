//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analytics_models_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalyticsModelsInner {
  /// Returns a new [AnalyticsModelsInner] instance.
  AnalyticsModelsInner({

    required  this.model,

    required  this.runs,

    required  this.reachedReview,

    required  this.avgTurns,
  });

  @JsonKey(
    
    name: r'model',
    required: true,
    includeIfNull: false,
  )


  final String model;



  @JsonKey(
    
    name: r'runs',
    required: true,
    includeIfNull: false,
  )


  final int runs;



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


  final num avgTurns;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AnalyticsModelsInner &&
      other.model == model &&
      other.runs == runs &&
      other.reachedReview == reachedReview &&
      other.avgTurns == avgTurns;

    @override
    int get hashCode =>
        model.hashCode +
        runs.hashCode +
        reachedReview.hashCode +
        avgTurns.hashCode;

  factory AnalyticsModelsInner.fromJson(Map<String, dynamic> json) => _$AnalyticsModelsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsModelsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


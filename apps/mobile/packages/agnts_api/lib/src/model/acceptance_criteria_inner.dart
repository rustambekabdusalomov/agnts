//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'acceptance_criteria_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AcceptanceCriteriaInner {
  /// Returns a new [AcceptanceCriteriaInner] instance.
  AcceptanceCriteriaInner({

    required  this.id,

    required  this.criterion,

    required  this.verdict,

     this.evidence,

     this.steps,

     this.shots,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'criterion',
    required: true,
    includeIfNull: false,
  )


  final String criterion;



  @JsonKey(
    
    name: r'verdict',
    required: true,
    includeIfNull: false,
  )


  final AcceptanceCriteriaInnerVerdictEnum verdict;



  @JsonKey(
    
    name: r'evidence',
    required: false,
    includeIfNull: false,
  )


  final String? evidence;



  @JsonKey(
    
    name: r'steps',
    required: false,
    includeIfNull: false,
  )


  final List<String>? steps;



      /// Screenshot ids in the preview
  @JsonKey(
    
    name: r'shots',
    required: false,
    includeIfNull: false,
  )


  final List<String>? shots;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AcceptanceCriteriaInner &&
      other.id == id &&
      other.criterion == criterion &&
      other.verdict == verdict &&
      other.evidence == evidence &&
      other.steps == steps &&
      other.shots == shots;

    @override
    int get hashCode =>
        id.hashCode +
        criterion.hashCode +
        verdict.hashCode +
        evidence.hashCode +
        steps.hashCode +
        shots.hashCode;

  factory AcceptanceCriteriaInner.fromJson(Map<String, dynamic> json) => _$AcceptanceCriteriaInnerFromJson(json);

  Map<String, dynamic> toJson() => _$AcceptanceCriteriaInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum AcceptanceCriteriaInnerVerdictEnum {
@JsonValue(r'pass')
pass(r'pass'),
@JsonValue(r'fail')
fail(r'fail'),
@JsonValue(r'unknown')
unknown(r'unknown');

const AcceptanceCriteriaInnerVerdictEnum(this.value);

final String value;

@override
String toString() => value;
}



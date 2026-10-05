//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hiro_api/src/model/model.dart';
import 'package:hiro_api/src/model/finding.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'code_review.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CodeReview {
  /// Returns a new [CodeReview] instance.
  CodeReview({

    required  this.revision,

    required  this.model,

    required  this.modelReason,

    required  this.verdict,

    required  this.summary,

    required  this.findings,

    required  this.strengths,

    required  this.createdAt,
  });

  @JsonKey(
    
    name: r'revision',
    required: true,
    includeIfNull: false,
  )


  final int revision;



  @JsonKey(
    
    name: r'model',
    required: true,
    includeIfNull: false,
  )


  final Model model;



      /// Why this model reviewed it
  @JsonKey(
    
    name: r'modelReason',
    required: true,
    includeIfNull: false,
  )


  final String modelReason;



  @JsonKey(
    
    name: r'verdict',
    required: true,
    includeIfNull: false,
  )


  final CodeReviewVerdictEnum verdict;



  @JsonKey(
    
    name: r'summary',
    required: true,
    includeIfNull: false,
  )


  final String summary;



  @JsonKey(
    
    name: r'findings',
    required: true,
    includeIfNull: false,
  )


  final List<Finding> findings;



  @JsonKey(
    
    name: r'strengths',
    required: true,
    includeIfNull: false,
  )


  final List<String> strengths;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CodeReview &&
      other.revision == revision &&
      other.model == model &&
      other.modelReason == modelReason &&
      other.verdict == verdict &&
      other.summary == summary &&
      other.findings == findings &&
      other.strengths == strengths &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        revision.hashCode +
        model.hashCode +
        modelReason.hashCode +
        verdict.hashCode +
        summary.hashCode +
        findings.hashCode +
        strengths.hashCode +
        createdAt.hashCode;

  factory CodeReview.fromJson(Map<String, dynamic> json) => _$CodeReviewFromJson(json);

  Map<String, dynamic> toJson() => _$CodeReviewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum CodeReviewVerdictEnum {
@JsonValue(r'looks_good')
looksGood(r'looks_good'),
@JsonValue(r'has_concerns')
hasConcerns(r'has_concerns'),
@JsonValue(r'needs_changes')
needsChanges(r'needs_changes');

const CodeReviewVerdictEnum(this.value);

final String value;

@override
String toString() => value;
}



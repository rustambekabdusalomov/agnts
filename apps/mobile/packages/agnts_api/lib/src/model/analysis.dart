//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/analysis_acceptance_inner.dart';
import 'package:agnts_api/src/model/footprint.dart';
import 'package:agnts_api/src/model/second_opinion.dart';
import 'package:agnts_api/src/model/approach.dart';
import 'package:agnts_api/src/model/ship_notes.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analysis.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Analysis {
  /// Returns a new [Analysis] instance.
  Analysis({

    required  this.summary,

    required  this.plan,

     this.complexity,

     this.footprint,

     this.approaches,

     this.outOfScope,

     this.ship,

     this.defect,

     this.acceptance,

     this.secondOpinion,
  });

  @JsonKey(
    
    name: r'summary',
    required: true,
    includeIfNull: false,
  )


  final String summary;



  @JsonKey(
    
    name: r'plan',
    required: true,
    includeIfNull: false,
  )


  final List<String> plan;



      /// The analysis's rating; picks the review model on auto
  @JsonKey(
    
    name: r'complexity',
    required: false,
    includeIfNull: false,
  )


  final AnalysisComplexityEnum? complexity;



  @JsonKey(
    
    name: r'footprint',
    required: false,
    includeIfNull: false,
  )


  final Footprint? footprint;



      /// Ways to do the work that the analysis weighed; exactly one is chosen
  @JsonKey(
    
    name: r'approaches',
    required: false,
    includeIfNull: false,
  )


  final List<Approach>? approaches;



      /// What the work will deliberately not do
  @JsonKey(
    
    name: r'outOfScope',
    required: false,
    includeIfNull: false,
  )


  final List<String>? outOfScope;



  @JsonKey(
    
    name: r'ship',
    required: false,
    includeIfNull: false,
  )


  final ShipNotes? ship;



      /// The work fixes broken behaviour; with proveFixes on it must prove the fix
  @JsonKey(
    
    name: r'defect',
    required: false,
    includeIfNull: false,
  )


  final bool? defect;



      /// What the finished work must do, as checks
  @JsonKey(
    
    name: r'acceptance',
    required: false,
    includeIfNull: false,
  )


  final List<AnalysisAcceptanceInner>? acceptance;



  @JsonKey(
    
    name: r'secondOpinion',
    required: false,
    includeIfNull: false,
  )


  final SecondOpinion? secondOpinion;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Analysis &&
      other.summary == summary &&
      other.plan == plan &&
      other.complexity == complexity &&
      other.footprint == footprint &&
      other.approaches == approaches &&
      other.outOfScope == outOfScope &&
      other.ship == ship &&
      other.defect == defect &&
      other.acceptance == acceptance &&
      other.secondOpinion == secondOpinion;

    @override
    int get hashCode =>
        summary.hashCode +
        plan.hashCode +
        complexity.hashCode +
        footprint.hashCode +
        approaches.hashCode +
        outOfScope.hashCode +
        ship.hashCode +
        defect.hashCode +
        acceptance.hashCode +
        secondOpinion.hashCode;

  factory Analysis.fromJson(Map<String, dynamic> json) => _$AnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// The analysis's rating; picks the review model on auto
enum AnalysisComplexityEnum {
@JsonValue(r'simple')
simple(r'simple'),
@JsonValue(r'complex')
complex(r'complex');

const AnalysisComplexityEnum(this.value);

final String value;

@override
String toString() => value;
}



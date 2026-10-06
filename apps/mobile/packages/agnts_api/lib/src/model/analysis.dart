//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/footprint.dart';
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





    @override
    bool operator ==(Object other) => identical(this, other) || other is Analysis &&
      other.summary == summary &&
      other.plan == plan &&
      other.complexity == complexity &&
      other.footprint == footprint;

    @override
    int get hashCode =>
        summary.hashCode +
        plan.hashCode +
        complexity.hashCode +
        footprint.hashCode;

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



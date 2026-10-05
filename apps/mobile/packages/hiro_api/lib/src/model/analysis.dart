//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
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





    @override
    bool operator ==(Object other) => identical(this, other) || other is Analysis &&
      other.summary == summary &&
      other.plan == plan;

    @override
    int get hashCode =>
        summary.hashCode +
        plan.hashCode;

  factory Analysis.fromJson(Map<String, dynamic> json) => _$AnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


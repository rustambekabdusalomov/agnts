//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analysis_test_plan_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalysisTestPlanInner {
  /// Returns a new [AnalysisTestPlanInner] instance.
  AnalysisTestPlanInner({

    required  this.file,

    required  this.what,
  });

  @JsonKey(
    
    name: r'file',
    required: true,
    includeIfNull: false,
  )


  final String file;



  @JsonKey(
    
    name: r'what',
    required: true,
    includeIfNull: false,
  )


  final String what;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AnalysisTestPlanInner &&
      other.file == file &&
      other.what == what;

    @override
    int get hashCode =>
        file.hashCode +
        what.hashCode;

  factory AnalysisTestPlanInner.fromJson(Map<String, dynamic> json) => _$AnalysisTestPlanInnerFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisTestPlanInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


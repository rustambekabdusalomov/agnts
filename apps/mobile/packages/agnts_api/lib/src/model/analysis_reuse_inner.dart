//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analysis_reuse_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalysisReuseInner {
  /// Returns a new [AnalysisReuseInner] instance.
  AnalysisReuseInner({

    required  this.name,

    required  this.where,

     this.for_,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'where',
    required: true,
    includeIfNull: false,
  )


  final String where;



  @JsonKey(
    
    name: r'for',
    required: false,
    includeIfNull: false,
  )


  final String? for_;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AnalysisReuseInner &&
      other.name == name &&
      other.where == where &&
      other.for_ == for_;

    @override
    int get hashCode =>
        name.hashCode +
        where.hashCode +
        for_.hashCode;

  factory AnalysisReuseInner.fromJson(Map<String, dynamic> json) => _$AnalysisReuseInnerFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisReuseInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


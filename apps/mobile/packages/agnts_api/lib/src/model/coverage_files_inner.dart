//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/coverage_files_inner_uncovered_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'coverage_files_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CoverageFilesInner {
  /// Returns a new [CoverageFilesInner] instance.
  CoverageFilesInner({

    required  this.path,

    required  this.covered,

    required  this.total,

    required  this.uncovered,
  });

  @JsonKey(
    
    name: r'path',
    required: true,
    includeIfNull: false,
  )


  final String path;



  @JsonKey(
    
    name: r'covered',
    required: true,
    includeIfNull: false,
  )


  final int covered;



  @JsonKey(
    
    name: r'total',
    required: true,
    includeIfNull: false,
  )


  final int total;



  @JsonKey(
    
    name: r'uncovered',
    required: true,
    includeIfNull: false,
  )


  final List<CoverageFilesInnerUncoveredInner> uncovered;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CoverageFilesInner &&
      other.path == path &&
      other.covered == covered &&
      other.total == total &&
      other.uncovered == uncovered;

    @override
    int get hashCode =>
        path.hashCode +
        covered.hashCode +
        total.hashCode +
        uncovered.hashCode;

  factory CoverageFilesInner.fromJson(Map<String, dynamic> json) => _$CoverageFilesInnerFromJson(json);

  Map<String, dynamic> toJson() => _$CoverageFilesInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


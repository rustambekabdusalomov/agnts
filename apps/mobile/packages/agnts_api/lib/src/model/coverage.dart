//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/coverage_files_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'coverage.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Coverage {
  /// Returns a new [Coverage] instance.
  Coverage({

    required  this.covered,

    required  this.total,

    required  this.percent,

     this.threshold,

     this.error,

    required  this.files,
  });

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
    
    name: r'percent',
    required: true,
    includeIfNull: false,
  )


  final num percent;



  @JsonKey(
    
    name: r'threshold',
    required: false,
    includeIfNull: false,
  )


  final int? threshold;



  @JsonKey(
    
    name: r'error',
    required: false,
    includeIfNull: false,
  )


  final String? error;



  @JsonKey(
    
    name: r'files',
    required: true,
    includeIfNull: false,
  )


  final List<CoverageFilesInner> files;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Coverage &&
      other.covered == covered &&
      other.total == total &&
      other.percent == percent &&
      other.threshold == threshold &&
      other.error == error &&
      other.files == files;

    @override
    int get hashCode =>
        covered.hashCode +
        total.hashCode +
        percent.hashCode +
        threshold.hashCode +
        error.hashCode +
        files.hashCode;

  factory Coverage.fromJson(Map<String, dynamic> json) => _$CoverageFromJson(json);

  Map<String, dynamic> toJson() => _$CoverageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


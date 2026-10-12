//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'coverage_files_inner_uncovered_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CoverageFilesInnerUncoveredInner {
  /// Returns a new [CoverageFilesInnerUncoveredInner] instance.
  CoverageFilesInnerUncoveredInner({

    required  this.from,

    required  this.to,
  });

  @JsonKey(
    
    name: r'from',
    required: true,
    includeIfNull: false,
  )


  final int from;



  @JsonKey(
    
    name: r'to',
    required: true,
    includeIfNull: false,
  )


  final int to;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CoverageFilesInnerUncoveredInner &&
      other.from == from &&
      other.to == to;

    @override
    int get hashCode =>
        from.hashCode +
        to.hashCode;

  factory CoverageFilesInnerUncoveredInner.fromJson(Map<String, dynamic> json) => _$CoverageFilesInnerUncoveredInnerFromJson(json);

  Map<String, dynamic> toJson() => _$CoverageFilesInnerUncoveredInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


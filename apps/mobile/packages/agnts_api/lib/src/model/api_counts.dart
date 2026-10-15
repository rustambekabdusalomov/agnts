//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api_counts.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ApiCounts {
  /// Returns a new [ApiCounts] instance.
  ApiCounts({

    required  this.passed,

    required  this.failed,

    required  this.skipped,

    required  this.blocked,
  });

  @JsonKey(
    
    name: r'passed',
    required: true,
    includeIfNull: false,
  )


  final int passed;



  @JsonKey(
    
    name: r'failed',
    required: true,
    includeIfNull: false,
  )


  final int failed;



  @JsonKey(
    
    name: r'skipped',
    required: true,
    includeIfNull: false,
  )


  final int skipped;



  @JsonKey(
    
    name: r'blocked',
    required: true,
    includeIfNull: false,
  )


  final int blocked;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ApiCounts &&
      other.passed == passed &&
      other.failed == failed &&
      other.skipped == skipped &&
      other.blocked == blocked;

    @override
    int get hashCode =>
        passed.hashCode +
        failed.hashCode +
        skipped.hashCode +
        blocked.hashCode;

  factory ApiCounts.fromJson(Map<String, dynamic> json) => _$ApiCountsFromJson(json);

  Map<String, dynamic> toJson() => _$ApiCountsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


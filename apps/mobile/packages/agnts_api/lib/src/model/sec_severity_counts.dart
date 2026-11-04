//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sec_severity_counts.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SecSeverityCounts {
  /// Returns a new [SecSeverityCounts] instance.
  SecSeverityCounts({

    required  this.critical,

    required  this.high,

    required  this.medium,

    required  this.low,

    required  this.info,
  });

  @JsonKey(
    
    name: r'critical',
    required: true,
    includeIfNull: false,
  )


  final int critical;



  @JsonKey(
    
    name: r'high',
    required: true,
    includeIfNull: false,
  )


  final int high;



  @JsonKey(
    
    name: r'medium',
    required: true,
    includeIfNull: false,
  )


  final int medium;



  @JsonKey(
    
    name: r'low',
    required: true,
    includeIfNull: false,
  )


  final int low;



  @JsonKey(
    
    name: r'info',
    required: true,
    includeIfNull: false,
  )


  final int info;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SecSeverityCounts &&
      other.critical == critical &&
      other.high == high &&
      other.medium == medium &&
      other.low == low &&
      other.info == info;

    @override
    int get hashCode =>
        critical.hashCode +
        high.hashCode +
        medium.hashCode +
        low.hashCode +
        info.hashCode;

  factory SecSeverityCounts.fromJson(Map<String, dynamic> json) => _$SecSeverityCountsFromJson(json);

  Map<String, dynamic> toJson() => _$SecSeverityCountsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


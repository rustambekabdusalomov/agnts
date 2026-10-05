//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hour_bucket.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HourBucket {
  /// Returns a new [HourBucket] instance.
  HourBucket({

    required  this.hour,

    required  this.hiro,

    required  this.you,

    required  this.problems,
  });

  @JsonKey(
    
    name: r'hour',
    required: true,
    includeIfNull: false,
  )


  final int hour;



  @JsonKey(
    
    name: r'hiro',
    required: true,
    includeIfNull: false,
  )


  final int hiro;



  @JsonKey(
    
    name: r'you',
    required: true,
    includeIfNull: false,
  )


  final int you;



  @JsonKey(
    
    name: r'problems',
    required: true,
    includeIfNull: false,
  )


  final int problems;





    @override
    bool operator ==(Object other) => identical(this, other) || other is HourBucket &&
      other.hour == hour &&
      other.hiro == hiro &&
      other.you == you &&
      other.problems == problems;

    @override
    int get hashCode =>
        hour.hashCode +
        hiro.hashCode +
        you.hashCode +
        problems.hashCode;

  factory HourBucket.fromJson(Map<String, dynamic> json) => _$HourBucketFromJson(json);

  Map<String, dynamic> toJson() => _$HourBucketToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


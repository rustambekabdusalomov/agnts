//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'follow_up_count.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FollowUpCount {
  /// Returns a new [FollowUpCount] instance.
  FollowUpCount({

    required  this.name,

    required  this.suggested,

    required  this.accepted,

    required  this.dismissed,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'suggested',
    required: true,
    includeIfNull: false,
  )


  final int suggested;



  @JsonKey(
    
    name: r'accepted',
    required: true,
    includeIfNull: false,
  )


  final int accepted;



  @JsonKey(
    
    name: r'dismissed',
    required: true,
    includeIfNull: false,
  )


  final int dismissed;





    @override
    bool operator ==(Object other) => identical(this, other) || other is FollowUpCount &&
      other.name == name &&
      other.suggested == suggested &&
      other.accepted == accepted &&
      other.dismissed == dismissed;

    @override
    int get hashCode =>
        name.hashCode +
        suggested.hashCode +
        accepted.hashCode +
        dismissed.hashCode;

  factory FollowUpCount.fromJson(Map<String, dynamic> json) => _$FollowUpCountFromJson(json);

  Map<String, dynamic> toJson() => _$FollowUpCountToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/accept_follow_up.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'accept_follow_ups.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AcceptFollowUps {
  /// Returns a new [AcceptFollowUps] instance.
  AcceptFollowUps({

    required  this.items,
  });

  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<AcceptFollowUp> items;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AcceptFollowUps &&
      other.items == items;

    @override
    int get hashCode =>
        items.hashCode;

  factory AcceptFollowUps.fromJson(Map<String, dynamic> json) => _$AcceptFollowUpsFromJson(json);

  Map<String, dynamic> toJson() => _$AcceptFollowUpsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


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

     this.start,
  });

  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<AcceptFollowUp> items;



      /// Queue the new tickets to run now instead of holding them until someone starts each one
  @JsonKey(
    
    name: r'start',
    required: false,
    includeIfNull: false,
  )


  final bool? start;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AcceptFollowUps &&
      other.items == items &&
      other.start == start;

    @override
    int get hashCode =>
        items.hashCode +
        start.hashCode;

  factory AcceptFollowUps.fromJson(Map<String, dynamic> json) => _$AcceptFollowUpsFromJson(json);

  Map<String, dynamic> toJson() => _$AcceptFollowUpsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/relation.dart';
import 'package:agnts_api/src/model/blocker.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'relations.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Relations {
  /// Returns a new [Relations] instance.
  Relations({

    required  this.items,

    required  this.blockedBy,
  });

  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<Relation> items;



      /// What holds the ticket's coding back right now
  @JsonKey(
    
    name: r'blockedBy',
    required: true,
    includeIfNull: false,
  )


  final List<Blocker> blockedBy;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Relations &&
      other.items == items &&
      other.blockedBy == blockedBy;

    @override
    int get hashCode =>
        items.hashCode +
        blockedBy.hashCode;

  factory Relations.fromJson(Map<String, dynamic> json) => _$RelationsFromJson(json);

  Map<String, dynamic> toJson() => _$RelationsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


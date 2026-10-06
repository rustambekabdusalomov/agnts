//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/relation_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'relation_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RelationInput {
  /// Returns a new [RelationInput] instance.
  RelationInput({

    required  this.otherKey,

    required  this.type,
  });

  @JsonKey(
    
    name: r'otherKey',
    required: true,
    includeIfNull: false,
  )


  final String otherKey;



  @JsonKey(
    
    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final RelationType type;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RelationInput &&
      other.otherKey == otherKey &&
      other.type == type;

    @override
    int get hashCode =>
        otherKey.hashCode +
        type.hashCode;

  factory RelationInput.fromJson(Map<String, dynamic> json) => _$RelationInputFromJson(json);

  Map<String, dynamic> toJson() => _$RelationInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


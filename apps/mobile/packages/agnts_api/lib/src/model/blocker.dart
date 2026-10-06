//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/relation_type.dart';
import 'package:agnts_api/src/model/ticket_state.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'blocker.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Blocker {
  /// Returns a new [Blocker] instance.
  Blocker({

    required  this.key,

    required  this.title,

    required  this.state,

    required  this.type,
  });

  @JsonKey(
    
    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'state',
    required: true,
    includeIfNull: false,
  )


  final TicketState state;



  @JsonKey(
    
    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final RelationType type;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Blocker &&
      other.key == key &&
      other.title == title &&
      other.state == state &&
      other.type == type;

    @override
    int get hashCode =>
        key.hashCode +
        title.hashCode +
        state.hashCode +
        type.hashCode;

  factory Blocker.fromJson(Map<String, dynamic> json) => _$BlockerFromJson(json);

  Map<String, dynamic> toJson() => _$BlockerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


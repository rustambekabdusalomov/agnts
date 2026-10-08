//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ship_notes.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ShipNotes {
  /// Returns a new [ShipNotes] instance.
  ShipNotes({

     this.migrations,

     this.compatibility,

     this.rollout,

     this.rollback,
  });

  @JsonKey(
    
    name: r'migrations',
    required: false,
    includeIfNull: false,
  )


  final String? migrations;



  @JsonKey(
    
    name: r'compatibility',
    required: false,
    includeIfNull: false,
  )


  final String? compatibility;



  @JsonKey(
    
    name: r'rollout',
    required: false,
    includeIfNull: false,
  )


  final String? rollout;



  @JsonKey(
    
    name: r'rollback',
    required: false,
    includeIfNull: false,
  )


  final String? rollback;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ShipNotes &&
      other.migrations == migrations &&
      other.compatibility == compatibility &&
      other.rollout == rollout &&
      other.rollback == rollback;

    @override
    int get hashCode =>
        migrations.hashCode +
        compatibility.hashCode +
        rollout.hashCode +
        rollback.hashCode;

  factory ShipNotes.fromJson(Map<String, dynamic> json) => _$ShipNotesFromJson(json);

  Map<String, dynamic> toJson() => _$ShipNotesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hiro_api/src/model/ci.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stage.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Stage {
  /// Returns a new [Stage] instance.
  Stage({

    required  this.id,

    required  this.name,

    required  this.status,

    required  this.durationMs,

    required  this.manual,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final CI status;



  @JsonKey(
    
    name: r'durationMs',
    required: true,
    includeIfNull: false,
  )


  final int durationMs;



  @JsonKey(
    
    name: r'manual',
    required: true,
    includeIfNull: false,
  )


  final bool manual;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Stage &&
      other.id == id &&
      other.name == name &&
      other.status == status &&
      other.durationMs == durationMs &&
      other.manual == manual;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        status.hashCode +
        durationMs.hashCode +
        manual.hashCode;

  factory Stage.fromJson(Map<String, dynamic> json) => _$StageFromJson(json);

  Map<String, dynamic> toJson() => _$StageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


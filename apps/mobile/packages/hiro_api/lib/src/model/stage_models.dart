//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hiro_api/src/model/model.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stage_models.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StageModels {
  /// Returns a new [StageModels] instance.
  StageModels({

    required  this.analyze,

    required  this.coding,

    required  this.retry,

    required  this.helper,

     this.learn,
  });

  @JsonKey(
    
    name: r'analyze',
    required: true,
    includeIfNull: false,
  )


  final Model analyze;



  @JsonKey(
    
    name: r'coding',
    required: true,
    includeIfNull: false,
  )


  final Model coding;



  @JsonKey(
    
    name: r'retry',
    required: true,
    includeIfNull: false,
  )


  final Model retry;



  @JsonKey(
    
    name: r'helper',
    required: true,
    includeIfNull: false,
  )


  final Model helper;



  @JsonKey(
    
    name: r'learn',
    required: false,
    includeIfNull: false,
  )


  final Model? learn;





    @override
    bool operator ==(Object other) => identical(this, other) || other is StageModels &&
      other.analyze == analyze &&
      other.coding == coding &&
      other.retry == retry &&
      other.helper == helper &&
      other.learn == learn;

    @override
    int get hashCode =>
        analyze.hashCode +
        coding.hashCode +
        retry.hashCode +
        helper.hashCode +
        learn.hashCode;

  factory StageModels.fromJson(Map<String, dynamic> json) => _$StageModelsFromJson(json);

  Map<String, dynamic> toJson() => _$StageModelsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


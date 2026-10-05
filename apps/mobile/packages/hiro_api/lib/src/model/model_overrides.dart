//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hiro_api/src/model/model.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model_overrides.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ModelOverrides {
  /// Returns a new [ModelOverrides] instance.
  ModelOverrides({

     this.analyze,

     this.coding,

     this.retry,

     this.review,
  });

  @JsonKey(
    
    name: r'analyze',
    required: false,
    includeIfNull: false,
  )


  final Model? analyze;



  @JsonKey(
    
    name: r'coding',
    required: false,
    includeIfNull: false,
  )


  final Model? coding;



  @JsonKey(
    
    name: r'retry',
    required: false,
    includeIfNull: false,
  )


  final Model? retry;



  @JsonKey(
    
    name: r'review',
    required: false,
    includeIfNull: false,
  )


  final Model? review;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ModelOverrides &&
      other.analyze == analyze &&
      other.coding == coding &&
      other.retry == retry &&
      other.review == review;

    @override
    int get hashCode =>
        analyze.hashCode +
        coding.hashCode +
        retry.hashCode +
        review.hashCode;

  factory ModelOverrides.fromJson(Map<String, dynamic> json) => _$ModelOverridesFromJson(json);

  Map<String, dynamic> toJson() => _$ModelOverridesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


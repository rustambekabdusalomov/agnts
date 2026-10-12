//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'second_opinion.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SecondOpinion {
  /// Returns a new [SecondOpinion] instance.
  SecondOpinion({

    required  this.model,

    required  this.agrees,

    required  this.summary,

     this.concerns,

     this.alternative,

     this.error,
  });

  @JsonKey(
    
    name: r'model',
    required: true,
    includeIfNull: false,
  )


  final String model;



  @JsonKey(
    
    name: r'agrees',
    required: true,
    includeIfNull: false,
  )


  final bool agrees;



  @JsonKey(
    
    name: r'summary',
    required: true,
    includeIfNull: false,
  )


  final String summary;



  @JsonKey(
    
    name: r'concerns',
    required: false,
    includeIfNull: false,
  )


  final List<String>? concerns;



  @JsonKey(
    
    name: r'alternative',
    required: false,
    includeIfNull: false,
  )


  final String? alternative;



  @JsonKey(
    
    name: r'error',
    required: false,
    includeIfNull: false,
  )


  final String? error;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SecondOpinion &&
      other.model == model &&
      other.agrees == agrees &&
      other.summary == summary &&
      other.concerns == concerns &&
      other.alternative == alternative &&
      other.error == error;

    @override
    int get hashCode =>
        model.hashCode +
        agrees.hashCode +
        summary.hashCode +
        concerns.hashCode +
        alternative.hashCode +
        error.hashCode;

  factory SecondOpinion.fromJson(Map<String, dynamic> json) => _$SecondOpinionFromJson(json);

  Map<String, dynamic> toJson() => _$SecondOpinionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


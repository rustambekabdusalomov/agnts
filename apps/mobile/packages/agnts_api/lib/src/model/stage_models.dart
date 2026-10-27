//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
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

     this.review,

     this.preview,
  });

      /// muse:<model> for Muse Code (muse:spark, muse:wonder), a Claude model (haiku, sonnet, opus), or codex:<model> for Codex CLI. listModels says which this server offers.
  @JsonKey(
    
    name: r'analyze',
    required: true,
    includeIfNull: false,
  )


  final String analyze;



      /// muse:<model> for Muse Code (muse:spark, muse:wonder), a Claude model (haiku, sonnet, opus), or codex:<model> for Codex CLI. listModels says which this server offers.
  @JsonKey(
    
    name: r'coding',
    required: true,
    includeIfNull: false,
  )


  final String coding;



      /// muse:<model> for Muse Code (muse:spark, muse:wonder), a Claude model (haiku, sonnet, opus), or codex:<model> for Codex CLI. listModels says which this server offers.
  @JsonKey(
    
    name: r'retry',
    required: true,
    includeIfNull: false,
  )


  final String retry;



      /// muse:<model> for Muse Code (muse:spark, muse:wonder), a Claude model (haiku, sonnet, opus), or codex:<model> for Codex CLI. listModels says which this server offers.
  @JsonKey(
    
    name: r'helper',
    required: true,
    includeIfNull: false,
  )


  final String helper;



      /// muse:<model> for Muse Code (muse:spark, muse:wonder), a Claude model (haiku, sonnet, opus), or codex:<model> for Codex CLI. listModels says which this server offers.
  @JsonKey(
    
    name: r'learn',
    required: false,
    includeIfNull: false,
  )


  final String? learn;



      /// auto: the stronger model (muse:wonder, opus) for complex tickets, the lighter one otherwise
  @JsonKey(
    
    name: r'review',
    required: false,
    includeIfNull: false,
  )


  final String? review;



      /// muse:<model> for Muse Code (muse:spark, muse:wonder), a Claude model (haiku, sonnet, opus), or codex:<model> for Codex CLI. listModels says which this server offers.
  @JsonKey(
    
    name: r'preview',
    required: false,
    includeIfNull: false,
  )


  final String? preview;





    @override
    bool operator ==(Object other) => identical(this, other) || other is StageModels &&
      other.analyze == analyze &&
      other.coding == coding &&
      other.retry == retry &&
      other.helper == helper &&
      other.learn == learn &&
      other.review == review &&
      other.preview == preview;

    @override
    int get hashCode =>
        analyze.hashCode +
        coding.hashCode +
        retry.hashCode +
        helper.hashCode +
        learn.hashCode +
        review.hashCode +
        preview.hashCode;

  factory StageModels.fromJson(Map<String, dynamic> json) => _$StageModelsFromJson(json);

  Map<String, dynamic> toJson() => _$StageModelsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


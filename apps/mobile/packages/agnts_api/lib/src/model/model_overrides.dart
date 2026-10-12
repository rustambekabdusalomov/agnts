//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
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

     this.preview,
  });

      /// A Claude model (haiku, sonnet, opus), or codex:<model> for a run on Codex CLI
  @JsonKey(
    
    name: r'analyze',
    required: false,
    includeIfNull: false,
  )


  final String? analyze;



      /// A Claude model (haiku, sonnet, opus), or codex:<model> for a run on Codex CLI
  @JsonKey(
    
    name: r'coding',
    required: false,
    includeIfNull: false,
  )


  final String? coding;



      /// A Claude model (haiku, sonnet, opus), or codex:<model> for a run on Codex CLI
  @JsonKey(
    
    name: r'retry',
    required: false,
    includeIfNull: false,
  )


  final String? retry;



      /// A Claude model (haiku, sonnet, opus), or codex:<model> for a run on Codex CLI
  @JsonKey(
    
    name: r'review',
    required: false,
    includeIfNull: false,
  )


  final String? review;



      /// A Claude model (haiku, sonnet, opus), or codex:<model> for a run on Codex CLI
  @JsonKey(
    
    name: r'preview',
    required: false,
    includeIfNull: false,
  )


  final String? preview;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ModelOverrides &&
      other.analyze == analyze &&
      other.coding == coding &&
      other.retry == retry &&
      other.review == review &&
      other.preview == preview;

    @override
    int get hashCode =>
        analyze.hashCode +
        coding.hashCode +
        retry.hashCode +
        review.hashCode +
        preview.hashCode;

  factory ModelOverrides.fromJson(Map<String, dynamic> json) => _$ModelOverridesFromJson(json);

  Map<String, dynamic> toJson() => _$ModelOverridesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


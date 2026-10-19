//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_stats_versions_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantStatsVersionsInner {
  /// Returns a new [AssistantStatsVersionsInner] instance.
  AssistantStatsVersionsInner({

    required  this.promptVersion,

    required  this.answered,

    required  this.failed,

    required  this.up,

    required  this.down,

    required  this.medianMs,

    required  this.tokens,

    required  this.proposed,

    required  this.done,
  });

  @JsonKey(
    
    name: r'promptVersion',
    required: true,
    includeIfNull: false,
  )


  final String promptVersion;



  @JsonKey(
    
    name: r'answered',
    required: true,
    includeIfNull: false,
  )


  final int answered;



  @JsonKey(
    
    name: r'failed',
    required: true,
    includeIfNull: false,
  )


  final int failed;



  @JsonKey(
    
    name: r'up',
    required: true,
    includeIfNull: false,
  )


  final int up;



  @JsonKey(
    
    name: r'down',
    required: true,
    includeIfNull: false,
  )


  final int down;



  @JsonKey(
    
    name: r'medianMs',
    required: true,
    includeIfNull: false,
  )


  final int medianMs;



  @JsonKey(
    
    name: r'tokens',
    required: true,
    includeIfNull: false,
  )


  final int tokens;



      /// Actions proposed
  @JsonKey(
    
    name: r'proposed',
    required: true,
    includeIfNull: false,
  )


  final int proposed;



      /// Actions confirmed and done
  @JsonKey(
    
    name: r'done',
    required: true,
    includeIfNull: false,
  )


  final int done;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantStatsVersionsInner &&
      other.promptVersion == promptVersion &&
      other.answered == answered &&
      other.failed == failed &&
      other.up == up &&
      other.down == down &&
      other.medianMs == medianMs &&
      other.tokens == tokens &&
      other.proposed == proposed &&
      other.done == done;

    @override
    int get hashCode =>
        promptVersion.hashCode +
        answered.hashCode +
        failed.hashCode +
        up.hashCode +
        down.hashCode +
        medianMs.hashCode +
        tokens.hashCode +
        proposed.hashCode +
        done.hashCode;

  factory AssistantStatsVersionsInner.fromJson(Map<String, dynamic> json) => _$AssistantStatsVersionsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantStatsVersionsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


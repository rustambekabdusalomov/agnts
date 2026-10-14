//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/assistant_stats_versions_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_stats.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantStats {
  /// Returns a new [AssistantStats] instance.
  AssistantStats({

    required  this.days,

    required  this.questions,

    required  this.answered,

    required  this.failed,

    required  this.people,

    required  this.medianMs,

    required  this.p90Ms,

    required  this.medianStartMs,

    required  this.medianSnapshotMs,

    required  this.medianClaudeMs,

    required  this.warm,

    required  this.up,

    required  this.down,

    required  this.tokens,

    required  this.costUsd,

    required  this.versions,
  });

  @JsonKey(
    
    name: r'days',
    required: true,
    includeIfNull: false,
  )


  final int days;



  @JsonKey(
    
    name: r'questions',
    required: true,
    includeIfNull: false,
  )


  final int questions;



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



      /// How many people asked
  @JsonKey(
    
    name: r'people',
    required: true,
    includeIfNull: false,
  )


  final int people;



  @JsonKey(
    
    name: r'medianMs',
    required: true,
    includeIfNull: false,
  )


  final int medianMs;



  @JsonKey(
    
    name: r'p90Ms',
    required: true,
    includeIfNull: false,
  )


  final int p90Ms;



      /// Opening (or reusing) the container, median
  @JsonKey(
    
    name: r'medianStartMs',
    required: true,
    includeIfNull: false,
  )


  final int medianStartMs;



      /// Reading the workspace, median
  @JsonKey(
    
    name: r'medianSnapshotMs',
    required: true,
    includeIfNull: false,
  )


  final int medianSnapshotMs;



      /// The Claude Code run, median
  @JsonKey(
    
    name: r'medianClaudeMs',
    required: true,
    includeIfNull: false,
  )


  final int medianClaudeMs;



      /// Answers that reused the container kept from the last one
  @JsonKey(
    
    name: r'warm',
    required: true,
    includeIfNull: false,
  )


  final int warm;



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
    
    name: r'tokens',
    required: true,
    includeIfNull: false,
  )


  final int tokens;



  @JsonKey(
    
    name: r'costUsd',
    required: true,
    includeIfNull: false,
  )


  final double costUsd;



      /// Per prompt version, newest first
  @JsonKey(
    
    name: r'versions',
    required: true,
    includeIfNull: false,
  )


  final List<AssistantStatsVersionsInner> versions;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantStats &&
      other.days == days &&
      other.questions == questions &&
      other.answered == answered &&
      other.failed == failed &&
      other.people == people &&
      other.medianMs == medianMs &&
      other.p90Ms == p90Ms &&
      other.medianStartMs == medianStartMs &&
      other.medianSnapshotMs == medianSnapshotMs &&
      other.medianClaudeMs == medianClaudeMs &&
      other.warm == warm &&
      other.up == up &&
      other.down == down &&
      other.tokens == tokens &&
      other.costUsd == costUsd &&
      other.versions == versions;

    @override
    int get hashCode =>
        days.hashCode +
        questions.hashCode +
        answered.hashCode +
        failed.hashCode +
        people.hashCode +
        medianMs.hashCode +
        p90Ms.hashCode +
        medianStartMs.hashCode +
        medianSnapshotMs.hashCode +
        medianClaudeMs.hashCode +
        warm.hashCode +
        up.hashCode +
        down.hashCode +
        tokens.hashCode +
        costUsd.hashCode +
        versions.hashCode;

  factory AssistantStats.fromJson(Map<String, dynamic> json) => _$AssistantStatsFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantStatsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


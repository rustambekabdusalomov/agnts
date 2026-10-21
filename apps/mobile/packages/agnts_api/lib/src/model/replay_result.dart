//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/ticket_state.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'replay_result.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReplayResult {
  /// Returns a new [ReplayResult] instance.
  ReplayResult({

    required  this.key,

    required  this.original,

    required  this.title,

    required  this.state,

    required  this.promptVersion,

     this.model,

     this.benchmark,

     this.against,

     this.lineRecall,

     this.originalLineRecall,

    required  this.hasChange,

    required  this.checksPassed,

    required  this.files,

    required  this.originalFiles,

    required  this.overlap,

    required  this.recall,

     this.verdict,

    required  this.turns,

    required  this.originalTurns,

    required  this.costUsd,

    required  this.originalCostUsd,

    required  this.createdAt,
  });

  @JsonKey(
    
    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;



  @JsonKey(
    
    name: r'original',
    required: true,
    includeIfNull: false,
  )


  final String original;



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
    
    name: r'promptVersion',
    required: true,
    includeIfNull: false,
  )


  final String promptVersion;



  @JsonKey(
    
    name: r'model',
    required: false,
    includeIfNull: false,
  )


  final String? model;



      /// The original is in the benchmark
  @JsonKey(
    
    name: r'benchmark',
    required: false,
    includeIfNull: false,
  )


  final bool? benchmark;



      /// What the replay is scored against: what the original merged as, or the original's own change
  @JsonKey(
    
    name: r'against',
    required: false,
    includeIfNull: false,
  )


  final ReplayResultAgainstEnum? against;



      /// Share of the merged change's added lines the replay adds too; absent when scored against agnts
  @JsonKey(
    
    name: r'lineRecall',
    required: false,
    includeIfNull: false,
  )


  final num? lineRecall;



      /// The same for the original's own change
  @JsonKey(
    
    name: r'originalLineRecall',
    required: false,
    includeIfNull: false,
  )


  final num? originalLineRecall;



  @JsonKey(
    
    name: r'hasChange',
    required: true,
    includeIfNull: false,
  )


  final bool hasChange;



  @JsonKey(
    
    name: r'checksPassed',
    required: true,
    includeIfNull: false,
  )


  final bool checksPassed;



  @JsonKey(
    
    name: r'files',
    required: true,
    includeIfNull: false,
  )


  final List<String> files;



  @JsonKey(
    
    name: r'originalFiles',
    required: true,
    includeIfNull: false,
  )


  final List<String> originalFiles;



  @JsonKey(
    
    name: r'overlap',
    required: true,
    includeIfNull: false,
  )


  final num overlap;



  @JsonKey(
    
    name: r'recall',
    required: true,
    includeIfNull: false,
  )


  final num recall;



  @JsonKey(
    
    name: r'verdict',
    required: false,
    includeIfNull: false,
  )


  final ReplayResultVerdictEnum? verdict;



  @JsonKey(
    
    name: r'turns',
    required: true,
    includeIfNull: false,
  )


  final int turns;



  @JsonKey(
    
    name: r'originalTurns',
    required: true,
    includeIfNull: false,
  )


  final int originalTurns;



  @JsonKey(
    
    name: r'costUsd',
    required: true,
    includeIfNull: false,
  )


  final num costUsd;



  @JsonKey(
    
    name: r'originalCostUsd',
    required: true,
    includeIfNull: false,
  )


  final num originalCostUsd;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReplayResult &&
      other.key == key &&
      other.original == original &&
      other.title == title &&
      other.state == state &&
      other.promptVersion == promptVersion &&
      other.model == model &&
      other.benchmark == benchmark &&
      other.against == against &&
      other.lineRecall == lineRecall &&
      other.originalLineRecall == originalLineRecall &&
      other.hasChange == hasChange &&
      other.checksPassed == checksPassed &&
      other.files == files &&
      other.originalFiles == originalFiles &&
      other.overlap == overlap &&
      other.recall == recall &&
      other.verdict == verdict &&
      other.turns == turns &&
      other.originalTurns == originalTurns &&
      other.costUsd == costUsd &&
      other.originalCostUsd == originalCostUsd &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        key.hashCode +
        original.hashCode +
        title.hashCode +
        state.hashCode +
        promptVersion.hashCode +
        model.hashCode +
        benchmark.hashCode +
        against.hashCode +
        lineRecall.hashCode +
        originalLineRecall.hashCode +
        hasChange.hashCode +
        checksPassed.hashCode +
        files.hashCode +
        originalFiles.hashCode +
        overlap.hashCode +
        recall.hashCode +
        verdict.hashCode +
        turns.hashCode +
        originalTurns.hashCode +
        costUsd.hashCode +
        originalCostUsd.hashCode +
        createdAt.hashCode;

  factory ReplayResult.fromJson(Map<String, dynamic> json) => _$ReplayResultFromJson(json);

  Map<String, dynamic> toJson() => _$ReplayResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// What the replay is scored against: what the original merged as, or the original's own change
enum ReplayResultAgainstEnum {
@JsonValue(r'merged')
merged(r'merged'),
@JsonValue(r'agnts')
agnts(r'agnts');

const ReplayResultAgainstEnum(this.value);

final String value;

@override
String toString() => value;
}


enum ReplayResultVerdictEnum {
@JsonValue(r'looks_good')
looksGood(r'looks_good'),
@JsonValue(r'has_concerns')
hasConcerns(r'has_concerns'),
@JsonValue(r'needs_changes')
needsChanges(r'needs_changes');

const ReplayResultVerdictEnum(this.value);

final String value;

@override
String toString() => value;
}



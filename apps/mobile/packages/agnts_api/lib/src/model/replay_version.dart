//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'replay_version.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReplayVersion {
  /// Returns a new [ReplayVersion] instance.
  ReplayVersion({

    required  this.promptVersion,

    required  this.replays,

    required  this.checksPassed,

    required  this.reviewed,

    required  this.looksGood,

    required  this.avgOverlap,

    required  this.avgRecall,

    required  this.avgTurns,

    required  this.avgCostUsd,

    required  this.originalTurns,

    required  this.originalCostUsd,
  });

  @JsonKey(
    
    name: r'promptVersion',
    required: true,
    includeIfNull: false,
  )


  final String promptVersion;



  @JsonKey(
    
    name: r'replays',
    required: true,
    includeIfNull: false,
  )


  final int replays;



  @JsonKey(
    
    name: r'checksPassed',
    required: true,
    includeIfNull: false,
  )


  final int checksPassed;



      /// Replays agnts's code review read
  @JsonKey(
    
    name: r'reviewed',
    required: true,
    includeIfNull: false,
  )


  final int reviewed;



      /// Reviews that found nothing to block
  @JsonKey(
    
    name: r'looksGood',
    required: true,
    includeIfNull: false,
  )


  final int looksGood;



      /// Average Jaccard index of the changed files, replay against original
  @JsonKey(
    
    name: r'avgOverlap',
    required: true,
    includeIfNull: false,
  )


  final num avgOverlap;



      /// Average share of the original's files the replay changed too
  @JsonKey(
    
    name: r'avgRecall',
    required: true,
    includeIfNull: false,
  )


  final num avgRecall;



  @JsonKey(
    
    name: r'avgTurns',
    required: true,
    includeIfNull: false,
  )


  final num avgTurns;



  @JsonKey(
    
    name: r'avgCostUsd',
    required: true,
    includeIfNull: false,
  )


  final num avgCostUsd;



      /// Average turns of the originals, for comparison
  @JsonKey(
    
    name: r'originalTurns',
    required: true,
    includeIfNull: false,
  )


  final num originalTurns;



  @JsonKey(
    
    name: r'originalCostUsd',
    required: true,
    includeIfNull: false,
  )


  final num originalCostUsd;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReplayVersion &&
      other.promptVersion == promptVersion &&
      other.replays == replays &&
      other.checksPassed == checksPassed &&
      other.reviewed == reviewed &&
      other.looksGood == looksGood &&
      other.avgOverlap == avgOverlap &&
      other.avgRecall == avgRecall &&
      other.avgTurns == avgTurns &&
      other.avgCostUsd == avgCostUsd &&
      other.originalTurns == originalTurns &&
      other.originalCostUsd == originalCostUsd;

    @override
    int get hashCode =>
        promptVersion.hashCode +
        replays.hashCode +
        checksPassed.hashCode +
        reviewed.hashCode +
        looksGood.hashCode +
        avgOverlap.hashCode +
        avgRecall.hashCode +
        avgTurns.hashCode +
        avgCostUsd.hashCode +
        originalTurns.hashCode +
        originalCostUsd.hashCode;

  factory ReplayVersion.fromJson(Map<String, dynamic> json) => _$ReplayVersionFromJson(json);

  Map<String, dynamic> toJson() => _$ReplayVersionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


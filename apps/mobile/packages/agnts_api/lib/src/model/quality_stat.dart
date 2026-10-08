//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'quality_stat.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class QualityStat {
  /// Returns a new [QualityStat] instance.
  QualityStat({

    required  this.promptVersion,

    required  this.tickets,

    required  this.reachedReview,

    required  this.done,

    required  this.firstTry,

    required  this.rejected,

    required  this.changeRounds,

    required  this.fixAttempts,

    required  this.serious,

     this.footprintHit,

    required  this.redFlags,

    required  this.selfFixes,
  });

      /// Empty for runs from before versions were recorded
  @JsonKey(
    
    name: r'promptVersion',
    required: true,
    includeIfNull: false,
  )


  final String promptVersion;



      /// First coding run in the period
  @JsonKey(
    
    name: r'tickets',
    required: true,
    includeIfNull: false,
  )


  final int tickets;



  @JsonKey(
    
    name: r'reachedReview',
    required: true,
    includeIfNull: false,
  )


  final int reachedReview;



  @JsonKey(
    
    name: r'done',
    required: true,
    includeIfNull: false,
  )


  final int done;



      /// Done without a person asking for changes
  @JsonKey(
    
    name: r'firstTry',
    required: true,
    includeIfNull: false,
  )


  final int firstTry;



  @JsonKey(
    
    name: r'rejected',
    required: true,
    includeIfNull: false,
  )


  final int rejected;



      /// Average change requests by a person, over the tickets that reached review
  @JsonKey(
    
    name: r'changeRounds',
    required: true,
    includeIfNull: false,
  )


  final num changeRounds;



      /// Average failing checks sent back to Claude
  @JsonKey(
    
    name: r'fixAttempts',
    required: true,
    includeIfNull: false,
  )


  final num fixAttempts;



      /// Reviewed with a blocker or major finding at least once
  @JsonKey(
    
    name: r'serious',
    required: true,
    includeIfNull: false,
  )


  final int serious;



      /// Average share of the changed files the analysis predicted; absent when none was measured
  @JsonKey(
    
    name: r'footprintHit',
    required: false,
    includeIfNull: false,
  )


  final num? footprintHit;



      /// Red flags found in the diffs
  @JsonKey(
    
    name: r'redFlags',
    required: true,
    includeIfNull: false,
  )


  final int redFlags;



      /// Findings of agnts's own review sent back to the coder
  @JsonKey(
    
    name: r'selfFixes',
    required: true,
    includeIfNull: false,
  )


  final int selfFixes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is QualityStat &&
      other.promptVersion == promptVersion &&
      other.tickets == tickets &&
      other.reachedReview == reachedReview &&
      other.done == done &&
      other.firstTry == firstTry &&
      other.rejected == rejected &&
      other.changeRounds == changeRounds &&
      other.fixAttempts == fixAttempts &&
      other.serious == serious &&
      other.footprintHit == footprintHit &&
      other.redFlags == redFlags &&
      other.selfFixes == selfFixes;

    @override
    int get hashCode =>
        promptVersion.hashCode +
        tickets.hashCode +
        reachedReview.hashCode +
        done.hashCode +
        firstTry.hashCode +
        rejected.hashCode +
        changeRounds.hashCode +
        fixAttempts.hashCode +
        serious.hashCode +
        footprintHit.hashCode +
        redFlags.hashCode +
        selfFixes.hashCode;

  factory QualityStat.fromJson(Map<String, dynamic> json) => _$QualityStatFromJson(json);

  Map<String, dynamic> toJson() => _$QualityStatToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


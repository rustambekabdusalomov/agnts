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

     this.guardBlocks,

     this.stopSaves,

     this.stalls,

     this.proofDue,

     this.proven,

     this.findings,

     this.adopted,

     this.tokens,

     this.factCheck,

     this.factCheckFirst,
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



      /// Actions agnts-guard refused in their coding runs
  @JsonKey(
    
    name: r'guardBlocks',
    required: false,
    includeIfNull: false,
  )


  final int? guardBlocks;



      /// Tickets whose stop gate sent failing checks back and whose checks then passed first time
  @JsonKey(
    
    name: r'stopSaves',
    required: false,
    includeIfNull: false,
  )


  final int? stopSaves;



      /// Times their runs looked stuck
  @JsonKey(
    
    name: r'stalls',
    required: false,
    includeIfNull: false,
  )


  final int? stalls;



      /// Tickets with a proof of fix
  @JsonKey(
    
    name: r'proofDue',
    required: false,
    includeIfNull: false,
  )


  final int? proofDue;



      /// Of those, proven
  @JsonKey(
    
    name: r'proven',
    required: false,
    includeIfNull: false,
  )


  final int? proven;



      /// Review findings shown on them
  @JsonKey(
    
    name: r'findings',
    required: false,
    includeIfNull: false,
  )


  final int? findings;



      /// Of those, put into a person's feedback
  @JsonKey(
    
    name: r'adopted',
    required: false,
    includeIfNull: false,
  )


  final int? adopted;



      /// Average tokens of a done ticket, all stages
  @JsonKey(
    
    name: r'tokens',
    required: false,
    includeIfNull: false,
  )


  final num? tokens;



      /// Tickets in the fact check group (A/B)
  @JsonKey(
    
    name: r'factCheck',
    required: false,
    includeIfNull: false,
  )


  final int? factCheck;



      /// Of those, done without a person asking for changes
  @JsonKey(
    
    name: r'factCheckFirst',
    required: false,
    includeIfNull: false,
  )


  final int? factCheckFirst;





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
      other.selfFixes == selfFixes &&
      other.guardBlocks == guardBlocks &&
      other.stopSaves == stopSaves &&
      other.stalls == stalls &&
      other.proofDue == proofDue &&
      other.proven == proven &&
      other.findings == findings &&
      other.adopted == adopted &&
      other.tokens == tokens &&
      other.factCheck == factCheck &&
      other.factCheckFirst == factCheckFirst;

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
        selfFixes.hashCode +
        guardBlocks.hashCode +
        stopSaves.hashCode +
        stalls.hashCode +
        proofDue.hashCode +
        proven.hashCode +
        findings.hashCode +
        adopted.hashCode +
        tokens.hashCode +
        factCheck.hashCode +
        factCheckFirst.hashCode;

  factory QualityStat.fromJson(Map<String, dynamic> json) => _$QualityStatFromJson(json);

  Map<String, dynamic> toJson() => _$QualityStatToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


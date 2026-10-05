//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'period_stats.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PeriodStats {
  /// Returns a new [PeriodStats] instance.
  PeriodStats({

    required  this.picked,

    required  this.pushed,

    required  this.rejected,

    required  this.stopped,

    required  this.firstTry,

    required  this.afterChanges,

    required  this.hiroMin,

    required  this.waitMin,

    required  this.reviewMin,

    required  this.answerMin,

    required  this.turns,
  });

  @JsonKey(
    
    name: r'picked',
    required: true,
    includeIfNull: false,
  )


  final int picked;



  @JsonKey(
    
    name: r'pushed',
    required: true,
    includeIfNull: false,
  )


  final int pushed;



  @JsonKey(
    
    name: r'rejected',
    required: true,
    includeIfNull: false,
  )


  final int rejected;



  @JsonKey(
    
    name: r'stopped',
    required: true,
    includeIfNull: false,
  )


  final int stopped;



  @JsonKey(
    
    name: r'firstTry',
    required: true,
    includeIfNull: false,
  )


  final int firstTry;



  @JsonKey(
    
    name: r'afterChanges',
    required: true,
    includeIfNull: false,
  )


  final int afterChanges;



  @JsonKey(
    
    name: r'hiroMin',
    required: true,
    includeIfNull: false,
  )


  final num hiroMin;



  @JsonKey(
    
    name: r'waitMin',
    required: true,
    includeIfNull: false,
  )


  final num waitMin;



  @JsonKey(
    
    name: r'reviewMin',
    required: true,
    includeIfNull: false,
  )


  final num reviewMin;



  @JsonKey(
    
    name: r'answerMin',
    required: true,
    includeIfNull: false,
  )


  final num answerMin;



  @JsonKey(
    
    name: r'turns',
    required: true,
    includeIfNull: false,
  )


  final num turns;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PeriodStats &&
      other.picked == picked &&
      other.pushed == pushed &&
      other.rejected == rejected &&
      other.stopped == stopped &&
      other.firstTry == firstTry &&
      other.afterChanges == afterChanges &&
      other.hiroMin == hiroMin &&
      other.waitMin == waitMin &&
      other.reviewMin == reviewMin &&
      other.answerMin == answerMin &&
      other.turns == turns;

    @override
    int get hashCode =>
        picked.hashCode +
        pushed.hashCode +
        rejected.hashCode +
        stopped.hashCode +
        firstTry.hashCode +
        afterChanges.hashCode +
        hiroMin.hashCode +
        waitMin.hashCode +
        reviewMin.hashCode +
        answerMin.hashCode +
        turns.hashCode;

  factory PeriodStats.fromJson(Map<String, dynamic> json) => _$PeriodStatsFromJson(json);

  Map<String, dynamic> toJson() => _$PeriodStatsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'week_stats.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeekStats {
  /// Returns a new [WeekStats] instance.
  WeekStats({

    required  this.picked,

    required  this.pushed,

    required  this.firstTryPct,

    required  this.avgTurns,

    required  this.avgWaitMin,

    required  this.stopped,
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
    
    name: r'firstTryPct',
    required: true,
    includeIfNull: false,
  )


  final int firstTryPct;



  @JsonKey(
    
    name: r'avgTurns',
    required: true,
    includeIfNull: false,
  )


  final int avgTurns;



  @JsonKey(
    
    name: r'avgWaitMin',
    required: true,
    includeIfNull: false,
  )


  final int avgWaitMin;



  @JsonKey(
    
    name: r'stopped',
    required: true,
    includeIfNull: false,
  )


  final int stopped;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WeekStats &&
      other.picked == picked &&
      other.pushed == pushed &&
      other.firstTryPct == firstTryPct &&
      other.avgTurns == avgTurns &&
      other.avgWaitMin == avgWaitMin &&
      other.stopped == stopped;

    @override
    int get hashCode =>
        picked.hashCode +
        pushed.hashCode +
        firstTryPct.hashCode +
        avgTurns.hashCode +
        avgWaitMin.hashCode +
        stopped.hashCode;

  factory WeekStats.fromJson(Map<String, dynamic> json) => _$WeekStatsFromJson(json);

  Map<String, dynamic> toJson() => _$WeekStatsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


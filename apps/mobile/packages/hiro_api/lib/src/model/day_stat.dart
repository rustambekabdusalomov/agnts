//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'day_stat.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DayStat {
  /// Returns a new [DayStat] instance.
  DayStat({

    required  this.date,

    required  this.picked,

    required  this.pushed,

    required  this.rejected,

    required  this.stopped,

    required  this.hiroMin,

    required  this.waitMin,

    required  this.turns,

     this.peakUsage,
  });

  @JsonKey(
    
    name: r'date',
    required: true,
    includeIfNull: false,
  )


  final DateTime date;



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
    
    name: r'turns',
    required: true,
    includeIfNull: false,
  )


  final num turns;



  @JsonKey(
    
    name: r'peakUsage',
    required: false,
    includeIfNull: false,
  )


  final num? peakUsage;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DayStat &&
      other.date == date &&
      other.picked == picked &&
      other.pushed == pushed &&
      other.rejected == rejected &&
      other.stopped == stopped &&
      other.hiroMin == hiroMin &&
      other.waitMin == waitMin &&
      other.turns == turns &&
      other.peakUsage == peakUsage;

    @override
    int get hashCode =>
        date.hashCode +
        picked.hashCode +
        pushed.hashCode +
        rejected.hashCode +
        stopped.hashCode +
        hiroMin.hashCode +
        waitMin.hashCode +
        turns.hashCode +
        peakUsage.hashCode;

  factory DayStat.fromJson(Map<String, dynamic> json) => _$DayStatFromJson(json);

  Map<String, dynamic> toJson() => _$DayStatToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


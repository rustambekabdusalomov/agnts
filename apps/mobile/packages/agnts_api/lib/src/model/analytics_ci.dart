//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/flaky_job.dart';
import 'package:agnts_api/src/model/ci_period.dart';
import 'package:agnts_api/src/model/ci_day.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analytics_ci.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalyticsCI {
  /// Returns a new [AnalyticsCI] instance.
  AnalyticsCI({

    required  this.days,

    required  this.watching,

    required  this.current,

    required  this.previous,

    required  this.byClass,

    required  this.perDay,

    required  this.flakiest,

    required  this.open,
  });

  @JsonKey(
    
    name: r'days',
    required: true,
    includeIfNull: false,
  )


  final int days;



      /// CI watching is set up for at least one repository
  @JsonKey(
    
    name: r'watching',
    required: true,
    includeIfNull: false,
  )


  final bool watching;



  @JsonKey(
    
    name: r'current',
    required: true,
    includeIfNull: false,
  )


  final CIPeriod current;



  @JsonKey(
    
    name: r'previous',
    required: true,
    includeIfNull: false,
  )


  final CIPeriod previous;



      /// Failure groups seen in the period by class: code, test, config, dependency, infra, flaky, unknown
  @JsonKey(
    
    name: r'byClass',
    required: true,
    includeIfNull: false,
  )


  final Map<String, int> byClass;



  @JsonKey(
    
    name: r'perDay',
    required: true,
    includeIfNull: false,
  )


  final List<CIDay> perDay;



  @JsonKey(
    
    name: r'flakiest',
    required: true,
    includeIfNull: false,
  )


  final List<FlakyJob> flakiest;



      /// Failure groups that need attention now
  @JsonKey(
    
    name: r'open',
    required: true,
    includeIfNull: false,
  )


  final int open;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AnalyticsCI &&
      other.days == days &&
      other.watching == watching &&
      other.current == current &&
      other.previous == previous &&
      other.byClass == byClass &&
      other.perDay == perDay &&
      other.flakiest == flakiest &&
      other.open == open;

    @override
    int get hashCode =>
        days.hashCode +
        watching.hashCode +
        current.hashCode +
        previous.hashCode +
        byClass.hashCode +
        perDay.hashCode +
        flakiest.hashCode +
        open.hashCode;

  factory AnalyticsCI.fromJson(Map<String, dynamic> json) => _$AnalyticsCIFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsCIToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


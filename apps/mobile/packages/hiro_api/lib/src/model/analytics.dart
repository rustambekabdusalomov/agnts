//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hiro_api/src/model/analytics_insights_inner.dart';
import 'package:hiro_api/src/model/day_stat.dart';
import 'package:hiro_api/src/model/analytics_repos_inner.dart';
import 'package:hiro_api/src/model/period_stats.dart';
import 'package:hiro_api/src/model/analytics_models_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analytics.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Analytics {
  /// Returns a new [Analytics] instance.
  Analytics({

    required  this.days,

    required  this.current,

    required  this.previous,

    required  this.perDay,

    required  this.steps,

    required  this.stops,

    required  this.models,

    required  this.repos,

    required  this.hours,

    required  this.insights,
  });

  @JsonKey(
    
    name: r'days',
    required: true,
    includeIfNull: false,
  )


  final int days;



  @JsonKey(
    
    name: r'current',
    required: true,
    includeIfNull: false,
  )


  final PeriodStats current;



  @JsonKey(
    
    name: r'previous',
    required: true,
    includeIfNull: false,
  )


  final PeriodStats previous;



  @JsonKey(
    
    name: r'perDay',
    required: true,
    includeIfNull: false,
  )


  final List<DayStat> perDay;



      /// Average minutes per state
  @JsonKey(
    
    name: r'steps',
    required: true,
    includeIfNull: false,
  )


  final Map<String, num> steps;



      /// Stopped runs by reason: tests, limit, you, turns, other
  @JsonKey(
    
    name: r'stops',
    required: true,
    includeIfNull: false,
  )


  final Map<String, int> stops;



  @JsonKey(
    
    name: r'models',
    required: true,
    includeIfNull: false,
  )


  final List<AnalyticsModelsInner> models;



  @JsonKey(
    
    name: r'repos',
    required: true,
    includeIfNull: false,
  )


  final List<AnalyticsReposInner> repos;



      /// hiro's events per hour of day (server time zone)
  @JsonKey(
    
    name: r'hours',
    required: true,
    includeIfNull: false,
  )


  final List<int> hours;



  @JsonKey(
    
    name: r'insights',
    required: true,
    includeIfNull: false,
  )


  final List<AnalyticsInsightsInner> insights;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Analytics &&
      other.days == days &&
      other.current == current &&
      other.previous == previous &&
      other.perDay == perDay &&
      other.steps == steps &&
      other.stops == stops &&
      other.models == models &&
      other.repos == repos &&
      other.hours == hours &&
      other.insights == insights;

    @override
    int get hashCode =>
        days.hashCode +
        current.hashCode +
        previous.hashCode +
        perDay.hashCode +
        steps.hashCode +
        stops.hashCode +
        models.hashCode +
        repos.hashCode +
        hours.hashCode +
        insights.hashCode;

  factory Analytics.fromJson(Map<String, dynamic> json) => _$AnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


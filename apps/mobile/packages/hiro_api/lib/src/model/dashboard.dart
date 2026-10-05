//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hiro_api/src/model/week_stats.dart';
import 'package:hiro_api/src/model/repo_activity.dart';
import 'package:hiro_api/src/model/dashboard_counts.dart';
import 'package:hiro_api/src/model/event.dart';
import 'package:hiro_api/src/model/live_run.dart';
import 'package:hiro_api/src/model/ticket.dart';
import 'package:hiro_api/src/model/usage.dart';
import 'package:hiro_api/src/model/hour_bucket.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dashboard.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Dashboard {
  /// Returns a new [Dashboard] instance.
  Dashboard({

    required  this.counts,

    required  this.waiting,

    required  this.live,

    required  this.pipeline,

    required  this.todayByHour,

    required  this.week,

    required  this.lastWeek,

    required  this.repos,

    required  this.recent,

    required  this.usage,

    required  this.parallel,
  });

  @JsonKey(
    
    name: r'counts',
    required: true,
    includeIfNull: false,
  )


  final DashboardCounts counts;



  @JsonKey(
    
    name: r'waiting',
    required: true,
    includeIfNull: false,
  )


  final List<Ticket> waiting;



  @JsonKey(
    
    name: r'live',
    required: true,
    includeIfNull: false,
  )


  final List<LiveRun> live;



      /// Open tickets per state
  @JsonKey(
    
    name: r'pipeline',
    required: true,
    includeIfNull: false,
  )


  final Map<String, int> pipeline;



  @JsonKey(
    
    name: r'todayByHour',
    required: true,
    includeIfNull: false,
  )


  final List<HourBucket> todayByHour;



  @JsonKey(
    
    name: r'week',
    required: true,
    includeIfNull: false,
  )


  final WeekStats week;



  @JsonKey(
    
    name: r'lastWeek',
    required: true,
    includeIfNull: false,
  )


  final WeekStats lastWeek;



  @JsonKey(
    
    name: r'repos',
    required: true,
    includeIfNull: false,
  )


  final List<RepoActivity> repos;



  @JsonKey(
    
    name: r'recent',
    required: true,
    includeIfNull: false,
  )


  final List<Event> recent;



  @JsonKey(
    
    name: r'usage',
    required: true,
    includeIfNull: false,
  )


  final Usage usage;



  @JsonKey(
    
    name: r'parallel',
    required: true,
    includeIfNull: false,
  )


  final int parallel;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Dashboard &&
      other.counts == counts &&
      other.waiting == waiting &&
      other.live == live &&
      other.pipeline == pipeline &&
      other.todayByHour == todayByHour &&
      other.week == week &&
      other.lastWeek == lastWeek &&
      other.repos == repos &&
      other.recent == recent &&
      other.usage == usage &&
      other.parallel == parallel;

    @override
    int get hashCode =>
        counts.hashCode +
        waiting.hashCode +
        live.hashCode +
        pipeline.hashCode +
        todayByHour.hashCode +
        week.hashCode +
        lastWeek.hashCode +
        repos.hashCode +
        recent.hashCode +
        usage.hashCode +
        parallel.hashCode;

  factory Dashboard.fromJson(Map<String, dynamic> json) => _$DashboardFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


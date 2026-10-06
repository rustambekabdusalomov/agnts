// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DashboardCWProxy {
  Dashboard counts(DashboardCounts counts);

  Dashboard waiting(List<Ticket> waiting);

  Dashboard live(List<LiveRun> live);

  Dashboard pipeline(Map<String, int> pipeline);

  Dashboard todayByHour(List<HourBucket> todayByHour);

  Dashboard week(WeekStats week);

  Dashboard lastWeek(WeekStats lastWeek);

  Dashboard repos(List<RepoActivity> repos);

  Dashboard recent(List<Event> recent);

  Dashboard usage(Usage usage);

  Dashboard parallel(int parallel);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Dashboard(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Dashboard(...).copyWith(id: 12, name: "My name")
  /// ````
  Dashboard call({
    DashboardCounts counts,
    List<Ticket> waiting,
    List<LiveRun> live,
    Map<String, int> pipeline,
    List<HourBucket> todayByHour,
    WeekStats week,
    WeekStats lastWeek,
    List<RepoActivity> repos,
    List<Event> recent,
    Usage usage,
    int parallel,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDashboard.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDashboard.copyWith.fieldName(...)`
class _$DashboardCWProxyImpl implements _$DashboardCWProxy {
  const _$DashboardCWProxyImpl(this._value);

  final Dashboard _value;

  @override
  Dashboard counts(DashboardCounts counts) => this(counts: counts);

  @override
  Dashboard waiting(List<Ticket> waiting) => this(waiting: waiting);

  @override
  Dashboard live(List<LiveRun> live) => this(live: live);

  @override
  Dashboard pipeline(Map<String, int> pipeline) => this(pipeline: pipeline);

  @override
  Dashboard todayByHour(List<HourBucket> todayByHour) =>
      this(todayByHour: todayByHour);

  @override
  Dashboard week(WeekStats week) => this(week: week);

  @override
  Dashboard lastWeek(WeekStats lastWeek) => this(lastWeek: lastWeek);

  @override
  Dashboard repos(List<RepoActivity> repos) => this(repos: repos);

  @override
  Dashboard recent(List<Event> recent) => this(recent: recent);

  @override
  Dashboard usage(Usage usage) => this(usage: usage);

  @override
  Dashboard parallel(int parallel) => this(parallel: parallel);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Dashboard(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Dashboard(...).copyWith(id: 12, name: "My name")
  /// ````
  Dashboard call({
    Object? counts = const $CopyWithPlaceholder(),
    Object? waiting = const $CopyWithPlaceholder(),
    Object? live = const $CopyWithPlaceholder(),
    Object? pipeline = const $CopyWithPlaceholder(),
    Object? todayByHour = const $CopyWithPlaceholder(),
    Object? week = const $CopyWithPlaceholder(),
    Object? lastWeek = const $CopyWithPlaceholder(),
    Object? repos = const $CopyWithPlaceholder(),
    Object? recent = const $CopyWithPlaceholder(),
    Object? usage = const $CopyWithPlaceholder(),
    Object? parallel = const $CopyWithPlaceholder(),
  }) {
    return Dashboard(
      counts: counts == const $CopyWithPlaceholder()
          ? _value.counts
          // ignore: cast_nullable_to_non_nullable
          : counts as DashboardCounts,
      waiting: waiting == const $CopyWithPlaceholder()
          ? _value.waiting
          // ignore: cast_nullable_to_non_nullable
          : waiting as List<Ticket>,
      live: live == const $CopyWithPlaceholder()
          ? _value.live
          // ignore: cast_nullable_to_non_nullable
          : live as List<LiveRun>,
      pipeline: pipeline == const $CopyWithPlaceholder()
          ? _value.pipeline
          // ignore: cast_nullable_to_non_nullable
          : pipeline as Map<String, int>,
      todayByHour: todayByHour == const $CopyWithPlaceholder()
          ? _value.todayByHour
          // ignore: cast_nullable_to_non_nullable
          : todayByHour as List<HourBucket>,
      week: week == const $CopyWithPlaceholder()
          ? _value.week
          // ignore: cast_nullable_to_non_nullable
          : week as WeekStats,
      lastWeek: lastWeek == const $CopyWithPlaceholder()
          ? _value.lastWeek
          // ignore: cast_nullable_to_non_nullable
          : lastWeek as WeekStats,
      repos: repos == const $CopyWithPlaceholder()
          ? _value.repos
          // ignore: cast_nullable_to_non_nullable
          : repos as List<RepoActivity>,
      recent: recent == const $CopyWithPlaceholder()
          ? _value.recent
          // ignore: cast_nullable_to_non_nullable
          : recent as List<Event>,
      usage: usage == const $CopyWithPlaceholder()
          ? _value.usage
          // ignore: cast_nullable_to_non_nullable
          : usage as Usage,
      parallel: parallel == const $CopyWithPlaceholder()
          ? _value.parallel
          // ignore: cast_nullable_to_non_nullable
          : parallel as int,
    );
  }
}

extension $DashboardCopyWith on Dashboard {
  /// Returns a callable class that can be used as follows: `instanceOfDashboard.copyWith(...)` or like so:`instanceOfDashboard.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DashboardCWProxy get copyWith => _$DashboardCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dashboard _$DashboardFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Dashboard', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'counts',
          'waiting',
          'live',
          'pipeline',
          'todayByHour',
          'week',
          'lastWeek',
          'repos',
          'recent',
          'usage',
          'parallel',
        ],
      );
      final val = Dashboard(
        counts: $checkedConvert(
          'counts',
          (v) => DashboardCounts.fromJson(v as Map<String, dynamic>),
        ),
        waiting: $checkedConvert(
          'waiting',
          (v) => (v as List<dynamic>)
              .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        live: $checkedConvert(
          'live',
          (v) => (v as List<dynamic>)
              .map((e) => LiveRun.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        pipeline: $checkedConvert(
          'pipeline',
          (v) => Map<String, int>.from(v as Map),
        ),
        todayByHour: $checkedConvert(
          'todayByHour',
          (v) => (v as List<dynamic>)
              .map((e) => HourBucket.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        week: $checkedConvert(
          'week',
          (v) => WeekStats.fromJson(v as Map<String, dynamic>),
        ),
        lastWeek: $checkedConvert(
          'lastWeek',
          (v) => WeekStats.fromJson(v as Map<String, dynamic>),
        ),
        repos: $checkedConvert(
          'repos',
          (v) => (v as List<dynamic>)
              .map((e) => RepoActivity.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        recent: $checkedConvert(
          'recent',
          (v) => (v as List<dynamic>)
              .map((e) => Event.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        usage: $checkedConvert(
          'usage',
          (v) => Usage.fromJson(v as Map<String, dynamic>),
        ),
        parallel: $checkedConvert('parallel', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$DashboardToJson(Dashboard instance) => <String, dynamic>{
  'counts': instance.counts.toJson(),
  'waiting': instance.waiting.map((e) => e.toJson()).toList(),
  'live': instance.live.map((e) => e.toJson()).toList(),
  'pipeline': instance.pipeline,
  'todayByHour': instance.todayByHour.map((e) => e.toJson()).toList(),
  'week': instance.week.toJson(),
  'lastWeek': instance.lastWeek.toJson(),
  'repos': instance.repos.map((e) => e.toJson()).toList(),
  'recent': instance.recent.map((e) => e.toJson()).toList(),
  'usage': instance.usage.toJson(),
  'parallel': instance.parallel,
};

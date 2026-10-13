// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AnalyticsCWProxy {
  Analytics days(int days);

  Analytics quality(List<QualityStat> quality);

  Analytics skills(List<SkillStat>? skills);

  Analytics current(PeriodStats current);

  Analytics previous(PeriodStats previous);

  Analytics perDay(List<DayStat> perDay);

  Analytics steps(Map<String, num> steps);

  Analytics stops(Map<String, int> stops);

  Analytics models(List<AnalyticsModelsInner> models);

  Analytics repos(List<AnalyticsReposInner> repos);

  Analytics hours(List<int> hours);

  Analytics spendByStage(List<StageSpend> spendByStage);

  Analytics insights(List<AnalyticsInsightsInner> insights);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Analytics(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Analytics(...).copyWith(id: 12, name: "My name")
  /// ````
  Analytics call({
    int days,
    List<QualityStat> quality,
    List<SkillStat>? skills,
    PeriodStats current,
    PeriodStats previous,
    List<DayStat> perDay,
    Map<String, num> steps,
    Map<String, int> stops,
    List<AnalyticsModelsInner> models,
    List<AnalyticsReposInner> repos,
    List<int> hours,
    List<StageSpend> spendByStage,
    List<AnalyticsInsightsInner> insights,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAnalytics.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAnalytics.copyWith.fieldName(...)`
class _$AnalyticsCWProxyImpl implements _$AnalyticsCWProxy {
  const _$AnalyticsCWProxyImpl(this._value);

  final Analytics _value;

  @override
  Analytics days(int days) => this(days: days);

  @override
  Analytics quality(List<QualityStat> quality) => this(quality: quality);

  @override
  Analytics skills(List<SkillStat>? skills) => this(skills: skills);

  @override
  Analytics current(PeriodStats current) => this(current: current);

  @override
  Analytics previous(PeriodStats previous) => this(previous: previous);

  @override
  Analytics perDay(List<DayStat> perDay) => this(perDay: perDay);

  @override
  Analytics steps(Map<String, num> steps) => this(steps: steps);

  @override
  Analytics stops(Map<String, int> stops) => this(stops: stops);

  @override
  Analytics models(List<AnalyticsModelsInner> models) => this(models: models);

  @override
  Analytics repos(List<AnalyticsReposInner> repos) => this(repos: repos);

  @override
  Analytics hours(List<int> hours) => this(hours: hours);

  @override
  Analytics spendByStage(List<StageSpend> spendByStage) =>
      this(spendByStage: spendByStage);

  @override
  Analytics insights(List<AnalyticsInsightsInner> insights) =>
      this(insights: insights);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Analytics(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Analytics(...).copyWith(id: 12, name: "My name")
  /// ````
  Analytics call({
    Object? days = const $CopyWithPlaceholder(),
    Object? quality = const $CopyWithPlaceholder(),
    Object? skills = const $CopyWithPlaceholder(),
    Object? current = const $CopyWithPlaceholder(),
    Object? previous = const $CopyWithPlaceholder(),
    Object? perDay = const $CopyWithPlaceholder(),
    Object? steps = const $CopyWithPlaceholder(),
    Object? stops = const $CopyWithPlaceholder(),
    Object? models = const $CopyWithPlaceholder(),
    Object? repos = const $CopyWithPlaceholder(),
    Object? hours = const $CopyWithPlaceholder(),
    Object? spendByStage = const $CopyWithPlaceholder(),
    Object? insights = const $CopyWithPlaceholder(),
  }) {
    return Analytics(
      days: days == const $CopyWithPlaceholder()
          ? _value.days
          // ignore: cast_nullable_to_non_nullable
          : days as int,
      quality: quality == const $CopyWithPlaceholder()
          ? _value.quality
          // ignore: cast_nullable_to_non_nullable
          : quality as List<QualityStat>,
      skills: skills == const $CopyWithPlaceholder()
          ? _value.skills
          // ignore: cast_nullable_to_non_nullable
          : skills as List<SkillStat>?,
      current: current == const $CopyWithPlaceholder()
          ? _value.current
          // ignore: cast_nullable_to_non_nullable
          : current as PeriodStats,
      previous: previous == const $CopyWithPlaceholder()
          ? _value.previous
          // ignore: cast_nullable_to_non_nullable
          : previous as PeriodStats,
      perDay: perDay == const $CopyWithPlaceholder()
          ? _value.perDay
          // ignore: cast_nullable_to_non_nullable
          : perDay as List<DayStat>,
      steps: steps == const $CopyWithPlaceholder()
          ? _value.steps
          // ignore: cast_nullable_to_non_nullable
          : steps as Map<String, num>,
      stops: stops == const $CopyWithPlaceholder()
          ? _value.stops
          // ignore: cast_nullable_to_non_nullable
          : stops as Map<String, int>,
      models: models == const $CopyWithPlaceholder()
          ? _value.models
          // ignore: cast_nullable_to_non_nullable
          : models as List<AnalyticsModelsInner>,
      repos: repos == const $CopyWithPlaceholder()
          ? _value.repos
          // ignore: cast_nullable_to_non_nullable
          : repos as List<AnalyticsReposInner>,
      hours: hours == const $CopyWithPlaceholder()
          ? _value.hours
          // ignore: cast_nullable_to_non_nullable
          : hours as List<int>,
      spendByStage: spendByStage == const $CopyWithPlaceholder()
          ? _value.spendByStage
          // ignore: cast_nullable_to_non_nullable
          : spendByStage as List<StageSpend>,
      insights: insights == const $CopyWithPlaceholder()
          ? _value.insights
          // ignore: cast_nullable_to_non_nullable
          : insights as List<AnalyticsInsightsInner>,
    );
  }
}

extension $AnalyticsCopyWith on Analytics {
  /// Returns a callable class that can be used as follows: `instanceOfAnalytics.copyWith(...)` or like so:`instanceOfAnalytics.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AnalyticsCWProxy get copyWith => _$AnalyticsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Analytics _$AnalyticsFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('Analytics', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'days',
      'quality',
      'current',
      'previous',
      'perDay',
      'steps',
      'stops',
      'models',
      'repos',
      'hours',
      'spendByStage',
      'insights',
    ],
  );
  final val = Analytics(
    days: $checkedConvert('days', (v) => (v as num).toInt()),
    quality: $checkedConvert(
      'quality',
      (v) => (v as List<dynamic>)
          .map((e) => QualityStat.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    skills: $checkedConvert(
      'skills',
      (v) => (v as List<dynamic>?)
          ?.map((e) => SkillStat.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    current: $checkedConvert(
      'current',
      (v) => PeriodStats.fromJson(v as Map<String, dynamic>),
    ),
    previous: $checkedConvert(
      'previous',
      (v) => PeriodStats.fromJson(v as Map<String, dynamic>),
    ),
    perDay: $checkedConvert(
      'perDay',
      (v) => (v as List<dynamic>)
          .map((e) => DayStat.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    steps: $checkedConvert('steps', (v) => Map<String, num>.from(v as Map)),
    stops: $checkedConvert('stops', (v) => Map<String, int>.from(v as Map)),
    models: $checkedConvert(
      'models',
      (v) => (v as List<dynamic>)
          .map((e) => AnalyticsModelsInner.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    repos: $checkedConvert(
      'repos',
      (v) => (v as List<dynamic>)
          .map((e) => AnalyticsReposInner.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    hours: $checkedConvert(
      'hours',
      (v) => (v as List<dynamic>).map((e) => (e as num).toInt()).toList(),
    ),
    spendByStage: $checkedConvert(
      'spendByStage',
      (v) => (v as List<dynamic>)
          .map((e) => StageSpend.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    insights: $checkedConvert(
      'insights',
      (v) => (v as List<dynamic>)
          .map(
            (e) => AnalyticsInsightsInner.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$AnalyticsToJson(Analytics instance) => <String, dynamic>{
  'days': instance.days,
  'quality': instance.quality.map((e) => e.toJson()).toList(),
  'skills': ?instance.skills?.map((e) => e.toJson()).toList(),
  'current': instance.current.toJson(),
  'previous': instance.previous.toJson(),
  'perDay': instance.perDay.map((e) => e.toJson()).toList(),
  'steps': instance.steps,
  'stops': instance.stops,
  'models': instance.models.map((e) => e.toJson()).toList(),
  'repos': instance.repos.map((e) => e.toJson()).toList(),
  'hours': instance.hours,
  'spendByStage': instance.spendByStage.map((e) => e.toJson()).toList(),
  'insights': instance.insights.map((e) => e.toJson()).toList(),
};

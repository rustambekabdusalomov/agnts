// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_learning.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AnalyticsLearningCWProxy {
  AnalyticsLearning days(int days);

  AnalyticsLearning current(LearningPeriod current);

  AnalyticsLearning previous(LearningPeriod previous);

  AnalyticsLearning lessons(List<LessonCount> lessons);

  AnalyticsLearning followUpTypes(List<FollowUpCount> followUpTypes);

  AnalyticsLearning followUpSources(List<FollowUpCount> followUpSources);

  AnalyticsLearning reviewers(List<ReviewerStat> reviewers);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnalyticsLearning(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnalyticsLearning(...).copyWith(id: 12, name: "My name")
  /// ````
  AnalyticsLearning call({
    int days,
    LearningPeriod current,
    LearningPeriod previous,
    List<LessonCount> lessons,
    List<FollowUpCount> followUpTypes,
    List<FollowUpCount> followUpSources,
    List<ReviewerStat> reviewers,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAnalyticsLearning.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAnalyticsLearning.copyWith.fieldName(...)`
class _$AnalyticsLearningCWProxyImpl implements _$AnalyticsLearningCWProxy {
  const _$AnalyticsLearningCWProxyImpl(this._value);

  final AnalyticsLearning _value;

  @override
  AnalyticsLearning days(int days) => this(days: days);

  @override
  AnalyticsLearning current(LearningPeriod current) => this(current: current);

  @override
  AnalyticsLearning previous(LearningPeriod previous) =>
      this(previous: previous);

  @override
  AnalyticsLearning lessons(List<LessonCount> lessons) =>
      this(lessons: lessons);

  @override
  AnalyticsLearning followUpTypes(List<FollowUpCount> followUpTypes) =>
      this(followUpTypes: followUpTypes);

  @override
  AnalyticsLearning followUpSources(List<FollowUpCount> followUpSources) =>
      this(followUpSources: followUpSources);

  @override
  AnalyticsLearning reviewers(List<ReviewerStat> reviewers) =>
      this(reviewers: reviewers);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnalyticsLearning(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnalyticsLearning(...).copyWith(id: 12, name: "My name")
  /// ````
  AnalyticsLearning call({
    Object? days = const $CopyWithPlaceholder(),
    Object? current = const $CopyWithPlaceholder(),
    Object? previous = const $CopyWithPlaceholder(),
    Object? lessons = const $CopyWithPlaceholder(),
    Object? followUpTypes = const $CopyWithPlaceholder(),
    Object? followUpSources = const $CopyWithPlaceholder(),
    Object? reviewers = const $CopyWithPlaceholder(),
  }) {
    return AnalyticsLearning(
      days: days == const $CopyWithPlaceholder()
          ? _value.days
          // ignore: cast_nullable_to_non_nullable
          : days as int,
      current: current == const $CopyWithPlaceholder()
          ? _value.current
          // ignore: cast_nullable_to_non_nullable
          : current as LearningPeriod,
      previous: previous == const $CopyWithPlaceholder()
          ? _value.previous
          // ignore: cast_nullable_to_non_nullable
          : previous as LearningPeriod,
      lessons: lessons == const $CopyWithPlaceholder()
          ? _value.lessons
          // ignore: cast_nullable_to_non_nullable
          : lessons as List<LessonCount>,
      followUpTypes: followUpTypes == const $CopyWithPlaceholder()
          ? _value.followUpTypes
          // ignore: cast_nullable_to_non_nullable
          : followUpTypes as List<FollowUpCount>,
      followUpSources: followUpSources == const $CopyWithPlaceholder()
          ? _value.followUpSources
          // ignore: cast_nullable_to_non_nullable
          : followUpSources as List<FollowUpCount>,
      reviewers: reviewers == const $CopyWithPlaceholder()
          ? _value.reviewers
          // ignore: cast_nullable_to_non_nullable
          : reviewers as List<ReviewerStat>,
    );
  }
}

extension $AnalyticsLearningCopyWith on AnalyticsLearning {
  /// Returns a callable class that can be used as follows: `instanceOfAnalyticsLearning.copyWith(...)` or like so:`instanceOfAnalyticsLearning.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AnalyticsLearningCWProxy get copyWith =>
      _$AnalyticsLearningCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsLearning _$AnalyticsLearningFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AnalyticsLearning', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'days',
          'current',
          'previous',
          'lessons',
          'followUpTypes',
          'followUpSources',
          'reviewers',
        ],
      );
      final val = AnalyticsLearning(
        days: $checkedConvert('days', (v) => (v as num).toInt()),
        current: $checkedConvert(
          'current',
          (v) => LearningPeriod.fromJson(v as Map<String, dynamic>),
        ),
        previous: $checkedConvert(
          'previous',
          (v) => LearningPeriod.fromJson(v as Map<String, dynamic>),
        ),
        lessons: $checkedConvert(
          'lessons',
          (v) => (v as List<dynamic>)
              .map((e) => LessonCount.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        followUpTypes: $checkedConvert(
          'followUpTypes',
          (v) => (v as List<dynamic>)
              .map((e) => FollowUpCount.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        followUpSources: $checkedConvert(
          'followUpSources',
          (v) => (v as List<dynamic>)
              .map((e) => FollowUpCount.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        reviewers: $checkedConvert(
          'reviewers',
          (v) => (v as List<dynamic>)
              .map((e) => ReviewerStat.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AnalyticsLearningToJson(
  AnalyticsLearning instance,
) => <String, dynamic>{
  'days': instance.days,
  'current': instance.current.toJson(),
  'previous': instance.previous.toJson(),
  'lessons': instance.lessons.map((e) => e.toJson()).toList(),
  'followUpTypes': instance.followUpTypes.map((e) => e.toJson()).toList(),
  'followUpSources': instance.followUpSources.map((e) => e.toJson()).toList(),
  'reviewers': instance.reviewers.map((e) => e.toJson()).toList(),
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_counts.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DashboardCountsCWProxy {
  DashboardCounts needs(int needs);

  DashboardCounts answers(int answers);

  DashboardCounts reviews(int reviews);

  DashboardCounts stopped(int stopped);

  DashboardCounts running(int running);

  DashboardCounts queued(int queued);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DashboardCounts(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DashboardCounts(...).copyWith(id: 12, name: "My name")
  /// ````
  DashboardCounts call({
    int needs,
    int answers,
    int reviews,
    int stopped,
    int running,
    int queued,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDashboardCounts.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDashboardCounts.copyWith.fieldName(...)`
class _$DashboardCountsCWProxyImpl implements _$DashboardCountsCWProxy {
  const _$DashboardCountsCWProxyImpl(this._value);

  final DashboardCounts _value;

  @override
  DashboardCounts needs(int needs) => this(needs: needs);

  @override
  DashboardCounts answers(int answers) => this(answers: answers);

  @override
  DashboardCounts reviews(int reviews) => this(reviews: reviews);

  @override
  DashboardCounts stopped(int stopped) => this(stopped: stopped);

  @override
  DashboardCounts running(int running) => this(running: running);

  @override
  DashboardCounts queued(int queued) => this(queued: queued);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DashboardCounts(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DashboardCounts(...).copyWith(id: 12, name: "My name")
  /// ````
  DashboardCounts call({
    Object? needs = const $CopyWithPlaceholder(),
    Object? answers = const $CopyWithPlaceholder(),
    Object? reviews = const $CopyWithPlaceholder(),
    Object? stopped = const $CopyWithPlaceholder(),
    Object? running = const $CopyWithPlaceholder(),
    Object? queued = const $CopyWithPlaceholder(),
  }) {
    return DashboardCounts(
      needs: needs == const $CopyWithPlaceholder()
          ? _value.needs
          // ignore: cast_nullable_to_non_nullable
          : needs as int,
      answers: answers == const $CopyWithPlaceholder()
          ? _value.answers
          // ignore: cast_nullable_to_non_nullable
          : answers as int,
      reviews: reviews == const $CopyWithPlaceholder()
          ? _value.reviews
          // ignore: cast_nullable_to_non_nullable
          : reviews as int,
      stopped: stopped == const $CopyWithPlaceholder()
          ? _value.stopped
          // ignore: cast_nullable_to_non_nullable
          : stopped as int,
      running: running == const $CopyWithPlaceholder()
          ? _value.running
          // ignore: cast_nullable_to_non_nullable
          : running as int,
      queued: queued == const $CopyWithPlaceholder()
          ? _value.queued
          // ignore: cast_nullable_to_non_nullable
          : queued as int,
    );
  }
}

extension $DashboardCountsCopyWith on DashboardCounts {
  /// Returns a callable class that can be used as follows: `instanceOfDashboardCounts.copyWith(...)` or like so:`instanceOfDashboardCounts.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DashboardCountsCWProxy get copyWith => _$DashboardCountsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardCounts _$DashboardCountsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DashboardCounts', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'needs',
          'answers',
          'reviews',
          'stopped',
          'running',
          'queued',
        ],
      );
      final val = DashboardCounts(
        needs: $checkedConvert('needs', (v) => (v as num).toInt()),
        answers: $checkedConvert('answers', (v) => (v as num).toInt()),
        reviews: $checkedConvert('reviews', (v) => (v as num).toInt()),
        stopped: $checkedConvert('stopped', (v) => (v as num).toInt()),
        running: $checkedConvert('running', (v) => (v as num).toInt()),
        queued: $checkedConvert('queued', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$DashboardCountsToJson(DashboardCounts instance) =>
    <String, dynamic>{
      'needs': instance.needs,
      'answers': instance.answers,
      'reviews': instance.reviews,
      'stopped': instance.stopped,
      'running': instance.running,
      'queued': instance.queued,
    };

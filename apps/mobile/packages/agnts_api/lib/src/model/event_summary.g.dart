// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EventSummaryCWProxy {
  EventSummary runsStarted(int runsStarted);

  EventSummary reachedReview(int reachedReview);

  EventSummary avgTurns(int avgTurns);

  EventSummary stops(int stops);

  EventSummary errors(int errors);

  EventSummary steps(List<StepDuration> steps);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EventSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EventSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  EventSummary call({
    int runsStarted,
    int reachedReview,
    int avgTurns,
    int stops,
    int errors,
    List<StepDuration> steps,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEventSummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEventSummary.copyWith.fieldName(...)`
class _$EventSummaryCWProxyImpl implements _$EventSummaryCWProxy {
  const _$EventSummaryCWProxyImpl(this._value);

  final EventSummary _value;

  @override
  EventSummary runsStarted(int runsStarted) => this(runsStarted: runsStarted);

  @override
  EventSummary reachedReview(int reachedReview) =>
      this(reachedReview: reachedReview);

  @override
  EventSummary avgTurns(int avgTurns) => this(avgTurns: avgTurns);

  @override
  EventSummary stops(int stops) => this(stops: stops);

  @override
  EventSummary errors(int errors) => this(errors: errors);

  @override
  EventSummary steps(List<StepDuration> steps) => this(steps: steps);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EventSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EventSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  EventSummary call({
    Object? runsStarted = const $CopyWithPlaceholder(),
    Object? reachedReview = const $CopyWithPlaceholder(),
    Object? avgTurns = const $CopyWithPlaceholder(),
    Object? stops = const $CopyWithPlaceholder(),
    Object? errors = const $CopyWithPlaceholder(),
    Object? steps = const $CopyWithPlaceholder(),
  }) {
    return EventSummary(
      runsStarted: runsStarted == const $CopyWithPlaceholder()
          ? _value.runsStarted
          // ignore: cast_nullable_to_non_nullable
          : runsStarted as int,
      reachedReview: reachedReview == const $CopyWithPlaceholder()
          ? _value.reachedReview
          // ignore: cast_nullable_to_non_nullable
          : reachedReview as int,
      avgTurns: avgTurns == const $CopyWithPlaceholder()
          ? _value.avgTurns
          // ignore: cast_nullable_to_non_nullable
          : avgTurns as int,
      stops: stops == const $CopyWithPlaceholder()
          ? _value.stops
          // ignore: cast_nullable_to_non_nullable
          : stops as int,
      errors: errors == const $CopyWithPlaceholder()
          ? _value.errors
          // ignore: cast_nullable_to_non_nullable
          : errors as int,
      steps: steps == const $CopyWithPlaceholder()
          ? _value.steps
          // ignore: cast_nullable_to_non_nullable
          : steps as List<StepDuration>,
    );
  }
}

extension $EventSummaryCopyWith on EventSummary {
  /// Returns a callable class that can be used as follows: `instanceOfEventSummary.copyWith(...)` or like so:`instanceOfEventSummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EventSummaryCWProxy get copyWith => _$EventSummaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventSummary _$EventSummaryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('EventSummary', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'runsStarted',
          'reachedReview',
          'avgTurns',
          'stops',
          'errors',
          'steps',
        ],
      );
      final val = EventSummary(
        runsStarted: $checkedConvert('runsStarted', (v) => (v as num).toInt()),
        reachedReview: $checkedConvert(
          'reachedReview',
          (v) => (v as num).toInt(),
        ),
        avgTurns: $checkedConvert('avgTurns', (v) => (v as num).toInt()),
        stops: $checkedConvert('stops', (v) => (v as num).toInt()),
        errors: $checkedConvert('errors', (v) => (v as num).toInt()),
        steps: $checkedConvert(
          'steps',
          (v) => (v as List<dynamic>)
              .map((e) => StepDuration.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$EventSummaryToJson(EventSummary instance) =>
    <String, dynamic>{
      'runsStarted': instance.runsStarted,
      'reachedReview': instance.reachedReview,
      'avgTurns': instance.avgTurns,
      'stops': instance.stops,
      'errors': instance.errors,
      'steps': instance.steps.map((e) => e.toJson()).toList(),
    };

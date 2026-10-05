// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step_duration.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StepDurationCWProxy {
  StepDuration state(TicketState state);

  StepDuration avgMs(int? avgMs);

  StepDuration count(int count);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StepDuration(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StepDuration(...).copyWith(id: 12, name: "My name")
  /// ````
  StepDuration call({TicketState state, int? avgMs, int count});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStepDuration.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStepDuration.copyWith.fieldName(...)`
class _$StepDurationCWProxyImpl implements _$StepDurationCWProxy {
  const _$StepDurationCWProxyImpl(this._value);

  final StepDuration _value;

  @override
  StepDuration state(TicketState state) => this(state: state);

  @override
  StepDuration avgMs(int? avgMs) => this(avgMs: avgMs);

  @override
  StepDuration count(int count) => this(count: count);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StepDuration(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StepDuration(...).copyWith(id: 12, name: "My name")
  /// ````
  StepDuration call({
    Object? state = const $CopyWithPlaceholder(),
    Object? avgMs = const $CopyWithPlaceholder(),
    Object? count = const $CopyWithPlaceholder(),
  }) {
    return StepDuration(
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as TicketState,
      avgMs: avgMs == const $CopyWithPlaceholder()
          ? _value.avgMs
          // ignore: cast_nullable_to_non_nullable
          : avgMs as int?,
      count: count == const $CopyWithPlaceholder()
          ? _value.count
          // ignore: cast_nullable_to_non_nullable
          : count as int,
    );
  }
}

extension $StepDurationCopyWith on StepDuration {
  /// Returns a callable class that can be used as follows: `instanceOfStepDuration.copyWith(...)` or like so:`instanceOfStepDuration.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StepDurationCWProxy get copyWith => _$StepDurationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StepDuration _$StepDurationFromJson(Map<String, dynamic> json) =>
    $checkedCreate('StepDuration', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['state', 'count']);
      final val = StepDuration(
        state: $checkedConvert(
          'state',
          (v) => $enumDecode(_$TicketStateEnumMap, v),
        ),
        avgMs: $checkedConvert('avgMs', (v) => (v as num?)?.toInt()),
        count: $checkedConvert('count', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$StepDurationToJson(StepDuration instance) =>
    <String, dynamic>{
      'state': _$TicketStateEnumMap[instance.state]!,
      'avgMs': ?instance.avgMs,
      'count': instance.count,
    };

const _$TicketStateEnumMap = {
  TicketState.new_: 'new',
  TicketState.analyzing: 'analyzing',
  TicketState.waitingForAnswers: 'waiting_for_answers',
  TicketState.coding: 'coding',
  TicketState.testing: 'testing',
  TicketState.waitingForReview: 'waiting_for_review',
  TicketState.pushing: 'pushing',
  TicketState.done: 'done',
  TicketState.rejected: 'rejected',
  TicketState.failed: 'failed',
  TicketState.rateLimited: 'rate_limited',
};

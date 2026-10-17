// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_history_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RunHistorySummaryCWProxy {
  RunHistorySummary count(int count);

  RunHistorySummary errors(int errors);

  RunHistorySummary stalled(int stalled);

  RunHistorySummary costUsd(num costUsd);

  RunHistorySummary backgroundCostUsd(num backgroundCostUsd);

  RunHistorySummary inputTokens(int inputTokens);

  RunHistorySummary outputTokens(int outputTokens);

  RunHistorySummary p50Ms(int p50Ms);

  RunHistorySummary p95Ms(int p95Ms);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RunHistorySummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RunHistorySummary(...).copyWith(id: 12, name: "My name")
  /// ````
  RunHistorySummary call({
    int count,
    int errors,
    int stalled,
    num costUsd,
    num backgroundCostUsd,
    int inputTokens,
    int outputTokens,
    int p50Ms,
    int p95Ms,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRunHistorySummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRunHistorySummary.copyWith.fieldName(...)`
class _$RunHistorySummaryCWProxyImpl implements _$RunHistorySummaryCWProxy {
  const _$RunHistorySummaryCWProxyImpl(this._value);

  final RunHistorySummary _value;

  @override
  RunHistorySummary count(int count) => this(count: count);

  @override
  RunHistorySummary errors(int errors) => this(errors: errors);

  @override
  RunHistorySummary stalled(int stalled) => this(stalled: stalled);

  @override
  RunHistorySummary costUsd(num costUsd) => this(costUsd: costUsd);

  @override
  RunHistorySummary backgroundCostUsd(num backgroundCostUsd) =>
      this(backgroundCostUsd: backgroundCostUsd);

  @override
  RunHistorySummary inputTokens(int inputTokens) =>
      this(inputTokens: inputTokens);

  @override
  RunHistorySummary outputTokens(int outputTokens) =>
      this(outputTokens: outputTokens);

  @override
  RunHistorySummary p50Ms(int p50Ms) => this(p50Ms: p50Ms);

  @override
  RunHistorySummary p95Ms(int p95Ms) => this(p95Ms: p95Ms);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RunHistorySummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RunHistorySummary(...).copyWith(id: 12, name: "My name")
  /// ````
  RunHistorySummary call({
    Object? count = const $CopyWithPlaceholder(),
    Object? errors = const $CopyWithPlaceholder(),
    Object? stalled = const $CopyWithPlaceholder(),
    Object? costUsd = const $CopyWithPlaceholder(),
    Object? backgroundCostUsd = const $CopyWithPlaceholder(),
    Object? inputTokens = const $CopyWithPlaceholder(),
    Object? outputTokens = const $CopyWithPlaceholder(),
    Object? p50Ms = const $CopyWithPlaceholder(),
    Object? p95Ms = const $CopyWithPlaceholder(),
  }) {
    return RunHistorySummary(
      count: count == const $CopyWithPlaceholder()
          ? _value.count
          // ignore: cast_nullable_to_non_nullable
          : count as int,
      errors: errors == const $CopyWithPlaceholder()
          ? _value.errors
          // ignore: cast_nullable_to_non_nullable
          : errors as int,
      stalled: stalled == const $CopyWithPlaceholder()
          ? _value.stalled
          // ignore: cast_nullable_to_non_nullable
          : stalled as int,
      costUsd: costUsd == const $CopyWithPlaceholder()
          ? _value.costUsd
          // ignore: cast_nullable_to_non_nullable
          : costUsd as num,
      backgroundCostUsd: backgroundCostUsd == const $CopyWithPlaceholder()
          ? _value.backgroundCostUsd
          // ignore: cast_nullable_to_non_nullable
          : backgroundCostUsd as num,
      inputTokens: inputTokens == const $CopyWithPlaceholder()
          ? _value.inputTokens
          // ignore: cast_nullable_to_non_nullable
          : inputTokens as int,
      outputTokens: outputTokens == const $CopyWithPlaceholder()
          ? _value.outputTokens
          // ignore: cast_nullable_to_non_nullable
          : outputTokens as int,
      p50Ms: p50Ms == const $CopyWithPlaceholder()
          ? _value.p50Ms
          // ignore: cast_nullable_to_non_nullable
          : p50Ms as int,
      p95Ms: p95Ms == const $CopyWithPlaceholder()
          ? _value.p95Ms
          // ignore: cast_nullable_to_non_nullable
          : p95Ms as int,
    );
  }
}

extension $RunHistorySummaryCopyWith on RunHistorySummary {
  /// Returns a callable class that can be used as follows: `instanceOfRunHistorySummary.copyWith(...)` or like so:`instanceOfRunHistorySummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RunHistorySummaryCWProxy get copyWith =>
      _$RunHistorySummaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RunHistorySummary _$RunHistorySummaryFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RunHistorySummary', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'count',
      'errors',
      'stalled',
      'costUsd',
      'backgroundCostUsd',
      'inputTokens',
      'outputTokens',
      'p50Ms',
      'p95Ms',
    ],
  );
  final val = RunHistorySummary(
    count: $checkedConvert('count', (v) => (v as num).toInt()),
    errors: $checkedConvert('errors', (v) => (v as num).toInt()),
    stalled: $checkedConvert('stalled', (v) => (v as num).toInt()),
    costUsd: $checkedConvert('costUsd', (v) => v as num),
    backgroundCostUsd: $checkedConvert('backgroundCostUsd', (v) => v as num),
    inputTokens: $checkedConvert('inputTokens', (v) => (v as num).toInt()),
    outputTokens: $checkedConvert('outputTokens', (v) => (v as num).toInt()),
    p50Ms: $checkedConvert('p50Ms', (v) => (v as num).toInt()),
    p95Ms: $checkedConvert('p95Ms', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$RunHistorySummaryToJson(RunHistorySummary instance) =>
    <String, dynamic>{
      'count': instance.count,
      'errors': instance.errors,
      'stalled': instance.stalled,
      'costUsd': instance.costUsd,
      'backgroundCostUsd': instance.backgroundCostUsd,
      'inputTokens': instance.inputTokens,
      'outputTokens': instance.outputTokens,
      'p50Ms': instance.p50Ms,
      'p95Ms': instance.p95Ms,
    };

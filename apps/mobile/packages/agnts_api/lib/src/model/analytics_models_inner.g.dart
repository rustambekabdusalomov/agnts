// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_models_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AnalyticsModelsInnerCWProxy {
  AnalyticsModelsInner model(String model);

  AnalyticsModelsInner runs(int runs);

  AnalyticsModelsInner reachedReview(int reachedReview);

  AnalyticsModelsInner avgTurns(num avgTurns);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnalyticsModelsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnalyticsModelsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AnalyticsModelsInner call({
    String model,
    int runs,
    int reachedReview,
    num avgTurns,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAnalyticsModelsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAnalyticsModelsInner.copyWith.fieldName(...)`
class _$AnalyticsModelsInnerCWProxyImpl
    implements _$AnalyticsModelsInnerCWProxy {
  const _$AnalyticsModelsInnerCWProxyImpl(this._value);

  final AnalyticsModelsInner _value;

  @override
  AnalyticsModelsInner model(String model) => this(model: model);

  @override
  AnalyticsModelsInner runs(int runs) => this(runs: runs);

  @override
  AnalyticsModelsInner reachedReview(int reachedReview) =>
      this(reachedReview: reachedReview);

  @override
  AnalyticsModelsInner avgTurns(num avgTurns) => this(avgTurns: avgTurns);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnalyticsModelsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnalyticsModelsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AnalyticsModelsInner call({
    Object? model = const $CopyWithPlaceholder(),
    Object? runs = const $CopyWithPlaceholder(),
    Object? reachedReview = const $CopyWithPlaceholder(),
    Object? avgTurns = const $CopyWithPlaceholder(),
  }) {
    return AnalyticsModelsInner(
      model: model == const $CopyWithPlaceholder()
          ? _value.model
          // ignore: cast_nullable_to_non_nullable
          : model as String,
      runs: runs == const $CopyWithPlaceholder()
          ? _value.runs
          // ignore: cast_nullable_to_non_nullable
          : runs as int,
      reachedReview: reachedReview == const $CopyWithPlaceholder()
          ? _value.reachedReview
          // ignore: cast_nullable_to_non_nullable
          : reachedReview as int,
      avgTurns: avgTurns == const $CopyWithPlaceholder()
          ? _value.avgTurns
          // ignore: cast_nullable_to_non_nullable
          : avgTurns as num,
    );
  }
}

extension $AnalyticsModelsInnerCopyWith on AnalyticsModelsInner {
  /// Returns a callable class that can be used as follows: `instanceOfAnalyticsModelsInner.copyWith(...)` or like so:`instanceOfAnalyticsModelsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AnalyticsModelsInnerCWProxy get copyWith =>
      _$AnalyticsModelsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsModelsInner _$AnalyticsModelsInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AnalyticsModelsInner', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['model', 'runs', 'reachedReview', 'avgTurns'],
  );
  final val = AnalyticsModelsInner(
    model: $checkedConvert('model', (v) => v as String),
    runs: $checkedConvert('runs', (v) => (v as num).toInt()),
    reachedReview: $checkedConvert('reachedReview', (v) => (v as num).toInt()),
    avgTurns: $checkedConvert('avgTurns', (v) => v as num),
  );
  return val;
});

Map<String, dynamic> _$AnalyticsModelsInnerToJson(
  AnalyticsModelsInner instance,
) => <String, dynamic>{
  'model': instance.model,
  'runs': instance.runs,
  'reachedReview': instance.reachedReview,
  'avgTurns': instance.avgTurns,
};

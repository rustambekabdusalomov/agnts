// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_insights_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AnalyticsInsightsInnerCWProxy {
  AnalyticsInsightsInner kind(AnalyticsInsightsInnerKindEnum kind);

  AnalyticsInsightsInner values(Map<String, String> values);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnalyticsInsightsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnalyticsInsightsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AnalyticsInsightsInner call({
    AnalyticsInsightsInnerKindEnum kind,
    Map<String, String> values,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAnalyticsInsightsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAnalyticsInsightsInner.copyWith.fieldName(...)`
class _$AnalyticsInsightsInnerCWProxyImpl
    implements _$AnalyticsInsightsInnerCWProxy {
  const _$AnalyticsInsightsInnerCWProxyImpl(this._value);

  final AnalyticsInsightsInner _value;

  @override
  AnalyticsInsightsInner kind(AnalyticsInsightsInnerKindEnum kind) =>
      this(kind: kind);

  @override
  AnalyticsInsightsInner values(Map<String, String> values) =>
      this(values: values);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnalyticsInsightsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnalyticsInsightsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AnalyticsInsightsInner call({
    Object? kind = const $CopyWithPlaceholder(),
    Object? values = const $CopyWithPlaceholder(),
  }) {
    return AnalyticsInsightsInner(
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as AnalyticsInsightsInnerKindEnum,
      values: values == const $CopyWithPlaceholder()
          ? _value.values
          // ignore: cast_nullable_to_non_nullable
          : values as Map<String, String>,
    );
  }
}

extension $AnalyticsInsightsInnerCopyWith on AnalyticsInsightsInner {
  /// Returns a callable class that can be used as follows: `instanceOfAnalyticsInsightsInner.copyWith(...)` or like so:`instanceOfAnalyticsInsightsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AnalyticsInsightsInnerCWProxy get copyWith =>
      _$AnalyticsInsightsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsInsightsInner _$AnalyticsInsightsInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AnalyticsInsightsInner', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['kind', 'values']);
  final val = AnalyticsInsightsInner(
    kind: $checkedConvert(
      'kind',
      (v) => $enumDecode(_$AnalyticsInsightsInnerKindEnumEnumMap, v),
    ),
    values: $checkedConvert(
      'values',
      (v) => Map<String, String>.from(v as Map),
    ),
  );
  return val;
});

Map<String, dynamic> _$AnalyticsInsightsInnerToJson(
  AnalyticsInsightsInner instance,
) => <String, dynamic>{
  'kind': _$AnalyticsInsightsInnerKindEnumEnumMap[instance.kind]!,
  'values': instance.values,
};

const _$AnalyticsInsightsInnerKindEnumEnumMap = {
  AnalyticsInsightsInnerKindEnum.claudeMd: 'claudeMd',
  AnalyticsInsightsInnerKindEnum.waiting: 'waiting',
  AnalyticsInsightsInnerKindEnum.stopsTests: 'stopsTests',
  AnalyticsInsightsInnerKindEnum.stopsLimit: 'stopsLimit',
  AnalyticsInsightsInnerKindEnum.night: 'night',
  AnalyticsInsightsInnerKindEnum.mergeRate: 'mergeRate',
  AnalyticsInsightsInnerKindEnum.slowAnswers: 'slowAnswers',
  AnalyticsInsightsInnerKindEnum.followUpsNoise: 'followUpsNoise',
  AnalyticsInsightsInnerKindEnum.flakyJob: 'flakyJob',
};

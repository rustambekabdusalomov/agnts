// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sec_severity_counts.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SecSeverityCountsCWProxy {
  SecSeverityCounts critical(int critical);

  SecSeverityCounts high(int high);

  SecSeverityCounts medium(int medium);

  SecSeverityCounts low(int low);

  SecSeverityCounts info(int info);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SecSeverityCounts(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SecSeverityCounts(...).copyWith(id: 12, name: "My name")
  /// ````
  SecSeverityCounts call({
    int critical,
    int high,
    int medium,
    int low,
    int info,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSecSeverityCounts.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSecSeverityCounts.copyWith.fieldName(...)`
class _$SecSeverityCountsCWProxyImpl implements _$SecSeverityCountsCWProxy {
  const _$SecSeverityCountsCWProxyImpl(this._value);

  final SecSeverityCounts _value;

  @override
  SecSeverityCounts critical(int critical) => this(critical: critical);

  @override
  SecSeverityCounts high(int high) => this(high: high);

  @override
  SecSeverityCounts medium(int medium) => this(medium: medium);

  @override
  SecSeverityCounts low(int low) => this(low: low);

  @override
  SecSeverityCounts info(int info) => this(info: info);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SecSeverityCounts(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SecSeverityCounts(...).copyWith(id: 12, name: "My name")
  /// ````
  SecSeverityCounts call({
    Object? critical = const $CopyWithPlaceholder(),
    Object? high = const $CopyWithPlaceholder(),
    Object? medium = const $CopyWithPlaceholder(),
    Object? low = const $CopyWithPlaceholder(),
    Object? info = const $CopyWithPlaceholder(),
  }) {
    return SecSeverityCounts(
      critical: critical == const $CopyWithPlaceholder()
          ? _value.critical
          // ignore: cast_nullable_to_non_nullable
          : critical as int,
      high: high == const $CopyWithPlaceholder()
          ? _value.high
          // ignore: cast_nullable_to_non_nullable
          : high as int,
      medium: medium == const $CopyWithPlaceholder()
          ? _value.medium
          // ignore: cast_nullable_to_non_nullable
          : medium as int,
      low: low == const $CopyWithPlaceholder()
          ? _value.low
          // ignore: cast_nullable_to_non_nullable
          : low as int,
      info: info == const $CopyWithPlaceholder()
          ? _value.info
          // ignore: cast_nullable_to_non_nullable
          : info as int,
    );
  }
}

extension $SecSeverityCountsCopyWith on SecSeverityCounts {
  /// Returns a callable class that can be used as follows: `instanceOfSecSeverityCounts.copyWith(...)` or like so:`instanceOfSecSeverityCounts.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SecSeverityCountsCWProxy get copyWith =>
      _$SecSeverityCountsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SecSeverityCounts _$SecSeverityCountsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SecSeverityCounts', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['critical', 'high', 'medium', 'low', 'info'],
      );
      final val = SecSeverityCounts(
        critical: $checkedConvert('critical', (v) => (v as num).toInt()),
        high: $checkedConvert('high', (v) => (v as num).toInt()),
        medium: $checkedConvert('medium', (v) => (v as num).toInt()),
        low: $checkedConvert('low', (v) => (v as num).toInt()),
        info: $checkedConvert('info', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$SecSeverityCountsToJson(SecSeverityCounts instance) =>
    <String, dynamic>{
      'critical': instance.critical,
      'high': instance.high,
      'medium': instance.medium,
      'low': instance.low,
      'info': instance.info,
    };

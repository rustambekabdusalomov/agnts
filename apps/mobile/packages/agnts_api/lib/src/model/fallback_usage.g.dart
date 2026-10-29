// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fallback_usage.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FallbackUsageCWProxy {
  FallbackUsage provider(String provider);

  FallbackUsage monthLimit(int monthLimit);

  FallbackUsage monthUsed(int monthUsed);

  FallbackUsage isDefault(bool isDefault);

  FallbackUsage setAt(DateTime? setAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FallbackUsage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FallbackUsage(...).copyWith(id: 12, name: "My name")
  /// ````
  FallbackUsage call({
    String provider,
    int monthLimit,
    int monthUsed,
    bool isDefault,
    DateTime? setAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFallbackUsage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFallbackUsage.copyWith.fieldName(...)`
class _$FallbackUsageCWProxyImpl implements _$FallbackUsageCWProxy {
  const _$FallbackUsageCWProxyImpl(this._value);

  final FallbackUsage _value;

  @override
  FallbackUsage provider(String provider) => this(provider: provider);

  @override
  FallbackUsage monthLimit(int monthLimit) => this(monthLimit: monthLimit);

  @override
  FallbackUsage monthUsed(int monthUsed) => this(monthUsed: monthUsed);

  @override
  FallbackUsage isDefault(bool isDefault) => this(isDefault: isDefault);

  @override
  FallbackUsage setAt(DateTime? setAt) => this(setAt: setAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FallbackUsage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FallbackUsage(...).copyWith(id: 12, name: "My name")
  /// ````
  FallbackUsage call({
    Object? provider = const $CopyWithPlaceholder(),
    Object? monthLimit = const $CopyWithPlaceholder(),
    Object? monthUsed = const $CopyWithPlaceholder(),
    Object? isDefault = const $CopyWithPlaceholder(),
    Object? setAt = const $CopyWithPlaceholder(),
  }) {
    return FallbackUsage(
      provider: provider == const $CopyWithPlaceholder()
          ? _value.provider
          // ignore: cast_nullable_to_non_nullable
          : provider as String,
      monthLimit: monthLimit == const $CopyWithPlaceholder()
          ? _value.monthLimit
          // ignore: cast_nullable_to_non_nullable
          : monthLimit as int,
      monthUsed: monthUsed == const $CopyWithPlaceholder()
          ? _value.monthUsed
          // ignore: cast_nullable_to_non_nullable
          : monthUsed as int,
      isDefault: isDefault == const $CopyWithPlaceholder()
          ? _value.isDefault
          // ignore: cast_nullable_to_non_nullable
          : isDefault as bool,
      setAt: setAt == const $CopyWithPlaceholder()
          ? _value.setAt
          // ignore: cast_nullable_to_non_nullable
          : setAt as DateTime?,
    );
  }
}

extension $FallbackUsageCopyWith on FallbackUsage {
  /// Returns a callable class that can be used as follows: `instanceOfFallbackUsage.copyWith(...)` or like so:`instanceOfFallbackUsage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FallbackUsageCWProxy get copyWith => _$FallbackUsageCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FallbackUsage _$FallbackUsageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('FallbackUsage', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'provider',
          'monthLimit',
          'monthUsed',
          'isDefault',
        ],
      );
      final val = FallbackUsage(
        provider: $checkedConvert('provider', (v) => v as String),
        monthLimit: $checkedConvert('monthLimit', (v) => (v as num).toInt()),
        monthUsed: $checkedConvert('monthUsed', (v) => (v as num).toInt()),
        isDefault: $checkedConvert('isDefault', (v) => v as bool),
        setAt: $checkedConvert(
          'setAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$FallbackUsageToJson(FallbackUsage instance) =>
    <String, dynamic>{
      'provider': instance.provider,
      'monthLimit': instance.monthLimit,
      'monthUsed': instance.monthUsed,
      'isDefault': instance.isDefault,
      'setAt': ?instance.setAt?.toIso8601String(),
    };

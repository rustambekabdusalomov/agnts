// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_usage.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreditUsageCWProxy {
  CreditUsage monthLimit(int monthLimit);

  CreditUsage monthUsed(int monthUsed);

  CreditUsage totalUsed(int totalUsed);

  CreditUsage setAt(DateTime? setAt);

  CreditUsage fallback(FallbackUsage? fallback);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreditUsage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreditUsage(...).copyWith(id: 12, name: "My name")
  /// ````
  CreditUsage call({
    int monthLimit,
    int monthUsed,
    int totalUsed,
    DateTime? setAt,
    FallbackUsage? fallback,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreditUsage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreditUsage.copyWith.fieldName(...)`
class _$CreditUsageCWProxyImpl implements _$CreditUsageCWProxy {
  const _$CreditUsageCWProxyImpl(this._value);

  final CreditUsage _value;

  @override
  CreditUsage monthLimit(int monthLimit) => this(monthLimit: monthLimit);

  @override
  CreditUsage monthUsed(int monthUsed) => this(monthUsed: monthUsed);

  @override
  CreditUsage totalUsed(int totalUsed) => this(totalUsed: totalUsed);

  @override
  CreditUsage setAt(DateTime? setAt) => this(setAt: setAt);

  @override
  CreditUsage fallback(FallbackUsage? fallback) => this(fallback: fallback);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreditUsage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreditUsage(...).copyWith(id: 12, name: "My name")
  /// ````
  CreditUsage call({
    Object? monthLimit = const $CopyWithPlaceholder(),
    Object? monthUsed = const $CopyWithPlaceholder(),
    Object? totalUsed = const $CopyWithPlaceholder(),
    Object? setAt = const $CopyWithPlaceholder(),
    Object? fallback = const $CopyWithPlaceholder(),
  }) {
    return CreditUsage(
      monthLimit: monthLimit == const $CopyWithPlaceholder()
          ? _value.monthLimit
          // ignore: cast_nullable_to_non_nullable
          : monthLimit as int,
      monthUsed: monthUsed == const $CopyWithPlaceholder()
          ? _value.monthUsed
          // ignore: cast_nullable_to_non_nullable
          : monthUsed as int,
      totalUsed: totalUsed == const $CopyWithPlaceholder()
          ? _value.totalUsed
          // ignore: cast_nullable_to_non_nullable
          : totalUsed as int,
      setAt: setAt == const $CopyWithPlaceholder()
          ? _value.setAt
          // ignore: cast_nullable_to_non_nullable
          : setAt as DateTime?,
      fallback: fallback == const $CopyWithPlaceholder()
          ? _value.fallback
          // ignore: cast_nullable_to_non_nullable
          : fallback as FallbackUsage?,
    );
  }
}

extension $CreditUsageCopyWith on CreditUsage {
  /// Returns a callable class that can be used as follows: `instanceOfCreditUsage.copyWith(...)` or like so:`instanceOfCreditUsage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreditUsageCWProxy get copyWith => _$CreditUsageCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreditUsage _$CreditUsageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CreditUsage', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['monthLimit', 'monthUsed', 'totalUsed'],
      );
      final val = CreditUsage(
        monthLimit: $checkedConvert('monthLimit', (v) => (v as num).toInt()),
        monthUsed: $checkedConvert('monthUsed', (v) => (v as num).toInt()),
        totalUsed: $checkedConvert('totalUsed', (v) => (v as num).toInt()),
        setAt: $checkedConvert(
          'setAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        fallback: $checkedConvert(
          'fallback',
          (v) => v == null
              ? null
              : FallbackUsage.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CreditUsageToJson(CreditUsage instance) =>
    <String, dynamic>{
      'monthLimit': instance.monthLimit,
      'monthUsed': instance.monthUsed,
      'totalUsed': instance.totalUsed,
      'setAt': ?instance.setAt?.toIso8601String(),
      'fallback': ?instance.fallback?.toJson(),
    };

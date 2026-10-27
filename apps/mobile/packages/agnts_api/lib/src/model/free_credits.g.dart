// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'free_credits.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FreeCreditsCWProxy {
  FreeCredits limit(int limit);

  FreeCredits used(int used);

  FreeCredits remaining(int remaining);

  FreeCredits setAt(DateTime? setAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FreeCredits(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FreeCredits(...).copyWith(id: 12, name: "My name")
  /// ````
  FreeCredits call({int limit, int used, int remaining, DateTime? setAt});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFreeCredits.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFreeCredits.copyWith.fieldName(...)`
class _$FreeCreditsCWProxyImpl implements _$FreeCreditsCWProxy {
  const _$FreeCreditsCWProxyImpl(this._value);

  final FreeCredits _value;

  @override
  FreeCredits limit(int limit) => this(limit: limit);

  @override
  FreeCredits used(int used) => this(used: used);

  @override
  FreeCredits remaining(int remaining) => this(remaining: remaining);

  @override
  FreeCredits setAt(DateTime? setAt) => this(setAt: setAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FreeCredits(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FreeCredits(...).copyWith(id: 12, name: "My name")
  /// ````
  FreeCredits call({
    Object? limit = const $CopyWithPlaceholder(),
    Object? used = const $CopyWithPlaceholder(),
    Object? remaining = const $CopyWithPlaceholder(),
    Object? setAt = const $CopyWithPlaceholder(),
  }) {
    return FreeCredits(
      limit: limit == const $CopyWithPlaceholder()
          ? _value.limit
          // ignore: cast_nullable_to_non_nullable
          : limit as int,
      used: used == const $CopyWithPlaceholder()
          ? _value.used
          // ignore: cast_nullable_to_non_nullable
          : used as int,
      remaining: remaining == const $CopyWithPlaceholder()
          ? _value.remaining
          // ignore: cast_nullable_to_non_nullable
          : remaining as int,
      setAt: setAt == const $CopyWithPlaceholder()
          ? _value.setAt
          // ignore: cast_nullable_to_non_nullable
          : setAt as DateTime?,
    );
  }
}

extension $FreeCreditsCopyWith on FreeCredits {
  /// Returns a callable class that can be used as follows: `instanceOfFreeCredits.copyWith(...)` or like so:`instanceOfFreeCredits.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FreeCreditsCWProxy get copyWith => _$FreeCreditsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FreeCredits _$FreeCreditsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('FreeCredits', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['limit', 'used', 'remaining']);
      final val = FreeCredits(
        limit: $checkedConvert('limit', (v) => (v as num).toInt()),
        used: $checkedConvert('used', (v) => (v as num).toInt()),
        remaining: $checkedConvert('remaining', (v) => (v as num).toInt()),
        setAt: $checkedConvert(
          'setAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$FreeCreditsToJson(FreeCredits instance) =>
    <String, dynamic>{
      'limit': instance.limit,
      'used': instance.used,
      'remaining': instance.remaining,
      'setAt': ?instance.setAt?.toIso8601String(),
    };

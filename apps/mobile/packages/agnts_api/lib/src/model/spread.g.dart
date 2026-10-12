// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spread.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SpreadCWProxy {
  Spread p50(num? p50);

  Spread p90(num? p90);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Spread(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Spread(...).copyWith(id: 12, name: "My name")
  /// ````
  Spread call({num? p50, num? p90});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSpread.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSpread.copyWith.fieldName(...)`
class _$SpreadCWProxyImpl implements _$SpreadCWProxy {
  const _$SpreadCWProxyImpl(this._value);

  final Spread _value;

  @override
  Spread p50(num? p50) => this(p50: p50);

  @override
  Spread p90(num? p90) => this(p90: p90);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Spread(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Spread(...).copyWith(id: 12, name: "My name")
  /// ````
  Spread call({
    Object? p50 = const $CopyWithPlaceholder(),
    Object? p90 = const $CopyWithPlaceholder(),
  }) {
    return Spread(
      p50: p50 == const $CopyWithPlaceholder()
          ? _value.p50
          // ignore: cast_nullable_to_non_nullable
          : p50 as num?,
      p90: p90 == const $CopyWithPlaceholder()
          ? _value.p90
          // ignore: cast_nullable_to_non_nullable
          : p90 as num?,
    );
  }
}

extension $SpreadCopyWith on Spread {
  /// Returns a callable class that can be used as follows: `instanceOfSpread.copyWith(...)` or like so:`instanceOfSpread.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SpreadCWProxy get copyWith => _$SpreadCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Spread _$SpreadFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Spread', json, ($checkedConvert) {
      final val = Spread(
        p50: $checkedConvert('p50', (v) => v as num?),
        p90: $checkedConvert('p90', (v) => v as num?),
      );
      return val;
    });

Map<String, dynamic> _$SpreadToJson(Spread instance) => <String, dynamic>{
  'p50': ?instance.p50,
  'p90': ?instance.p90,
};

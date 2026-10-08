// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capacity.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CapacityCWProxy {
  Capacity budgetMb(int budgetMb);

  Capacity reservedMb(int reservedMb);

  Capacity runs(int runs);

  Capacity diskFreeMb(int? diskFreeMb);

  Capacity full(bool full);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Capacity(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Capacity(...).copyWith(id: 12, name: "My name")
  /// ````
  Capacity call({
    int budgetMb,
    int reservedMb,
    int runs,
    int? diskFreeMb,
    bool full,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCapacity.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCapacity.copyWith.fieldName(...)`
class _$CapacityCWProxyImpl implements _$CapacityCWProxy {
  const _$CapacityCWProxyImpl(this._value);

  final Capacity _value;

  @override
  Capacity budgetMb(int budgetMb) => this(budgetMb: budgetMb);

  @override
  Capacity reservedMb(int reservedMb) => this(reservedMb: reservedMb);

  @override
  Capacity runs(int runs) => this(runs: runs);

  @override
  Capacity diskFreeMb(int? diskFreeMb) => this(diskFreeMb: diskFreeMb);

  @override
  Capacity full(bool full) => this(full: full);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Capacity(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Capacity(...).copyWith(id: 12, name: "My name")
  /// ````
  Capacity call({
    Object? budgetMb = const $CopyWithPlaceholder(),
    Object? reservedMb = const $CopyWithPlaceholder(),
    Object? runs = const $CopyWithPlaceholder(),
    Object? diskFreeMb = const $CopyWithPlaceholder(),
    Object? full = const $CopyWithPlaceholder(),
  }) {
    return Capacity(
      budgetMb: budgetMb == const $CopyWithPlaceholder()
          ? _value.budgetMb
          // ignore: cast_nullable_to_non_nullable
          : budgetMb as int,
      reservedMb: reservedMb == const $CopyWithPlaceholder()
          ? _value.reservedMb
          // ignore: cast_nullable_to_non_nullable
          : reservedMb as int,
      runs: runs == const $CopyWithPlaceholder()
          ? _value.runs
          // ignore: cast_nullable_to_non_nullable
          : runs as int,
      diskFreeMb: diskFreeMb == const $CopyWithPlaceholder()
          ? _value.diskFreeMb
          // ignore: cast_nullable_to_non_nullable
          : diskFreeMb as int?,
      full: full == const $CopyWithPlaceholder()
          ? _value.full
          // ignore: cast_nullable_to_non_nullable
          : full as bool,
    );
  }
}

extension $CapacityCopyWith on Capacity {
  /// Returns a callable class that can be used as follows: `instanceOfCapacity.copyWith(...)` or like so:`instanceOfCapacity.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CapacityCWProxy get copyWith => _$CapacityCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Capacity _$CapacityFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Capacity', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['budgetMb', 'reservedMb', 'runs', 'full'],
      );
      final val = Capacity(
        budgetMb: $checkedConvert('budgetMb', (v) => (v as num).toInt()),
        reservedMb: $checkedConvert('reservedMb', (v) => (v as num).toInt()),
        runs: $checkedConvert('runs', (v) => (v as num).toInt()),
        diskFreeMb: $checkedConvert('diskFreeMb', (v) => (v as num?)?.toInt()),
        full: $checkedConvert('full', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$CapacityToJson(Capacity instance) => <String, dynamic>{
  'budgetMb': instance.budgetMb,
  'reservedMb': instance.reservedMb,
  'runs': instance.runs,
  'diskFreeMb': ?instance.diskFreeMb,
  'full': instance.full,
};

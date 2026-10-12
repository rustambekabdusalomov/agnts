// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ci_day.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CIDayCWProxy {
  CIDay date(DateTime date);

  CIDay new_(int new_);

  CIDay fixed(int fixed);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CIDay(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CIDay(...).copyWith(id: 12, name: "My name")
  /// ````
  CIDay call({DateTime date, int new_, int fixed});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCIDay.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCIDay.copyWith.fieldName(...)`
class _$CIDayCWProxyImpl implements _$CIDayCWProxy {
  const _$CIDayCWProxyImpl(this._value);

  final CIDay _value;

  @override
  CIDay date(DateTime date) => this(date: date);

  @override
  CIDay new_(int new_) => this(new_: new_);

  @override
  CIDay fixed(int fixed) => this(fixed: fixed);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CIDay(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CIDay(...).copyWith(id: 12, name: "My name")
  /// ````
  CIDay call({
    Object? date = const $CopyWithPlaceholder(),
    Object? new_ = const $CopyWithPlaceholder(),
    Object? fixed = const $CopyWithPlaceholder(),
  }) {
    return CIDay(
      date: date == const $CopyWithPlaceholder()
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as DateTime,
      new_: new_ == const $CopyWithPlaceholder()
          ? _value.new_
          // ignore: cast_nullable_to_non_nullable
          : new_ as int,
      fixed: fixed == const $CopyWithPlaceholder()
          ? _value.fixed
          // ignore: cast_nullable_to_non_nullable
          : fixed as int,
    );
  }
}

extension $CIDayCopyWith on CIDay {
  /// Returns a callable class that can be used as follows: `instanceOfCIDay.copyWith(...)` or like so:`instanceOfCIDay.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CIDayCWProxy get copyWith => _$CIDayCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CIDay _$CIDayFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CIDay', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['date', 'new', 'fixed']);
      final val = CIDay(
        date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
        new_: $checkedConvert('new', (v) => (v as num).toInt()),
        fixed: $checkedConvert('fixed', (v) => (v as num).toInt()),
      );
      return val;
    }, fieldKeyMap: const {'new_': 'new'});

Map<String, dynamic> _$CIDayToJson(CIDay instance) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'new': instance.new_,
  'fixed': instance.fixed,
};

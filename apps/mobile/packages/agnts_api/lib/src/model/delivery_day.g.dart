// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_day.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DeliveryDayCWProxy {
  DeliveryDay date(DateTime date);

  DeliveryDay merged(int merged);

  DeliveryDay closed(int closed);

  DeliveryDay pushedMin(num? pushedMin);

  DeliveryDay mergedMin(num? mergedMin);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeliveryDay(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeliveryDay(...).copyWith(id: 12, name: "My name")
  /// ````
  DeliveryDay call({
    DateTime date,
    int merged,
    int closed,
    num? pushedMin,
    num? mergedMin,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDeliveryDay.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDeliveryDay.copyWith.fieldName(...)`
class _$DeliveryDayCWProxyImpl implements _$DeliveryDayCWProxy {
  const _$DeliveryDayCWProxyImpl(this._value);

  final DeliveryDay _value;

  @override
  DeliveryDay date(DateTime date) => this(date: date);

  @override
  DeliveryDay merged(int merged) => this(merged: merged);

  @override
  DeliveryDay closed(int closed) => this(closed: closed);

  @override
  DeliveryDay pushedMin(num? pushedMin) => this(pushedMin: pushedMin);

  @override
  DeliveryDay mergedMin(num? mergedMin) => this(mergedMin: mergedMin);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeliveryDay(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeliveryDay(...).copyWith(id: 12, name: "My name")
  /// ````
  DeliveryDay call({
    Object? date = const $CopyWithPlaceholder(),
    Object? merged = const $CopyWithPlaceholder(),
    Object? closed = const $CopyWithPlaceholder(),
    Object? pushedMin = const $CopyWithPlaceholder(),
    Object? mergedMin = const $CopyWithPlaceholder(),
  }) {
    return DeliveryDay(
      date: date == const $CopyWithPlaceholder()
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as DateTime,
      merged: merged == const $CopyWithPlaceholder()
          ? _value.merged
          // ignore: cast_nullable_to_non_nullable
          : merged as int,
      closed: closed == const $CopyWithPlaceholder()
          ? _value.closed
          // ignore: cast_nullable_to_non_nullable
          : closed as int,
      pushedMin: pushedMin == const $CopyWithPlaceholder()
          ? _value.pushedMin
          // ignore: cast_nullable_to_non_nullable
          : pushedMin as num?,
      mergedMin: mergedMin == const $CopyWithPlaceholder()
          ? _value.mergedMin
          // ignore: cast_nullable_to_non_nullable
          : mergedMin as num?,
    );
  }
}

extension $DeliveryDayCopyWith on DeliveryDay {
  /// Returns a callable class that can be used as follows: `instanceOfDeliveryDay.copyWith(...)` or like so:`instanceOfDeliveryDay.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DeliveryDayCWProxy get copyWith => _$DeliveryDayCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryDay _$DeliveryDayFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DeliveryDay', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['date', 'merged', 'closed']);
      final val = DeliveryDay(
        date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
        merged: $checkedConvert('merged', (v) => (v as num).toInt()),
        closed: $checkedConvert('closed', (v) => (v as num).toInt()),
        pushedMin: $checkedConvert('pushedMin', (v) => v as num?),
        mergedMin: $checkedConvert('mergedMin', (v) => v as num?),
      );
      return val;
    });

Map<String, dynamic> _$DeliveryDayToJson(DeliveryDay instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'merged': instance.merged,
      'closed': instance.closed,
      'pushedMin': ?instance.pushedMin,
      'mergedMin': ?instance.mergedMin,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_delivery.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AnalyticsDeliveryCWProxy {
  AnalyticsDelivery days(int days);

  AnalyticsDelivery current(DeliveryPeriod current);

  AnalyticsDelivery previous(DeliveryPeriod previous);

  AnalyticsDelivery perDay(List<DeliveryDay> perDay);

  AnalyticsDelivery slowest(List<SlowTicket> slowest);

  AnalyticsDelivery stale(List<StalePR> stale);

  AnalyticsDelivery unanswered(int unanswered);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnalyticsDelivery(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnalyticsDelivery(...).copyWith(id: 12, name: "My name")
  /// ````
  AnalyticsDelivery call({
    int days,
    DeliveryPeriod current,
    DeliveryPeriod previous,
    List<DeliveryDay> perDay,
    List<SlowTicket> slowest,
    List<StalePR> stale,
    int unanswered,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAnalyticsDelivery.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAnalyticsDelivery.copyWith.fieldName(...)`
class _$AnalyticsDeliveryCWProxyImpl implements _$AnalyticsDeliveryCWProxy {
  const _$AnalyticsDeliveryCWProxyImpl(this._value);

  final AnalyticsDelivery _value;

  @override
  AnalyticsDelivery days(int days) => this(days: days);

  @override
  AnalyticsDelivery current(DeliveryPeriod current) => this(current: current);

  @override
  AnalyticsDelivery previous(DeliveryPeriod previous) =>
      this(previous: previous);

  @override
  AnalyticsDelivery perDay(List<DeliveryDay> perDay) => this(perDay: perDay);

  @override
  AnalyticsDelivery slowest(List<SlowTicket> slowest) => this(slowest: slowest);

  @override
  AnalyticsDelivery stale(List<StalePR> stale) => this(stale: stale);

  @override
  AnalyticsDelivery unanswered(int unanswered) => this(unanswered: unanswered);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnalyticsDelivery(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnalyticsDelivery(...).copyWith(id: 12, name: "My name")
  /// ````
  AnalyticsDelivery call({
    Object? days = const $CopyWithPlaceholder(),
    Object? current = const $CopyWithPlaceholder(),
    Object? previous = const $CopyWithPlaceholder(),
    Object? perDay = const $CopyWithPlaceholder(),
    Object? slowest = const $CopyWithPlaceholder(),
    Object? stale = const $CopyWithPlaceholder(),
    Object? unanswered = const $CopyWithPlaceholder(),
  }) {
    return AnalyticsDelivery(
      days: days == const $CopyWithPlaceholder()
          ? _value.days
          // ignore: cast_nullable_to_non_nullable
          : days as int,
      current: current == const $CopyWithPlaceholder()
          ? _value.current
          // ignore: cast_nullable_to_non_nullable
          : current as DeliveryPeriod,
      previous: previous == const $CopyWithPlaceholder()
          ? _value.previous
          // ignore: cast_nullable_to_non_nullable
          : previous as DeliveryPeriod,
      perDay: perDay == const $CopyWithPlaceholder()
          ? _value.perDay
          // ignore: cast_nullable_to_non_nullable
          : perDay as List<DeliveryDay>,
      slowest: slowest == const $CopyWithPlaceholder()
          ? _value.slowest
          // ignore: cast_nullable_to_non_nullable
          : slowest as List<SlowTicket>,
      stale: stale == const $CopyWithPlaceholder()
          ? _value.stale
          // ignore: cast_nullable_to_non_nullable
          : stale as List<StalePR>,
      unanswered: unanswered == const $CopyWithPlaceholder()
          ? _value.unanswered
          // ignore: cast_nullable_to_non_nullable
          : unanswered as int,
    );
  }
}

extension $AnalyticsDeliveryCopyWith on AnalyticsDelivery {
  /// Returns a callable class that can be used as follows: `instanceOfAnalyticsDelivery.copyWith(...)` or like so:`instanceOfAnalyticsDelivery.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AnalyticsDeliveryCWProxy get copyWith =>
      _$AnalyticsDeliveryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsDelivery _$AnalyticsDeliveryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AnalyticsDelivery', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'days',
          'current',
          'previous',
          'perDay',
          'slowest',
          'stale',
          'unanswered',
        ],
      );
      final val = AnalyticsDelivery(
        days: $checkedConvert('days', (v) => (v as num).toInt()),
        current: $checkedConvert(
          'current',
          (v) => DeliveryPeriod.fromJson(v as Map<String, dynamic>),
        ),
        previous: $checkedConvert(
          'previous',
          (v) => DeliveryPeriod.fromJson(v as Map<String, dynamic>),
        ),
        perDay: $checkedConvert(
          'perDay',
          (v) => (v as List<dynamic>)
              .map((e) => DeliveryDay.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        slowest: $checkedConvert(
          'slowest',
          (v) => (v as List<dynamic>)
              .map((e) => SlowTicket.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        stale: $checkedConvert(
          'stale',
          (v) => (v as List<dynamic>)
              .map((e) => StalePR.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        unanswered: $checkedConvert('unanswered', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$AnalyticsDeliveryToJson(AnalyticsDelivery instance) =>
    <String, dynamic>{
      'days': instance.days,
      'current': instance.current.toJson(),
      'previous': instance.previous.toJson(),
      'perDay': instance.perDay.map((e) => e.toJson()).toList(),
      'slowest': instance.slowest.map((e) => e.toJson()).toList(),
      'stale': instance.stale.map((e) => e.toJson()).toList(),
      'unanswered': instance.unanswered,
    };

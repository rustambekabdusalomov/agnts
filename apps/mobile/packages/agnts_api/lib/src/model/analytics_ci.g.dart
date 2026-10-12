// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_ci.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AnalyticsCICWProxy {
  AnalyticsCI days(int days);

  AnalyticsCI watching(bool watching);

  AnalyticsCI current(CIPeriod current);

  AnalyticsCI previous(CIPeriod previous);

  AnalyticsCI byClass(Map<String, int> byClass);

  AnalyticsCI perDay(List<CIDay> perDay);

  AnalyticsCI flakiest(List<FlakyJob> flakiest);

  AnalyticsCI open(int open);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnalyticsCI(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnalyticsCI(...).copyWith(id: 12, name: "My name")
  /// ````
  AnalyticsCI call({
    int days,
    bool watching,
    CIPeriod current,
    CIPeriod previous,
    Map<String, int> byClass,
    List<CIDay> perDay,
    List<FlakyJob> flakiest,
    int open,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAnalyticsCI.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAnalyticsCI.copyWith.fieldName(...)`
class _$AnalyticsCICWProxyImpl implements _$AnalyticsCICWProxy {
  const _$AnalyticsCICWProxyImpl(this._value);

  final AnalyticsCI _value;

  @override
  AnalyticsCI days(int days) => this(days: days);

  @override
  AnalyticsCI watching(bool watching) => this(watching: watching);

  @override
  AnalyticsCI current(CIPeriod current) => this(current: current);

  @override
  AnalyticsCI previous(CIPeriod previous) => this(previous: previous);

  @override
  AnalyticsCI byClass(Map<String, int> byClass) => this(byClass: byClass);

  @override
  AnalyticsCI perDay(List<CIDay> perDay) => this(perDay: perDay);

  @override
  AnalyticsCI flakiest(List<FlakyJob> flakiest) => this(flakiest: flakiest);

  @override
  AnalyticsCI open(int open) => this(open: open);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnalyticsCI(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnalyticsCI(...).copyWith(id: 12, name: "My name")
  /// ````
  AnalyticsCI call({
    Object? days = const $CopyWithPlaceholder(),
    Object? watching = const $CopyWithPlaceholder(),
    Object? current = const $CopyWithPlaceholder(),
    Object? previous = const $CopyWithPlaceholder(),
    Object? byClass = const $CopyWithPlaceholder(),
    Object? perDay = const $CopyWithPlaceholder(),
    Object? flakiest = const $CopyWithPlaceholder(),
    Object? open = const $CopyWithPlaceholder(),
  }) {
    return AnalyticsCI(
      days: days == const $CopyWithPlaceholder()
          ? _value.days
          // ignore: cast_nullable_to_non_nullable
          : days as int,
      watching: watching == const $CopyWithPlaceholder()
          ? _value.watching
          // ignore: cast_nullable_to_non_nullable
          : watching as bool,
      current: current == const $CopyWithPlaceholder()
          ? _value.current
          // ignore: cast_nullable_to_non_nullable
          : current as CIPeriod,
      previous: previous == const $CopyWithPlaceholder()
          ? _value.previous
          // ignore: cast_nullable_to_non_nullable
          : previous as CIPeriod,
      byClass: byClass == const $CopyWithPlaceholder()
          ? _value.byClass
          // ignore: cast_nullable_to_non_nullable
          : byClass as Map<String, int>,
      perDay: perDay == const $CopyWithPlaceholder()
          ? _value.perDay
          // ignore: cast_nullable_to_non_nullable
          : perDay as List<CIDay>,
      flakiest: flakiest == const $CopyWithPlaceholder()
          ? _value.flakiest
          // ignore: cast_nullable_to_non_nullable
          : flakiest as List<FlakyJob>,
      open: open == const $CopyWithPlaceholder()
          ? _value.open
          // ignore: cast_nullable_to_non_nullable
          : open as int,
    );
  }
}

extension $AnalyticsCICopyWith on AnalyticsCI {
  /// Returns a callable class that can be used as follows: `instanceOfAnalyticsCI.copyWith(...)` or like so:`instanceOfAnalyticsCI.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AnalyticsCICWProxy get copyWith => _$AnalyticsCICWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsCI _$AnalyticsCIFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AnalyticsCI', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'days',
          'watching',
          'current',
          'previous',
          'byClass',
          'perDay',
          'flakiest',
          'open',
        ],
      );
      final val = AnalyticsCI(
        days: $checkedConvert('days', (v) => (v as num).toInt()),
        watching: $checkedConvert('watching', (v) => v as bool),
        current: $checkedConvert(
          'current',
          (v) => CIPeriod.fromJson(v as Map<String, dynamic>),
        ),
        previous: $checkedConvert(
          'previous',
          (v) => CIPeriod.fromJson(v as Map<String, dynamic>),
        ),
        byClass: $checkedConvert(
          'byClass',
          (v) => Map<String, int>.from(v as Map),
        ),
        perDay: $checkedConvert(
          'perDay',
          (v) => (v as List<dynamic>)
              .map((e) => CIDay.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        flakiest: $checkedConvert(
          'flakiest',
          (v) => (v as List<dynamic>)
              .map((e) => FlakyJob.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        open: $checkedConvert('open', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$AnalyticsCIToJson(AnalyticsCI instance) =>
    <String, dynamic>{
      'days': instance.days,
      'watching': instance.watching,
      'current': instance.current.toJson(),
      'previous': instance.previous.toJson(),
      'byClass': instance.byClass,
      'perDay': instance.perDay.map((e) => e.toJson()).toList(),
      'flakiest': instance.flakiest.map((e) => e.toJson()).toList(),
      'open': instance.open,
    };

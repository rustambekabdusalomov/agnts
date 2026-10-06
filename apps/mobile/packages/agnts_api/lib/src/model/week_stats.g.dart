// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'week_stats.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeekStatsCWProxy {
  WeekStats picked(int picked);

  WeekStats pushed(int pushed);

  WeekStats firstTryPct(int firstTryPct);

  WeekStats avgTurns(int avgTurns);

  WeekStats avgWaitMin(int avgWaitMin);

  WeekStats stopped(int stopped);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeekStats(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeekStats(...).copyWith(id: 12, name: "My name")
  /// ````
  WeekStats call({
    int picked,
    int pushed,
    int firstTryPct,
    int avgTurns,
    int avgWaitMin,
    int stopped,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeekStats.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeekStats.copyWith.fieldName(...)`
class _$WeekStatsCWProxyImpl implements _$WeekStatsCWProxy {
  const _$WeekStatsCWProxyImpl(this._value);

  final WeekStats _value;

  @override
  WeekStats picked(int picked) => this(picked: picked);

  @override
  WeekStats pushed(int pushed) => this(pushed: pushed);

  @override
  WeekStats firstTryPct(int firstTryPct) => this(firstTryPct: firstTryPct);

  @override
  WeekStats avgTurns(int avgTurns) => this(avgTurns: avgTurns);

  @override
  WeekStats avgWaitMin(int avgWaitMin) => this(avgWaitMin: avgWaitMin);

  @override
  WeekStats stopped(int stopped) => this(stopped: stopped);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeekStats(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeekStats(...).copyWith(id: 12, name: "My name")
  /// ````
  WeekStats call({
    Object? picked = const $CopyWithPlaceholder(),
    Object? pushed = const $CopyWithPlaceholder(),
    Object? firstTryPct = const $CopyWithPlaceholder(),
    Object? avgTurns = const $CopyWithPlaceholder(),
    Object? avgWaitMin = const $CopyWithPlaceholder(),
    Object? stopped = const $CopyWithPlaceholder(),
  }) {
    return WeekStats(
      picked: picked == const $CopyWithPlaceholder()
          ? _value.picked
          // ignore: cast_nullable_to_non_nullable
          : picked as int,
      pushed: pushed == const $CopyWithPlaceholder()
          ? _value.pushed
          // ignore: cast_nullable_to_non_nullable
          : pushed as int,
      firstTryPct: firstTryPct == const $CopyWithPlaceholder()
          ? _value.firstTryPct
          // ignore: cast_nullable_to_non_nullable
          : firstTryPct as int,
      avgTurns: avgTurns == const $CopyWithPlaceholder()
          ? _value.avgTurns
          // ignore: cast_nullable_to_non_nullable
          : avgTurns as int,
      avgWaitMin: avgWaitMin == const $CopyWithPlaceholder()
          ? _value.avgWaitMin
          // ignore: cast_nullable_to_non_nullable
          : avgWaitMin as int,
      stopped: stopped == const $CopyWithPlaceholder()
          ? _value.stopped
          // ignore: cast_nullable_to_non_nullable
          : stopped as int,
    );
  }
}

extension $WeekStatsCopyWith on WeekStats {
  /// Returns a callable class that can be used as follows: `instanceOfWeekStats.copyWith(...)` or like so:`instanceOfWeekStats.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeekStatsCWProxy get copyWith => _$WeekStatsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeekStats _$WeekStatsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WeekStats', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'picked',
          'pushed',
          'firstTryPct',
          'avgTurns',
          'avgWaitMin',
          'stopped',
        ],
      );
      final val = WeekStats(
        picked: $checkedConvert('picked', (v) => (v as num).toInt()),
        pushed: $checkedConvert('pushed', (v) => (v as num).toInt()),
        firstTryPct: $checkedConvert('firstTryPct', (v) => (v as num).toInt()),
        avgTurns: $checkedConvert('avgTurns', (v) => (v as num).toInt()),
        avgWaitMin: $checkedConvert('avgWaitMin', (v) => (v as num).toInt()),
        stopped: $checkedConvert('stopped', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$WeekStatsToJson(WeekStats instance) => <String, dynamic>{
  'picked': instance.picked,
  'pushed': instance.pushed,
  'firstTryPct': instance.firstTryPct,
  'avgTurns': instance.avgTurns,
  'avgWaitMin': instance.avgWaitMin,
  'stopped': instance.stopped,
};

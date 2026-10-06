// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_stat.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DayStatCWProxy {
  DayStat date(DateTime date);

  DayStat picked(int picked);

  DayStat pushed(int pushed);

  DayStat rejected(int rejected);

  DayStat stopped(int stopped);

  DayStat agntsMin(num agntsMin);

  DayStat waitMin(num waitMin);

  DayStat turns(num turns);

  DayStat peakUsage(num? peakUsage);

  DayStat spend(TokenSpend spend);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DayStat(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DayStat(...).copyWith(id: 12, name: "My name")
  /// ````
  DayStat call({
    DateTime date,
    int picked,
    int pushed,
    int rejected,
    int stopped,
    num agntsMin,
    num waitMin,
    num turns,
    num? peakUsage,
    TokenSpend spend,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDayStat.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDayStat.copyWith.fieldName(...)`
class _$DayStatCWProxyImpl implements _$DayStatCWProxy {
  const _$DayStatCWProxyImpl(this._value);

  final DayStat _value;

  @override
  DayStat date(DateTime date) => this(date: date);

  @override
  DayStat picked(int picked) => this(picked: picked);

  @override
  DayStat pushed(int pushed) => this(pushed: pushed);

  @override
  DayStat rejected(int rejected) => this(rejected: rejected);

  @override
  DayStat stopped(int stopped) => this(stopped: stopped);

  @override
  DayStat agntsMin(num agntsMin) => this(agntsMin: agntsMin);

  @override
  DayStat waitMin(num waitMin) => this(waitMin: waitMin);

  @override
  DayStat turns(num turns) => this(turns: turns);

  @override
  DayStat peakUsage(num? peakUsage) => this(peakUsage: peakUsage);

  @override
  DayStat spend(TokenSpend spend) => this(spend: spend);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DayStat(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DayStat(...).copyWith(id: 12, name: "My name")
  /// ````
  DayStat call({
    Object? date = const $CopyWithPlaceholder(),
    Object? picked = const $CopyWithPlaceholder(),
    Object? pushed = const $CopyWithPlaceholder(),
    Object? rejected = const $CopyWithPlaceholder(),
    Object? stopped = const $CopyWithPlaceholder(),
    Object? agntsMin = const $CopyWithPlaceholder(),
    Object? waitMin = const $CopyWithPlaceholder(),
    Object? turns = const $CopyWithPlaceholder(),
    Object? peakUsage = const $CopyWithPlaceholder(),
    Object? spend = const $CopyWithPlaceholder(),
  }) {
    return DayStat(
      date: date == const $CopyWithPlaceholder()
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as DateTime,
      picked: picked == const $CopyWithPlaceholder()
          ? _value.picked
          // ignore: cast_nullable_to_non_nullable
          : picked as int,
      pushed: pushed == const $CopyWithPlaceholder()
          ? _value.pushed
          // ignore: cast_nullable_to_non_nullable
          : pushed as int,
      rejected: rejected == const $CopyWithPlaceholder()
          ? _value.rejected
          // ignore: cast_nullable_to_non_nullable
          : rejected as int,
      stopped: stopped == const $CopyWithPlaceholder()
          ? _value.stopped
          // ignore: cast_nullable_to_non_nullable
          : stopped as int,
      agntsMin: agntsMin == const $CopyWithPlaceholder()
          ? _value.agntsMin
          // ignore: cast_nullable_to_non_nullable
          : agntsMin as num,
      waitMin: waitMin == const $CopyWithPlaceholder()
          ? _value.waitMin
          // ignore: cast_nullable_to_non_nullable
          : waitMin as num,
      turns: turns == const $CopyWithPlaceholder()
          ? _value.turns
          // ignore: cast_nullable_to_non_nullable
          : turns as num,
      peakUsage: peakUsage == const $CopyWithPlaceholder()
          ? _value.peakUsage
          // ignore: cast_nullable_to_non_nullable
          : peakUsage as num?,
      spend: spend == const $CopyWithPlaceholder()
          ? _value.spend
          // ignore: cast_nullable_to_non_nullable
          : spend as TokenSpend,
    );
  }
}

extension $DayStatCopyWith on DayStat {
  /// Returns a callable class that can be used as follows: `instanceOfDayStat.copyWith(...)` or like so:`instanceOfDayStat.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DayStatCWProxy get copyWith => _$DayStatCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DayStat _$DayStatFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DayStat', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'date',
          'picked',
          'pushed',
          'rejected',
          'stopped',
          'agntsMin',
          'waitMin',
          'turns',
          'spend',
        ],
      );
      final val = DayStat(
        date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
        picked: $checkedConvert('picked', (v) => (v as num).toInt()),
        pushed: $checkedConvert('pushed', (v) => (v as num).toInt()),
        rejected: $checkedConvert('rejected', (v) => (v as num).toInt()),
        stopped: $checkedConvert('stopped', (v) => (v as num).toInt()),
        agntsMin: $checkedConvert('agntsMin', (v) => v as num),
        waitMin: $checkedConvert('waitMin', (v) => v as num),
        turns: $checkedConvert('turns', (v) => v as num),
        peakUsage: $checkedConvert('peakUsage', (v) => v as num?),
        spend: $checkedConvert(
          'spend',
          (v) => TokenSpend.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$DayStatToJson(DayStat instance) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'picked': instance.picked,
  'pushed': instance.pushed,
  'rejected': instance.rejected,
  'stopped': instance.stopped,
  'agntsMin': instance.agntsMin,
  'waitMin': instance.waitMin,
  'turns': instance.turns,
  'peakUsage': ?instance.peakUsage,
  'spend': instance.spend.toJson(),
};

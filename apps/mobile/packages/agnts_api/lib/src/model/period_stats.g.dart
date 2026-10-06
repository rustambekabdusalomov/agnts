// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'period_stats.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PeriodStatsCWProxy {
  PeriodStats picked(int picked);

  PeriodStats pushed(int pushed);

  PeriodStats rejected(int rejected);

  PeriodStats stopped(int stopped);

  PeriodStats firstTry(int firstTry);

  PeriodStats afterChanges(int afterChanges);

  PeriodStats agntsMin(num agntsMin);

  PeriodStats waitMin(num waitMin);

  PeriodStats reviewMin(num reviewMin);

  PeriodStats answerMin(num answerMin);

  PeriodStats turns(num turns);

  PeriodStats spend(TokenSpend spend);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PeriodStats(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PeriodStats(...).copyWith(id: 12, name: "My name")
  /// ````
  PeriodStats call({
    int picked,
    int pushed,
    int rejected,
    int stopped,
    int firstTry,
    int afterChanges,
    num agntsMin,
    num waitMin,
    num reviewMin,
    num answerMin,
    num turns,
    TokenSpend spend,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPeriodStats.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPeriodStats.copyWith.fieldName(...)`
class _$PeriodStatsCWProxyImpl implements _$PeriodStatsCWProxy {
  const _$PeriodStatsCWProxyImpl(this._value);

  final PeriodStats _value;

  @override
  PeriodStats picked(int picked) => this(picked: picked);

  @override
  PeriodStats pushed(int pushed) => this(pushed: pushed);

  @override
  PeriodStats rejected(int rejected) => this(rejected: rejected);

  @override
  PeriodStats stopped(int stopped) => this(stopped: stopped);

  @override
  PeriodStats firstTry(int firstTry) => this(firstTry: firstTry);

  @override
  PeriodStats afterChanges(int afterChanges) =>
      this(afterChanges: afterChanges);

  @override
  PeriodStats agntsMin(num agntsMin) => this(agntsMin: agntsMin);

  @override
  PeriodStats waitMin(num waitMin) => this(waitMin: waitMin);

  @override
  PeriodStats reviewMin(num reviewMin) => this(reviewMin: reviewMin);

  @override
  PeriodStats answerMin(num answerMin) => this(answerMin: answerMin);

  @override
  PeriodStats turns(num turns) => this(turns: turns);

  @override
  PeriodStats spend(TokenSpend spend) => this(spend: spend);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PeriodStats(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PeriodStats(...).copyWith(id: 12, name: "My name")
  /// ````
  PeriodStats call({
    Object? picked = const $CopyWithPlaceholder(),
    Object? pushed = const $CopyWithPlaceholder(),
    Object? rejected = const $CopyWithPlaceholder(),
    Object? stopped = const $CopyWithPlaceholder(),
    Object? firstTry = const $CopyWithPlaceholder(),
    Object? afterChanges = const $CopyWithPlaceholder(),
    Object? agntsMin = const $CopyWithPlaceholder(),
    Object? waitMin = const $CopyWithPlaceholder(),
    Object? reviewMin = const $CopyWithPlaceholder(),
    Object? answerMin = const $CopyWithPlaceholder(),
    Object? turns = const $CopyWithPlaceholder(),
    Object? spend = const $CopyWithPlaceholder(),
  }) {
    return PeriodStats(
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
      firstTry: firstTry == const $CopyWithPlaceholder()
          ? _value.firstTry
          // ignore: cast_nullable_to_non_nullable
          : firstTry as int,
      afterChanges: afterChanges == const $CopyWithPlaceholder()
          ? _value.afterChanges
          // ignore: cast_nullable_to_non_nullable
          : afterChanges as int,
      agntsMin: agntsMin == const $CopyWithPlaceholder()
          ? _value.agntsMin
          // ignore: cast_nullable_to_non_nullable
          : agntsMin as num,
      waitMin: waitMin == const $CopyWithPlaceholder()
          ? _value.waitMin
          // ignore: cast_nullable_to_non_nullable
          : waitMin as num,
      reviewMin: reviewMin == const $CopyWithPlaceholder()
          ? _value.reviewMin
          // ignore: cast_nullable_to_non_nullable
          : reviewMin as num,
      answerMin: answerMin == const $CopyWithPlaceholder()
          ? _value.answerMin
          // ignore: cast_nullable_to_non_nullable
          : answerMin as num,
      turns: turns == const $CopyWithPlaceholder()
          ? _value.turns
          // ignore: cast_nullable_to_non_nullable
          : turns as num,
      spend: spend == const $CopyWithPlaceholder()
          ? _value.spend
          // ignore: cast_nullable_to_non_nullable
          : spend as TokenSpend,
    );
  }
}

extension $PeriodStatsCopyWith on PeriodStats {
  /// Returns a callable class that can be used as follows: `instanceOfPeriodStats.copyWith(...)` or like so:`instanceOfPeriodStats.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PeriodStatsCWProxy get copyWith => _$PeriodStatsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PeriodStats _$PeriodStatsFromJson(Map<String, dynamic> json) => $checkedCreate(
  'PeriodStats',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'picked',
        'pushed',
        'rejected',
        'stopped',
        'firstTry',
        'afterChanges',
        'agntsMin',
        'waitMin',
        'reviewMin',
        'answerMin',
        'turns',
        'spend',
      ],
    );
    final val = PeriodStats(
      picked: $checkedConvert('picked', (v) => (v as num).toInt()),
      pushed: $checkedConvert('pushed', (v) => (v as num).toInt()),
      rejected: $checkedConvert('rejected', (v) => (v as num).toInt()),
      stopped: $checkedConvert('stopped', (v) => (v as num).toInt()),
      firstTry: $checkedConvert('firstTry', (v) => (v as num).toInt()),
      afterChanges: $checkedConvert('afterChanges', (v) => (v as num).toInt()),
      agntsMin: $checkedConvert('agntsMin', (v) => v as num),
      waitMin: $checkedConvert('waitMin', (v) => v as num),
      reviewMin: $checkedConvert('reviewMin', (v) => v as num),
      answerMin: $checkedConvert('answerMin', (v) => v as num),
      turns: $checkedConvert('turns', (v) => v as num),
      spend: $checkedConvert(
        'spend',
        (v) => TokenSpend.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
);

Map<String, dynamic> _$PeriodStatsToJson(PeriodStats instance) =>
    <String, dynamic>{
      'picked': instance.picked,
      'pushed': instance.pushed,
      'rejected': instance.rejected,
      'stopped': instance.stopped,
      'firstTry': instance.firstTry,
      'afterChanges': instance.afterChanges,
      'agntsMin': instance.agntsMin,
      'waitMin': instance.waitMin,
      'reviewMin': instance.reviewMin,
      'answerMin': instance.answerMin,
      'turns': instance.turns,
      'spend': instance.spend.toJson(),
    };

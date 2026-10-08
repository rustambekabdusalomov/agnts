// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quality_stat.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$QualityStatCWProxy {
  QualityStat promptVersion(String promptVersion);

  QualityStat tickets(int tickets);

  QualityStat reachedReview(int reachedReview);

  QualityStat done(int done);

  QualityStat firstTry(int firstTry);

  QualityStat rejected(int rejected);

  QualityStat changeRounds(num changeRounds);

  QualityStat fixAttempts(num fixAttempts);

  QualityStat serious(int serious);

  QualityStat footprintHit(num? footprintHit);

  QualityStat redFlags(int redFlags);

  QualityStat selfFixes(int selfFixes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `QualityStat(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// QualityStat(...).copyWith(id: 12, name: "My name")
  /// ````
  QualityStat call({
    String promptVersion,
    int tickets,
    int reachedReview,
    int done,
    int firstTry,
    int rejected,
    num changeRounds,
    num fixAttempts,
    int serious,
    num? footprintHit,
    int redFlags,
    int selfFixes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfQualityStat.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfQualityStat.copyWith.fieldName(...)`
class _$QualityStatCWProxyImpl implements _$QualityStatCWProxy {
  const _$QualityStatCWProxyImpl(this._value);

  final QualityStat _value;

  @override
  QualityStat promptVersion(String promptVersion) =>
      this(promptVersion: promptVersion);

  @override
  QualityStat tickets(int tickets) => this(tickets: tickets);

  @override
  QualityStat reachedReview(int reachedReview) =>
      this(reachedReview: reachedReview);

  @override
  QualityStat done(int done) => this(done: done);

  @override
  QualityStat firstTry(int firstTry) => this(firstTry: firstTry);

  @override
  QualityStat rejected(int rejected) => this(rejected: rejected);

  @override
  QualityStat changeRounds(num changeRounds) =>
      this(changeRounds: changeRounds);

  @override
  QualityStat fixAttempts(num fixAttempts) => this(fixAttempts: fixAttempts);

  @override
  QualityStat serious(int serious) => this(serious: serious);

  @override
  QualityStat footprintHit(num? footprintHit) =>
      this(footprintHit: footprintHit);

  @override
  QualityStat redFlags(int redFlags) => this(redFlags: redFlags);

  @override
  QualityStat selfFixes(int selfFixes) => this(selfFixes: selfFixes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `QualityStat(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// QualityStat(...).copyWith(id: 12, name: "My name")
  /// ````
  QualityStat call({
    Object? promptVersion = const $CopyWithPlaceholder(),
    Object? tickets = const $CopyWithPlaceholder(),
    Object? reachedReview = const $CopyWithPlaceholder(),
    Object? done = const $CopyWithPlaceholder(),
    Object? firstTry = const $CopyWithPlaceholder(),
    Object? rejected = const $CopyWithPlaceholder(),
    Object? changeRounds = const $CopyWithPlaceholder(),
    Object? fixAttempts = const $CopyWithPlaceholder(),
    Object? serious = const $CopyWithPlaceholder(),
    Object? footprintHit = const $CopyWithPlaceholder(),
    Object? redFlags = const $CopyWithPlaceholder(),
    Object? selfFixes = const $CopyWithPlaceholder(),
  }) {
    return QualityStat(
      promptVersion: promptVersion == const $CopyWithPlaceholder()
          ? _value.promptVersion
          // ignore: cast_nullable_to_non_nullable
          : promptVersion as String,
      tickets: tickets == const $CopyWithPlaceholder()
          ? _value.tickets
          // ignore: cast_nullable_to_non_nullable
          : tickets as int,
      reachedReview: reachedReview == const $CopyWithPlaceholder()
          ? _value.reachedReview
          // ignore: cast_nullable_to_non_nullable
          : reachedReview as int,
      done: done == const $CopyWithPlaceholder()
          ? _value.done
          // ignore: cast_nullable_to_non_nullable
          : done as int,
      firstTry: firstTry == const $CopyWithPlaceholder()
          ? _value.firstTry
          // ignore: cast_nullable_to_non_nullable
          : firstTry as int,
      rejected: rejected == const $CopyWithPlaceholder()
          ? _value.rejected
          // ignore: cast_nullable_to_non_nullable
          : rejected as int,
      changeRounds: changeRounds == const $CopyWithPlaceholder()
          ? _value.changeRounds
          // ignore: cast_nullable_to_non_nullable
          : changeRounds as num,
      fixAttempts: fixAttempts == const $CopyWithPlaceholder()
          ? _value.fixAttempts
          // ignore: cast_nullable_to_non_nullable
          : fixAttempts as num,
      serious: serious == const $CopyWithPlaceholder()
          ? _value.serious
          // ignore: cast_nullable_to_non_nullable
          : serious as int,
      footprintHit: footprintHit == const $CopyWithPlaceholder()
          ? _value.footprintHit
          // ignore: cast_nullable_to_non_nullable
          : footprintHit as num?,
      redFlags: redFlags == const $CopyWithPlaceholder()
          ? _value.redFlags
          // ignore: cast_nullable_to_non_nullable
          : redFlags as int,
      selfFixes: selfFixes == const $CopyWithPlaceholder()
          ? _value.selfFixes
          // ignore: cast_nullable_to_non_nullable
          : selfFixes as int,
    );
  }
}

extension $QualityStatCopyWith on QualityStat {
  /// Returns a callable class that can be used as follows: `instanceOfQualityStat.copyWith(...)` or like so:`instanceOfQualityStat.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$QualityStatCWProxy get copyWith => _$QualityStatCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QualityStat _$QualityStatFromJson(Map<String, dynamic> json) =>
    $checkedCreate('QualityStat', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'promptVersion',
          'tickets',
          'reachedReview',
          'done',
          'firstTry',
          'rejected',
          'changeRounds',
          'fixAttempts',
          'serious',
          'redFlags',
          'selfFixes',
        ],
      );
      final val = QualityStat(
        promptVersion: $checkedConvert('promptVersion', (v) => v as String),
        tickets: $checkedConvert('tickets', (v) => (v as num).toInt()),
        reachedReview: $checkedConvert(
          'reachedReview',
          (v) => (v as num).toInt(),
        ),
        done: $checkedConvert('done', (v) => (v as num).toInt()),
        firstTry: $checkedConvert('firstTry', (v) => (v as num).toInt()),
        rejected: $checkedConvert('rejected', (v) => (v as num).toInt()),
        changeRounds: $checkedConvert('changeRounds', (v) => v as num),
        fixAttempts: $checkedConvert('fixAttempts', (v) => v as num),
        serious: $checkedConvert('serious', (v) => (v as num).toInt()),
        footprintHit: $checkedConvert('footprintHit', (v) => v as num?),
        redFlags: $checkedConvert('redFlags', (v) => (v as num).toInt()),
        selfFixes: $checkedConvert('selfFixes', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$QualityStatToJson(QualityStat instance) =>
    <String, dynamic>{
      'promptVersion': instance.promptVersion,
      'tickets': instance.tickets,
      'reachedReview': instance.reachedReview,
      'done': instance.done,
      'firstTry': instance.firstTry,
      'rejected': instance.rejected,
      'changeRounds': instance.changeRounds,
      'fixAttempts': instance.fixAttempts,
      'serious': instance.serious,
      'footprintHit': ?instance.footprintHit,
      'redFlags': instance.redFlags,
      'selfFixes': instance.selfFixes,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill_stat.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SkillStatCWProxy {
  SkillStat skill(String skill);

  SkillStat tickets(int tickets);

  SkillStat loaded(int loaded);

  SkillStat done(int done);

  SkillStat firstTry(int firstTry);

  SkillStat loadedDone(int loadedDone);

  SkillStat loadedFirstTry(int loadedFirstTry);

  SkillStat findings(int findings);

  SkillStat tokens(num tokens);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SkillStat(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SkillStat(...).copyWith(id: 12, name: "My name")
  /// ````
  SkillStat call({
    String skill,
    int tickets,
    int loaded,
    int done,
    int firstTry,
    int loadedDone,
    int loadedFirstTry,
    int findings,
    num tokens,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSkillStat.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSkillStat.copyWith.fieldName(...)`
class _$SkillStatCWProxyImpl implements _$SkillStatCWProxy {
  const _$SkillStatCWProxyImpl(this._value);

  final SkillStat _value;

  @override
  SkillStat skill(String skill) => this(skill: skill);

  @override
  SkillStat tickets(int tickets) => this(tickets: tickets);

  @override
  SkillStat loaded(int loaded) => this(loaded: loaded);

  @override
  SkillStat done(int done) => this(done: done);

  @override
  SkillStat firstTry(int firstTry) => this(firstTry: firstTry);

  @override
  SkillStat loadedDone(int loadedDone) => this(loadedDone: loadedDone);

  @override
  SkillStat loadedFirstTry(int loadedFirstTry) =>
      this(loadedFirstTry: loadedFirstTry);

  @override
  SkillStat findings(int findings) => this(findings: findings);

  @override
  SkillStat tokens(num tokens) => this(tokens: tokens);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SkillStat(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SkillStat(...).copyWith(id: 12, name: "My name")
  /// ````
  SkillStat call({
    Object? skill = const $CopyWithPlaceholder(),
    Object? tickets = const $CopyWithPlaceholder(),
    Object? loaded = const $CopyWithPlaceholder(),
    Object? done = const $CopyWithPlaceholder(),
    Object? firstTry = const $CopyWithPlaceholder(),
    Object? loadedDone = const $CopyWithPlaceholder(),
    Object? loadedFirstTry = const $CopyWithPlaceholder(),
    Object? findings = const $CopyWithPlaceholder(),
    Object? tokens = const $CopyWithPlaceholder(),
  }) {
    return SkillStat(
      skill: skill == const $CopyWithPlaceholder()
          ? _value.skill
          // ignore: cast_nullable_to_non_nullable
          : skill as String,
      tickets: tickets == const $CopyWithPlaceholder()
          ? _value.tickets
          // ignore: cast_nullable_to_non_nullable
          : tickets as int,
      loaded: loaded == const $CopyWithPlaceholder()
          ? _value.loaded
          // ignore: cast_nullable_to_non_nullable
          : loaded as int,
      done: done == const $CopyWithPlaceholder()
          ? _value.done
          // ignore: cast_nullable_to_non_nullable
          : done as int,
      firstTry: firstTry == const $CopyWithPlaceholder()
          ? _value.firstTry
          // ignore: cast_nullable_to_non_nullable
          : firstTry as int,
      loadedDone: loadedDone == const $CopyWithPlaceholder()
          ? _value.loadedDone
          // ignore: cast_nullable_to_non_nullable
          : loadedDone as int,
      loadedFirstTry: loadedFirstTry == const $CopyWithPlaceholder()
          ? _value.loadedFirstTry
          // ignore: cast_nullable_to_non_nullable
          : loadedFirstTry as int,
      findings: findings == const $CopyWithPlaceholder()
          ? _value.findings
          // ignore: cast_nullable_to_non_nullable
          : findings as int,
      tokens: tokens == const $CopyWithPlaceholder()
          ? _value.tokens
          // ignore: cast_nullable_to_non_nullable
          : tokens as num,
    );
  }
}

extension $SkillStatCopyWith on SkillStat {
  /// Returns a callable class that can be used as follows: `instanceOfSkillStat.copyWith(...)` or like so:`instanceOfSkillStat.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SkillStatCWProxy get copyWith => _$SkillStatCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SkillStat _$SkillStatFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SkillStat', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'skill',
          'tickets',
          'loaded',
          'done',
          'firstTry',
          'loadedDone',
          'loadedFirstTry',
          'findings',
          'tokens',
        ],
      );
      final val = SkillStat(
        skill: $checkedConvert('skill', (v) => v as String),
        tickets: $checkedConvert('tickets', (v) => (v as num).toInt()),
        loaded: $checkedConvert('loaded', (v) => (v as num).toInt()),
        done: $checkedConvert('done', (v) => (v as num).toInt()),
        firstTry: $checkedConvert('firstTry', (v) => (v as num).toInt()),
        loadedDone: $checkedConvert('loadedDone', (v) => (v as num).toInt()),
        loadedFirstTry: $checkedConvert(
          'loadedFirstTry',
          (v) => (v as num).toInt(),
        ),
        findings: $checkedConvert('findings', (v) => (v as num).toInt()),
        tokens: $checkedConvert('tokens', (v) => v as num),
      );
      return val;
    });

Map<String, dynamic> _$SkillStatToJson(SkillStat instance) => <String, dynamic>{
  'skill': instance.skill,
  'tickets': instance.tickets,
  'loaded': instance.loaded,
  'done': instance.done,
  'firstTry': instance.firstTry,
  'loadedDone': instance.loadedDone,
  'loadedFirstTry': instance.loadedFirstTry,
  'findings': instance.findings,
  'tokens': instance.tokens,
};

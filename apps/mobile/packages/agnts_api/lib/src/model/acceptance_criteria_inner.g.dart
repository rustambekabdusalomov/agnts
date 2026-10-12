// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acceptance_criteria_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AcceptanceCriteriaInnerCWProxy {
  AcceptanceCriteriaInner id(String id);

  AcceptanceCriteriaInner criterion(String criterion);

  AcceptanceCriteriaInner verdict(AcceptanceCriteriaInnerVerdictEnum verdict);

  AcceptanceCriteriaInner evidence(String? evidence);

  AcceptanceCriteriaInner steps(List<String>? steps);

  AcceptanceCriteriaInner shots(List<String>? shots);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AcceptanceCriteriaInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AcceptanceCriteriaInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AcceptanceCriteriaInner call({
    String id,
    String criterion,
    AcceptanceCriteriaInnerVerdictEnum verdict,
    String? evidence,
    List<String>? steps,
    List<String>? shots,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAcceptanceCriteriaInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAcceptanceCriteriaInner.copyWith.fieldName(...)`
class _$AcceptanceCriteriaInnerCWProxyImpl
    implements _$AcceptanceCriteriaInnerCWProxy {
  const _$AcceptanceCriteriaInnerCWProxyImpl(this._value);

  final AcceptanceCriteriaInner _value;

  @override
  AcceptanceCriteriaInner id(String id) => this(id: id);

  @override
  AcceptanceCriteriaInner criterion(String criterion) =>
      this(criterion: criterion);

  @override
  AcceptanceCriteriaInner verdict(AcceptanceCriteriaInnerVerdictEnum verdict) =>
      this(verdict: verdict);

  @override
  AcceptanceCriteriaInner evidence(String? evidence) =>
      this(evidence: evidence);

  @override
  AcceptanceCriteriaInner steps(List<String>? steps) => this(steps: steps);

  @override
  AcceptanceCriteriaInner shots(List<String>? shots) => this(shots: shots);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AcceptanceCriteriaInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AcceptanceCriteriaInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AcceptanceCriteriaInner call({
    Object? id = const $CopyWithPlaceholder(),
    Object? criterion = const $CopyWithPlaceholder(),
    Object? verdict = const $CopyWithPlaceholder(),
    Object? evidence = const $CopyWithPlaceholder(),
    Object? steps = const $CopyWithPlaceholder(),
    Object? shots = const $CopyWithPlaceholder(),
  }) {
    return AcceptanceCriteriaInner(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      criterion: criterion == const $CopyWithPlaceholder()
          ? _value.criterion
          // ignore: cast_nullable_to_non_nullable
          : criterion as String,
      verdict: verdict == const $CopyWithPlaceholder()
          ? _value.verdict
          // ignore: cast_nullable_to_non_nullable
          : verdict as AcceptanceCriteriaInnerVerdictEnum,
      evidence: evidence == const $CopyWithPlaceholder()
          ? _value.evidence
          // ignore: cast_nullable_to_non_nullable
          : evidence as String?,
      steps: steps == const $CopyWithPlaceholder()
          ? _value.steps
          // ignore: cast_nullable_to_non_nullable
          : steps as List<String>?,
      shots: shots == const $CopyWithPlaceholder()
          ? _value.shots
          // ignore: cast_nullable_to_non_nullable
          : shots as List<String>?,
    );
  }
}

extension $AcceptanceCriteriaInnerCopyWith on AcceptanceCriteriaInner {
  /// Returns a callable class that can be used as follows: `instanceOfAcceptanceCriteriaInner.copyWith(...)` or like so:`instanceOfAcceptanceCriteriaInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AcceptanceCriteriaInnerCWProxy get copyWith =>
      _$AcceptanceCriteriaInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcceptanceCriteriaInner _$AcceptanceCriteriaInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AcceptanceCriteriaInner', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['id', 'criterion', 'verdict']);
  final val = AcceptanceCriteriaInner(
    id: $checkedConvert('id', (v) => v as String),
    criterion: $checkedConvert('criterion', (v) => v as String),
    verdict: $checkedConvert(
      'verdict',
      (v) => $enumDecode(_$AcceptanceCriteriaInnerVerdictEnumEnumMap, v),
    ),
    evidence: $checkedConvert('evidence', (v) => v as String?),
    steps: $checkedConvert(
      'steps',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    shots: $checkedConvert(
      'shots',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$AcceptanceCriteriaInnerToJson(
  AcceptanceCriteriaInner instance,
) => <String, dynamic>{
  'id': instance.id,
  'criterion': instance.criterion,
  'verdict': _$AcceptanceCriteriaInnerVerdictEnumEnumMap[instance.verdict]!,
  'evidence': ?instance.evidence,
  'steps': ?instance.steps,
  'shots': ?instance.shots,
};

const _$AcceptanceCriteriaInnerVerdictEnumEnumMap = {
  AcceptanceCriteriaInnerVerdictEnum.pass: 'pass',
  AcceptanceCriteriaInnerVerdictEnum.fail: 'fail',
  AcceptanceCriteriaInnerVerdictEnum.unknown: 'unknown',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AnalysisCWProxy {
  Analysis summary(String summary);

  Analysis plan(List<String> plan);

  Analysis complexity(AnalysisComplexityEnum? complexity);

  Analysis footprint(Footprint? footprint);

  Analysis approaches(List<Approach>? approaches);

  Analysis outOfScope(List<String>? outOfScope);

  Analysis ship(ShipNotes? ship);

  Analysis defect(bool? defect);

  Analysis acceptance(List<AnalysisAcceptanceInner>? acceptance);

  Analysis patterns(List<Pattern>? patterns);

  Analysis reuse(List<AnalysisReuseInner>? reuse);

  Analysis testPlan(List<AnalysisTestPlanInner>? testPlan);

  Analysis edgeCases(List<String>? edgeCases);

  Analysis repro(AnalysisRepro? repro);

  Analysis secondOpinion(SecondOpinion? secondOpinion);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Analysis(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Analysis(...).copyWith(id: 12, name: "My name")
  /// ````
  Analysis call({
    String summary,
    List<String> plan,
    AnalysisComplexityEnum? complexity,
    Footprint? footprint,
    List<Approach>? approaches,
    List<String>? outOfScope,
    ShipNotes? ship,
    bool? defect,
    List<AnalysisAcceptanceInner>? acceptance,
    List<Pattern>? patterns,
    List<AnalysisReuseInner>? reuse,
    List<AnalysisTestPlanInner>? testPlan,
    List<String>? edgeCases,
    AnalysisRepro? repro,
    SecondOpinion? secondOpinion,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAnalysis.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAnalysis.copyWith.fieldName(...)`
class _$AnalysisCWProxyImpl implements _$AnalysisCWProxy {
  const _$AnalysisCWProxyImpl(this._value);

  final Analysis _value;

  @override
  Analysis summary(String summary) => this(summary: summary);

  @override
  Analysis plan(List<String> plan) => this(plan: plan);

  @override
  Analysis complexity(AnalysisComplexityEnum? complexity) =>
      this(complexity: complexity);

  @override
  Analysis footprint(Footprint? footprint) => this(footprint: footprint);

  @override
  Analysis approaches(List<Approach>? approaches) =>
      this(approaches: approaches);

  @override
  Analysis outOfScope(List<String>? outOfScope) => this(outOfScope: outOfScope);

  @override
  Analysis ship(ShipNotes? ship) => this(ship: ship);

  @override
  Analysis defect(bool? defect) => this(defect: defect);

  @override
  Analysis acceptance(List<AnalysisAcceptanceInner>? acceptance) =>
      this(acceptance: acceptance);

  @override
  Analysis patterns(List<Pattern>? patterns) => this(patterns: patterns);

  @override
  Analysis reuse(List<AnalysisReuseInner>? reuse) => this(reuse: reuse);

  @override
  Analysis testPlan(List<AnalysisTestPlanInner>? testPlan) =>
      this(testPlan: testPlan);

  @override
  Analysis edgeCases(List<String>? edgeCases) => this(edgeCases: edgeCases);

  @override
  Analysis repro(AnalysisRepro? repro) => this(repro: repro);

  @override
  Analysis secondOpinion(SecondOpinion? secondOpinion) =>
      this(secondOpinion: secondOpinion);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Analysis(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Analysis(...).copyWith(id: 12, name: "My name")
  /// ````
  Analysis call({
    Object? summary = const $CopyWithPlaceholder(),
    Object? plan = const $CopyWithPlaceholder(),
    Object? complexity = const $CopyWithPlaceholder(),
    Object? footprint = const $CopyWithPlaceholder(),
    Object? approaches = const $CopyWithPlaceholder(),
    Object? outOfScope = const $CopyWithPlaceholder(),
    Object? ship = const $CopyWithPlaceholder(),
    Object? defect = const $CopyWithPlaceholder(),
    Object? acceptance = const $CopyWithPlaceholder(),
    Object? patterns = const $CopyWithPlaceholder(),
    Object? reuse = const $CopyWithPlaceholder(),
    Object? testPlan = const $CopyWithPlaceholder(),
    Object? edgeCases = const $CopyWithPlaceholder(),
    Object? repro = const $CopyWithPlaceholder(),
    Object? secondOpinion = const $CopyWithPlaceholder(),
  }) {
    return Analysis(
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as String,
      plan: plan == const $CopyWithPlaceholder()
          ? _value.plan
          // ignore: cast_nullable_to_non_nullable
          : plan as List<String>,
      complexity: complexity == const $CopyWithPlaceholder()
          ? _value.complexity
          // ignore: cast_nullable_to_non_nullable
          : complexity as AnalysisComplexityEnum?,
      footprint: footprint == const $CopyWithPlaceholder()
          ? _value.footprint
          // ignore: cast_nullable_to_non_nullable
          : footprint as Footprint?,
      approaches: approaches == const $CopyWithPlaceholder()
          ? _value.approaches
          // ignore: cast_nullable_to_non_nullable
          : approaches as List<Approach>?,
      outOfScope: outOfScope == const $CopyWithPlaceholder()
          ? _value.outOfScope
          // ignore: cast_nullable_to_non_nullable
          : outOfScope as List<String>?,
      ship: ship == const $CopyWithPlaceholder()
          ? _value.ship
          // ignore: cast_nullable_to_non_nullable
          : ship as ShipNotes?,
      defect: defect == const $CopyWithPlaceholder()
          ? _value.defect
          // ignore: cast_nullable_to_non_nullable
          : defect as bool?,
      acceptance: acceptance == const $CopyWithPlaceholder()
          ? _value.acceptance
          // ignore: cast_nullable_to_non_nullable
          : acceptance as List<AnalysisAcceptanceInner>?,
      patterns: patterns == const $CopyWithPlaceholder()
          ? _value.patterns
          // ignore: cast_nullable_to_non_nullable
          : patterns as List<Pattern>?,
      reuse: reuse == const $CopyWithPlaceholder()
          ? _value.reuse
          // ignore: cast_nullable_to_non_nullable
          : reuse as List<AnalysisReuseInner>?,
      testPlan: testPlan == const $CopyWithPlaceholder()
          ? _value.testPlan
          // ignore: cast_nullable_to_non_nullable
          : testPlan as List<AnalysisTestPlanInner>?,
      edgeCases: edgeCases == const $CopyWithPlaceholder()
          ? _value.edgeCases
          // ignore: cast_nullable_to_non_nullable
          : edgeCases as List<String>?,
      repro: repro == const $CopyWithPlaceholder()
          ? _value.repro
          // ignore: cast_nullable_to_non_nullable
          : repro as AnalysisRepro?,
      secondOpinion: secondOpinion == const $CopyWithPlaceholder()
          ? _value.secondOpinion
          // ignore: cast_nullable_to_non_nullable
          : secondOpinion as SecondOpinion?,
    );
  }
}

extension $AnalysisCopyWith on Analysis {
  /// Returns a callable class that can be used as follows: `instanceOfAnalysis.copyWith(...)` or like so:`instanceOfAnalysis.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AnalysisCWProxy get copyWith => _$AnalysisCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Analysis _$AnalysisFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('Analysis', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['summary', 'plan']);
  final val = Analysis(
    summary: $checkedConvert('summary', (v) => v as String),
    plan: $checkedConvert(
      'plan',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    complexity: $checkedConvert(
      'complexity',
      (v) => $enumDecodeNullable(_$AnalysisComplexityEnumEnumMap, v),
    ),
    footprint: $checkedConvert(
      'footprint',
      (v) => v == null ? null : Footprint.fromJson(v as Map<String, dynamic>),
    ),
    approaches: $checkedConvert(
      'approaches',
      (v) => (v as List<dynamic>?)
          ?.map((e) => Approach.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    outOfScope: $checkedConvert(
      'outOfScope',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    ship: $checkedConvert(
      'ship',
      (v) => v == null ? null : ShipNotes.fromJson(v as Map<String, dynamic>),
    ),
    defect: $checkedConvert('defect', (v) => v as bool?),
    acceptance: $checkedConvert(
      'acceptance',
      (v) => (v as List<dynamic>?)
          ?.map(
            (e) => AnalysisAcceptanceInner.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
    patterns: $checkedConvert(
      'patterns',
      (v) => (v as List<dynamic>?)
          ?.map((e) => Pattern.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    reuse: $checkedConvert(
      'reuse',
      (v) => (v as List<dynamic>?)
          ?.map((e) => AnalysisReuseInner.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    testPlan: $checkedConvert(
      'testPlan',
      (v) => (v as List<dynamic>?)
          ?.map(
            (e) => AnalysisTestPlanInner.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
    edgeCases: $checkedConvert(
      'edgeCases',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    repro: $checkedConvert(
      'repro',
      (v) =>
          v == null ? null : AnalysisRepro.fromJson(v as Map<String, dynamic>),
    ),
    secondOpinion: $checkedConvert(
      'secondOpinion',
      (v) =>
          v == null ? null : SecondOpinion.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$AnalysisToJson(Analysis instance) => <String, dynamic>{
  'summary': instance.summary,
  'plan': instance.plan,
  'complexity': ?_$AnalysisComplexityEnumEnumMap[instance.complexity],
  'footprint': ?instance.footprint?.toJson(),
  'approaches': ?instance.approaches?.map((e) => e.toJson()).toList(),
  'outOfScope': ?instance.outOfScope,
  'ship': ?instance.ship?.toJson(),
  'defect': ?instance.defect,
  'acceptance': ?instance.acceptance?.map((e) => e.toJson()).toList(),
  'patterns': ?instance.patterns?.map((e) => e.toJson()).toList(),
  'reuse': ?instance.reuse?.map((e) => e.toJson()).toList(),
  'testPlan': ?instance.testPlan?.map((e) => e.toJson()).toList(),
  'edgeCases': ?instance.edgeCases,
  'repro': ?instance.repro?.toJson(),
  'secondOpinion': ?instance.secondOpinion?.toJson(),
};

const _$AnalysisComplexityEnumEnumMap = {
  AnalysisComplexityEnum.simple: 'simple',
  AnalysisComplexityEnum.complex: 'complex',
};

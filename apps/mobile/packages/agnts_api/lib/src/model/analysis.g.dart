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

Analysis _$AnalysisFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Analysis', json, ($checkedConvert) {
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
          (v) =>
              v == null ? null : Footprint.fromJson(v as Map<String, dynamic>),
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
          (v) =>
              v == null ? null : ShipNotes.fromJson(v as Map<String, dynamic>),
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
};

const _$AnalysisComplexityEnumEnumMap = {
  AnalysisComplexityEnum.simple: 'simple',
  AnalysisComplexityEnum.complex: 'complex',
};

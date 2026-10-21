// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_harness.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RepoHarnessCWProxy {
  RepoHarness guardProfile(RepoHarnessGuardProfileEnum? guardProfile);

  RepoHarness secretAllow(List<String>? secretAllow);

  RepoHarness editChecks(List<EditCheck>? editChecks);

  RepoHarness editChecksOff(bool? editChecksOff);

  RepoHarness layersBlock(bool? layersBlock);

  RepoHarness coverage(CoverageConfig? coverage);

  RepoHarness acceptance(bool? acceptance);

  RepoHarness derivedEditChecks(List<EditCheck>? derivedEditChecks);

  RepoHarness derivedCoverage(RepoHarnessAllOfDerivedCoverage? derivedCoverage);

  RepoHarness agentConfig(AgentConfigScan? agentConfig);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoHarness(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoHarness(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoHarness call({
    RepoHarnessGuardProfileEnum? guardProfile,
    List<String>? secretAllow,
    List<EditCheck>? editChecks,
    bool? editChecksOff,
    bool? layersBlock,
    CoverageConfig? coverage,
    bool? acceptance,
    List<EditCheck>? derivedEditChecks,
    RepoHarnessAllOfDerivedCoverage? derivedCoverage,
    AgentConfigScan? agentConfig,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRepoHarness.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRepoHarness.copyWith.fieldName(...)`
class _$RepoHarnessCWProxyImpl implements _$RepoHarnessCWProxy {
  const _$RepoHarnessCWProxyImpl(this._value);

  final RepoHarness _value;

  @override
  RepoHarness guardProfile(RepoHarnessGuardProfileEnum? guardProfile) =>
      this(guardProfile: guardProfile);

  @override
  RepoHarness secretAllow(List<String>? secretAllow) =>
      this(secretAllow: secretAllow);

  @override
  RepoHarness editChecks(List<EditCheck>? editChecks) =>
      this(editChecks: editChecks);

  @override
  RepoHarness editChecksOff(bool? editChecksOff) =>
      this(editChecksOff: editChecksOff);

  @override
  RepoHarness layersBlock(bool? layersBlock) => this(layersBlock: layersBlock);

  @override
  RepoHarness coverage(CoverageConfig? coverage) => this(coverage: coverage);

  @override
  RepoHarness acceptance(bool? acceptance) => this(acceptance: acceptance);

  @override
  RepoHarness derivedEditChecks(List<EditCheck>? derivedEditChecks) =>
      this(derivedEditChecks: derivedEditChecks);

  @override
  RepoHarness derivedCoverage(
    RepoHarnessAllOfDerivedCoverage? derivedCoverage,
  ) => this(derivedCoverage: derivedCoverage);

  @override
  RepoHarness agentConfig(AgentConfigScan? agentConfig) =>
      this(agentConfig: agentConfig);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoHarness(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoHarness(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoHarness call({
    Object? guardProfile = const $CopyWithPlaceholder(),
    Object? secretAllow = const $CopyWithPlaceholder(),
    Object? editChecks = const $CopyWithPlaceholder(),
    Object? editChecksOff = const $CopyWithPlaceholder(),
    Object? layersBlock = const $CopyWithPlaceholder(),
    Object? coverage = const $CopyWithPlaceholder(),
    Object? acceptance = const $CopyWithPlaceholder(),
    Object? derivedEditChecks = const $CopyWithPlaceholder(),
    Object? derivedCoverage = const $CopyWithPlaceholder(),
    Object? agentConfig = const $CopyWithPlaceholder(),
  }) {
    return RepoHarness(
      guardProfile: guardProfile == const $CopyWithPlaceholder()
          ? _value.guardProfile
          // ignore: cast_nullable_to_non_nullable
          : guardProfile as RepoHarnessGuardProfileEnum?,
      secretAllow: secretAllow == const $CopyWithPlaceholder()
          ? _value.secretAllow
          // ignore: cast_nullable_to_non_nullable
          : secretAllow as List<String>?,
      editChecks: editChecks == const $CopyWithPlaceholder()
          ? _value.editChecks
          // ignore: cast_nullable_to_non_nullable
          : editChecks as List<EditCheck>?,
      editChecksOff: editChecksOff == const $CopyWithPlaceholder()
          ? _value.editChecksOff
          // ignore: cast_nullable_to_non_nullable
          : editChecksOff as bool?,
      layersBlock: layersBlock == const $CopyWithPlaceholder()
          ? _value.layersBlock
          // ignore: cast_nullable_to_non_nullable
          : layersBlock as bool?,
      coverage: coverage == const $CopyWithPlaceholder()
          ? _value.coverage
          // ignore: cast_nullable_to_non_nullable
          : coverage as CoverageConfig?,
      acceptance: acceptance == const $CopyWithPlaceholder()
          ? _value.acceptance
          // ignore: cast_nullable_to_non_nullable
          : acceptance as bool?,
      derivedEditChecks: derivedEditChecks == const $CopyWithPlaceholder()
          ? _value.derivedEditChecks
          // ignore: cast_nullable_to_non_nullable
          : derivedEditChecks as List<EditCheck>?,
      derivedCoverage: derivedCoverage == const $CopyWithPlaceholder()
          ? _value.derivedCoverage
          // ignore: cast_nullable_to_non_nullable
          : derivedCoverage as RepoHarnessAllOfDerivedCoverage?,
      agentConfig: agentConfig == const $CopyWithPlaceholder()
          ? _value.agentConfig
          // ignore: cast_nullable_to_non_nullable
          : agentConfig as AgentConfigScan?,
    );
  }
}

extension $RepoHarnessCopyWith on RepoHarness {
  /// Returns a callable class that can be used as follows: `instanceOfRepoHarness.copyWith(...)` or like so:`instanceOfRepoHarness.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RepoHarnessCWProxy get copyWith => _$RepoHarnessCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepoHarness _$RepoHarnessFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RepoHarness', json, ($checkedConvert) {
  final val = RepoHarness(
    guardProfile: $checkedConvert(
      'guardProfile',
      (v) => $enumDecodeNullable(_$RepoHarnessGuardProfileEnumEnumMap, v),
    ),
    secretAllow: $checkedConvert(
      'secretAllow',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    editChecks: $checkedConvert(
      'editChecks',
      (v) => (v as List<dynamic>?)
          ?.map((e) => EditCheck.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    editChecksOff: $checkedConvert('editChecksOff', (v) => v as bool?),
    layersBlock: $checkedConvert('layersBlock', (v) => v as bool?),
    coverage: $checkedConvert(
      'coverage',
      (v) =>
          v == null ? null : CoverageConfig.fromJson(v as Map<String, dynamic>),
    ),
    acceptance: $checkedConvert('acceptance', (v) => v as bool?),
    derivedEditChecks: $checkedConvert(
      'derivedEditChecks',
      (v) => (v as List<dynamic>?)
          ?.map((e) => EditCheck.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    derivedCoverage: $checkedConvert(
      'derivedCoverage',
      (v) => v == null
          ? null
          : RepoHarnessAllOfDerivedCoverage.fromJson(v as Map<String, dynamic>),
    ),
    agentConfig: $checkedConvert(
      'agentConfig',
      (v) => v == null
          ? null
          : AgentConfigScan.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$RepoHarnessToJson(
  RepoHarness instance,
) => <String, dynamic>{
  'guardProfile': ?_$RepoHarnessGuardProfileEnumEnumMap[instance.guardProfile],
  'secretAllow': ?instance.secretAllow,
  'editChecks': ?instance.editChecks?.map((e) => e.toJson()).toList(),
  'editChecksOff': ?instance.editChecksOff,
  'layersBlock': ?instance.layersBlock,
  'coverage': ?instance.coverage?.toJson(),
  'acceptance': ?instance.acceptance,
  'derivedEditChecks': ?instance.derivedEditChecks
      ?.map((e) => e.toJson())
      .toList(),
  'derivedCoverage': ?instance.derivedCoverage?.toJson(),
  'agentConfig': ?instance.agentConfig?.toJson(),
};

const _$RepoHarnessGuardProfileEnumEnumMap = {
  RepoHarnessGuardProfileEnum.empty: '',
  RepoHarnessGuardProfileEnum.minimal: 'minimal',
  RepoHarnessGuardProfileEnum.standard: 'standard',
  RepoHarnessGuardProfileEnum.strict: 'strict',
};

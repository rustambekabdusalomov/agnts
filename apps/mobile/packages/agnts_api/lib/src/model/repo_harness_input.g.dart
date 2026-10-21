// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_harness_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RepoHarnessInputCWProxy {
  RepoHarnessInput guardProfile(RepoHarnessInputGuardProfileEnum? guardProfile);

  RepoHarnessInput secretAllow(List<String>? secretAllow);

  RepoHarnessInput editChecks(List<EditCheck>? editChecks);

  RepoHarnessInput editChecksOff(bool? editChecksOff);

  RepoHarnessInput layersBlock(bool? layersBlock);

  RepoHarnessInput coverage(CoverageConfig? coverage);

  RepoHarnessInput acceptance(bool? acceptance);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoHarnessInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoHarnessInput(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoHarnessInput call({
    RepoHarnessInputGuardProfileEnum? guardProfile,
    List<String>? secretAllow,
    List<EditCheck>? editChecks,
    bool? editChecksOff,
    bool? layersBlock,
    CoverageConfig? coverage,
    bool? acceptance,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRepoHarnessInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRepoHarnessInput.copyWith.fieldName(...)`
class _$RepoHarnessInputCWProxyImpl implements _$RepoHarnessInputCWProxy {
  const _$RepoHarnessInputCWProxyImpl(this._value);

  final RepoHarnessInput _value;

  @override
  RepoHarnessInput guardProfile(
    RepoHarnessInputGuardProfileEnum? guardProfile,
  ) => this(guardProfile: guardProfile);

  @override
  RepoHarnessInput secretAllow(List<String>? secretAllow) =>
      this(secretAllow: secretAllow);

  @override
  RepoHarnessInput editChecks(List<EditCheck>? editChecks) =>
      this(editChecks: editChecks);

  @override
  RepoHarnessInput editChecksOff(bool? editChecksOff) =>
      this(editChecksOff: editChecksOff);

  @override
  RepoHarnessInput layersBlock(bool? layersBlock) =>
      this(layersBlock: layersBlock);

  @override
  RepoHarnessInput coverage(CoverageConfig? coverage) =>
      this(coverage: coverage);

  @override
  RepoHarnessInput acceptance(bool? acceptance) => this(acceptance: acceptance);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoHarnessInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoHarnessInput(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoHarnessInput call({
    Object? guardProfile = const $CopyWithPlaceholder(),
    Object? secretAllow = const $CopyWithPlaceholder(),
    Object? editChecks = const $CopyWithPlaceholder(),
    Object? editChecksOff = const $CopyWithPlaceholder(),
    Object? layersBlock = const $CopyWithPlaceholder(),
    Object? coverage = const $CopyWithPlaceholder(),
    Object? acceptance = const $CopyWithPlaceholder(),
  }) {
    return RepoHarnessInput(
      guardProfile: guardProfile == const $CopyWithPlaceholder()
          ? _value.guardProfile
          // ignore: cast_nullable_to_non_nullable
          : guardProfile as RepoHarnessInputGuardProfileEnum?,
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
    );
  }
}

extension $RepoHarnessInputCopyWith on RepoHarnessInput {
  /// Returns a callable class that can be used as follows: `instanceOfRepoHarnessInput.copyWith(...)` or like so:`instanceOfRepoHarnessInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RepoHarnessInputCWProxy get copyWith => _$RepoHarnessInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepoHarnessInput _$RepoHarnessInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RepoHarnessInput', json, ($checkedConvert) {
      final val = RepoHarnessInput(
        guardProfile: $checkedConvert(
          'guardProfile',
          (v) =>
              $enumDecodeNullable(_$RepoHarnessInputGuardProfileEnumEnumMap, v),
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
          (v) => v == null
              ? null
              : CoverageConfig.fromJson(v as Map<String, dynamic>),
        ),
        acceptance: $checkedConvert('acceptance', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$RepoHarnessInputToJson(RepoHarnessInput instance) =>
    <String, dynamic>{
      'guardProfile':
          ?_$RepoHarnessInputGuardProfileEnumEnumMap[instance.guardProfile],
      'secretAllow': ?instance.secretAllow,
      'editChecks': ?instance.editChecks?.map((e) => e.toJson()).toList(),
      'editChecksOff': ?instance.editChecksOff,
      'layersBlock': ?instance.layersBlock,
      'coverage': ?instance.coverage?.toJson(),
      'acceptance': ?instance.acceptance,
    };

const _$RepoHarnessInputGuardProfileEnumEnumMap = {
  RepoHarnessInputGuardProfileEnum.empty: '',
  RepoHarnessInputGuardProfileEnum.minimal: 'minimal',
  RepoHarnessInputGuardProfileEnum.standard: 'standard',
  RepoHarnessInputGuardProfileEnum.strict: 'strict',
};

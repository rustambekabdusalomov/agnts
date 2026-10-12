// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_harness_all_of_derived_coverage.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RepoHarnessAllOfDerivedCoverageCWProxy {
  RepoHarnessAllOfDerivedCoverage command(String? command);

  RepoHarnessAllOfDerivedCoverage report(String? report);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoHarnessAllOfDerivedCoverage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoHarnessAllOfDerivedCoverage(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoHarnessAllOfDerivedCoverage call({String? command, String? report});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRepoHarnessAllOfDerivedCoverage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRepoHarnessAllOfDerivedCoverage.copyWith.fieldName(...)`
class _$RepoHarnessAllOfDerivedCoverageCWProxyImpl
    implements _$RepoHarnessAllOfDerivedCoverageCWProxy {
  const _$RepoHarnessAllOfDerivedCoverageCWProxyImpl(this._value);

  final RepoHarnessAllOfDerivedCoverage _value;

  @override
  RepoHarnessAllOfDerivedCoverage command(String? command) =>
      this(command: command);

  @override
  RepoHarnessAllOfDerivedCoverage report(String? report) =>
      this(report: report);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoHarnessAllOfDerivedCoverage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoHarnessAllOfDerivedCoverage(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoHarnessAllOfDerivedCoverage call({
    Object? command = const $CopyWithPlaceholder(),
    Object? report = const $CopyWithPlaceholder(),
  }) {
    return RepoHarnessAllOfDerivedCoverage(
      command: command == const $CopyWithPlaceholder()
          ? _value.command
          // ignore: cast_nullable_to_non_nullable
          : command as String?,
      report: report == const $CopyWithPlaceholder()
          ? _value.report
          // ignore: cast_nullable_to_non_nullable
          : report as String?,
    );
  }
}

extension $RepoHarnessAllOfDerivedCoverageCopyWith
    on RepoHarnessAllOfDerivedCoverage {
  /// Returns a callable class that can be used as follows: `instanceOfRepoHarnessAllOfDerivedCoverage.copyWith(...)` or like so:`instanceOfRepoHarnessAllOfDerivedCoverage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RepoHarnessAllOfDerivedCoverageCWProxy get copyWith =>
      _$RepoHarnessAllOfDerivedCoverageCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepoHarnessAllOfDerivedCoverage _$RepoHarnessAllOfDerivedCoverageFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RepoHarnessAllOfDerivedCoverage', json, ($checkedConvert) {
  final val = RepoHarnessAllOfDerivedCoverage(
    command: $checkedConvert('command', (v) => v as String?),
    report: $checkedConvert('report', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$RepoHarnessAllOfDerivedCoverageToJson(
  RepoHarnessAllOfDerivedCoverage instance,
) => <String, dynamic>{
  'command': ?instance.command,
  'report': ?instance.report,
};

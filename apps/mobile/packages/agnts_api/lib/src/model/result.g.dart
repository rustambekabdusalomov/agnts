// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ResultCWProxy {
  Result summary(String summary);

  Result notes(List<String> notes);

  Result checks(List<CheckStep> checks);

  Result files(List<FileChange> files);

  Result report(String? report);

  Result deviations(List<String>? deviations);

  Result redFlags(List<RedFlag>? redFlags);

  Result proof(Proof? proof);

  Result coverage(Coverage? coverage);

  Result createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Result(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Result(...).copyWith(id: 12, name: "My name")
  /// ````
  Result call({
    String summary,
    List<String> notes,
    List<CheckStep> checks,
    List<FileChange> files,
    String? report,
    List<String>? deviations,
    List<RedFlag>? redFlags,
    Proof? proof,
    Coverage? coverage,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfResult.copyWith.fieldName(...)`
class _$ResultCWProxyImpl implements _$ResultCWProxy {
  const _$ResultCWProxyImpl(this._value);

  final Result _value;

  @override
  Result summary(String summary) => this(summary: summary);

  @override
  Result notes(List<String> notes) => this(notes: notes);

  @override
  Result checks(List<CheckStep> checks) => this(checks: checks);

  @override
  Result files(List<FileChange> files) => this(files: files);

  @override
  Result report(String? report) => this(report: report);

  @override
  Result deviations(List<String>? deviations) => this(deviations: deviations);

  @override
  Result redFlags(List<RedFlag>? redFlags) => this(redFlags: redFlags);

  @override
  Result proof(Proof? proof) => this(proof: proof);

  @override
  Result coverage(Coverage? coverage) => this(coverage: coverage);

  @override
  Result createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Result(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Result(...).copyWith(id: 12, name: "My name")
  /// ````
  Result call({
    Object? summary = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? checks = const $CopyWithPlaceholder(),
    Object? files = const $CopyWithPlaceholder(),
    Object? report = const $CopyWithPlaceholder(),
    Object? deviations = const $CopyWithPlaceholder(),
    Object? redFlags = const $CopyWithPlaceholder(),
    Object? proof = const $CopyWithPlaceholder(),
    Object? coverage = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return Result(
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as String,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as List<String>,
      checks: checks == const $CopyWithPlaceholder()
          ? _value.checks
          // ignore: cast_nullable_to_non_nullable
          : checks as List<CheckStep>,
      files: files == const $CopyWithPlaceholder()
          ? _value.files
          // ignore: cast_nullable_to_non_nullable
          : files as List<FileChange>,
      report: report == const $CopyWithPlaceholder()
          ? _value.report
          // ignore: cast_nullable_to_non_nullable
          : report as String?,
      deviations: deviations == const $CopyWithPlaceholder()
          ? _value.deviations
          // ignore: cast_nullable_to_non_nullable
          : deviations as List<String>?,
      redFlags: redFlags == const $CopyWithPlaceholder()
          ? _value.redFlags
          // ignore: cast_nullable_to_non_nullable
          : redFlags as List<RedFlag>?,
      proof: proof == const $CopyWithPlaceholder()
          ? _value.proof
          // ignore: cast_nullable_to_non_nullable
          : proof as Proof?,
      coverage: coverage == const $CopyWithPlaceholder()
          ? _value.coverage
          // ignore: cast_nullable_to_non_nullable
          : coverage as Coverage?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $ResultCopyWith on Result {
  /// Returns a callable class that can be used as follows: `instanceOfResult.copyWith(...)` or like so:`instanceOfResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ResultCWProxy get copyWith => _$ResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Result _$ResultFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('Result', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['summary', 'notes', 'checks', 'files', 'createdAt'],
  );
  final val = Result(
    summary: $checkedConvert('summary', (v) => v as String),
    notes: $checkedConvert(
      'notes',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    checks: $checkedConvert(
      'checks',
      (v) => (v as List<dynamic>)
          .map((e) => CheckStep.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    files: $checkedConvert(
      'files',
      (v) => (v as List<dynamic>)
          .map((e) => FileChange.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    report: $checkedConvert('report', (v) => v as String?),
    deviations: $checkedConvert(
      'deviations',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    redFlags: $checkedConvert(
      'redFlags',
      (v) => (v as List<dynamic>?)
          ?.map((e) => RedFlag.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    proof: $checkedConvert(
      'proof',
      (v) => v == null ? null : Proof.fromJson(v as Map<String, dynamic>),
    ),
    coverage: $checkedConvert(
      'coverage',
      (v) => v == null ? null : Coverage.fromJson(v as Map<String, dynamic>),
    ),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$ResultToJson(Result instance) => <String, dynamic>{
  'summary': instance.summary,
  'notes': instance.notes,
  'checks': instance.checks.map((e) => e.toJson()).toList(),
  'files': instance.files.map((e) => e.toJson()).toList(),
  'report': ?instance.report,
  'deviations': ?instance.deviations,
  'redFlags': ?instance.redFlags?.map((e) => e.toJson()).toList(),
  'proof': ?instance.proof?.toJson(),
  'coverage': ?instance.coverage?.toJson(),
  'createdAt': instance.createdAt.toIso8601String(),
};

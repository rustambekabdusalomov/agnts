// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_repo_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SecurityRepoSummaryCWProxy {
  SecurityRepoSummary repoId(int repoId);

  SecurityRepoSummary repo(String repo);

  SecurityRepoSummary open(SecSeverityCounts open);

  SecurityRepoSummary lastScan(SecurityScan? lastScan);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SecurityRepoSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SecurityRepoSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  SecurityRepoSummary call({
    int repoId,
    String repo,
    SecSeverityCounts open,
    SecurityScan? lastScan,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSecurityRepoSummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSecurityRepoSummary.copyWith.fieldName(...)`
class _$SecurityRepoSummaryCWProxyImpl implements _$SecurityRepoSummaryCWProxy {
  const _$SecurityRepoSummaryCWProxyImpl(this._value);

  final SecurityRepoSummary _value;

  @override
  SecurityRepoSummary repoId(int repoId) => this(repoId: repoId);

  @override
  SecurityRepoSummary repo(String repo) => this(repo: repo);

  @override
  SecurityRepoSummary open(SecSeverityCounts open) => this(open: open);

  @override
  SecurityRepoSummary lastScan(SecurityScan? lastScan) =>
      this(lastScan: lastScan);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SecurityRepoSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SecurityRepoSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  SecurityRepoSummary call({
    Object? repoId = const $CopyWithPlaceholder(),
    Object? repo = const $CopyWithPlaceholder(),
    Object? open = const $CopyWithPlaceholder(),
    Object? lastScan = const $CopyWithPlaceholder(),
  }) {
    return SecurityRepoSummary(
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int,
      repo: repo == const $CopyWithPlaceholder()
          ? _value.repo
          // ignore: cast_nullable_to_non_nullable
          : repo as String,
      open: open == const $CopyWithPlaceholder()
          ? _value.open
          // ignore: cast_nullable_to_non_nullable
          : open as SecSeverityCounts,
      lastScan: lastScan == const $CopyWithPlaceholder()
          ? _value.lastScan
          // ignore: cast_nullable_to_non_nullable
          : lastScan as SecurityScan?,
    );
  }
}

extension $SecurityRepoSummaryCopyWith on SecurityRepoSummary {
  /// Returns a callable class that can be used as follows: `instanceOfSecurityRepoSummary.copyWith(...)` or like so:`instanceOfSecurityRepoSummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SecurityRepoSummaryCWProxy get copyWith =>
      _$SecurityRepoSummaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SecurityRepoSummary _$SecurityRepoSummaryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SecurityRepoSummary', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['repoId', 'repo', 'open']);
      final val = SecurityRepoSummary(
        repoId: $checkedConvert('repoId', (v) => (v as num).toInt()),
        repo: $checkedConvert('repo', (v) => v as String),
        open: $checkedConvert(
          'open',
          (v) => SecSeverityCounts.fromJson(v as Map<String, dynamic>),
        ),
        lastScan: $checkedConvert(
          'lastScan',
          (v) => v == null
              ? null
              : SecurityScan.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SecurityRepoSummaryToJson(
  SecurityRepoSummary instance,
) => <String, dynamic>{
  'repoId': instance.repoId,
  'repo': instance.repo,
  'open': instance.open.toJson(),
  'lastScan': ?instance.lastScan?.toJson(),
};

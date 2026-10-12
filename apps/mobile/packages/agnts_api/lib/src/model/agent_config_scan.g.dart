// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_config_scan.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AgentConfigScanCWProxy {
  AgentConfigScan scannedAt(DateTime scannedAt);

  AgentConfigScan findings(List<AgentConfigFinding> findings);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AgentConfigScan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AgentConfigScan(...).copyWith(id: 12, name: "My name")
  /// ````
  AgentConfigScan call({DateTime scannedAt, List<AgentConfigFinding> findings});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAgentConfigScan.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAgentConfigScan.copyWith.fieldName(...)`
class _$AgentConfigScanCWProxyImpl implements _$AgentConfigScanCWProxy {
  const _$AgentConfigScanCWProxyImpl(this._value);

  final AgentConfigScan _value;

  @override
  AgentConfigScan scannedAt(DateTime scannedAt) => this(scannedAt: scannedAt);

  @override
  AgentConfigScan findings(List<AgentConfigFinding> findings) =>
      this(findings: findings);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AgentConfigScan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AgentConfigScan(...).copyWith(id: 12, name: "My name")
  /// ````
  AgentConfigScan call({
    Object? scannedAt = const $CopyWithPlaceholder(),
    Object? findings = const $CopyWithPlaceholder(),
  }) {
    return AgentConfigScan(
      scannedAt: scannedAt == const $CopyWithPlaceholder()
          ? _value.scannedAt
          // ignore: cast_nullable_to_non_nullable
          : scannedAt as DateTime,
      findings: findings == const $CopyWithPlaceholder()
          ? _value.findings
          // ignore: cast_nullable_to_non_nullable
          : findings as List<AgentConfigFinding>,
    );
  }
}

extension $AgentConfigScanCopyWith on AgentConfigScan {
  /// Returns a callable class that can be used as follows: `instanceOfAgentConfigScan.copyWith(...)` or like so:`instanceOfAgentConfigScan.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AgentConfigScanCWProxy get copyWith => _$AgentConfigScanCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgentConfigScan _$AgentConfigScanFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AgentConfigScan', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['scannedAt', 'findings']);
  final val = AgentConfigScan(
    scannedAt: $checkedConvert('scannedAt', (v) => DateTime.parse(v as String)),
    findings: $checkedConvert(
      'findings',
      (v) => (v as List<dynamic>)
          .map((e) => AgentConfigFinding.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$AgentConfigScanToJson(AgentConfigScan instance) =>
    <String, dynamic>{
      'scannedAt': instance.scannedAt.toIso8601String(),
      'findings': instance.findings.map((e) => e.toJson()).toList(),
    };

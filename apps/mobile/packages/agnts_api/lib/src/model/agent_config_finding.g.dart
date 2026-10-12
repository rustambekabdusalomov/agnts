// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_config_finding.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AgentConfigFindingCWProxy {
  AgentConfigFinding path(String path);

  AgentConfigFinding line(int? line);

  AgentConfigFinding kind(AgentConfigFindingKindEnum kind);

  AgentConfigFinding severity(AgentConfigFindingSeverityEnum severity);

  AgentConfigFinding text(String text);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AgentConfigFinding(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AgentConfigFinding(...).copyWith(id: 12, name: "My name")
  /// ````
  AgentConfigFinding call({
    String path,
    int? line,
    AgentConfigFindingKindEnum kind,
    AgentConfigFindingSeverityEnum severity,
    String text,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAgentConfigFinding.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAgentConfigFinding.copyWith.fieldName(...)`
class _$AgentConfigFindingCWProxyImpl implements _$AgentConfigFindingCWProxy {
  const _$AgentConfigFindingCWProxyImpl(this._value);

  final AgentConfigFinding _value;

  @override
  AgentConfigFinding path(String path) => this(path: path);

  @override
  AgentConfigFinding line(int? line) => this(line: line);

  @override
  AgentConfigFinding kind(AgentConfigFindingKindEnum kind) => this(kind: kind);

  @override
  AgentConfigFinding severity(AgentConfigFindingSeverityEnum severity) =>
      this(severity: severity);

  @override
  AgentConfigFinding text(String text) => this(text: text);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AgentConfigFinding(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AgentConfigFinding(...).copyWith(id: 12, name: "My name")
  /// ````
  AgentConfigFinding call({
    Object? path = const $CopyWithPlaceholder(),
    Object? line = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? severity = const $CopyWithPlaceholder(),
    Object? text = const $CopyWithPlaceholder(),
  }) {
    return AgentConfigFinding(
      path: path == const $CopyWithPlaceholder()
          ? _value.path
          // ignore: cast_nullable_to_non_nullable
          : path as String,
      line: line == const $CopyWithPlaceholder()
          ? _value.line
          // ignore: cast_nullable_to_non_nullable
          : line as int?,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as AgentConfigFindingKindEnum,
      severity: severity == const $CopyWithPlaceholder()
          ? _value.severity
          // ignore: cast_nullable_to_non_nullable
          : severity as AgentConfigFindingSeverityEnum,
      text: text == const $CopyWithPlaceholder()
          ? _value.text
          // ignore: cast_nullable_to_non_nullable
          : text as String,
    );
  }
}

extension $AgentConfigFindingCopyWith on AgentConfigFinding {
  /// Returns a callable class that can be used as follows: `instanceOfAgentConfigFinding.copyWith(...)` or like so:`instanceOfAgentConfigFinding.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AgentConfigFindingCWProxy get copyWith =>
      _$AgentConfigFindingCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgentConfigFinding _$AgentConfigFindingFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AgentConfigFinding', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['path', 'kind', 'severity', 'text'],
      );
      final val = AgentConfigFinding(
        path: $checkedConvert('path', (v) => v as String),
        line: $checkedConvert('line', (v) => (v as num?)?.toInt()),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$AgentConfigFindingKindEnumEnumMap, v),
        ),
        severity: $checkedConvert(
          'severity',
          (v) => $enumDecode(_$AgentConfigFindingSeverityEnumEnumMap, v),
        ),
        text: $checkedConvert('text', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$AgentConfigFindingToJson(AgentConfigFinding instance) =>
    <String, dynamic>{
      'path': instance.path,
      'line': ?instance.line,
      'kind': _$AgentConfigFindingKindEnumEnumMap[instance.kind]!,
      'severity': _$AgentConfigFindingSeverityEnumEnumMap[instance.severity]!,
      'text': instance.text,
    };

const _$AgentConfigFindingKindEnumEnumMap = {
  AgentConfigFindingKindEnum.hiddenUnicode: 'hidden_unicode',
  AgentConfigFindingKindEnum.agentInstruction: 'agent_instruction',
  AgentConfigFindingKindEnum.exfiltration: 'exfiltration',
  AgentConfigFindingKindEnum.encodedBlob: 'encoded_blob',
  AgentConfigFindingKindEnum.hooks: 'hooks',
  AgentConfigFindingKindEnum.mcpServer: 'mcp_server',
};

const _$AgentConfigFindingSeverityEnumEnumMap = {
  AgentConfigFindingSeverityEnum.high: 'high',
  AgentConfigFindingSeverityEnum.medium: 'medium',
  AgentConfigFindingSeverityEnum.info: 'info',
};

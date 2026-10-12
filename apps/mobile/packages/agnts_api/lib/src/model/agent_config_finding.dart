//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'agent_config_finding.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AgentConfigFinding {
  /// Returns a new [AgentConfigFinding] instance.
  AgentConfigFinding({

    required  this.path,

     this.line,

    required  this.kind,

    required  this.severity,

    required  this.text,
  });

  @JsonKey(
    
    name: r'path',
    required: true,
    includeIfNull: false,
  )


  final String path;



  @JsonKey(
    
    name: r'line',
    required: false,
    includeIfNull: false,
  )


  final int? line;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final AgentConfigFindingKindEnum kind;



  @JsonKey(
    
    name: r'severity',
    required: true,
    includeIfNull: false,
  )


  final AgentConfigFindingSeverityEnum severity;



  @JsonKey(
    
    name: r'text',
    required: true,
    includeIfNull: false,
  )


  final String text;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AgentConfigFinding &&
      other.path == path &&
      other.line == line &&
      other.kind == kind &&
      other.severity == severity &&
      other.text == text;

    @override
    int get hashCode =>
        path.hashCode +
        line.hashCode +
        kind.hashCode +
        severity.hashCode +
        text.hashCode;

  factory AgentConfigFinding.fromJson(Map<String, dynamic> json) => _$AgentConfigFindingFromJson(json);

  Map<String, dynamic> toJson() => _$AgentConfigFindingToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum AgentConfigFindingKindEnum {
@JsonValue(r'hidden_unicode')
hiddenUnicode(r'hidden_unicode'),
@JsonValue(r'agent_instruction')
agentInstruction(r'agent_instruction'),
@JsonValue(r'exfiltration')
exfiltration(r'exfiltration'),
@JsonValue(r'encoded_blob')
encodedBlob(r'encoded_blob'),
@JsonValue(r'hooks')
hooks(r'hooks'),
@JsonValue(r'mcp_server')
mcpServer(r'mcp_server');

const AgentConfigFindingKindEnum(this.value);

final String value;

@override
String toString() => value;
}


enum AgentConfigFindingSeverityEnum {
@JsonValue(r'high')
high(r'high'),
@JsonValue(r'medium')
medium(r'medium'),
@JsonValue(r'info')
info(r'info');

const AgentConfigFindingSeverityEnum(this.value);

final String value;

@override
String toString() => value;
}



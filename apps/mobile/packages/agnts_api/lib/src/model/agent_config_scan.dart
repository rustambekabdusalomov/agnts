//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/agent_config_finding.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'agent_config_scan.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AgentConfigScan {
  /// Returns a new [AgentConfigScan] instance.
  AgentConfigScan({

    required  this.scannedAt,

    required  this.findings,
  });

  @JsonKey(
    
    name: r'scannedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime scannedAt;



  @JsonKey(
    
    name: r'findings',
    required: true,
    includeIfNull: false,
  )


  final List<AgentConfigFinding> findings;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AgentConfigScan &&
      other.scannedAt == scannedAt &&
      other.findings == findings;

    @override
    int get hashCode =>
        scannedAt.hashCode +
        findings.hashCode;

  factory AgentConfigScan.fromJson(Map<String, dynamic> json) => _$AgentConfigScanFromJson(json);

  Map<String, dynamic> toJson() => _$AgentConfigScanToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


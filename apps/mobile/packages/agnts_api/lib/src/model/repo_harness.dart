//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/edit_check.dart';
import 'package:agnts_api/src/model/agent_config_scan.dart';
import 'package:agnts_api/src/model/repo_harness_all_of_derived_coverage.dart';
import 'package:agnts_api/src/model/coverage_config.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'repo_harness.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RepoHarness {
  /// Returns a new [RepoHarness] instance.
  RepoHarness({

     this.guardProfile,

     this.secretAllow,

     this.editChecks,

     this.editChecksOff,

     this.coverage,

     this.acceptance,

     this.derivedEditChecks,

     this.derivedCoverage,

     this.agentConfig,
  });

      /// Empty follows the workspace
  @JsonKey(
    
    name: r'guardProfile',
    required: false,
    includeIfNull: false,
  )


  final RepoHarnessGuardProfileEnum? guardProfile;



      /// Path globs where example credentials are expected, besides testdata/, fixtures/ and *.example
  @JsonKey(
    
    name: r'secretAllow',
    required: false,
    includeIfNull: false,
  )


  final List<String>? secretAllow;



      /// Per-file checks after each edit; null uses the ones agnts derives from the toolchains
  @JsonKey(
    
    name: r'editChecks',
    required: false,
    includeIfNull: false,
  )


  final List<EditCheck>? editChecks;



  @JsonKey(
    
    name: r'editChecksOff',
    required: false,
    includeIfNull: false,
  )


  final bool? editChecksOff;



  @JsonKey(
    
    name: r'coverage',
    required: false,
    includeIfNull: false,
  )


  final CoverageConfig? coverage;



      /// Check the ticket's acceptance criteria in the running app after the preview
  @JsonKey(
    
    name: r'acceptance',
    required: false,
    includeIfNull: false,
  )


  final bool? acceptance;



      /// The per-file checks agnts derives from the toolchains
  @JsonKey(
    
    name: r'derivedEditChecks',
    required: false,
    includeIfNull: false,
  )


  final List<EditCheck>? derivedEditChecks;



  @JsonKey(
    
    name: r'derivedCoverage',
    required: false,
    includeIfNull: false,
  )


  final RepoHarnessAllOfDerivedCoverage? derivedCoverage;



  @JsonKey(
    
    name: r'agentConfig',
    required: false,
    includeIfNull: false,
  )


  final AgentConfigScan? agentConfig;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RepoHarness &&
      other.guardProfile == guardProfile &&
      other.secretAllow == secretAllow &&
      other.editChecks == editChecks &&
      other.editChecksOff == editChecksOff &&
      other.coverage == coverage &&
      other.acceptance == acceptance &&
      other.derivedEditChecks == derivedEditChecks &&
      other.derivedCoverage == derivedCoverage &&
      other.agentConfig == agentConfig;

    @override
    int get hashCode =>
        guardProfile.hashCode +
        secretAllow.hashCode +
        (editChecks == null ? 0 : editChecks.hashCode) +
        editChecksOff.hashCode +
        coverage.hashCode +
        acceptance.hashCode +
        derivedEditChecks.hashCode +
        derivedCoverage.hashCode +
        agentConfig.hashCode;

  factory RepoHarness.fromJson(Map<String, dynamic> json) => _$RepoHarnessFromJson(json);

  Map<String, dynamic> toJson() => _$RepoHarnessToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// Empty follows the workspace
enum RepoHarnessGuardProfileEnum {
@JsonValue(r'')
empty(r''),
@JsonValue(r'minimal')
minimal(r'minimal'),
@JsonValue(r'standard')
standard(r'standard'),
@JsonValue(r'strict')
strict(r'strict');

const RepoHarnessGuardProfileEnum(this.value);

final String value;

@override
String toString() => value;
}



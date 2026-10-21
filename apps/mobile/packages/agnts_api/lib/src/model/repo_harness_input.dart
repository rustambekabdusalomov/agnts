//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/edit_check.dart';
import 'package:agnts_api/src/model/coverage_config.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'repo_harness_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RepoHarnessInput {
  /// Returns a new [RepoHarnessInput] instance.
  RepoHarnessInput({

     this.guardProfile,

     this.secretAllow,

     this.editChecks,

     this.editChecksOff,

     this.layersBlock,

     this.coverage,

     this.acceptance,
  });

      /// Empty follows the workspace
  @JsonKey(
    
    name: r'guardProfile',
    required: false,
    includeIfNull: false,
  )


  final RepoHarnessInputGuardProfileEnum? guardProfile;



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



      /// An import the approved architecture does not allow is a blocker agnts's review sends back, not only a red flag
  @JsonKey(
    
    name: r'layersBlock',
    required: false,
    includeIfNull: false,
  )


  final bool? layersBlock;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is RepoHarnessInput &&
      other.guardProfile == guardProfile &&
      other.secretAllow == secretAllow &&
      other.editChecks == editChecks &&
      other.editChecksOff == editChecksOff &&
      other.layersBlock == layersBlock &&
      other.coverage == coverage &&
      other.acceptance == acceptance;

    @override
    int get hashCode =>
        guardProfile.hashCode +
        secretAllow.hashCode +
        (editChecks == null ? 0 : editChecks.hashCode) +
        editChecksOff.hashCode +
        layersBlock.hashCode +
        coverage.hashCode +
        acceptance.hashCode;

  factory RepoHarnessInput.fromJson(Map<String, dynamic> json) => _$RepoHarnessInputFromJson(json);

  Map<String, dynamic> toJson() => _$RepoHarnessInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// Empty follows the workspace
enum RepoHarnessInputGuardProfileEnum {
@JsonValue(r'')
empty(r''),
@JsonValue(r'minimal')
minimal(r'minimal'),
@JsonValue(r'standard')
standard(r'standard'),
@JsonValue(r'strict')
strict(r'strict');

const RepoHarnessInputGuardProfileEnum(this.value);

final String value;

@override
String toString() => value;
}



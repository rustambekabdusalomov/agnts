//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'repo_harness_all_of_derived_coverage.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RepoHarnessAllOfDerivedCoverage {
  /// Returns a new [RepoHarnessAllOfDerivedCoverage] instance.
  RepoHarnessAllOfDerivedCoverage({

     this.command,

     this.report,
  });

  @JsonKey(
    
    name: r'command',
    required: false,
    includeIfNull: false,
  )


  final String? command;



  @JsonKey(
    
    name: r'report',
    required: false,
    includeIfNull: false,
  )


  final String? report;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RepoHarnessAllOfDerivedCoverage &&
      other.command == command &&
      other.report == report;

    @override
    int get hashCode =>
        command.hashCode +
        report.hashCode;

  factory RepoHarnessAllOfDerivedCoverage.fromJson(Map<String, dynamic> json) => _$RepoHarnessAllOfDerivedCoverageFromJson(json);

  Map<String, dynamic> toJson() => _$RepoHarnessAllOfDerivedCoverageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


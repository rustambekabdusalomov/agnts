//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/security_scan.dart';
import 'package:agnts_api/src/model/sec_severity_counts.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'security_repo_summary.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SecurityRepoSummary {
  /// Returns a new [SecurityRepoSummary] instance.
  SecurityRepoSummary({

    required  this.repoId,

    required  this.repo,

    required  this.open,

     this.lastScan,
  });

  @JsonKey(
    
    name: r'repoId',
    required: true,
    includeIfNull: false,
  )


  final int repoId;



  @JsonKey(
    
    name: r'repo',
    required: true,
    includeIfNull: false,
  )


  final String repo;



  @JsonKey(
    
    name: r'open',
    required: true,
    includeIfNull: false,
  )


  final SecSeverityCounts open;



  @JsonKey(
    
    name: r'lastScan',
    required: false,
    includeIfNull: false,
  )


  final SecurityScan? lastScan;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SecurityRepoSummary &&
      other.repoId == repoId &&
      other.repo == repo &&
      other.open == open &&
      other.lastScan == lastScan;

    @override
    int get hashCode =>
        repoId.hashCode +
        repo.hashCode +
        open.hashCode +
        lastScan.hashCode;

  factory SecurityRepoSummary.fromJson(Map<String, dynamic> json) => _$SecurityRepoSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$SecurityRepoSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


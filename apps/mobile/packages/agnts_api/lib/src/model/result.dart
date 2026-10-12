//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/check_step.dart';
import 'package:agnts_api/src/model/red_flag.dart';
import 'package:agnts_api/src/model/coverage.dart';
import 'package:agnts_api/src/model/proof.dart';
import 'package:agnts_api/src/model/file_change.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'result.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Result {
  /// Returns a new [Result] instance.
  Result({

    required  this.summary,

    required  this.notes,

    required  this.checks,

    required  this.files,

     this.report,

     this.deviations,

     this.redFlags,

     this.proof,

     this.coverage,

    required  this.createdAt,
  });

  @JsonKey(
    
    name: r'summary',
    required: true,
    includeIfNull: false,
  )


  final String summary;



  @JsonKey(
    
    name: r'notes',
    required: true,
    includeIfNull: false,
  )


  final List<String> notes;



  @JsonKey(
    
    name: r'checks',
    required: true,
    includeIfNull: false,
  )


  final List<CheckStep> checks;



  @JsonKey(
    
    name: r'files',
    required: true,
    includeIfNull: false,
  )


  final List<FileChange> files;



      /// The Markdown report, for report kinds
  @JsonKey(
    
    name: r'report',
    required: false,
    includeIfNull: false,
  )


  final String? report;



      /// Where the work departed from the chosen approach or the plan, and why
  @JsonKey(
    
    name: r'deviations',
    required: false,
    includeIfNull: false,
  )


  final List<String>? deviations;



      /// Lines agnts's scan of the change flagged for the reviewer: skipped tests, removed assertions, silenced linters and the like
  @JsonKey(
    
    name: r'redFlags',
    required: false,
    includeIfNull: false,
  )


  final List<RedFlag>? redFlags;



  @JsonKey(
    
    name: r'proof',
    required: false,
    includeIfNull: false,
  )


  final Proof? proof;



  @JsonKey(
    
    name: r'coverage',
    required: false,
    includeIfNull: false,
  )


  final Coverage? coverage;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Result &&
      other.summary == summary &&
      other.notes == notes &&
      other.checks == checks &&
      other.files == files &&
      other.report == report &&
      other.deviations == deviations &&
      other.redFlags == redFlags &&
      other.proof == proof &&
      other.coverage == coverage &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        summary.hashCode +
        notes.hashCode +
        checks.hashCode +
        files.hashCode +
        report.hashCode +
        deviations.hashCode +
        redFlags.hashCode +
        proof.hashCode +
        coverage.hashCode +
        createdAt.hashCode;

  factory Result.fromJson(Map<String, dynamic> json) => _$ResultFromJson(json);

  Map<String, dynamic> toJson() => _$ResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


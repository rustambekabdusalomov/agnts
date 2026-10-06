//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/check_step.dart';
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
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        summary.hashCode +
        notes.hashCode +
        checks.hashCode +
        files.hashCode +
        report.hashCode +
        createdAt.hashCode;

  factory Result.fromJson(Map<String, dynamic> json) => _$ResultFromJson(json);

  Map<String, dynamic> toJson() => _$ResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


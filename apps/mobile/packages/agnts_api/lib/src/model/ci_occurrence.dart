//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ci_occurrence.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CIOccurrence {
  /// Returns a new [CIOccurrence] instance.
  CIOccurrence({

    required  this.runId,

    required  this.url,

    required  this.sha,

    required  this.job,

    required  this.at,

     this.flaky,
  });

  @JsonKey(
    
    name: r'runId',
    required: true,
    includeIfNull: false,
  )


  final int runId;



  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;



  @JsonKey(
    
    name: r'sha',
    required: true,
    includeIfNull: false,
  )


  final String sha;



  @JsonKey(
    
    name: r'job',
    required: true,
    includeIfNull: false,
  )


  final String job;



  @JsonKey(
    
    name: r'at',
    required: true,
    includeIfNull: false,
  )


  final DateTime at;



      /// Passed when re-run
  @JsonKey(
    
    name: r'flaky',
    required: false,
    includeIfNull: false,
  )


  final bool? flaky;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CIOccurrence &&
      other.runId == runId &&
      other.url == url &&
      other.sha == sha &&
      other.job == job &&
      other.at == at &&
      other.flaky == flaky;

    @override
    int get hashCode =>
        runId.hashCode +
        url.hashCode +
        sha.hashCode +
        job.hashCode +
        at.hashCode +
        flaky.hashCode;

  factory CIOccurrence.fromJson(Map<String, dynamic> json) => _$CIOccurrenceFromJson(json);

  Map<String, dynamic> toJson() => _$CIOccurrenceToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


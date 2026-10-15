//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/api_case.dart';
import 'package:agnts_api/src/model/api_request_row.dart';
import 'package:agnts_api/src/model/api_counts.dart';
import 'package:agnts_api/src/model/swagger_test_view.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'swagger_results.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SwaggerResults {
  /// Returns a new [SwaggerResults] instance.
  SwaggerResults({

    required  this.test,

     this.runId,

     this.createdAt,

     this.status,

     this.summary,

     this.counts,

    required  this.cases,

    required  this.requests,

    required  this.notes,

     this.previous,

    required  this.newFailures,
  });

  @JsonKey(
    
    name: r'test',
    required: true,
    includeIfNull: false,
  )


  final SwaggerTestView test;



      /// Absent until a run finished
  @JsonKey(
    
    name: r'runId',
    required: false,
    includeIfNull: false,
  )


  final int? runId;



  @JsonKey(
    
    name: r'createdAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? createdAt;



  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final String? status;



  @JsonKey(
    
    name: r'summary',
    required: false,
    includeIfNull: false,
  )


  final String? summary;



  @JsonKey(
    
    name: r'counts',
    required: false,
    includeIfNull: false,
  )


  final ApiCounts? counts;



  @JsonKey(
    
    name: r'cases',
    required: true,
    includeIfNull: false,
  )


  final List<ApiCase> cases;



  @JsonKey(
    
    name: r'requests',
    required: true,
    includeIfNull: false,
  )


  final List<ApiRequestRow> requests;



      /// What agnts dropped or added while checking
  @JsonKey(
    
    name: r'notes',
    required: true,
    includeIfNull: false,
  )


  final List<String> notes;



  @JsonKey(
    
    name: r'previous',
    required: false,
    includeIfNull: false,
  )


  final ApiCounts? previous;



      /// Cases failing now that did not fail in the run before
  @JsonKey(
    
    name: r'newFailures',
    required: true,
    includeIfNull: false,
  )


  final List<String> newFailures;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SwaggerResults &&
      other.test == test &&
      other.runId == runId &&
      other.createdAt == createdAt &&
      other.status == status &&
      other.summary == summary &&
      other.counts == counts &&
      other.cases == cases &&
      other.requests == requests &&
      other.notes == notes &&
      other.previous == previous &&
      other.newFailures == newFailures;

    @override
    int get hashCode =>
        test.hashCode +
        runId.hashCode +
        createdAt.hashCode +
        status.hashCode +
        summary.hashCode +
        counts.hashCode +
        cases.hashCode +
        requests.hashCode +
        notes.hashCode +
        previous.hashCode +
        newFailures.hashCode;

  factory SwaggerResults.fromJson(Map<String, dynamic> json) => _$SwaggerResultsFromJson(json);

  Map<String, dynamic> toJson() => _$SwaggerResultsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


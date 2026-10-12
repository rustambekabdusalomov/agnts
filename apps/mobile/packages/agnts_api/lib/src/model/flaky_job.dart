//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'flaky_job.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FlakyJob {
  /// Returns a new [FlakyJob] instance.
  FlakyJob({

    required  this.id,

    required  this.repo,

    required  this.workflow,

    required  this.job,

    required  this.title,

    required  this.flaky,

    required  this.failures,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'repo',
    required: true,
    includeIfNull: false,
  )


  final String repo;



  @JsonKey(
    
    name: r'workflow',
    required: true,
    includeIfNull: false,
  )


  final String workflow;



  @JsonKey(
    
    name: r'job',
    required: true,
    includeIfNull: false,
  )


  final String job;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



      /// Times it passed on re-run
  @JsonKey(
    
    name: r'flaky',
    required: true,
    includeIfNull: false,
  )


  final int flaky;



  @JsonKey(
    
    name: r'failures',
    required: true,
    includeIfNull: false,
  )


  final int failures;





    @override
    bool operator ==(Object other) => identical(this, other) || other is FlakyJob &&
      other.id == id &&
      other.repo == repo &&
      other.workflow == workflow &&
      other.job == job &&
      other.title == title &&
      other.flaky == flaky &&
      other.failures == failures;

    @override
    int get hashCode =>
        id.hashCode +
        repo.hashCode +
        workflow.hashCode +
        job.hashCode +
        title.hashCode +
        flaky.hashCode +
        failures.hashCode;

  factory FlakyJob.fromJson(Map<String, dynamic> json) => _$FlakyJobFromJson(json);

  Map<String, dynamic> toJson() => _$FlakyJobToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


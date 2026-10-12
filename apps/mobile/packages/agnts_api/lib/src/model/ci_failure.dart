//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/ci_occurrence.dart';
import 'package:agnts_api/src/model/ticket_state.dart';
import 'package:agnts_api/src/model/ci_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ci_failure.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CIFailure {
  /// Returns a new [CIFailure] instance.
  CIFailure({

    required  this.id,

    required  this.repoId,

    required  this.repo,

    required  this.branch,

    required  this.workflow,

    required  this.job,

    required  this.title,

    required  this.class_,

    required  this.status,

    required  this.count,

    required  this.flakyCount,

    required  this.firstSeenAt,

    required  this.lastSeenAt,

    required  this.firstSha,

    required  this.lastSha,

    required  this.occurrences,

    required  this.ticketKey,

     this.ticketState,

     this.fixedSha,

     this.fixedAt,

    required  this.prNumber,

     this.sample,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



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



      /// The branch, or pr/<number> for a failure on someone else's pull request
  @JsonKey(
    
    name: r'branch',
    required: true,
    includeIfNull: false,
  )


  final String branch;



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



      /// code, test, config, dependency, infra, flaky, report, or empty while unknown
  @JsonKey(
    
    name: r'class',
    required: true,
    includeIfNull: false,
  )


  final String class_;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final CIStatus status;



  @JsonKey(
    
    name: r'count',
    required: true,
    includeIfNull: false,
  )


  final int count;



  @JsonKey(
    
    name: r'flakyCount',
    required: true,
    includeIfNull: false,
  )


  final int flakyCount;



  @JsonKey(
    
    name: r'firstSeenAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime firstSeenAt;



  @JsonKey(
    
    name: r'lastSeenAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime lastSeenAt;



  @JsonKey(
    
    name: r'firstSha',
    required: true,
    includeIfNull: false,
  )


  final String firstSha;



  @JsonKey(
    
    name: r'lastSha',
    required: true,
    includeIfNull: false,
  )


  final String lastSha;



  @JsonKey(
    
    name: r'occurrences',
    required: true,
    includeIfNull: false,
  )


  final List<CIOccurrence> occurrences;



      /// The ticket fixing it, or empty
  @JsonKey(
    
    name: r'ticketKey',
    required: true,
    includeIfNull: false,
  )


  final String ticketKey;



  @JsonKey(
    
    name: r'ticketState',
    required: false,
    includeIfNull: false,
  )


  final TicketState? ticketState;



  @JsonKey(
    
    name: r'fixedSha',
    required: false,
    includeIfNull: false,
  )


  final String? fixedSha;



  @JsonKey(
    
    name: r'fixedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? fixedAt;



      /// Someone else's pull request (diagnosis comment only), 0 otherwise
  @JsonKey(
    
    name: r'prNumber',
    required: true,
    includeIfNull: false,
  )


  final int prNumber;



      /// Redacted log excerpt (single reads only)
  @JsonKey(
    
    name: r'sample',
    required: false,
    includeIfNull: false,
  )


  final String? sample;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CIFailure &&
      other.id == id &&
      other.repoId == repoId &&
      other.repo == repo &&
      other.branch == branch &&
      other.workflow == workflow &&
      other.job == job &&
      other.title == title &&
      other.class_ == class_ &&
      other.status == status &&
      other.count == count &&
      other.flakyCount == flakyCount &&
      other.firstSeenAt == firstSeenAt &&
      other.lastSeenAt == lastSeenAt &&
      other.firstSha == firstSha &&
      other.lastSha == lastSha &&
      other.occurrences == occurrences &&
      other.ticketKey == ticketKey &&
      other.ticketState == ticketState &&
      other.fixedSha == fixedSha &&
      other.fixedAt == fixedAt &&
      other.prNumber == prNumber &&
      other.sample == sample;

    @override
    int get hashCode =>
        id.hashCode +
        repoId.hashCode +
        repo.hashCode +
        branch.hashCode +
        workflow.hashCode +
        job.hashCode +
        title.hashCode +
        class_.hashCode +
        status.hashCode +
        count.hashCode +
        flakyCount.hashCode +
        firstSeenAt.hashCode +
        lastSeenAt.hashCode +
        firstSha.hashCode +
        lastSha.hashCode +
        occurrences.hashCode +
        ticketKey.hashCode +
        ticketState.hashCode +
        fixedSha.hashCode +
        fixedAt.hashCode +
        prNumber.hashCode +
        sample.hashCode;

  factory CIFailure.fromJson(Map<String, dynamic> json) => _$CIFailureFromJson(json);

  Map<String, dynamic> toJson() => _$CIFailureToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


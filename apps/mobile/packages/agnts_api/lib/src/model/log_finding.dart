//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/log_occurrence.dart';
import 'package:agnts_api/src/model/log_severity.dart';
import 'package:agnts_api/src/model/ticket_state.dart';
import 'package:agnts_api/src/model/log_finding_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'log_finding.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LogFinding {
  /// Returns a new [LogFinding] instance.
  LogFinding({

    required  this.id,

    required  this.service,

    required  this.repoIds,

    required  this.repos,

    required  this.category,

    required  this.detector,

    required  this.class_,

    required  this.severity,

    required  this.title,

    required  this.remediation,

    required  this.status,

    required  this.reason,

    required  this.count,

    required  this.hourCount,

    required  this.firstSeenAt,

    required  this.lastSeenAt,

    required  this.revision,

    required  this.route,

    required  this.secretMask,

    required  this.occurrences,

     this.reportedAt,

    required  this.ticketKey,

     this.ticketState,

     this.fixedSha,

     this.fixedAt,

     this.sample,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'service',
    required: true,
    includeIfNull: false,
  )


  final String service;



  @JsonKey(
    
    name: r'repoIds',
    required: true,
    includeIfNull: false,
  )


  final List<int> repoIds;



  @JsonKey(
    
    name: r'repos',
    required: true,
    includeIfNull: false,
  )


  final List<String> repos;



  @JsonKey(
    
    name: r'category',
    required: true,
    includeIfNull: false,
  )


  final LogFindingCategoryEnum category;



  @JsonKey(
    
    name: r'detector',
    required: true,
    includeIfNull: false,
  )


  final String detector;



      /// code, config, infra, dependency, leak, exposure, weakness, attack or noise
  @JsonKey(
    
    name: r'class',
    required: true,
    includeIfNull: false,
  )


  final String class_;



  @JsonKey(
    
    name: r'severity',
    required: true,
    includeIfNull: false,
  )


  final LogSeverity severity;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'remediation',
    required: true,
    includeIfNull: false,
  )


  final String remediation;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final LogFindingStatus status;



      /// Why a finding that could have been a ticket is only reported
  @JsonKey(
    
    name: r'reason',
    required: true,
    includeIfNull: false,
  )


  final String reason;



  @JsonKey(
    
    name: r'count',
    required: true,
    includeIfNull: false,
  )


  final int count;



  @JsonKey(
    
    name: r'hourCount',
    required: true,
    includeIfNull: false,
  )


  final int hourCount;



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
    
    name: r'revision',
    required: true,
    includeIfNull: false,
  )


  final String revision;



  @JsonKey(
    
    name: r'route',
    required: true,
    includeIfNull: false,
  )


  final String route;



      /// A leaked secret's first and last characters; never the value
  @JsonKey(
    
    name: r'secretMask',
    required: true,
    includeIfNull: false,
  )


  final String secretMask;



  @JsonKey(
    
    name: r'occurrences',
    required: true,
    includeIfNull: false,
  )


  final List<LogOccurrence> occurrences;



  @JsonKey(
    
    name: r'reportedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? reportedAt;



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



      /// Redacted log excerpt (single reads only)
  @JsonKey(
    
    name: r'sample',
    required: false,
    includeIfNull: false,
  )


  final String? sample;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LogFinding &&
      other.id == id &&
      other.service == service &&
      other.repoIds == repoIds &&
      other.repos == repos &&
      other.category == category &&
      other.detector == detector &&
      other.class_ == class_ &&
      other.severity == severity &&
      other.title == title &&
      other.remediation == remediation &&
      other.status == status &&
      other.reason == reason &&
      other.count == count &&
      other.hourCount == hourCount &&
      other.firstSeenAt == firstSeenAt &&
      other.lastSeenAt == lastSeenAt &&
      other.revision == revision &&
      other.route == route &&
      other.secretMask == secretMask &&
      other.occurrences == occurrences &&
      other.reportedAt == reportedAt &&
      other.ticketKey == ticketKey &&
      other.ticketState == ticketState &&
      other.fixedSha == fixedSha &&
      other.fixedAt == fixedAt &&
      other.sample == sample;

    @override
    int get hashCode =>
        id.hashCode +
        service.hashCode +
        repoIds.hashCode +
        repos.hashCode +
        category.hashCode +
        detector.hashCode +
        class_.hashCode +
        severity.hashCode +
        title.hashCode +
        remediation.hashCode +
        status.hashCode +
        reason.hashCode +
        count.hashCode +
        hourCount.hashCode +
        firstSeenAt.hashCode +
        lastSeenAt.hashCode +
        revision.hashCode +
        route.hashCode +
        secretMask.hashCode +
        occurrences.hashCode +
        reportedAt.hashCode +
        ticketKey.hashCode +
        ticketState.hashCode +
        fixedSha.hashCode +
        fixedAt.hashCode +
        sample.hashCode;

  factory LogFinding.fromJson(Map<String, dynamic> json) => _$LogFindingFromJson(json);

  Map<String, dynamic> toJson() => _$LogFindingToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum LogFindingCategoryEnum {
@JsonValue(r'error')
error(r'error'),
@JsonValue(r'security')
security(r'security');

const LogFindingCategoryEnum(this.value);

final String value;

@override
String toString() => value;
}



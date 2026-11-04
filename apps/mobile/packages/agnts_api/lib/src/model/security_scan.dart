//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/sec_rejected_hit.dart';
import 'package:agnts_api/src/model/sec_tool_run.dart';
import 'package:agnts_api/src/model/sec_severity_counts.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'security_scan.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SecurityScan {
  /// Returns a new [SecurityScan] instance.
  SecurityScan({

    required  this.id,

    required  this.repoId,

    required  this.repo,

    required  this.trigger,

    required  this.status,

    required  this.commit,

     this.findingIds,

     this.fullHistory,

    required  this.tools,

    required  this.agent,

    required  this.history,

    required  this.commits,

     this.dbVersions,

    required  this.new_,

    required  this.seen,

    required  this.fixed,

    required  this.reopened,

    required  this.unchecked,

    required  this.rejectedCount,

     this.rejected,

    required  this.open,

    required  this.summary,

    required  this.error,

    required  this.provider,

    required  this.createdAt,

     this.startedAt,

     this.finishedAt,
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



  @JsonKey(
    
    name: r'trigger',
    required: true,
    includeIfNull: false,
  )


  final SecurityScanTriggerEnum trigger;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final SecurityScanStatusEnum status;



  @JsonKey(
    
    name: r'commit',
    required: true,
    includeIfNull: false,
  )


  final String commit;



      /// A verify scan: the findings it checks
  @JsonKey(
    
    name: r'findingIds',
    required: false,
    includeIfNull: false,
  )


  final List<int>? findingIds;



  @JsonKey(
    
    name: r'fullHistory',
    required: false,
    includeIfNull: false,
  )


  final bool? fullHistory;



      /// What actually ran
  @JsonKey(
    
    name: r'tools',
    required: true,
    includeIfNull: false,
  )


  final List<SecToolRun> tools;



      /// done, limit (stopped at its turn or time limit), failed, skipped, or empty when it has not run
  @JsonKey(
    
    name: r'agent',
    required: true,
    includeIfNull: false,
  )


  final String agent;



      /// Commits the secret scan read
  @JsonKey(
    
    name: r'history',
    required: true,
    includeIfNull: false,
  )


  final int history;



      /// Commits the checkout had
  @JsonKey(
    
    name: r'commits',
    required: true,
    includeIfNull: false,
  )


  final int commits;



  @JsonKey(
    
    name: r'dbVersions',
    required: false,
    includeIfNull: false,
  )


  final Map<String, String>? dbVersions;



  @JsonKey(
    
    name: r'new',
    required: true,
    includeIfNull: false,
  )


  final int new_;



  @JsonKey(
    
    name: r'seen',
    required: true,
    includeIfNull: false,
  )


  final int seen;



  @JsonKey(
    
    name: r'fixed',
    required: true,
    includeIfNull: false,
  )


  final int fixed;



  @JsonKey(
    
    name: r'reopened',
    required: true,
    includeIfNull: false,
  )


  final int reopened;



      /// Active findings this scan could not recheck
  @JsonKey(
    
    name: r'unchecked',
    required: true,
    includeIfNull: false,
  )


  final int unchecked;



  @JsonKey(
    
    name: r'rejectedCount',
    required: true,
    includeIfNull: false,
  )


  final int rejectedCount;



  @JsonKey(
    
    name: r'rejected',
    required: false,
    includeIfNull: false,
  )


  final List<SecRejectedHit>? rejected;



  @JsonKey(
    
    name: r'open',
    required: true,
    includeIfNull: false,
  )


  final SecSeverityCounts open;



  @JsonKey(
    
    name: r'summary',
    required: true,
    includeIfNull: false,
  )


  final String summary;



  @JsonKey(
    
    name: r'error',
    required: true,
    includeIfNull: false,
  )


  final String error;



      /// The agent's module (claude, muse)
  @JsonKey(
    
    name: r'provider',
    required: true,
    includeIfNull: false,
  )


  final String provider;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;



  @JsonKey(
    
    name: r'startedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? startedAt;



  @JsonKey(
    
    name: r'finishedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? finishedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SecurityScan &&
      other.id == id &&
      other.repoId == repoId &&
      other.repo == repo &&
      other.trigger == trigger &&
      other.status == status &&
      other.commit == commit &&
      other.findingIds == findingIds &&
      other.fullHistory == fullHistory &&
      other.tools == tools &&
      other.agent == agent &&
      other.history == history &&
      other.commits == commits &&
      other.dbVersions == dbVersions &&
      other.new_ == new_ &&
      other.seen == seen &&
      other.fixed == fixed &&
      other.reopened == reopened &&
      other.unchecked == unchecked &&
      other.rejectedCount == rejectedCount &&
      other.rejected == rejected &&
      other.open == open &&
      other.summary == summary &&
      other.error == error &&
      other.provider == provider &&
      other.createdAt == createdAt &&
      other.startedAt == startedAt &&
      other.finishedAt == finishedAt;

    @override
    int get hashCode =>
        id.hashCode +
        repoId.hashCode +
        repo.hashCode +
        trigger.hashCode +
        status.hashCode +
        commit.hashCode +
        findingIds.hashCode +
        fullHistory.hashCode +
        tools.hashCode +
        agent.hashCode +
        history.hashCode +
        commits.hashCode +
        dbVersions.hashCode +
        new_.hashCode +
        seen.hashCode +
        fixed.hashCode +
        reopened.hashCode +
        unchecked.hashCode +
        rejectedCount.hashCode +
        rejected.hashCode +
        open.hashCode +
        summary.hashCode +
        error.hashCode +
        provider.hashCode +
        createdAt.hashCode +
        startedAt.hashCode +
        finishedAt.hashCode;

  factory SecurityScan.fromJson(Map<String, dynamic> json) => _$SecurityScanFromJson(json);

  Map<String, dynamic> toJson() => _$SecurityScanToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum SecurityScanTriggerEnum {
@JsonValue(r'manual')
manual(r'manual'),
@JsonValue(r'schedule')
schedule(r'schedule'),
@JsonValue(r'verify')
verify(r'verify');

const SecurityScanTriggerEnum(this.value);

final String value;

@override
String toString() => value;
}


enum SecurityScanStatusEnum {
@JsonValue(r'pending')
pending(r'pending'),
@JsonValue(r'running')
running(r'running'),
@JsonValue(r'done')
done(r'done'),
@JsonValue(r'failed')
failed(r'failed'),
@JsonValue(r'cancelled')
cancelled(r'cancelled');

const SecurityScanStatusEnum(this.value);

final String value;

@override
String toString() => value;
}



//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/follow_ups_mode.dart';
import 'package:agnts_api/src/model/blocker.dart';
import 'package:agnts_api/src/model/token_spend.dart';
import 'package:agnts_api/src/model/ticket_kind.dart';
import 'package:agnts_api/src/model/ticket_state.dart';
import 'package:agnts_api/src/model/model_overrides.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ticket.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Ticket {
  /// Returns a new [Ticket] instance.
  Ticket({

    required  this.key,

    required  this.source_,

     this.repoId,

    required  this.title,

    required  this.description,

    required  this.priority,

    required  this.state,

     this.resumeState,

    required  this.revision,

    required  this.turns,

    required  this.branch,

     this.prNumber,

    required  this.prUrl,

     this.assignees,

     this.afterApprove,

     this.held,

     this.askFirst,

    required  this.kind,

    required  this.kindAuto,

     this.postReport,

     this.parentKey,

     this.followUpOf,

     this.suggestFollowUps,

     this.openSuggestions,

     this.blockedBy,

     this.repoName,

     this.models,

     this.since,

     this.stopReason,

     this.mergedAt,

     this.learnState,

     this.reviewState,

     this.previewState,

     this.previewCompare,

     this.canPreview,

     this.spend,

    required  this.createdAt,

    required  this.updatedAt,
  });

  @JsonKey(
    
    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;



  @JsonKey(
    
    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final TicketSource_Enum source_;



  @JsonKey(
    
    name: r'repoId',
    required: false,
    includeIfNull: false,
  )


  final int? repoId;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'description',
    required: true,
    includeIfNull: false,
  )


  final String description;



  @JsonKey(
    
    name: r'priority',
    required: true,
    includeIfNull: false,
  )


  final String priority;



  @JsonKey(
    
    name: r'state',
    required: true,
    includeIfNull: false,
  )


  final TicketState state;



  @JsonKey(
    
    name: r'resumeState',
    required: false,
    includeIfNull: false,
  )


  final TicketState? resumeState;



  @JsonKey(
    
    name: r'revision',
    required: true,
    includeIfNull: false,
  )


  final int revision;



  @JsonKey(
    
    name: r'turns',
    required: true,
    includeIfNull: false,
  )


  final int turns;



  @JsonKey(
    
    name: r'branch',
    required: true,
    includeIfNull: false,
  )


  final String branch;



  @JsonKey(
    
    name: r'prNumber',
    required: false,
    includeIfNull: false,
  )


  final int? prNumber;



  @JsonKey(
    
    name: r'prUrl',
    required: true,
    includeIfNull: false,
  )


  final String prUrl;



      /// Git host usernames the pull request is (or will be) assigned to
  @JsonKey(
    
    name: r'assignees',
    required: false,
    includeIfNull: false,
  )


  final List<String>? assignees;



  @JsonKey(
    
    name: r'afterApprove',
    required: false,
    includeIfNull: false,
  )


  final TicketAfterApproveEnum? afterApprove;



      /// Kept in the queue until started
  @JsonKey(
    
    name: r'held',
    required: false,
    includeIfNull: false,
  )


  final bool? held;



  @JsonKey(
    
    name: r'askFirst',
    required: false,
    includeIfNull: false,
  )


  final bool? askFirst;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final TicketKind kind;



      /// agnts picks the kind; the analysis may still change it
  @JsonKey(
    
    name: r'kindAuto',
    required: true,
    includeIfNull: false,
  )


  final bool kindAuto;



      /// The approved report is posted to the tracker issue
  @JsonKey(
    
    name: r'postReport',
    required: false,
    includeIfNull: false,
  )


  final bool? postReport;



      /// The plan or bug investigation this ticket implements
  @JsonKey(
    
    name: r'parentKey',
    required: false,
    includeIfNull: false,
  )


  final String? parentKey;



      /// The ticket that suggested this one as a follow-up
  @JsonKey(
    
    name: r'followUpOf',
    required: false,
    includeIfNull: false,
  )


  final String? followUpOf;



  @JsonKey(
    
    name: r'suggestFollowUps',
    required: false,
    includeIfNull: false,
  )


  final FollowUpsMode? suggestFollowUps;



      /// Follow-up suggestions waiting for a decision
  @JsonKey(
    
    name: r'openSuggestions',
    required: false,
    includeIfNull: false,
  )


  final int? openSuggestions;



      /// The tickets holding this one's coding back right now (it is in coding with no commit yet). Absent when nothing does.
  @JsonKey(
    
    name: r'blockedBy',
    required: false,
    includeIfNull: false,
  )


  final List<Blocker>? blockedBy;



  @JsonKey(
    
    name: r'repoName',
    required: false,
    includeIfNull: false,
  )


  final String? repoName;



  @JsonKey(
    
    name: r'models',
    required: false,
    includeIfNull: false,
  )


  final ModelOverrides? models;



      /// When the ticket entered its current state
  @JsonKey(
    
    name: r'since',
    required: false,
    includeIfNull: false,
  )


  final DateTime? since;



      /// Why it failed or paused
  @JsonKey(
    
    name: r'stopReason',
    required: false,
    includeIfNull: false,
  )


  final String? stopReason;



  @JsonKey(
    
    name: r'mergedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? mergedAt;



      /// The learn run after push; pending also while it runs
  @JsonKey(
    
    name: r'learnState',
    required: false,
    includeIfNull: false,
  )


  final TicketLearnStateEnum? learnState;



      /// The code review agnts runs beside the human review
  @JsonKey(
    
    name: r'reviewState',
    required: false,
    includeIfNull: false,
  )


  final TicketReviewStateEnum? reviewState;



      /// The screenshots agnts takes beside the human review
  @JsonKey(
    
    name: r'previewState',
    required: false,
    includeIfNull: false,
  )


  final TicketPreviewStateEnum? previewState;



      /// Previews of this ticket also capture the default branch (before shots)
  @JsonKey(
    
    name: r'previewCompare',
    required: false,
    includeIfNull: false,
  )


  final bool? previewCompare;



      /// The ticket's repository has a preview command
  @JsonKey(
    
    name: r'canPreview',
    required: false,
    includeIfNull: false,
  )


  final bool? canPreview;



  @JsonKey(
    
    name: r'spend',
    required: false,
    includeIfNull: false,
  )


  final TokenSpend? spend;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;



  @JsonKey(
    
    name: r'updatedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime updatedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Ticket &&
      other.key == key &&
      other.source_ == source_ &&
      other.repoId == repoId &&
      other.title == title &&
      other.description == description &&
      other.priority == priority &&
      other.state == state &&
      other.resumeState == resumeState &&
      other.revision == revision &&
      other.turns == turns &&
      other.branch == branch &&
      other.prNumber == prNumber &&
      other.prUrl == prUrl &&
      other.assignees == assignees &&
      other.afterApprove == afterApprove &&
      other.held == held &&
      other.askFirst == askFirst &&
      other.kind == kind &&
      other.kindAuto == kindAuto &&
      other.postReport == postReport &&
      other.parentKey == parentKey &&
      other.followUpOf == followUpOf &&
      other.suggestFollowUps == suggestFollowUps &&
      other.openSuggestions == openSuggestions &&
      other.blockedBy == blockedBy &&
      other.repoName == repoName &&
      other.models == models &&
      other.since == since &&
      other.stopReason == stopReason &&
      other.mergedAt == mergedAt &&
      other.learnState == learnState &&
      other.reviewState == reviewState &&
      other.previewState == previewState &&
      other.previewCompare == previewCompare &&
      other.canPreview == canPreview &&
      other.spend == spend &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        key.hashCode +
        source_.hashCode +
        repoId.hashCode +
        title.hashCode +
        description.hashCode +
        priority.hashCode +
        state.hashCode +
        resumeState.hashCode +
        revision.hashCode +
        turns.hashCode +
        branch.hashCode +
        prNumber.hashCode +
        prUrl.hashCode +
        assignees.hashCode +
        afterApprove.hashCode +
        held.hashCode +
        askFirst.hashCode +
        kind.hashCode +
        kindAuto.hashCode +
        postReport.hashCode +
        parentKey.hashCode +
        followUpOf.hashCode +
        suggestFollowUps.hashCode +
        openSuggestions.hashCode +
        blockedBy.hashCode +
        repoName.hashCode +
        models.hashCode +
        since.hashCode +
        stopReason.hashCode +
        mergedAt.hashCode +
        learnState.hashCode +
        reviewState.hashCode +
        previewState.hashCode +
        previewCompare.hashCode +
        canPreview.hashCode +
        spend.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode;

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);

  Map<String, dynamic> toJson() => _$TicketToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum TicketSource_Enum {
@JsonValue(r'jira')
jira(r'jira'),
@JsonValue(r'local')
local(r'local');

const TicketSource_Enum(this.value);

final String value;

@override
String toString() => value;
}


enum TicketAfterApproveEnum {
@JsonValue(r'pr')
pr(r'pr'),
@JsonValue(r'main')
main(r'main');

const TicketAfterApproveEnum(this.value);

final String value;

@override
String toString() => value;
}


/// The learn run after push; pending also while it runs
enum TicketLearnStateEnum {
@JsonValue(r'none')
none(r'none'),
@JsonValue(r'pending')
pending(r'pending'),
@JsonValue(r'done')
done(r'done'),
@JsonValue(r'failed')
failed(r'failed');

const TicketLearnStateEnum(this.value);

final String value;

@override
String toString() => value;
}


/// The code review agnts runs beside the human review
enum TicketReviewStateEnum {
@JsonValue(r'none')
none(r'none'),
@JsonValue(r'pending')
pending(r'pending'),
@JsonValue(r'running')
running(r'running'),
@JsonValue(r'done')
done(r'done'),
@JsonValue(r'failed')
failed(r'failed');

const TicketReviewStateEnum(this.value);

final String value;

@override
String toString() => value;
}


/// The screenshots agnts takes beside the human review
enum TicketPreviewStateEnum {
@JsonValue(r'none')
none(r'none'),
@JsonValue(r'pending')
pending(r'pending'),
@JsonValue(r'running')
running(r'running'),
@JsonValue(r'done')
done(r'done'),
@JsonValue(r'failed')
failed(r'failed');

const TicketPreviewStateEnum(this.value);

final String value;

@override
String toString() => value;
}



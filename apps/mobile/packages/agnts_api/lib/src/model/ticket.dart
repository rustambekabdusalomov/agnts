//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/follow_ups_mode.dart';
import 'package:agnts_api/src/model/blocker.dart';
import 'package:agnts_api/src/model/pull_request.dart';
import 'package:agnts_api/src/model/tracker_update.dart';
import 'package:agnts_api/src/model/token_spend.dart';
import 'package:agnts_api/src/model/repo_group_ref.dart';
import 'package:agnts_api/src/model/wait_reason.dart';
import 'package:agnts_api/src/model/ticket_repo_state.dart';
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

     this.ticketNumber,

    required  this.source_,

     this.repoId,

     this.repos,

     this.group,

     this.partlyMerged,

    required  this.title,

    required  this.description,

    required  this.priority,

    required  this.state,

     this.resumeState,

    required  this.revision,

     this.replayOf,

    required  this.turns,

    required  this.branch,

     this.headSha,

     this.prNumber,

    required  this.prUrl,

     this.ciFixes,

     this.assignees,

     this.afterApprove,

     this.held,

     this.askFirst,

    required  this.kind,

    required  this.kindAuto,

    required  this.skipChecks,

     this.benchmark,

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

     this.pull,

     this.trackerUpdate,

     this.learnState,

     this.reviewState,

     this.previewState,

     this.previewCompare,

     this.canPreview,

     this.continueTo,

     this.canStartOver,

     this.savedWork,

     this.spend,

     this.waitReason,

     this.waitMessage,

     this.queuedAt,

     this.memberId,

     this.member,

     this.createdBy,

    required  this.createdAt,

    required  this.updatedAt,
  });

  @JsonKey(
    
    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;



      /// The team's number for the work (AMANAT-2288), used in branch and commit names; absent uses key
  @JsonKey(
    
    name: r'ticketNumber',
    required: false,
    includeIfNull: false,
  )


  final String? ticketNumber;



  @JsonKey(
    
    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final TicketSource_Enum source_;



      /// The primary repository; repos lists all of them
  @JsonKey(
    
    name: r'repoId',
    required: false,
    includeIfNull: false,
  )


  final int? repoId;



      /// Every repository the ticket works in, the primary first, with its branch and pull request
  @JsonKey(
    
    name: r'repos',
    required: false,
    includeIfNull: false,
  )


  final List<TicketRepoState>? repos;



  @JsonKey(
    
    name: r'group',
    required: false,
    includeIfNull: false,
  )


  final RepoGroupRef? group;



      /// Some pull requests merged and at least one closed without a merge
  @JsonKey(
    
    name: r'partlyMerged',
    required: false,
    includeIfNull: false,
  )


  final bool? partlyMerged;



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



      /// For a replay: the done ticket it re-runs. Replays are never pushed.
  @JsonKey(
    
    name: r'replayOf',
    required: false,
    includeIfNull: false,
  )


  final String? replayOf;



  @JsonKey(
    
    name: r'turns',
    required: true,
    includeIfNull: false,
  )


  final int turns;



      /// The primary repository's branch (see repos)
  @JsonKey(
    
    name: r'branch',
    required: true,
    includeIfNull: false,
  )


  final String branch;



      /// The reviewed commit: the branch head agnts committed (in the primary repository; see repos), or for a pull request review the head agnts reviewed
  @JsonKey(
    
    name: r'headSha',
    required: false,
    includeIfNull: false,
  )


  final String? headSha;



      /// The primary repository's pull request (see repos)
  @JsonKey(
    
    name: r'prNumber',
    required: false,
    includeIfNull: false,
  )


  final int? prNumber;



      /// The primary repository's pull request (see repos)
  @JsonKey(
    
    name: r'prUrl',
    required: true,
    includeIfNull: false,
  )


  final String prUrl;



      /// Rounds a red CI check sent the pull request back to coding
  @JsonKey(
    
    name: r'ciFixes',
    required: false,
    includeIfNull: false,
  )


  final int? ciFixes;



      /// Git host usernames the pull request is (or will be) assigned to
  @JsonKey(
    
    name: r'assignees',
    required: false,
    includeIfNull: false,
  )


  final List<String>? assignees;



      /// pr: open a pull request (a review: merge it); main: push to the default branch; none: a review asked for from the pull request page, which approving finishes without merging
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



      /// coding runs skip the checks and go to review on the code alone (set with retryTicket or requestChanges)
  @JsonKey(
    
    name: r'skipChecks',
    required: true,
    includeIfNull: false,
  )


  final bool skipChecks;



      /// A merged ticket in the benchmark that changes to agnts are replayed against (setTicketBenchmark)
  @JsonKey(
    
    name: r'benchmark',
    required: false,
    includeIfNull: false,
  )


  final bool? benchmark;



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



  @JsonKey(
    
    name: r'pull',
    required: false,
    includeIfNull: false,
  )


  final PullRequest? pull;



  @JsonKey(
    
    name: r'trackerUpdate',
    required: false,
    includeIfNull: false,
  )


  final TrackerUpdate? trackerUpdate;



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
    
    name: r'continueTo',
    required: false,
    includeIfNull: false,
  )


  final TicketState? continueTo;



      /// This rejected ticket can start over from scratch (nothing of it was pushed); continueTo, when set, is where Continue sends it without a note
  @JsonKey(
    
    name: r'canStartOver',
    required: false,
    includeIfNull: false,
  )


  final bool? canStartOver;



      /// Ticket page of a stopped (failed, rate-limited or rejected) ticket: the files of the unfinished change its last coding run left, which the next coding run picks up again (paths from /workspace). Absent when there is none.
  @JsonKey(
    
    name: r'savedWork',
    required: false,
    includeIfNull: false,
  )


  final List<String>? savedWork;



  @JsonKey(
    
    name: r'spend',
    required: false,
    includeIfNull: false,
  )


  final TokenSpend? spend;



  @JsonKey(
    
    name: r'waitReason',
    required: false,
    includeIfNull: false,
  )


  final WaitReason? waitReason;



      /// Why it waits, in a sentence
  @JsonKey(
    
    name: r'waitMessage',
    required: false,
    includeIfNull: false,
  )


  final String? waitMessage;



      /// When it started waiting for a worker
  @JsonKey(
    
    name: r'queuedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? queuedAt;



      /// Whose ticket it is (per-member Claude mode runs on their account)
  @JsonKey(
    
    name: r'memberId',
    required: false,
    includeIfNull: false,
  )


  final int? memberId;



      /// The member's username
  @JsonKey(
    
    name: r'member',
    required: false,
    includeIfNull: false,
  )


  final String? member;



      /// Who created it; absent for webhooks and agnts
  @JsonKey(
    
    name: r'createdBy',
    required: false,
    includeIfNull: false,
  )


  final String? createdBy;



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
      other.ticketNumber == ticketNumber &&
      other.source_ == source_ &&
      other.repoId == repoId &&
      other.repos == repos &&
      other.group == group &&
      other.partlyMerged == partlyMerged &&
      other.title == title &&
      other.description == description &&
      other.priority == priority &&
      other.state == state &&
      other.resumeState == resumeState &&
      other.revision == revision &&
      other.replayOf == replayOf &&
      other.turns == turns &&
      other.branch == branch &&
      other.headSha == headSha &&
      other.prNumber == prNumber &&
      other.prUrl == prUrl &&
      other.ciFixes == ciFixes &&
      other.assignees == assignees &&
      other.afterApprove == afterApprove &&
      other.held == held &&
      other.askFirst == askFirst &&
      other.kind == kind &&
      other.kindAuto == kindAuto &&
      other.skipChecks == skipChecks &&
      other.benchmark == benchmark &&
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
      other.pull == pull &&
      other.trackerUpdate == trackerUpdate &&
      other.learnState == learnState &&
      other.reviewState == reviewState &&
      other.previewState == previewState &&
      other.previewCompare == previewCompare &&
      other.canPreview == canPreview &&
      other.continueTo == continueTo &&
      other.canStartOver == canStartOver &&
      other.savedWork == savedWork &&
      other.spend == spend &&
      other.waitReason == waitReason &&
      other.waitMessage == waitMessage &&
      other.queuedAt == queuedAt &&
      other.memberId == memberId &&
      other.member == member &&
      other.createdBy == createdBy &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        key.hashCode +
        ticketNumber.hashCode +
        source_.hashCode +
        repoId.hashCode +
        repos.hashCode +
        group.hashCode +
        partlyMerged.hashCode +
        title.hashCode +
        description.hashCode +
        priority.hashCode +
        state.hashCode +
        resumeState.hashCode +
        revision.hashCode +
        replayOf.hashCode +
        turns.hashCode +
        branch.hashCode +
        headSha.hashCode +
        prNumber.hashCode +
        prUrl.hashCode +
        ciFixes.hashCode +
        assignees.hashCode +
        afterApprove.hashCode +
        held.hashCode +
        askFirst.hashCode +
        kind.hashCode +
        kindAuto.hashCode +
        skipChecks.hashCode +
        benchmark.hashCode +
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
        pull.hashCode +
        trackerUpdate.hashCode +
        learnState.hashCode +
        reviewState.hashCode +
        previewState.hashCode +
        previewCompare.hashCode +
        canPreview.hashCode +
        continueTo.hashCode +
        canStartOver.hashCode +
        savedWork.hashCode +
        spend.hashCode +
        waitReason.hashCode +
        waitMessage.hashCode +
        queuedAt.hashCode +
        memberId.hashCode +
        member.hashCode +
        createdBy.hashCode +
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
@JsonValue(r'plane')
plane(r'plane'),
@JsonValue(r'local')
local(r'local'),
@JsonValue(r'git')
git(r'git'),
@JsonValue(r'ci')
ci(r'ci'),
@JsonValue(r'logs')
logs(r'logs'),
@JsonValue(r'security')
security(r'security');

const TicketSource_Enum(this.value);

final String value;

@override
String toString() => value;
}


/// pr: open a pull request (a review: merge it); main: push to the default branch; none: a review asked for from the pull request page, which approving finishes without merging
enum TicketAfterApproveEnum {
@JsonValue(r'pr')
pr(r'pr'),
@JsonValue(r'main')
main(r'main'),
@JsonValue(r'none')
none(r'none');

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



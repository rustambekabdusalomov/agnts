// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TicketCWProxy {
  Ticket key(String key);

  Ticket ticketNumber(String? ticketNumber);

  Ticket source_(TicketSource_Enum source_);

  Ticket repoId(int? repoId);

  Ticket repos(List<TicketRepoState>? repos);

  Ticket group(RepoGroupRef? group);

  Ticket partlyMerged(bool? partlyMerged);

  Ticket title(String title);

  Ticket description(String description);

  Ticket priority(String priority);

  Ticket state(TicketState state);

  Ticket resumeState(TicketState? resumeState);

  Ticket revision(int revision);

  Ticket replayOf(String? replayOf);

  Ticket turns(int turns);

  Ticket branch(String branch);

  Ticket headSha(String? headSha);

  Ticket prNumber(int? prNumber);

  Ticket prUrl(String prUrl);

  Ticket ciFixes(int? ciFixes);

  Ticket assignees(List<String>? assignees);

  Ticket afterApprove(TicketAfterApproveEnum? afterApprove);

  Ticket held(bool? held);

  Ticket askFirst(bool? askFirst);

  Ticket kind(TicketKind kind);

  Ticket kindAuto(bool kindAuto);

  Ticket skipChecks(bool skipChecks);

  Ticket benchmark(bool? benchmark);

  Ticket postReport(bool? postReport);

  Ticket parentKey(String? parentKey);

  Ticket followUpOf(String? followUpOf);

  Ticket suggestFollowUps(FollowUpsMode? suggestFollowUps);

  Ticket openSuggestions(int? openSuggestions);

  Ticket blockedBy(List<Blocker>? blockedBy);

  Ticket repoName(String? repoName);

  Ticket models(ModelOverrides? models);

  Ticket since(DateTime? since);

  Ticket stopReason(String? stopReason);

  Ticket mergedAt(DateTime? mergedAt);

  Ticket pull(PullRequest? pull);

  Ticket trackerUpdate(TrackerUpdate? trackerUpdate);

  Ticket learnState(TicketLearnStateEnum? learnState);

  Ticket reviewState(TicketReviewStateEnum? reviewState);

  Ticket previewState(TicketPreviewStateEnum? previewState);

  Ticket previewCompare(bool? previewCompare);

  Ticket canPreview(bool? canPreview);

  Ticket continueTo(TicketState? continueTo);

  Ticket canStartOver(bool? canStartOver);

  Ticket savedWork(List<String>? savedWork);

  Ticket spend(TokenSpend? spend);

  Ticket waitReason(WaitReason? waitReason);

  Ticket waitMessage(String? waitMessage);

  Ticket queuedAt(DateTime? queuedAt);

  Ticket memberId(int? memberId);

  Ticket member(String? member);

  Ticket createdBy(String? createdBy);

  Ticket createdAt(DateTime createdAt);

  Ticket updatedAt(DateTime updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Ticket(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Ticket(...).copyWith(id: 12, name: "My name")
  /// ````
  Ticket call({
    String key,
    String? ticketNumber,
    TicketSource_Enum source_,
    int? repoId,
    List<TicketRepoState>? repos,
    RepoGroupRef? group,
    bool? partlyMerged,
    String title,
    String description,
    String priority,
    TicketState state,
    TicketState? resumeState,
    int revision,
    String? replayOf,
    int turns,
    String branch,
    String? headSha,
    int? prNumber,
    String prUrl,
    int? ciFixes,
    List<String>? assignees,
    TicketAfterApproveEnum? afterApprove,
    bool? held,
    bool? askFirst,
    TicketKind kind,
    bool kindAuto,
    bool skipChecks,
    bool? benchmark,
    bool? postReport,
    String? parentKey,
    String? followUpOf,
    FollowUpsMode? suggestFollowUps,
    int? openSuggestions,
    List<Blocker>? blockedBy,
    String? repoName,
    ModelOverrides? models,
    DateTime? since,
    String? stopReason,
    DateTime? mergedAt,
    PullRequest? pull,
    TrackerUpdate? trackerUpdate,
    TicketLearnStateEnum? learnState,
    TicketReviewStateEnum? reviewState,
    TicketPreviewStateEnum? previewState,
    bool? previewCompare,
    bool? canPreview,
    TicketState? continueTo,
    bool? canStartOver,
    List<String>? savedWork,
    TokenSpend? spend,
    WaitReason? waitReason,
    String? waitMessage,
    DateTime? queuedAt,
    int? memberId,
    String? member,
    String? createdBy,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTicket.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTicket.copyWith.fieldName(...)`
class _$TicketCWProxyImpl implements _$TicketCWProxy {
  const _$TicketCWProxyImpl(this._value);

  final Ticket _value;

  @override
  Ticket key(String key) => this(key: key);

  @override
  Ticket ticketNumber(String? ticketNumber) => this(ticketNumber: ticketNumber);

  @override
  Ticket source_(TicketSource_Enum source_) => this(source_: source_);

  @override
  Ticket repoId(int? repoId) => this(repoId: repoId);

  @override
  Ticket repos(List<TicketRepoState>? repos) => this(repos: repos);

  @override
  Ticket group(RepoGroupRef? group) => this(group: group);

  @override
  Ticket partlyMerged(bool? partlyMerged) => this(partlyMerged: partlyMerged);

  @override
  Ticket title(String title) => this(title: title);

  @override
  Ticket description(String description) => this(description: description);

  @override
  Ticket priority(String priority) => this(priority: priority);

  @override
  Ticket state(TicketState state) => this(state: state);

  @override
  Ticket resumeState(TicketState? resumeState) =>
      this(resumeState: resumeState);

  @override
  Ticket revision(int revision) => this(revision: revision);

  @override
  Ticket replayOf(String? replayOf) => this(replayOf: replayOf);

  @override
  Ticket turns(int turns) => this(turns: turns);

  @override
  Ticket branch(String branch) => this(branch: branch);

  @override
  Ticket headSha(String? headSha) => this(headSha: headSha);

  @override
  Ticket prNumber(int? prNumber) => this(prNumber: prNumber);

  @override
  Ticket prUrl(String prUrl) => this(prUrl: prUrl);

  @override
  Ticket ciFixes(int? ciFixes) => this(ciFixes: ciFixes);

  @override
  Ticket assignees(List<String>? assignees) => this(assignees: assignees);

  @override
  Ticket afterApprove(TicketAfterApproveEnum? afterApprove) =>
      this(afterApprove: afterApprove);

  @override
  Ticket held(bool? held) => this(held: held);

  @override
  Ticket askFirst(bool? askFirst) => this(askFirst: askFirst);

  @override
  Ticket kind(TicketKind kind) => this(kind: kind);

  @override
  Ticket kindAuto(bool kindAuto) => this(kindAuto: kindAuto);

  @override
  Ticket skipChecks(bool skipChecks) => this(skipChecks: skipChecks);

  @override
  Ticket benchmark(bool? benchmark) => this(benchmark: benchmark);

  @override
  Ticket postReport(bool? postReport) => this(postReport: postReport);

  @override
  Ticket parentKey(String? parentKey) => this(parentKey: parentKey);

  @override
  Ticket followUpOf(String? followUpOf) => this(followUpOf: followUpOf);

  @override
  Ticket suggestFollowUps(FollowUpsMode? suggestFollowUps) =>
      this(suggestFollowUps: suggestFollowUps);

  @override
  Ticket openSuggestions(int? openSuggestions) =>
      this(openSuggestions: openSuggestions);

  @override
  Ticket blockedBy(List<Blocker>? blockedBy) => this(blockedBy: blockedBy);

  @override
  Ticket repoName(String? repoName) => this(repoName: repoName);

  @override
  Ticket models(ModelOverrides? models) => this(models: models);

  @override
  Ticket since(DateTime? since) => this(since: since);

  @override
  Ticket stopReason(String? stopReason) => this(stopReason: stopReason);

  @override
  Ticket mergedAt(DateTime? mergedAt) => this(mergedAt: mergedAt);

  @override
  Ticket pull(PullRequest? pull) => this(pull: pull);

  @override
  Ticket trackerUpdate(TrackerUpdate? trackerUpdate) =>
      this(trackerUpdate: trackerUpdate);

  @override
  Ticket learnState(TicketLearnStateEnum? learnState) =>
      this(learnState: learnState);

  @override
  Ticket reviewState(TicketReviewStateEnum? reviewState) =>
      this(reviewState: reviewState);

  @override
  Ticket previewState(TicketPreviewStateEnum? previewState) =>
      this(previewState: previewState);

  @override
  Ticket previewCompare(bool? previewCompare) =>
      this(previewCompare: previewCompare);

  @override
  Ticket canPreview(bool? canPreview) => this(canPreview: canPreview);

  @override
  Ticket continueTo(TicketState? continueTo) => this(continueTo: continueTo);

  @override
  Ticket canStartOver(bool? canStartOver) => this(canStartOver: canStartOver);

  @override
  Ticket savedWork(List<String>? savedWork) => this(savedWork: savedWork);

  @override
  Ticket spend(TokenSpend? spend) => this(spend: spend);

  @override
  Ticket waitReason(WaitReason? waitReason) => this(waitReason: waitReason);

  @override
  Ticket waitMessage(String? waitMessage) => this(waitMessage: waitMessage);

  @override
  Ticket queuedAt(DateTime? queuedAt) => this(queuedAt: queuedAt);

  @override
  Ticket memberId(int? memberId) => this(memberId: memberId);

  @override
  Ticket member(String? member) => this(member: member);

  @override
  Ticket createdBy(String? createdBy) => this(createdBy: createdBy);

  @override
  Ticket createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  Ticket updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Ticket(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Ticket(...).copyWith(id: 12, name: "My name")
  /// ````
  Ticket call({
    Object? key = const $CopyWithPlaceholder(),
    Object? ticketNumber = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
    Object? repoId = const $CopyWithPlaceholder(),
    Object? repos = const $CopyWithPlaceholder(),
    Object? group = const $CopyWithPlaceholder(),
    Object? partlyMerged = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? priority = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? resumeState = const $CopyWithPlaceholder(),
    Object? revision = const $CopyWithPlaceholder(),
    Object? replayOf = const $CopyWithPlaceholder(),
    Object? turns = const $CopyWithPlaceholder(),
    Object? branch = const $CopyWithPlaceholder(),
    Object? headSha = const $CopyWithPlaceholder(),
    Object? prNumber = const $CopyWithPlaceholder(),
    Object? prUrl = const $CopyWithPlaceholder(),
    Object? ciFixes = const $CopyWithPlaceholder(),
    Object? assignees = const $CopyWithPlaceholder(),
    Object? afterApprove = const $CopyWithPlaceholder(),
    Object? held = const $CopyWithPlaceholder(),
    Object? askFirst = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? kindAuto = const $CopyWithPlaceholder(),
    Object? skipChecks = const $CopyWithPlaceholder(),
    Object? benchmark = const $CopyWithPlaceholder(),
    Object? postReport = const $CopyWithPlaceholder(),
    Object? parentKey = const $CopyWithPlaceholder(),
    Object? followUpOf = const $CopyWithPlaceholder(),
    Object? suggestFollowUps = const $CopyWithPlaceholder(),
    Object? openSuggestions = const $CopyWithPlaceholder(),
    Object? blockedBy = const $CopyWithPlaceholder(),
    Object? repoName = const $CopyWithPlaceholder(),
    Object? models = const $CopyWithPlaceholder(),
    Object? since = const $CopyWithPlaceholder(),
    Object? stopReason = const $CopyWithPlaceholder(),
    Object? mergedAt = const $CopyWithPlaceholder(),
    Object? pull = const $CopyWithPlaceholder(),
    Object? trackerUpdate = const $CopyWithPlaceholder(),
    Object? learnState = const $CopyWithPlaceholder(),
    Object? reviewState = const $CopyWithPlaceholder(),
    Object? previewState = const $CopyWithPlaceholder(),
    Object? previewCompare = const $CopyWithPlaceholder(),
    Object? canPreview = const $CopyWithPlaceholder(),
    Object? continueTo = const $CopyWithPlaceholder(),
    Object? canStartOver = const $CopyWithPlaceholder(),
    Object? savedWork = const $CopyWithPlaceholder(),
    Object? spend = const $CopyWithPlaceholder(),
    Object? waitReason = const $CopyWithPlaceholder(),
    Object? waitMessage = const $CopyWithPlaceholder(),
    Object? queuedAt = const $CopyWithPlaceholder(),
    Object? memberId = const $CopyWithPlaceholder(),
    Object? member = const $CopyWithPlaceholder(),
    Object? createdBy = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return Ticket(
      key: key == const $CopyWithPlaceholder()
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
      ticketNumber: ticketNumber == const $CopyWithPlaceholder()
          ? _value.ticketNumber
          // ignore: cast_nullable_to_non_nullable
          : ticketNumber as String?,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as TicketSource_Enum,
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int?,
      repos: repos == const $CopyWithPlaceholder()
          ? _value.repos
          // ignore: cast_nullable_to_non_nullable
          : repos as List<TicketRepoState>?,
      group: group == const $CopyWithPlaceholder()
          ? _value.group
          // ignore: cast_nullable_to_non_nullable
          : group as RepoGroupRef?,
      partlyMerged: partlyMerged == const $CopyWithPlaceholder()
          ? _value.partlyMerged
          // ignore: cast_nullable_to_non_nullable
          : partlyMerged as bool?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String,
      priority: priority == const $CopyWithPlaceholder()
          ? _value.priority
          // ignore: cast_nullable_to_non_nullable
          : priority as String,
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as TicketState,
      resumeState: resumeState == const $CopyWithPlaceholder()
          ? _value.resumeState
          // ignore: cast_nullable_to_non_nullable
          : resumeState as TicketState?,
      revision: revision == const $CopyWithPlaceholder()
          ? _value.revision
          // ignore: cast_nullable_to_non_nullable
          : revision as int,
      replayOf: replayOf == const $CopyWithPlaceholder()
          ? _value.replayOf
          // ignore: cast_nullable_to_non_nullable
          : replayOf as String?,
      turns: turns == const $CopyWithPlaceholder()
          ? _value.turns
          // ignore: cast_nullable_to_non_nullable
          : turns as int,
      branch: branch == const $CopyWithPlaceholder()
          ? _value.branch
          // ignore: cast_nullable_to_non_nullable
          : branch as String,
      headSha: headSha == const $CopyWithPlaceholder()
          ? _value.headSha
          // ignore: cast_nullable_to_non_nullable
          : headSha as String?,
      prNumber: prNumber == const $CopyWithPlaceholder()
          ? _value.prNumber
          // ignore: cast_nullable_to_non_nullable
          : prNumber as int?,
      prUrl: prUrl == const $CopyWithPlaceholder()
          ? _value.prUrl
          // ignore: cast_nullable_to_non_nullable
          : prUrl as String,
      ciFixes: ciFixes == const $CopyWithPlaceholder()
          ? _value.ciFixes
          // ignore: cast_nullable_to_non_nullable
          : ciFixes as int?,
      assignees: assignees == const $CopyWithPlaceholder()
          ? _value.assignees
          // ignore: cast_nullable_to_non_nullable
          : assignees as List<String>?,
      afterApprove: afterApprove == const $CopyWithPlaceholder()
          ? _value.afterApprove
          // ignore: cast_nullable_to_non_nullable
          : afterApprove as TicketAfterApproveEnum?,
      held: held == const $CopyWithPlaceholder()
          ? _value.held
          // ignore: cast_nullable_to_non_nullable
          : held as bool?,
      askFirst: askFirst == const $CopyWithPlaceholder()
          ? _value.askFirst
          // ignore: cast_nullable_to_non_nullable
          : askFirst as bool?,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as TicketKind,
      kindAuto: kindAuto == const $CopyWithPlaceholder()
          ? _value.kindAuto
          // ignore: cast_nullable_to_non_nullable
          : kindAuto as bool,
      skipChecks: skipChecks == const $CopyWithPlaceholder()
          ? _value.skipChecks
          // ignore: cast_nullable_to_non_nullable
          : skipChecks as bool,
      benchmark: benchmark == const $CopyWithPlaceholder()
          ? _value.benchmark
          // ignore: cast_nullable_to_non_nullable
          : benchmark as bool?,
      postReport: postReport == const $CopyWithPlaceholder()
          ? _value.postReport
          // ignore: cast_nullable_to_non_nullable
          : postReport as bool?,
      parentKey: parentKey == const $CopyWithPlaceholder()
          ? _value.parentKey
          // ignore: cast_nullable_to_non_nullable
          : parentKey as String?,
      followUpOf: followUpOf == const $CopyWithPlaceholder()
          ? _value.followUpOf
          // ignore: cast_nullable_to_non_nullable
          : followUpOf as String?,
      suggestFollowUps: suggestFollowUps == const $CopyWithPlaceholder()
          ? _value.suggestFollowUps
          // ignore: cast_nullable_to_non_nullable
          : suggestFollowUps as FollowUpsMode?,
      openSuggestions: openSuggestions == const $CopyWithPlaceholder()
          ? _value.openSuggestions
          // ignore: cast_nullable_to_non_nullable
          : openSuggestions as int?,
      blockedBy: blockedBy == const $CopyWithPlaceholder()
          ? _value.blockedBy
          // ignore: cast_nullable_to_non_nullable
          : blockedBy as List<Blocker>?,
      repoName: repoName == const $CopyWithPlaceholder()
          ? _value.repoName
          // ignore: cast_nullable_to_non_nullable
          : repoName as String?,
      models: models == const $CopyWithPlaceholder()
          ? _value.models
          // ignore: cast_nullable_to_non_nullable
          : models as ModelOverrides?,
      since: since == const $CopyWithPlaceholder()
          ? _value.since
          // ignore: cast_nullable_to_non_nullable
          : since as DateTime?,
      stopReason: stopReason == const $CopyWithPlaceholder()
          ? _value.stopReason
          // ignore: cast_nullable_to_non_nullable
          : stopReason as String?,
      mergedAt: mergedAt == const $CopyWithPlaceholder()
          ? _value.mergedAt
          // ignore: cast_nullable_to_non_nullable
          : mergedAt as DateTime?,
      pull: pull == const $CopyWithPlaceholder()
          ? _value.pull
          // ignore: cast_nullable_to_non_nullable
          : pull as PullRequest?,
      trackerUpdate: trackerUpdate == const $CopyWithPlaceholder()
          ? _value.trackerUpdate
          // ignore: cast_nullable_to_non_nullable
          : trackerUpdate as TrackerUpdate?,
      learnState: learnState == const $CopyWithPlaceholder()
          ? _value.learnState
          // ignore: cast_nullable_to_non_nullable
          : learnState as TicketLearnStateEnum?,
      reviewState: reviewState == const $CopyWithPlaceholder()
          ? _value.reviewState
          // ignore: cast_nullable_to_non_nullable
          : reviewState as TicketReviewStateEnum?,
      previewState: previewState == const $CopyWithPlaceholder()
          ? _value.previewState
          // ignore: cast_nullable_to_non_nullable
          : previewState as TicketPreviewStateEnum?,
      previewCompare: previewCompare == const $CopyWithPlaceholder()
          ? _value.previewCompare
          // ignore: cast_nullable_to_non_nullable
          : previewCompare as bool?,
      canPreview: canPreview == const $CopyWithPlaceholder()
          ? _value.canPreview
          // ignore: cast_nullable_to_non_nullable
          : canPreview as bool?,
      continueTo: continueTo == const $CopyWithPlaceholder()
          ? _value.continueTo
          // ignore: cast_nullable_to_non_nullable
          : continueTo as TicketState?,
      canStartOver: canStartOver == const $CopyWithPlaceholder()
          ? _value.canStartOver
          // ignore: cast_nullable_to_non_nullable
          : canStartOver as bool?,
      savedWork: savedWork == const $CopyWithPlaceholder()
          ? _value.savedWork
          // ignore: cast_nullable_to_non_nullable
          : savedWork as List<String>?,
      spend: spend == const $CopyWithPlaceholder()
          ? _value.spend
          // ignore: cast_nullable_to_non_nullable
          : spend as TokenSpend?,
      waitReason: waitReason == const $CopyWithPlaceholder()
          ? _value.waitReason
          // ignore: cast_nullable_to_non_nullable
          : waitReason as WaitReason?,
      waitMessage: waitMessage == const $CopyWithPlaceholder()
          ? _value.waitMessage
          // ignore: cast_nullable_to_non_nullable
          : waitMessage as String?,
      queuedAt: queuedAt == const $CopyWithPlaceholder()
          ? _value.queuedAt
          // ignore: cast_nullable_to_non_nullable
          : queuedAt as DateTime?,
      memberId: memberId == const $CopyWithPlaceholder()
          ? _value.memberId
          // ignore: cast_nullable_to_non_nullable
          : memberId as int?,
      member: member == const $CopyWithPlaceholder()
          ? _value.member
          // ignore: cast_nullable_to_non_nullable
          : member as String?,
      createdBy: createdBy == const $CopyWithPlaceholder()
          ? _value.createdBy
          // ignore: cast_nullable_to_non_nullable
          : createdBy as String?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
    );
  }
}

extension $TicketCopyWith on Ticket {
  /// Returns a callable class that can be used as follows: `instanceOfTicket.copyWith(...)` or like so:`instanceOfTicket.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TicketCWProxy get copyWith => _$TicketCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ticket _$TicketFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('Ticket', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'key',
      'source',
      'title',
      'description',
      'priority',
      'state',
      'revision',
      'turns',
      'branch',
      'prUrl',
      'kind',
      'kindAuto',
      'skipChecks',
      'createdAt',
      'updatedAt',
    ],
  );
  final val = Ticket(
    key: $checkedConvert('key', (v) => v as String),
    ticketNumber: $checkedConvert('ticketNumber', (v) => v as String?),
    source_: $checkedConvert(
      'source',
      (v) => $enumDecode(_$TicketSource_EnumEnumMap, v),
    ),
    repoId: $checkedConvert('repoId', (v) => (v as num?)?.toInt()),
    repos: $checkedConvert(
      'repos',
      (v) => (v as List<dynamic>?)
          ?.map((e) => TicketRepoState.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    group: $checkedConvert(
      'group',
      (v) =>
          v == null ? null : RepoGroupRef.fromJson(v as Map<String, dynamic>),
    ),
    partlyMerged: $checkedConvert('partlyMerged', (v) => v as bool?),
    title: $checkedConvert('title', (v) => v as String),
    description: $checkedConvert('description', (v) => v as String),
    priority: $checkedConvert('priority', (v) => v as String),
    state: $checkedConvert(
      'state',
      (v) => $enumDecode(_$TicketStateEnumMap, v),
    ),
    resumeState: $checkedConvert(
      'resumeState',
      (v) => $enumDecodeNullable(_$TicketStateEnumMap, v),
    ),
    revision: $checkedConvert('revision', (v) => (v as num).toInt()),
    replayOf: $checkedConvert('replayOf', (v) => v as String?),
    turns: $checkedConvert('turns', (v) => (v as num).toInt()),
    branch: $checkedConvert('branch', (v) => v as String),
    headSha: $checkedConvert('headSha', (v) => v as String?),
    prNumber: $checkedConvert('prNumber', (v) => (v as num?)?.toInt()),
    prUrl: $checkedConvert('prUrl', (v) => v as String),
    ciFixes: $checkedConvert('ciFixes', (v) => (v as num?)?.toInt()),
    assignees: $checkedConvert(
      'assignees',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    afterApprove: $checkedConvert(
      'afterApprove',
      (v) => $enumDecodeNullable(_$TicketAfterApproveEnumEnumMap, v),
    ),
    held: $checkedConvert('held', (v) => v as bool?),
    askFirst: $checkedConvert('askFirst', (v) => v as bool?),
    kind: $checkedConvert('kind', (v) => $enumDecode(_$TicketKindEnumMap, v)),
    kindAuto: $checkedConvert('kindAuto', (v) => v as bool),
    skipChecks: $checkedConvert('skipChecks', (v) => v as bool),
    benchmark: $checkedConvert('benchmark', (v) => v as bool?),
    postReport: $checkedConvert('postReport', (v) => v as bool?),
    parentKey: $checkedConvert('parentKey', (v) => v as String?),
    followUpOf: $checkedConvert('followUpOf', (v) => v as String?),
    suggestFollowUps: $checkedConvert(
      'suggestFollowUps',
      (v) => $enumDecodeNullable(_$FollowUpsModeEnumMap, v),
    ),
    openSuggestions: $checkedConvert(
      'openSuggestions',
      (v) => (v as num?)?.toInt(),
    ),
    blockedBy: $checkedConvert(
      'blockedBy',
      (v) => (v as List<dynamic>?)
          ?.map((e) => Blocker.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    repoName: $checkedConvert('repoName', (v) => v as String?),
    models: $checkedConvert(
      'models',
      (v) =>
          v == null ? null : ModelOverrides.fromJson(v as Map<String, dynamic>),
    ),
    since: $checkedConvert(
      'since',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    stopReason: $checkedConvert('stopReason', (v) => v as String?),
    mergedAt: $checkedConvert(
      'mergedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    pull: $checkedConvert(
      'pull',
      (v) => v == null ? null : PullRequest.fromJson(v as Map<String, dynamic>),
    ),
    trackerUpdate: $checkedConvert(
      'trackerUpdate',
      (v) =>
          v == null ? null : TrackerUpdate.fromJson(v as Map<String, dynamic>),
    ),
    learnState: $checkedConvert(
      'learnState',
      (v) => $enumDecodeNullable(_$TicketLearnStateEnumEnumMap, v),
    ),
    reviewState: $checkedConvert(
      'reviewState',
      (v) => $enumDecodeNullable(_$TicketReviewStateEnumEnumMap, v),
    ),
    previewState: $checkedConvert(
      'previewState',
      (v) => $enumDecodeNullable(_$TicketPreviewStateEnumEnumMap, v),
    ),
    previewCompare: $checkedConvert('previewCompare', (v) => v as bool?),
    canPreview: $checkedConvert('canPreview', (v) => v as bool?),
    continueTo: $checkedConvert(
      'continueTo',
      (v) => $enumDecodeNullable(_$TicketStateEnumMap, v),
    ),
    canStartOver: $checkedConvert('canStartOver', (v) => v as bool?),
    savedWork: $checkedConvert(
      'savedWork',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    spend: $checkedConvert(
      'spend',
      (v) => v == null ? null : TokenSpend.fromJson(v as Map<String, dynamic>),
    ),
    waitReason: $checkedConvert(
      'waitReason',
      (v) => $enumDecodeNullable(_$WaitReasonEnumMap, v),
    ),
    waitMessage: $checkedConvert('waitMessage', (v) => v as String?),
    queuedAt: $checkedConvert(
      'queuedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    memberId: $checkedConvert('memberId', (v) => (v as num?)?.toInt()),
    member: $checkedConvert('member', (v) => v as String?),
    createdBy: $checkedConvert('createdBy', (v) => v as String?),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
  );
  return val;
}, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$TicketToJson(Ticket instance) => <String, dynamic>{
  'key': instance.key,
  'ticketNumber': ?instance.ticketNumber,
  'source': _$TicketSource_EnumEnumMap[instance.source_]!,
  'repoId': ?instance.repoId,
  'repos': ?instance.repos?.map((e) => e.toJson()).toList(),
  'group': ?instance.group?.toJson(),
  'partlyMerged': ?instance.partlyMerged,
  'title': instance.title,
  'description': instance.description,
  'priority': instance.priority,
  'state': _$TicketStateEnumMap[instance.state]!,
  'resumeState': ?_$TicketStateEnumMap[instance.resumeState],
  'revision': instance.revision,
  'replayOf': ?instance.replayOf,
  'turns': instance.turns,
  'branch': instance.branch,
  'headSha': ?instance.headSha,
  'prNumber': ?instance.prNumber,
  'prUrl': instance.prUrl,
  'ciFixes': ?instance.ciFixes,
  'assignees': ?instance.assignees,
  'afterApprove': ?_$TicketAfterApproveEnumEnumMap[instance.afterApprove],
  'held': ?instance.held,
  'askFirst': ?instance.askFirst,
  'kind': _$TicketKindEnumMap[instance.kind]!,
  'kindAuto': instance.kindAuto,
  'skipChecks': instance.skipChecks,
  'benchmark': ?instance.benchmark,
  'postReport': ?instance.postReport,
  'parentKey': ?instance.parentKey,
  'followUpOf': ?instance.followUpOf,
  'suggestFollowUps': ?_$FollowUpsModeEnumMap[instance.suggestFollowUps],
  'openSuggestions': ?instance.openSuggestions,
  'blockedBy': ?instance.blockedBy?.map((e) => e.toJson()).toList(),
  'repoName': ?instance.repoName,
  'models': ?instance.models?.toJson(),
  'since': ?instance.since?.toIso8601String(),
  'stopReason': ?instance.stopReason,
  'mergedAt': ?instance.mergedAt?.toIso8601String(),
  'pull': ?instance.pull?.toJson(),
  'trackerUpdate': ?instance.trackerUpdate?.toJson(),
  'learnState': ?_$TicketLearnStateEnumEnumMap[instance.learnState],
  'reviewState': ?_$TicketReviewStateEnumEnumMap[instance.reviewState],
  'previewState': ?_$TicketPreviewStateEnumEnumMap[instance.previewState],
  'previewCompare': ?instance.previewCompare,
  'canPreview': ?instance.canPreview,
  'continueTo': ?_$TicketStateEnumMap[instance.continueTo],
  'canStartOver': ?instance.canStartOver,
  'savedWork': ?instance.savedWork,
  'spend': ?instance.spend?.toJson(),
  'waitReason': ?_$WaitReasonEnumMap[instance.waitReason],
  'waitMessage': ?instance.waitMessage,
  'queuedAt': ?instance.queuedAt?.toIso8601String(),
  'memberId': ?instance.memberId,
  'member': ?instance.member,
  'createdBy': ?instance.createdBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$TicketSource_EnumEnumMap = {
  TicketSource_Enum.jira: 'jira',
  TicketSource_Enum.plane: 'plane',
  TicketSource_Enum.local: 'local',
  TicketSource_Enum.git: 'git',
  TicketSource_Enum.ci: 'ci',
  TicketSource_Enum.logs: 'logs',
};

const _$TicketStateEnumMap = {
  TicketState.new_: 'new',
  TicketState.analyzing: 'analyzing',
  TicketState.waitingForAnswers: 'waiting_for_answers',
  TicketState.coding: 'coding',
  TicketState.testing: 'testing',
  TicketState.waitingForReview: 'waiting_for_review',
  TicketState.pushing: 'pushing',
  TicketState.done: 'done',
  TicketState.rejected: 'rejected',
  TicketState.failed: 'failed',
  TicketState.rateLimited: 'rate_limited',
};

const _$TicketAfterApproveEnumEnumMap = {
  TicketAfterApproveEnum.pr: 'pr',
  TicketAfterApproveEnum.main: 'main',
  TicketAfterApproveEnum.none: 'none',
};

const _$TicketKindEnumMap = {
  TicketKind.code: 'code',
  TicketKind.test: 'test',
  TicketKind.plan: 'plan',
  TicketKind.analysis: 'analysis',
  TicketKind.bug: 'bug',
  TicketKind.review: 'review',
  TicketKind.swaggertest: 'swaggertest',
};

const _$FollowUpsModeEnumMap = {
  FollowUpsMode.inherit: 'inherit',
  FollowUpsMode.on_: 'on',
  FollowUpsMode.off: 'off',
};

const _$TicketLearnStateEnumEnumMap = {
  TicketLearnStateEnum.none: 'none',
  TicketLearnStateEnum.pending: 'pending',
  TicketLearnStateEnum.done: 'done',
  TicketLearnStateEnum.failed: 'failed',
};

const _$TicketReviewStateEnumEnumMap = {
  TicketReviewStateEnum.none: 'none',
  TicketReviewStateEnum.pending: 'pending',
  TicketReviewStateEnum.running: 'running',
  TicketReviewStateEnum.done: 'done',
  TicketReviewStateEnum.failed: 'failed',
};

const _$TicketPreviewStateEnumEnumMap = {
  TicketPreviewStateEnum.none: 'none',
  TicketPreviewStateEnum.pending: 'pending',
  TicketPreviewStateEnum.running: 'running',
  TicketPreviewStateEnum.done: 'done',
  TicketPreviewStateEnum.failed: 'failed',
};

const _$WaitReasonEnumMap = {
  WaitReason.blocked: 'blocked',
  WaitReason.slots: 'slots',
  WaitReason.server: 'server',
  WaitReason.claude: 'claude',
};

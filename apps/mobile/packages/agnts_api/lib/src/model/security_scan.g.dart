// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_scan.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SecurityScanCWProxy {
  SecurityScan id(int id);

  SecurityScan repoId(int repoId);

  SecurityScan repo(String repo);

  SecurityScan trigger(SecurityScanTriggerEnum trigger);

  SecurityScan status(SecurityScanStatusEnum status);

  SecurityScan commit(String commit);

  SecurityScan findingIds(List<int>? findingIds);

  SecurityScan fullHistory(bool? fullHistory);

  SecurityScan tools(List<SecToolRun> tools);

  SecurityScan agent(String agent);

  SecurityScan history(int history);

  SecurityScan commits(int commits);

  SecurityScan dbVersions(Map<String, String>? dbVersions);

  SecurityScan new_(int new_);

  SecurityScan seen(int seen);

  SecurityScan fixed(int fixed);

  SecurityScan reopened(int reopened);

  SecurityScan unchecked(int unchecked);

  SecurityScan rejectedCount(int rejectedCount);

  SecurityScan rejected(List<SecRejectedHit>? rejected);

  SecurityScan open(SecSeverityCounts open);

  SecurityScan summary(String summary);

  SecurityScan error(String error);

  SecurityScan provider(String provider);

  SecurityScan createdAt(DateTime createdAt);

  SecurityScan startedAt(DateTime? startedAt);

  SecurityScan finishedAt(DateTime? finishedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SecurityScan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SecurityScan(...).copyWith(id: 12, name: "My name")
  /// ````
  SecurityScan call({
    int id,
    int repoId,
    String repo,
    SecurityScanTriggerEnum trigger,
    SecurityScanStatusEnum status,
    String commit,
    List<int>? findingIds,
    bool? fullHistory,
    List<SecToolRun> tools,
    String agent,
    int history,
    int commits,
    Map<String, String>? dbVersions,
    int new_,
    int seen,
    int fixed,
    int reopened,
    int unchecked,
    int rejectedCount,
    List<SecRejectedHit>? rejected,
    SecSeverityCounts open,
    String summary,
    String error,
    String provider,
    DateTime createdAt,
    DateTime? startedAt,
    DateTime? finishedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSecurityScan.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSecurityScan.copyWith.fieldName(...)`
class _$SecurityScanCWProxyImpl implements _$SecurityScanCWProxy {
  const _$SecurityScanCWProxyImpl(this._value);

  final SecurityScan _value;

  @override
  SecurityScan id(int id) => this(id: id);

  @override
  SecurityScan repoId(int repoId) => this(repoId: repoId);

  @override
  SecurityScan repo(String repo) => this(repo: repo);

  @override
  SecurityScan trigger(SecurityScanTriggerEnum trigger) =>
      this(trigger: trigger);

  @override
  SecurityScan status(SecurityScanStatusEnum status) => this(status: status);

  @override
  SecurityScan commit(String commit) => this(commit: commit);

  @override
  SecurityScan findingIds(List<int>? findingIds) =>
      this(findingIds: findingIds);

  @override
  SecurityScan fullHistory(bool? fullHistory) => this(fullHistory: fullHistory);

  @override
  SecurityScan tools(List<SecToolRun> tools) => this(tools: tools);

  @override
  SecurityScan agent(String agent) => this(agent: agent);

  @override
  SecurityScan history(int history) => this(history: history);

  @override
  SecurityScan commits(int commits) => this(commits: commits);

  @override
  SecurityScan dbVersions(Map<String, String>? dbVersions) =>
      this(dbVersions: dbVersions);

  @override
  SecurityScan new_(int new_) => this(new_: new_);

  @override
  SecurityScan seen(int seen) => this(seen: seen);

  @override
  SecurityScan fixed(int fixed) => this(fixed: fixed);

  @override
  SecurityScan reopened(int reopened) => this(reopened: reopened);

  @override
  SecurityScan unchecked(int unchecked) => this(unchecked: unchecked);

  @override
  SecurityScan rejectedCount(int rejectedCount) =>
      this(rejectedCount: rejectedCount);

  @override
  SecurityScan rejected(List<SecRejectedHit>? rejected) =>
      this(rejected: rejected);

  @override
  SecurityScan open(SecSeverityCounts open) => this(open: open);

  @override
  SecurityScan summary(String summary) => this(summary: summary);

  @override
  SecurityScan error(String error) => this(error: error);

  @override
  SecurityScan provider(String provider) => this(provider: provider);

  @override
  SecurityScan createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  SecurityScan startedAt(DateTime? startedAt) => this(startedAt: startedAt);

  @override
  SecurityScan finishedAt(DateTime? finishedAt) => this(finishedAt: finishedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SecurityScan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SecurityScan(...).copyWith(id: 12, name: "My name")
  /// ````
  SecurityScan call({
    Object? id = const $CopyWithPlaceholder(),
    Object? repoId = const $CopyWithPlaceholder(),
    Object? repo = const $CopyWithPlaceholder(),
    Object? trigger = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? commit = const $CopyWithPlaceholder(),
    Object? findingIds = const $CopyWithPlaceholder(),
    Object? fullHistory = const $CopyWithPlaceholder(),
    Object? tools = const $CopyWithPlaceholder(),
    Object? agent = const $CopyWithPlaceholder(),
    Object? history = const $CopyWithPlaceholder(),
    Object? commits = const $CopyWithPlaceholder(),
    Object? dbVersions = const $CopyWithPlaceholder(),
    Object? new_ = const $CopyWithPlaceholder(),
    Object? seen = const $CopyWithPlaceholder(),
    Object? fixed = const $CopyWithPlaceholder(),
    Object? reopened = const $CopyWithPlaceholder(),
    Object? unchecked = const $CopyWithPlaceholder(),
    Object? rejectedCount = const $CopyWithPlaceholder(),
    Object? rejected = const $CopyWithPlaceholder(),
    Object? open = const $CopyWithPlaceholder(),
    Object? summary = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
    Object? provider = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
    Object? finishedAt = const $CopyWithPlaceholder(),
  }) {
    return SecurityScan(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int,
      repo: repo == const $CopyWithPlaceholder()
          ? _value.repo
          // ignore: cast_nullable_to_non_nullable
          : repo as String,
      trigger: trigger == const $CopyWithPlaceholder()
          ? _value.trigger
          // ignore: cast_nullable_to_non_nullable
          : trigger as SecurityScanTriggerEnum,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as SecurityScanStatusEnum,
      commit: commit == const $CopyWithPlaceholder()
          ? _value.commit
          // ignore: cast_nullable_to_non_nullable
          : commit as String,
      findingIds: findingIds == const $CopyWithPlaceholder()
          ? _value.findingIds
          // ignore: cast_nullable_to_non_nullable
          : findingIds as List<int>?,
      fullHistory: fullHistory == const $CopyWithPlaceholder()
          ? _value.fullHistory
          // ignore: cast_nullable_to_non_nullable
          : fullHistory as bool?,
      tools: tools == const $CopyWithPlaceholder()
          ? _value.tools
          // ignore: cast_nullable_to_non_nullable
          : tools as List<SecToolRun>,
      agent: agent == const $CopyWithPlaceholder()
          ? _value.agent
          // ignore: cast_nullable_to_non_nullable
          : agent as String,
      history: history == const $CopyWithPlaceholder()
          ? _value.history
          // ignore: cast_nullable_to_non_nullable
          : history as int,
      commits: commits == const $CopyWithPlaceholder()
          ? _value.commits
          // ignore: cast_nullable_to_non_nullable
          : commits as int,
      dbVersions: dbVersions == const $CopyWithPlaceholder()
          ? _value.dbVersions
          // ignore: cast_nullable_to_non_nullable
          : dbVersions as Map<String, String>?,
      new_: new_ == const $CopyWithPlaceholder()
          ? _value.new_
          // ignore: cast_nullable_to_non_nullable
          : new_ as int,
      seen: seen == const $CopyWithPlaceholder()
          ? _value.seen
          // ignore: cast_nullable_to_non_nullable
          : seen as int,
      fixed: fixed == const $CopyWithPlaceholder()
          ? _value.fixed
          // ignore: cast_nullable_to_non_nullable
          : fixed as int,
      reopened: reopened == const $CopyWithPlaceholder()
          ? _value.reopened
          // ignore: cast_nullable_to_non_nullable
          : reopened as int,
      unchecked: unchecked == const $CopyWithPlaceholder()
          ? _value.unchecked
          // ignore: cast_nullable_to_non_nullable
          : unchecked as int,
      rejectedCount: rejectedCount == const $CopyWithPlaceholder()
          ? _value.rejectedCount
          // ignore: cast_nullable_to_non_nullable
          : rejectedCount as int,
      rejected: rejected == const $CopyWithPlaceholder()
          ? _value.rejected
          // ignore: cast_nullable_to_non_nullable
          : rejected as List<SecRejectedHit>?,
      open: open == const $CopyWithPlaceholder()
          ? _value.open
          // ignore: cast_nullable_to_non_nullable
          : open as SecSeverityCounts,
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as String,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String,
      provider: provider == const $CopyWithPlaceholder()
          ? _value.provider
          // ignore: cast_nullable_to_non_nullable
          : provider as String,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      startedAt: startedAt == const $CopyWithPlaceholder()
          ? _value.startedAt
          // ignore: cast_nullable_to_non_nullable
          : startedAt as DateTime?,
      finishedAt: finishedAt == const $CopyWithPlaceholder()
          ? _value.finishedAt
          // ignore: cast_nullable_to_non_nullable
          : finishedAt as DateTime?,
    );
  }
}

extension $SecurityScanCopyWith on SecurityScan {
  /// Returns a callable class that can be used as follows: `instanceOfSecurityScan.copyWith(...)` or like so:`instanceOfSecurityScan.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SecurityScanCWProxy get copyWith => _$SecurityScanCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SecurityScan _$SecurityScanFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SecurityScan', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'repoId',
      'repo',
      'trigger',
      'status',
      'commit',
      'tools',
      'agent',
      'history',
      'commits',
      'new',
      'seen',
      'fixed',
      'reopened',
      'unchecked',
      'rejectedCount',
      'open',
      'summary',
      'error',
      'provider',
      'createdAt',
    ],
  );
  final val = SecurityScan(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    repoId: $checkedConvert('repoId', (v) => (v as num).toInt()),
    repo: $checkedConvert('repo', (v) => v as String),
    trigger: $checkedConvert(
      'trigger',
      (v) => $enumDecode(_$SecurityScanTriggerEnumEnumMap, v),
    ),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$SecurityScanStatusEnumEnumMap, v),
    ),
    commit: $checkedConvert('commit', (v) => v as String),
    findingIds: $checkedConvert(
      'findingIds',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
    ),
    fullHistory: $checkedConvert('fullHistory', (v) => v as bool?),
    tools: $checkedConvert(
      'tools',
      (v) => (v as List<dynamic>)
          .map((e) => SecToolRun.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    agent: $checkedConvert('agent', (v) => v as String),
    history: $checkedConvert('history', (v) => (v as num).toInt()),
    commits: $checkedConvert('commits', (v) => (v as num).toInt()),
    dbVersions: $checkedConvert(
      'dbVersions',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as String)),
    ),
    new_: $checkedConvert('new', (v) => (v as num).toInt()),
    seen: $checkedConvert('seen', (v) => (v as num).toInt()),
    fixed: $checkedConvert('fixed', (v) => (v as num).toInt()),
    reopened: $checkedConvert('reopened', (v) => (v as num).toInt()),
    unchecked: $checkedConvert('unchecked', (v) => (v as num).toInt()),
    rejectedCount: $checkedConvert('rejectedCount', (v) => (v as num).toInt()),
    rejected: $checkedConvert(
      'rejected',
      (v) => (v as List<dynamic>?)
          ?.map((e) => SecRejectedHit.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    open: $checkedConvert(
      'open',
      (v) => SecSeverityCounts.fromJson(v as Map<String, dynamic>),
    ),
    summary: $checkedConvert('summary', (v) => v as String),
    error: $checkedConvert('error', (v) => v as String),
    provider: $checkedConvert('provider', (v) => v as String),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    startedAt: $checkedConvert(
      'startedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    finishedAt: $checkedConvert(
      'finishedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
  );
  return val;
}, fieldKeyMap: const {'new_': 'new'});

Map<String, dynamic> _$SecurityScanToJson(SecurityScan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'repoId': instance.repoId,
      'repo': instance.repo,
      'trigger': _$SecurityScanTriggerEnumEnumMap[instance.trigger]!,
      'status': _$SecurityScanStatusEnumEnumMap[instance.status]!,
      'commit': instance.commit,
      'findingIds': ?instance.findingIds,
      'fullHistory': ?instance.fullHistory,
      'tools': instance.tools.map((e) => e.toJson()).toList(),
      'agent': instance.agent,
      'history': instance.history,
      'commits': instance.commits,
      'dbVersions': ?instance.dbVersions,
      'new': instance.new_,
      'seen': instance.seen,
      'fixed': instance.fixed,
      'reopened': instance.reopened,
      'unchecked': instance.unchecked,
      'rejectedCount': instance.rejectedCount,
      'rejected': ?instance.rejected?.map((e) => e.toJson()).toList(),
      'open': instance.open.toJson(),
      'summary': instance.summary,
      'error': instance.error,
      'provider': instance.provider,
      'createdAt': instance.createdAt.toIso8601String(),
      'startedAt': ?instance.startedAt?.toIso8601String(),
      'finishedAt': ?instance.finishedAt?.toIso8601String(),
    };

const _$SecurityScanTriggerEnumEnumMap = {
  SecurityScanTriggerEnum.manual: 'manual',
  SecurityScanTriggerEnum.schedule: 'schedule',
  SecurityScanTriggerEnum.verify: 'verify',
};

const _$SecurityScanStatusEnumEnumMap = {
  SecurityScanStatusEnum.pending: 'pending',
  SecurityScanStatusEnum.running: 'running',
  SecurityScanStatusEnum.done: 'done',
  SecurityScanStatusEnum.failed: 'failed',
  SecurityScanStatusEnum.cancelled: 'cancelled',
};

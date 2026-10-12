// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ci_failure.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CIFailureCWProxy {
  CIFailure id(int id);

  CIFailure repoId(int repoId);

  CIFailure repo(String repo);

  CIFailure branch(String branch);

  CIFailure workflow(String workflow);

  CIFailure job(String job);

  CIFailure title(String title);

  CIFailure class_(String class_);

  CIFailure status(CIStatus status);

  CIFailure count(int count);

  CIFailure flakyCount(int flakyCount);

  CIFailure firstSeenAt(DateTime firstSeenAt);

  CIFailure lastSeenAt(DateTime lastSeenAt);

  CIFailure firstSha(String firstSha);

  CIFailure lastSha(String lastSha);

  CIFailure occurrences(List<CIOccurrence> occurrences);

  CIFailure ticketKey(String ticketKey);

  CIFailure ticketState(TicketState? ticketState);

  CIFailure fixedSha(String? fixedSha);

  CIFailure fixedAt(DateTime? fixedAt);

  CIFailure prNumber(int prNumber);

  CIFailure sample(String? sample);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CIFailure(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CIFailure(...).copyWith(id: 12, name: "My name")
  /// ````
  CIFailure call({
    int id,
    int repoId,
    String repo,
    String branch,
    String workflow,
    String job,
    String title,
    String class_,
    CIStatus status,
    int count,
    int flakyCount,
    DateTime firstSeenAt,
    DateTime lastSeenAt,
    String firstSha,
    String lastSha,
    List<CIOccurrence> occurrences,
    String ticketKey,
    TicketState? ticketState,
    String? fixedSha,
    DateTime? fixedAt,
    int prNumber,
    String? sample,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCIFailure.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCIFailure.copyWith.fieldName(...)`
class _$CIFailureCWProxyImpl implements _$CIFailureCWProxy {
  const _$CIFailureCWProxyImpl(this._value);

  final CIFailure _value;

  @override
  CIFailure id(int id) => this(id: id);

  @override
  CIFailure repoId(int repoId) => this(repoId: repoId);

  @override
  CIFailure repo(String repo) => this(repo: repo);

  @override
  CIFailure branch(String branch) => this(branch: branch);

  @override
  CIFailure workflow(String workflow) => this(workflow: workflow);

  @override
  CIFailure job(String job) => this(job: job);

  @override
  CIFailure title(String title) => this(title: title);

  @override
  CIFailure class_(String class_) => this(class_: class_);

  @override
  CIFailure status(CIStatus status) => this(status: status);

  @override
  CIFailure count(int count) => this(count: count);

  @override
  CIFailure flakyCount(int flakyCount) => this(flakyCount: flakyCount);

  @override
  CIFailure firstSeenAt(DateTime firstSeenAt) => this(firstSeenAt: firstSeenAt);

  @override
  CIFailure lastSeenAt(DateTime lastSeenAt) => this(lastSeenAt: lastSeenAt);

  @override
  CIFailure firstSha(String firstSha) => this(firstSha: firstSha);

  @override
  CIFailure lastSha(String lastSha) => this(lastSha: lastSha);

  @override
  CIFailure occurrences(List<CIOccurrence> occurrences) =>
      this(occurrences: occurrences);

  @override
  CIFailure ticketKey(String ticketKey) => this(ticketKey: ticketKey);

  @override
  CIFailure ticketState(TicketState? ticketState) =>
      this(ticketState: ticketState);

  @override
  CIFailure fixedSha(String? fixedSha) => this(fixedSha: fixedSha);

  @override
  CIFailure fixedAt(DateTime? fixedAt) => this(fixedAt: fixedAt);

  @override
  CIFailure prNumber(int prNumber) => this(prNumber: prNumber);

  @override
  CIFailure sample(String? sample) => this(sample: sample);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CIFailure(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CIFailure(...).copyWith(id: 12, name: "My name")
  /// ````
  CIFailure call({
    Object? id = const $CopyWithPlaceholder(),
    Object? repoId = const $CopyWithPlaceholder(),
    Object? repo = const $CopyWithPlaceholder(),
    Object? branch = const $CopyWithPlaceholder(),
    Object? workflow = const $CopyWithPlaceholder(),
    Object? job = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? class_ = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? count = const $CopyWithPlaceholder(),
    Object? flakyCount = const $CopyWithPlaceholder(),
    Object? firstSeenAt = const $CopyWithPlaceholder(),
    Object? lastSeenAt = const $CopyWithPlaceholder(),
    Object? firstSha = const $CopyWithPlaceholder(),
    Object? lastSha = const $CopyWithPlaceholder(),
    Object? occurrences = const $CopyWithPlaceholder(),
    Object? ticketKey = const $CopyWithPlaceholder(),
    Object? ticketState = const $CopyWithPlaceholder(),
    Object? fixedSha = const $CopyWithPlaceholder(),
    Object? fixedAt = const $CopyWithPlaceholder(),
    Object? prNumber = const $CopyWithPlaceholder(),
    Object? sample = const $CopyWithPlaceholder(),
  }) {
    return CIFailure(
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
      branch: branch == const $CopyWithPlaceholder()
          ? _value.branch
          // ignore: cast_nullable_to_non_nullable
          : branch as String,
      workflow: workflow == const $CopyWithPlaceholder()
          ? _value.workflow
          // ignore: cast_nullable_to_non_nullable
          : workflow as String,
      job: job == const $CopyWithPlaceholder()
          ? _value.job
          // ignore: cast_nullable_to_non_nullable
          : job as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      class_: class_ == const $CopyWithPlaceholder()
          ? _value.class_
          // ignore: cast_nullable_to_non_nullable
          : class_ as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as CIStatus,
      count: count == const $CopyWithPlaceholder()
          ? _value.count
          // ignore: cast_nullable_to_non_nullable
          : count as int,
      flakyCount: flakyCount == const $CopyWithPlaceholder()
          ? _value.flakyCount
          // ignore: cast_nullable_to_non_nullable
          : flakyCount as int,
      firstSeenAt: firstSeenAt == const $CopyWithPlaceholder()
          ? _value.firstSeenAt
          // ignore: cast_nullable_to_non_nullable
          : firstSeenAt as DateTime,
      lastSeenAt: lastSeenAt == const $CopyWithPlaceholder()
          ? _value.lastSeenAt
          // ignore: cast_nullable_to_non_nullable
          : lastSeenAt as DateTime,
      firstSha: firstSha == const $CopyWithPlaceholder()
          ? _value.firstSha
          // ignore: cast_nullable_to_non_nullable
          : firstSha as String,
      lastSha: lastSha == const $CopyWithPlaceholder()
          ? _value.lastSha
          // ignore: cast_nullable_to_non_nullable
          : lastSha as String,
      occurrences: occurrences == const $CopyWithPlaceholder()
          ? _value.occurrences
          // ignore: cast_nullable_to_non_nullable
          : occurrences as List<CIOccurrence>,
      ticketKey: ticketKey == const $CopyWithPlaceholder()
          ? _value.ticketKey
          // ignore: cast_nullable_to_non_nullable
          : ticketKey as String,
      ticketState: ticketState == const $CopyWithPlaceholder()
          ? _value.ticketState
          // ignore: cast_nullable_to_non_nullable
          : ticketState as TicketState?,
      fixedSha: fixedSha == const $CopyWithPlaceholder()
          ? _value.fixedSha
          // ignore: cast_nullable_to_non_nullable
          : fixedSha as String?,
      fixedAt: fixedAt == const $CopyWithPlaceholder()
          ? _value.fixedAt
          // ignore: cast_nullable_to_non_nullable
          : fixedAt as DateTime?,
      prNumber: prNumber == const $CopyWithPlaceholder()
          ? _value.prNumber
          // ignore: cast_nullable_to_non_nullable
          : prNumber as int,
      sample: sample == const $CopyWithPlaceholder()
          ? _value.sample
          // ignore: cast_nullable_to_non_nullable
          : sample as String?,
    );
  }
}

extension $CIFailureCopyWith on CIFailure {
  /// Returns a callable class that can be used as follows: `instanceOfCIFailure.copyWith(...)` or like so:`instanceOfCIFailure.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CIFailureCWProxy get copyWith => _$CIFailureCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CIFailure _$CIFailureFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CIFailure', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'repoId',
          'repo',
          'branch',
          'workflow',
          'job',
          'title',
          'class',
          'status',
          'count',
          'flakyCount',
          'firstSeenAt',
          'lastSeenAt',
          'firstSha',
          'lastSha',
          'occurrences',
          'ticketKey',
          'prNumber',
        ],
      );
      final val = CIFailure(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        repoId: $checkedConvert('repoId', (v) => (v as num).toInt()),
        repo: $checkedConvert('repo', (v) => v as String),
        branch: $checkedConvert('branch', (v) => v as String),
        workflow: $checkedConvert('workflow', (v) => v as String),
        job: $checkedConvert('job', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        class_: $checkedConvert('class', (v) => v as String),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$CIStatusEnumMap, v),
        ),
        count: $checkedConvert('count', (v) => (v as num).toInt()),
        flakyCount: $checkedConvert('flakyCount', (v) => (v as num).toInt()),
        firstSeenAt: $checkedConvert(
          'firstSeenAt',
          (v) => DateTime.parse(v as String),
        ),
        lastSeenAt: $checkedConvert(
          'lastSeenAt',
          (v) => DateTime.parse(v as String),
        ),
        firstSha: $checkedConvert('firstSha', (v) => v as String),
        lastSha: $checkedConvert('lastSha', (v) => v as String),
        occurrences: $checkedConvert(
          'occurrences',
          (v) => (v as List<dynamic>)
              .map((e) => CIOccurrence.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        ticketKey: $checkedConvert('ticketKey', (v) => v as String),
        ticketState: $checkedConvert(
          'ticketState',
          (v) => $enumDecodeNullable(_$TicketStateEnumMap, v),
        ),
        fixedSha: $checkedConvert('fixedSha', (v) => v as String?),
        fixedAt: $checkedConvert(
          'fixedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        prNumber: $checkedConvert('prNumber', (v) => (v as num).toInt()),
        sample: $checkedConvert('sample', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'class_': 'class'});

Map<String, dynamic> _$CIFailureToJson(CIFailure instance) => <String, dynamic>{
  'id': instance.id,
  'repoId': instance.repoId,
  'repo': instance.repo,
  'branch': instance.branch,
  'workflow': instance.workflow,
  'job': instance.job,
  'title': instance.title,
  'class': instance.class_,
  'status': _$CIStatusEnumMap[instance.status]!,
  'count': instance.count,
  'flakyCount': instance.flakyCount,
  'firstSeenAt': instance.firstSeenAt.toIso8601String(),
  'lastSeenAt': instance.lastSeenAt.toIso8601String(),
  'firstSha': instance.firstSha,
  'lastSha': instance.lastSha,
  'occurrences': instance.occurrences.map((e) => e.toJson()).toList(),
  'ticketKey': instance.ticketKey,
  'ticketState': ?_$TicketStateEnumMap[instance.ticketState],
  'fixedSha': ?instance.fixedSha,
  'fixedAt': ?instance.fixedAt?.toIso8601String(),
  'prNumber': instance.prNumber,
  'sample': ?instance.sample,
};

const _$CIStatusEnumMap = {
  CIStatus.triage: 'triage',
  CIStatus.open: 'open',
  CIStatus.fixing: 'fixing',
  CIStatus.fixed: 'fixed',
  CIStatus.resolved: 'resolved',
  CIStatus.flaky: 'flaky',
  CIStatus.infra: 'infra',
  CIStatus.muted: 'muted',
  CIStatus.regression: 'regression',
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_finding.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LogFindingCWProxy {
  LogFinding id(int id);

  LogFinding service(String service);

  LogFinding repoIds(List<int> repoIds);

  LogFinding repos(List<String> repos);

  LogFinding category(LogFindingCategoryEnum category);

  LogFinding detector(String detector);

  LogFinding class_(String class_);

  LogFinding severity(LogSeverity severity);

  LogFinding title(String title);

  LogFinding remediation(String remediation);

  LogFinding status(LogFindingStatus status);

  LogFinding reason(String reason);

  LogFinding count(int count);

  LogFinding hourCount(int hourCount);

  LogFinding firstSeenAt(DateTime firstSeenAt);

  LogFinding lastSeenAt(DateTime lastSeenAt);

  LogFinding revision(String revision);

  LogFinding route(String route);

  LogFinding secretMask(String secretMask);

  LogFinding occurrences(List<LogOccurrence> occurrences);

  LogFinding reportedAt(DateTime? reportedAt);

  LogFinding ticketKey(String ticketKey);

  LogFinding ticketState(TicketState? ticketState);

  LogFinding fixedSha(String? fixedSha);

  LogFinding fixedAt(DateTime? fixedAt);

  LogFinding sample(String? sample);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogFinding(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogFinding(...).copyWith(id: 12, name: "My name")
  /// ````
  LogFinding call({
    int id,
    String service,
    List<int> repoIds,
    List<String> repos,
    LogFindingCategoryEnum category,
    String detector,
    String class_,
    LogSeverity severity,
    String title,
    String remediation,
    LogFindingStatus status,
    String reason,
    int count,
    int hourCount,
    DateTime firstSeenAt,
    DateTime lastSeenAt,
    String revision,
    String route,
    String secretMask,
    List<LogOccurrence> occurrences,
    DateTime? reportedAt,
    String ticketKey,
    TicketState? ticketState,
    String? fixedSha,
    DateTime? fixedAt,
    String? sample,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLogFinding.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLogFinding.copyWith.fieldName(...)`
class _$LogFindingCWProxyImpl implements _$LogFindingCWProxy {
  const _$LogFindingCWProxyImpl(this._value);

  final LogFinding _value;

  @override
  LogFinding id(int id) => this(id: id);

  @override
  LogFinding service(String service) => this(service: service);

  @override
  LogFinding repoIds(List<int> repoIds) => this(repoIds: repoIds);

  @override
  LogFinding repos(List<String> repos) => this(repos: repos);

  @override
  LogFinding category(LogFindingCategoryEnum category) =>
      this(category: category);

  @override
  LogFinding detector(String detector) => this(detector: detector);

  @override
  LogFinding class_(String class_) => this(class_: class_);

  @override
  LogFinding severity(LogSeverity severity) => this(severity: severity);

  @override
  LogFinding title(String title) => this(title: title);

  @override
  LogFinding remediation(String remediation) => this(remediation: remediation);

  @override
  LogFinding status(LogFindingStatus status) => this(status: status);

  @override
  LogFinding reason(String reason) => this(reason: reason);

  @override
  LogFinding count(int count) => this(count: count);

  @override
  LogFinding hourCount(int hourCount) => this(hourCount: hourCount);

  @override
  LogFinding firstSeenAt(DateTime firstSeenAt) =>
      this(firstSeenAt: firstSeenAt);

  @override
  LogFinding lastSeenAt(DateTime lastSeenAt) => this(lastSeenAt: lastSeenAt);

  @override
  LogFinding revision(String revision) => this(revision: revision);

  @override
  LogFinding route(String route) => this(route: route);

  @override
  LogFinding secretMask(String secretMask) => this(secretMask: secretMask);

  @override
  LogFinding occurrences(List<LogOccurrence> occurrences) =>
      this(occurrences: occurrences);

  @override
  LogFinding reportedAt(DateTime? reportedAt) => this(reportedAt: reportedAt);

  @override
  LogFinding ticketKey(String ticketKey) => this(ticketKey: ticketKey);

  @override
  LogFinding ticketState(TicketState? ticketState) =>
      this(ticketState: ticketState);

  @override
  LogFinding fixedSha(String? fixedSha) => this(fixedSha: fixedSha);

  @override
  LogFinding fixedAt(DateTime? fixedAt) => this(fixedAt: fixedAt);

  @override
  LogFinding sample(String? sample) => this(sample: sample);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogFinding(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogFinding(...).copyWith(id: 12, name: "My name")
  /// ````
  LogFinding call({
    Object? id = const $CopyWithPlaceholder(),
    Object? service = const $CopyWithPlaceholder(),
    Object? repoIds = const $CopyWithPlaceholder(),
    Object? repos = const $CopyWithPlaceholder(),
    Object? category = const $CopyWithPlaceholder(),
    Object? detector = const $CopyWithPlaceholder(),
    Object? class_ = const $CopyWithPlaceholder(),
    Object? severity = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? remediation = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? count = const $CopyWithPlaceholder(),
    Object? hourCount = const $CopyWithPlaceholder(),
    Object? firstSeenAt = const $CopyWithPlaceholder(),
    Object? lastSeenAt = const $CopyWithPlaceholder(),
    Object? revision = const $CopyWithPlaceholder(),
    Object? route = const $CopyWithPlaceholder(),
    Object? secretMask = const $CopyWithPlaceholder(),
    Object? occurrences = const $CopyWithPlaceholder(),
    Object? reportedAt = const $CopyWithPlaceholder(),
    Object? ticketKey = const $CopyWithPlaceholder(),
    Object? ticketState = const $CopyWithPlaceholder(),
    Object? fixedSha = const $CopyWithPlaceholder(),
    Object? fixedAt = const $CopyWithPlaceholder(),
    Object? sample = const $CopyWithPlaceholder(),
  }) {
    return LogFinding(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      service: service == const $CopyWithPlaceholder()
          ? _value.service
          // ignore: cast_nullable_to_non_nullable
          : service as String,
      repoIds: repoIds == const $CopyWithPlaceholder()
          ? _value.repoIds
          // ignore: cast_nullable_to_non_nullable
          : repoIds as List<int>,
      repos: repos == const $CopyWithPlaceholder()
          ? _value.repos
          // ignore: cast_nullable_to_non_nullable
          : repos as List<String>,
      category: category == const $CopyWithPlaceholder()
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as LogFindingCategoryEnum,
      detector: detector == const $CopyWithPlaceholder()
          ? _value.detector
          // ignore: cast_nullable_to_non_nullable
          : detector as String,
      class_: class_ == const $CopyWithPlaceholder()
          ? _value.class_
          // ignore: cast_nullable_to_non_nullable
          : class_ as String,
      severity: severity == const $CopyWithPlaceholder()
          ? _value.severity
          // ignore: cast_nullable_to_non_nullable
          : severity as LogSeverity,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      remediation: remediation == const $CopyWithPlaceholder()
          ? _value.remediation
          // ignore: cast_nullable_to_non_nullable
          : remediation as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as LogFindingStatus,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
      count: count == const $CopyWithPlaceholder()
          ? _value.count
          // ignore: cast_nullable_to_non_nullable
          : count as int,
      hourCount: hourCount == const $CopyWithPlaceholder()
          ? _value.hourCount
          // ignore: cast_nullable_to_non_nullable
          : hourCount as int,
      firstSeenAt: firstSeenAt == const $CopyWithPlaceholder()
          ? _value.firstSeenAt
          // ignore: cast_nullable_to_non_nullable
          : firstSeenAt as DateTime,
      lastSeenAt: lastSeenAt == const $CopyWithPlaceholder()
          ? _value.lastSeenAt
          // ignore: cast_nullable_to_non_nullable
          : lastSeenAt as DateTime,
      revision: revision == const $CopyWithPlaceholder()
          ? _value.revision
          // ignore: cast_nullable_to_non_nullable
          : revision as String,
      route: route == const $CopyWithPlaceholder()
          ? _value.route
          // ignore: cast_nullable_to_non_nullable
          : route as String,
      secretMask: secretMask == const $CopyWithPlaceholder()
          ? _value.secretMask
          // ignore: cast_nullable_to_non_nullable
          : secretMask as String,
      occurrences: occurrences == const $CopyWithPlaceholder()
          ? _value.occurrences
          // ignore: cast_nullable_to_non_nullable
          : occurrences as List<LogOccurrence>,
      reportedAt: reportedAt == const $CopyWithPlaceholder()
          ? _value.reportedAt
          // ignore: cast_nullable_to_non_nullable
          : reportedAt as DateTime?,
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
      sample: sample == const $CopyWithPlaceholder()
          ? _value.sample
          // ignore: cast_nullable_to_non_nullable
          : sample as String?,
    );
  }
}

extension $LogFindingCopyWith on LogFinding {
  /// Returns a callable class that can be used as follows: `instanceOfLogFinding.copyWith(...)` or like so:`instanceOfLogFinding.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LogFindingCWProxy get copyWith => _$LogFindingCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogFinding _$LogFindingFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LogFinding', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'service',
          'repoIds',
          'repos',
          'category',
          'detector',
          'class',
          'severity',
          'title',
          'remediation',
          'status',
          'reason',
          'count',
          'hourCount',
          'firstSeenAt',
          'lastSeenAt',
          'revision',
          'route',
          'secretMask',
          'occurrences',
          'ticketKey',
        ],
      );
      final val = LogFinding(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        service: $checkedConvert('service', (v) => v as String),
        repoIds: $checkedConvert(
          'repoIds',
          (v) => (v as List<dynamic>).map((e) => (e as num).toInt()).toList(),
        ),
        repos: $checkedConvert(
          'repos',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        category: $checkedConvert(
          'category',
          (v) => $enumDecode(_$LogFindingCategoryEnumEnumMap, v),
        ),
        detector: $checkedConvert('detector', (v) => v as String),
        class_: $checkedConvert('class', (v) => v as String),
        severity: $checkedConvert(
          'severity',
          (v) => $enumDecode(_$LogSeverityEnumMap, v),
        ),
        title: $checkedConvert('title', (v) => v as String),
        remediation: $checkedConvert('remediation', (v) => v as String),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$LogFindingStatusEnumMap, v),
        ),
        reason: $checkedConvert('reason', (v) => v as String),
        count: $checkedConvert('count', (v) => (v as num).toInt()),
        hourCount: $checkedConvert('hourCount', (v) => (v as num).toInt()),
        firstSeenAt: $checkedConvert(
          'firstSeenAt',
          (v) => DateTime.parse(v as String),
        ),
        lastSeenAt: $checkedConvert(
          'lastSeenAt',
          (v) => DateTime.parse(v as String),
        ),
        revision: $checkedConvert('revision', (v) => v as String),
        route: $checkedConvert('route', (v) => v as String),
        secretMask: $checkedConvert('secretMask', (v) => v as String),
        occurrences: $checkedConvert(
          'occurrences',
          (v) => (v as List<dynamic>)
              .map((e) => LogOccurrence.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        reportedAt: $checkedConvert(
          'reportedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
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
        sample: $checkedConvert('sample', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'class_': 'class'});

Map<String, dynamic> _$LogFindingToJson(LogFinding instance) =>
    <String, dynamic>{
      'id': instance.id,
      'service': instance.service,
      'repoIds': instance.repoIds,
      'repos': instance.repos,
      'category': _$LogFindingCategoryEnumEnumMap[instance.category]!,
      'detector': instance.detector,
      'class': instance.class_,
      'severity': _$LogSeverityEnumMap[instance.severity]!,
      'title': instance.title,
      'remediation': instance.remediation,
      'status': _$LogFindingStatusEnumMap[instance.status]!,
      'reason': instance.reason,
      'count': instance.count,
      'hourCount': instance.hourCount,
      'firstSeenAt': instance.firstSeenAt.toIso8601String(),
      'lastSeenAt': instance.lastSeenAt.toIso8601String(),
      'revision': instance.revision,
      'route': instance.route,
      'secretMask': instance.secretMask,
      'occurrences': instance.occurrences.map((e) => e.toJson()).toList(),
      'reportedAt': ?instance.reportedAt?.toIso8601String(),
      'ticketKey': instance.ticketKey,
      'ticketState': ?_$TicketStateEnumMap[instance.ticketState],
      'fixedSha': ?instance.fixedSha,
      'fixedAt': ?instance.fixedAt?.toIso8601String(),
      'sample': ?instance.sample,
    };

const _$LogFindingCategoryEnumEnumMap = {
  LogFindingCategoryEnum.error: 'error',
  LogFindingCategoryEnum.security: 'security',
};

const _$LogSeverityEnumMap = {
  LogSeverity.low: 'low',
  LogSeverity.medium: 'medium',
  LogSeverity.high: 'high',
  LogSeverity.critical: 'critical',
};

const _$LogFindingStatusEnumMap = {
  LogFindingStatus.open: 'open',
  LogFindingStatus.reported: 'reported',
  LogFindingStatus.fixing: 'fixing',
  LogFindingStatus.fixed: 'fixed',
  LogFindingStatus.resolved: 'resolved',
  LogFindingStatus.muted: 'muted',
  LogFindingStatus.regression: 'regression',
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

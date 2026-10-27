// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SettingsCWProxy {
  Settings models(StageModels models);

  Settings maxTurns(int maxTurns);

  Settings runBudget(int? runBudget);

  Settings timeoutMin(int timeoutMin);

  Settings allow(List<String> allow);

  Settings deny(List<String> deny);

  Settings askFirst(bool askFirst);

  Settings autoResume(bool autoResume);

  Settings autoLearn(bool? autoLearn);

  Settings autoReview(bool? autoReview);

  Settings autoPreview(bool? autoPreview);

  Settings visualCheck(bool? visualCheck);

  Settings autoBrief(bool? autoBrief);

  Settings publicDocuments(bool? publicDocuments);

  Settings selfReview(bool? selfReview);

  Settings reflect(bool? reflect);

  Settings egressAllow(List<String>? egressAllow);

  Settings suggestFollowUps(bool? suggestFollowUps);

  Settings maxTicketRepos(int? maxTicketRepos);

  Settings pullReviews(PullReviewSettings? pullReviews);

  Settings prComments(PRCommentSettings? prComments);

  Settings ci(CISettings? ci);

  Settings guard(GuardSettings? guard);

  Settings stalls(String? stalls);

  Settings proveFixes(bool? proveFixes);

  Settings methodSkills(bool? methodSkills);

  Settings deepReview(String? deepReview);

  Settings learnFromRuns(bool? learnFromRuns);

  Settings effort(EffortSettings? effort);

  Settings recheckComplex(bool? recheckComplex);

  Settings baselineChecks(bool? baselineChecks);

  Settings secondOpinion(String? secondOpinion);

  Settings pauseAbove(int pauseAbove);

  Settings parallel(int parallel);

  Settings git(GitSettings git);

  Settings notify(NotifySettings? notify);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Settings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Settings(...).copyWith(id: 12, name: "My name")
  /// ````
  Settings call({
    StageModels models,
    int maxTurns,
    int? runBudget,
    int timeoutMin,
    List<String> allow,
    List<String> deny,
    bool askFirst,
    bool autoResume,
    bool? autoLearn,
    bool? autoReview,
    bool? autoPreview,
    bool? visualCheck,
    bool? autoBrief,
    bool? publicDocuments,
    bool? selfReview,
    bool? reflect,
    List<String>? egressAllow,
    bool? suggestFollowUps,
    int? maxTicketRepos,
    PullReviewSettings? pullReviews,
    PRCommentSettings? prComments,
    CISettings? ci,
    GuardSettings? guard,
    String? stalls,
    bool? proveFixes,
    bool? methodSkills,
    String? deepReview,
    bool? learnFromRuns,
    EffortSettings? effort,
    bool? recheckComplex,
    bool? baselineChecks,
    String? secondOpinion,
    int pauseAbove,
    int parallel,
    GitSettings git,
    NotifySettings? notify,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSettings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSettings.copyWith.fieldName(...)`
class _$SettingsCWProxyImpl implements _$SettingsCWProxy {
  const _$SettingsCWProxyImpl(this._value);

  final Settings _value;

  @override
  Settings models(StageModels models) => this(models: models);

  @override
  Settings maxTurns(int maxTurns) => this(maxTurns: maxTurns);

  @override
  Settings runBudget(int? runBudget) => this(runBudget: runBudget);

  @override
  Settings timeoutMin(int timeoutMin) => this(timeoutMin: timeoutMin);

  @override
  Settings allow(List<String> allow) => this(allow: allow);

  @override
  Settings deny(List<String> deny) => this(deny: deny);

  @override
  Settings askFirst(bool askFirst) => this(askFirst: askFirst);

  @override
  Settings autoResume(bool autoResume) => this(autoResume: autoResume);

  @override
  Settings autoLearn(bool? autoLearn) => this(autoLearn: autoLearn);

  @override
  Settings autoReview(bool? autoReview) => this(autoReview: autoReview);

  @override
  Settings autoPreview(bool? autoPreview) => this(autoPreview: autoPreview);

  @override
  Settings visualCheck(bool? visualCheck) => this(visualCheck: visualCheck);

  @override
  Settings autoBrief(bool? autoBrief) => this(autoBrief: autoBrief);

  @override
  Settings publicDocuments(bool? publicDocuments) =>
      this(publicDocuments: publicDocuments);

  @override
  Settings selfReview(bool? selfReview) => this(selfReview: selfReview);

  @override
  Settings reflect(bool? reflect) => this(reflect: reflect);

  @override
  Settings egressAllow(List<String>? egressAllow) =>
      this(egressAllow: egressAllow);

  @override
  Settings suggestFollowUps(bool? suggestFollowUps) =>
      this(suggestFollowUps: suggestFollowUps);

  @override
  Settings maxTicketRepos(int? maxTicketRepos) =>
      this(maxTicketRepos: maxTicketRepos);

  @override
  Settings pullReviews(PullReviewSettings? pullReviews) =>
      this(pullReviews: pullReviews);

  @override
  Settings prComments(PRCommentSettings? prComments) =>
      this(prComments: prComments);

  @override
  Settings ci(CISettings? ci) => this(ci: ci);

  @override
  Settings guard(GuardSettings? guard) => this(guard: guard);

  @override
  Settings stalls(String? stalls) => this(stalls: stalls);

  @override
  Settings proveFixes(bool? proveFixes) => this(proveFixes: proveFixes);

  @override
  Settings methodSkills(bool? methodSkills) => this(methodSkills: methodSkills);

  @override
  Settings deepReview(String? deepReview) => this(deepReview: deepReview);

  @override
  Settings learnFromRuns(bool? learnFromRuns) =>
      this(learnFromRuns: learnFromRuns);

  @override
  Settings effort(EffortSettings? effort) => this(effort: effort);

  @override
  Settings recheckComplex(bool? recheckComplex) =>
      this(recheckComplex: recheckComplex);

  @override
  Settings baselineChecks(bool? baselineChecks) =>
      this(baselineChecks: baselineChecks);

  @override
  Settings secondOpinion(String? secondOpinion) =>
      this(secondOpinion: secondOpinion);

  @override
  Settings pauseAbove(int pauseAbove) => this(pauseAbove: pauseAbove);

  @override
  Settings parallel(int parallel) => this(parallel: parallel);

  @override
  Settings git(GitSettings git) => this(git: git);

  @override
  Settings notify(NotifySettings? notify) => this(notify: notify);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Settings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Settings(...).copyWith(id: 12, name: "My name")
  /// ````
  Settings call({
    Object? models = const $CopyWithPlaceholder(),
    Object? maxTurns = const $CopyWithPlaceholder(),
    Object? runBudget = const $CopyWithPlaceholder(),
    Object? timeoutMin = const $CopyWithPlaceholder(),
    Object? allow = const $CopyWithPlaceholder(),
    Object? deny = const $CopyWithPlaceholder(),
    Object? askFirst = const $CopyWithPlaceholder(),
    Object? autoResume = const $CopyWithPlaceholder(),
    Object? autoLearn = const $CopyWithPlaceholder(),
    Object? autoReview = const $CopyWithPlaceholder(),
    Object? autoPreview = const $CopyWithPlaceholder(),
    Object? visualCheck = const $CopyWithPlaceholder(),
    Object? autoBrief = const $CopyWithPlaceholder(),
    Object? publicDocuments = const $CopyWithPlaceholder(),
    Object? selfReview = const $CopyWithPlaceholder(),
    Object? reflect = const $CopyWithPlaceholder(),
    Object? egressAllow = const $CopyWithPlaceholder(),
    Object? suggestFollowUps = const $CopyWithPlaceholder(),
    Object? maxTicketRepos = const $CopyWithPlaceholder(),
    Object? pullReviews = const $CopyWithPlaceholder(),
    Object? prComments = const $CopyWithPlaceholder(),
    Object? ci = const $CopyWithPlaceholder(),
    Object? guard = const $CopyWithPlaceholder(),
    Object? stalls = const $CopyWithPlaceholder(),
    Object? proveFixes = const $CopyWithPlaceholder(),
    Object? methodSkills = const $CopyWithPlaceholder(),
    Object? deepReview = const $CopyWithPlaceholder(),
    Object? learnFromRuns = const $CopyWithPlaceholder(),
    Object? effort = const $CopyWithPlaceholder(),
    Object? recheckComplex = const $CopyWithPlaceholder(),
    Object? baselineChecks = const $CopyWithPlaceholder(),
    Object? secondOpinion = const $CopyWithPlaceholder(),
    Object? pauseAbove = const $CopyWithPlaceholder(),
    Object? parallel = const $CopyWithPlaceholder(),
    Object? git = const $CopyWithPlaceholder(),
    Object? notify = const $CopyWithPlaceholder(),
  }) {
    return Settings(
      models: models == const $CopyWithPlaceholder()
          ? _value.models
          // ignore: cast_nullable_to_non_nullable
          : models as StageModels,
      maxTurns: maxTurns == const $CopyWithPlaceholder()
          ? _value.maxTurns
          // ignore: cast_nullable_to_non_nullable
          : maxTurns as int,
      runBudget: runBudget == const $CopyWithPlaceholder()
          ? _value.runBudget
          // ignore: cast_nullable_to_non_nullable
          : runBudget as int?,
      timeoutMin: timeoutMin == const $CopyWithPlaceholder()
          ? _value.timeoutMin
          // ignore: cast_nullable_to_non_nullable
          : timeoutMin as int,
      allow: allow == const $CopyWithPlaceholder()
          ? _value.allow
          // ignore: cast_nullable_to_non_nullable
          : allow as List<String>,
      deny: deny == const $CopyWithPlaceholder()
          ? _value.deny
          // ignore: cast_nullable_to_non_nullable
          : deny as List<String>,
      askFirst: askFirst == const $CopyWithPlaceholder()
          ? _value.askFirst
          // ignore: cast_nullable_to_non_nullable
          : askFirst as bool,
      autoResume: autoResume == const $CopyWithPlaceholder()
          ? _value.autoResume
          // ignore: cast_nullable_to_non_nullable
          : autoResume as bool,
      autoLearn: autoLearn == const $CopyWithPlaceholder()
          ? _value.autoLearn
          // ignore: cast_nullable_to_non_nullable
          : autoLearn as bool?,
      autoReview: autoReview == const $CopyWithPlaceholder()
          ? _value.autoReview
          // ignore: cast_nullable_to_non_nullable
          : autoReview as bool?,
      autoPreview: autoPreview == const $CopyWithPlaceholder()
          ? _value.autoPreview
          // ignore: cast_nullable_to_non_nullable
          : autoPreview as bool?,
      visualCheck: visualCheck == const $CopyWithPlaceholder()
          ? _value.visualCheck
          // ignore: cast_nullable_to_non_nullable
          : visualCheck as bool?,
      autoBrief: autoBrief == const $CopyWithPlaceholder()
          ? _value.autoBrief
          // ignore: cast_nullable_to_non_nullable
          : autoBrief as bool?,
      publicDocuments: publicDocuments == const $CopyWithPlaceholder()
          ? _value.publicDocuments
          // ignore: cast_nullable_to_non_nullable
          : publicDocuments as bool?,
      selfReview: selfReview == const $CopyWithPlaceholder()
          ? _value.selfReview
          // ignore: cast_nullable_to_non_nullable
          : selfReview as bool?,
      reflect: reflect == const $CopyWithPlaceholder()
          ? _value.reflect
          // ignore: cast_nullable_to_non_nullable
          : reflect as bool?,
      egressAllow: egressAllow == const $CopyWithPlaceholder()
          ? _value.egressAllow
          // ignore: cast_nullable_to_non_nullable
          : egressAllow as List<String>?,
      suggestFollowUps: suggestFollowUps == const $CopyWithPlaceholder()
          ? _value.suggestFollowUps
          // ignore: cast_nullable_to_non_nullable
          : suggestFollowUps as bool?,
      maxTicketRepos: maxTicketRepos == const $CopyWithPlaceholder()
          ? _value.maxTicketRepos
          // ignore: cast_nullable_to_non_nullable
          : maxTicketRepos as int?,
      pullReviews: pullReviews == const $CopyWithPlaceholder()
          ? _value.pullReviews
          // ignore: cast_nullable_to_non_nullable
          : pullReviews as PullReviewSettings?,
      prComments: prComments == const $CopyWithPlaceholder()
          ? _value.prComments
          // ignore: cast_nullable_to_non_nullable
          : prComments as PRCommentSettings?,
      ci: ci == const $CopyWithPlaceholder()
          ? _value.ci
          // ignore: cast_nullable_to_non_nullable
          : ci as CISettings?,
      guard: guard == const $CopyWithPlaceholder()
          ? _value.guard
          // ignore: cast_nullable_to_non_nullable
          : guard as GuardSettings?,
      stalls: stalls == const $CopyWithPlaceholder()
          ? _value.stalls
          // ignore: cast_nullable_to_non_nullable
          : stalls as String?,
      proveFixes: proveFixes == const $CopyWithPlaceholder()
          ? _value.proveFixes
          // ignore: cast_nullable_to_non_nullable
          : proveFixes as bool?,
      methodSkills: methodSkills == const $CopyWithPlaceholder()
          ? _value.methodSkills
          // ignore: cast_nullable_to_non_nullable
          : methodSkills as bool?,
      deepReview: deepReview == const $CopyWithPlaceholder()
          ? _value.deepReview
          // ignore: cast_nullable_to_non_nullable
          : deepReview as String?,
      learnFromRuns: learnFromRuns == const $CopyWithPlaceholder()
          ? _value.learnFromRuns
          // ignore: cast_nullable_to_non_nullable
          : learnFromRuns as bool?,
      effort: effort == const $CopyWithPlaceholder()
          ? _value.effort
          // ignore: cast_nullable_to_non_nullable
          : effort as EffortSettings?,
      recheckComplex: recheckComplex == const $CopyWithPlaceholder()
          ? _value.recheckComplex
          // ignore: cast_nullable_to_non_nullable
          : recheckComplex as bool?,
      baselineChecks: baselineChecks == const $CopyWithPlaceholder()
          ? _value.baselineChecks
          // ignore: cast_nullable_to_non_nullable
          : baselineChecks as bool?,
      secondOpinion: secondOpinion == const $CopyWithPlaceholder()
          ? _value.secondOpinion
          // ignore: cast_nullable_to_non_nullable
          : secondOpinion as String?,
      pauseAbove: pauseAbove == const $CopyWithPlaceholder()
          ? _value.pauseAbove
          // ignore: cast_nullable_to_non_nullable
          : pauseAbove as int,
      parallel: parallel == const $CopyWithPlaceholder()
          ? _value.parallel
          // ignore: cast_nullable_to_non_nullable
          : parallel as int,
      git: git == const $CopyWithPlaceholder()
          ? _value.git
          // ignore: cast_nullable_to_non_nullable
          : git as GitSettings,
      notify: notify == const $CopyWithPlaceholder()
          ? _value.notify
          // ignore: cast_nullable_to_non_nullable
          : notify as NotifySettings?,
    );
  }
}

extension $SettingsCopyWith on Settings {
  /// Returns a callable class that can be used as follows: `instanceOfSettings.copyWith(...)` or like so:`instanceOfSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SettingsCWProxy get copyWith => _$SettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('Settings', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'models',
      'maxTurns',
      'timeoutMin',
      'allow',
      'deny',
      'askFirst',
      'autoResume',
      'pauseAbove',
      'parallel',
      'git',
    ],
  );
  final val = Settings(
    models: $checkedConvert(
      'models',
      (v) => StageModels.fromJson(v as Map<String, dynamic>),
    ),
    maxTurns: $checkedConvert('maxTurns', (v) => (v as num).toInt()),
    runBudget: $checkedConvert('runBudget', (v) => (v as num?)?.toInt()),
    timeoutMin: $checkedConvert('timeoutMin', (v) => (v as num).toInt()),
    allow: $checkedConvert(
      'allow',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    deny: $checkedConvert(
      'deny',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    askFirst: $checkedConvert('askFirst', (v) => v as bool),
    autoResume: $checkedConvert('autoResume', (v) => v as bool),
    autoLearn: $checkedConvert('autoLearn', (v) => v as bool?),
    autoReview: $checkedConvert('autoReview', (v) => v as bool?),
    autoPreview: $checkedConvert('autoPreview', (v) => v as bool?),
    visualCheck: $checkedConvert('visualCheck', (v) => v as bool?),
    autoBrief: $checkedConvert('autoBrief', (v) => v as bool?),
    publicDocuments: $checkedConvert('publicDocuments', (v) => v as bool?),
    selfReview: $checkedConvert('selfReview', (v) => v as bool?),
    reflect: $checkedConvert('reflect', (v) => v as bool?),
    egressAllow: $checkedConvert(
      'egressAllow',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    suggestFollowUps: $checkedConvert('suggestFollowUps', (v) => v as bool?),
    maxTicketRepos: $checkedConvert(
      'maxTicketRepos',
      (v) => (v as num?)?.toInt(),
    ),
    pullReviews: $checkedConvert(
      'pullReviews',
      (v) => v == null
          ? null
          : PullReviewSettings.fromJson(v as Map<String, dynamic>),
    ),
    prComments: $checkedConvert(
      'prComments',
      (v) => v == null
          ? null
          : PRCommentSettings.fromJson(v as Map<String, dynamic>),
    ),
    ci: $checkedConvert(
      'ci',
      (v) => v == null ? null : CISettings.fromJson(v as Map<String, dynamic>),
    ),
    guard: $checkedConvert(
      'guard',
      (v) =>
          v == null ? null : GuardSettings.fromJson(v as Map<String, dynamic>),
    ),
    stalls: $checkedConvert('stalls', (v) => v as String?),
    proveFixes: $checkedConvert('proveFixes', (v) => v as bool?),
    methodSkills: $checkedConvert('methodSkills', (v) => v as bool?),
    deepReview: $checkedConvert('deepReview', (v) => v as String?),
    learnFromRuns: $checkedConvert('learnFromRuns', (v) => v as bool?),
    effort: $checkedConvert(
      'effort',
      (v) =>
          v == null ? null : EffortSettings.fromJson(v as Map<String, dynamic>),
    ),
    recheckComplex: $checkedConvert('recheckComplex', (v) => v as bool?),
    baselineChecks: $checkedConvert('baselineChecks', (v) => v as bool?),
    secondOpinion: $checkedConvert('secondOpinion', (v) => v as String?),
    pauseAbove: $checkedConvert('pauseAbove', (v) => (v as num).toInt()),
    parallel: $checkedConvert('parallel', (v) => (v as num).toInt()),
    git: $checkedConvert(
      'git',
      (v) => GitSettings.fromJson(v as Map<String, dynamic>),
    ),
    notify: $checkedConvert(
      'notify',
      (v) =>
          v == null ? null : NotifySettings.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
  'models': instance.models.toJson(),
  'maxTurns': instance.maxTurns,
  'runBudget': ?instance.runBudget,
  'timeoutMin': instance.timeoutMin,
  'allow': instance.allow,
  'deny': instance.deny,
  'askFirst': instance.askFirst,
  'autoResume': instance.autoResume,
  'autoLearn': ?instance.autoLearn,
  'autoReview': ?instance.autoReview,
  'autoPreview': ?instance.autoPreview,
  'visualCheck': ?instance.visualCheck,
  'autoBrief': ?instance.autoBrief,
  'publicDocuments': ?instance.publicDocuments,
  'selfReview': ?instance.selfReview,
  'reflect': ?instance.reflect,
  'egressAllow': ?instance.egressAllow,
  'suggestFollowUps': ?instance.suggestFollowUps,
  'maxTicketRepos': ?instance.maxTicketRepos,
  'pullReviews': ?instance.pullReviews?.toJson(),
  'prComments': ?instance.prComments?.toJson(),
  'ci': ?instance.ci?.toJson(),
  'guard': ?instance.guard?.toJson(),
  'stalls': ?instance.stalls,
  'proveFixes': ?instance.proveFixes,
  'methodSkills': ?instance.methodSkills,
  'deepReview': ?instance.deepReview,
  'learnFromRuns': ?instance.learnFromRuns,
  'effort': ?instance.effort?.toJson(),
  'recheckComplex': ?instance.recheckComplex,
  'baselineChecks': ?instance.baselineChecks,
  'secondOpinion': ?instance.secondOpinion,
  'pauseAbove': instance.pauseAbove,
  'parallel': instance.parallel,
  'git': instance.git.toJson(),
  'notify': ?instance.notify?.toJson(),
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SettingsCWProxy {
  Settings models(StageModels models);

  Settings maxTurns(int maxTurns);

  Settings timeoutMin(int timeoutMin);

  Settings allow(List<String> allow);

  Settings deny(List<String> deny);

  Settings askFirst(bool askFirst);

  Settings autoResume(bool autoResume);

  Settings autoLearn(bool? autoLearn);

  Settings autoReview(bool? autoReview);

  Settings autoPreview(bool? autoPreview);

  Settings visualCheck(bool? visualCheck);

  Settings egressAllow(List<String>? egressAllow);

  Settings suggestFollowUps(bool? suggestFollowUps);

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
    int timeoutMin,
    List<String> allow,
    List<String> deny,
    bool askFirst,
    bool autoResume,
    bool? autoLearn,
    bool? autoReview,
    bool? autoPreview,
    bool? visualCheck,
    List<String>? egressAllow,
    bool? suggestFollowUps,
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
  Settings egressAllow(List<String>? egressAllow) =>
      this(egressAllow: egressAllow);

  @override
  Settings suggestFollowUps(bool? suggestFollowUps) =>
      this(suggestFollowUps: suggestFollowUps);

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
    Object? timeoutMin = const $CopyWithPlaceholder(),
    Object? allow = const $CopyWithPlaceholder(),
    Object? deny = const $CopyWithPlaceholder(),
    Object? askFirst = const $CopyWithPlaceholder(),
    Object? autoResume = const $CopyWithPlaceholder(),
    Object? autoLearn = const $CopyWithPlaceholder(),
    Object? autoReview = const $CopyWithPlaceholder(),
    Object? autoPreview = const $CopyWithPlaceholder(),
    Object? visualCheck = const $CopyWithPlaceholder(),
    Object? egressAllow = const $CopyWithPlaceholder(),
    Object? suggestFollowUps = const $CopyWithPlaceholder(),
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
      egressAllow: egressAllow == const $CopyWithPlaceholder()
          ? _value.egressAllow
          // ignore: cast_nullable_to_non_nullable
          : egressAllow as List<String>?,
      suggestFollowUps: suggestFollowUps == const $CopyWithPlaceholder()
          ? _value.suggestFollowUps
          // ignore: cast_nullable_to_non_nullable
          : suggestFollowUps as bool?,
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
    egressAllow: $checkedConvert(
      'egressAllow',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    suggestFollowUps: $checkedConvert('suggestFollowUps', (v) => v as bool?),
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
  'timeoutMin': instance.timeoutMin,
  'allow': instance.allow,
  'deny': instance.deny,
  'askFirst': instance.askFirst,
  'autoResume': instance.autoResume,
  'autoLearn': ?instance.autoLearn,
  'autoReview': ?instance.autoReview,
  'autoPreview': ?instance.autoPreview,
  'visualCheck': ?instance.visualCheck,
  'egressAllow': ?instance.egressAllow,
  'suggestFollowUps': ?instance.suggestFollowUps,
  'pauseAbove': instance.pauseAbove,
  'parallel': instance.parallel,
  'git': instance.git.toJson(),
  'notify': ?instance.notify?.toJson(),
};

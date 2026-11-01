// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notify_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NotifySettingsCWProxy {
  NotifySettings push(bool push);

  NotifySettings telegram(bool telegram);

  NotifySettings needsYou(bool needsYou);

  NotifySettings stopped(bool stopped);

  NotifySettings done(bool done);

  NotifySettings progress(bool? progress);

  NotifySettings lessons(bool? lessons);

  NotifySettings review(bool? review);

  NotifySettings preview(bool? preview);

  NotifySettings previewPhotos(bool? previewPhotos);

  NotifySettings followUps(bool? followUps);

  NotifySettings ci(bool? ci);

  NotifySettings logs(bool? logs);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NotifySettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NotifySettings(...).copyWith(id: 12, name: "My name")
  /// ````
  NotifySettings call({
    bool push,
    bool telegram,
    bool needsYou,
    bool stopped,
    bool done,
    bool? progress,
    bool? lessons,
    bool? review,
    bool? preview,
    bool? previewPhotos,
    bool? followUps,
    bool? ci,
    bool? logs,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNotifySettings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNotifySettings.copyWith.fieldName(...)`
class _$NotifySettingsCWProxyImpl implements _$NotifySettingsCWProxy {
  const _$NotifySettingsCWProxyImpl(this._value);

  final NotifySettings _value;

  @override
  NotifySettings push(bool push) => this(push: push);

  @override
  NotifySettings telegram(bool telegram) => this(telegram: telegram);

  @override
  NotifySettings needsYou(bool needsYou) => this(needsYou: needsYou);

  @override
  NotifySettings stopped(bool stopped) => this(stopped: stopped);

  @override
  NotifySettings done(bool done) => this(done: done);

  @override
  NotifySettings progress(bool? progress) => this(progress: progress);

  @override
  NotifySettings lessons(bool? lessons) => this(lessons: lessons);

  @override
  NotifySettings review(bool? review) => this(review: review);

  @override
  NotifySettings preview(bool? preview) => this(preview: preview);

  @override
  NotifySettings previewPhotos(bool? previewPhotos) =>
      this(previewPhotos: previewPhotos);

  @override
  NotifySettings followUps(bool? followUps) => this(followUps: followUps);

  @override
  NotifySettings ci(bool? ci) => this(ci: ci);

  @override
  NotifySettings logs(bool? logs) => this(logs: logs);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NotifySettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NotifySettings(...).copyWith(id: 12, name: "My name")
  /// ````
  NotifySettings call({
    Object? push = const $CopyWithPlaceholder(),
    Object? telegram = const $CopyWithPlaceholder(),
    Object? needsYou = const $CopyWithPlaceholder(),
    Object? stopped = const $CopyWithPlaceholder(),
    Object? done = const $CopyWithPlaceholder(),
    Object? progress = const $CopyWithPlaceholder(),
    Object? lessons = const $CopyWithPlaceholder(),
    Object? review = const $CopyWithPlaceholder(),
    Object? preview = const $CopyWithPlaceholder(),
    Object? previewPhotos = const $CopyWithPlaceholder(),
    Object? followUps = const $CopyWithPlaceholder(),
    Object? ci = const $CopyWithPlaceholder(),
    Object? logs = const $CopyWithPlaceholder(),
  }) {
    return NotifySettings(
      push: push == const $CopyWithPlaceholder()
          ? _value.push
          // ignore: cast_nullable_to_non_nullable
          : push as bool,
      telegram: telegram == const $CopyWithPlaceholder()
          ? _value.telegram
          // ignore: cast_nullable_to_non_nullable
          : telegram as bool,
      needsYou: needsYou == const $CopyWithPlaceholder()
          ? _value.needsYou
          // ignore: cast_nullable_to_non_nullable
          : needsYou as bool,
      stopped: stopped == const $CopyWithPlaceholder()
          ? _value.stopped
          // ignore: cast_nullable_to_non_nullable
          : stopped as bool,
      done: done == const $CopyWithPlaceholder()
          ? _value.done
          // ignore: cast_nullable_to_non_nullable
          : done as bool,
      progress: progress == const $CopyWithPlaceholder()
          ? _value.progress
          // ignore: cast_nullable_to_non_nullable
          : progress as bool?,
      lessons: lessons == const $CopyWithPlaceholder()
          ? _value.lessons
          // ignore: cast_nullable_to_non_nullable
          : lessons as bool?,
      review: review == const $CopyWithPlaceholder()
          ? _value.review
          // ignore: cast_nullable_to_non_nullable
          : review as bool?,
      preview: preview == const $CopyWithPlaceholder()
          ? _value.preview
          // ignore: cast_nullable_to_non_nullable
          : preview as bool?,
      previewPhotos: previewPhotos == const $CopyWithPlaceholder()
          ? _value.previewPhotos
          // ignore: cast_nullable_to_non_nullable
          : previewPhotos as bool?,
      followUps: followUps == const $CopyWithPlaceholder()
          ? _value.followUps
          // ignore: cast_nullable_to_non_nullable
          : followUps as bool?,
      ci: ci == const $CopyWithPlaceholder()
          ? _value.ci
          // ignore: cast_nullable_to_non_nullable
          : ci as bool?,
      logs: logs == const $CopyWithPlaceholder()
          ? _value.logs
          // ignore: cast_nullable_to_non_nullable
          : logs as bool?,
    );
  }
}

extension $NotifySettingsCopyWith on NotifySettings {
  /// Returns a callable class that can be used as follows: `instanceOfNotifySettings.copyWith(...)` or like so:`instanceOfNotifySettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NotifySettingsCWProxy get copyWith => _$NotifySettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotifySettings _$NotifySettingsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('NotifySettings', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['push', 'telegram', 'needsYou', 'stopped', 'done'],
      );
      final val = NotifySettings(
        push: $checkedConvert('push', (v) => v as bool),
        telegram: $checkedConvert('telegram', (v) => v as bool),
        needsYou: $checkedConvert('needsYou', (v) => v as bool),
        stopped: $checkedConvert('stopped', (v) => v as bool),
        done: $checkedConvert('done', (v) => v as bool),
        progress: $checkedConvert('progress', (v) => v as bool?),
        lessons: $checkedConvert('lessons', (v) => v as bool?),
        review: $checkedConvert('review', (v) => v as bool?),
        preview: $checkedConvert('preview', (v) => v as bool?),
        previewPhotos: $checkedConvert('previewPhotos', (v) => v as bool?),
        followUps: $checkedConvert('followUps', (v) => v as bool?),
        ci: $checkedConvert('ci', (v) => v as bool?),
        logs: $checkedConvert('logs', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$NotifySettingsToJson(NotifySettings instance) =>
    <String, dynamic>{
      'push': instance.push,
      'telegram': instance.telegram,
      'needsYou': instance.needsYou,
      'stopped': instance.stopped,
      'done': instance.done,
      'progress': ?instance.progress,
      'lessons': ?instance.lessons,
      'review': ?instance.review,
      'preview': ?instance.preview,
      'previewPhotos': ?instance.previewPhotos,
      'followUps': ?instance.followUps,
      'ci': ?instance.ci,
      'logs': ?instance.logs,
    };

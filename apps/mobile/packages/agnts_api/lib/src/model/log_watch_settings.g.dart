// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_watch_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LogWatchSettingsCWProxy {
  LogWatchSettings errors(LogMode errors);

  LogWatchSettings security(LogMode security);

  LogWatchSettings alwaysNotifyLeaks(bool alwaysNotifyLeaks);

  LogWatchSettings minSeverity(LogSeverity minSeverity);

  LogWatchSettings threshold(int threshold);

  LogWatchSettings maxAutoPerDay(int maxAutoPerDay);

  LogWatchSettings attackTicketAfter(int attackTicketAfter);

  LogWatchSettings resolveAfterDays(int resolveAfterDays);

  LogWatchSettings digest(bool digest);

  LogWatchSettings triagePerDay(int triagePerDay);

  LogWatchSettings patterns(List<LogPattern> patterns);

  LogWatchSettings overrides(List<LogOverride> overrides);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogWatchSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogWatchSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  LogWatchSettings call({
    LogMode errors,
    LogMode security,
    bool alwaysNotifyLeaks,
    LogSeverity minSeverity,
    int threshold,
    int maxAutoPerDay,
    int attackTicketAfter,
    int resolveAfterDays,
    bool digest,
    int triagePerDay,
    List<LogPattern> patterns,
    List<LogOverride> overrides,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLogWatchSettings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLogWatchSettings.copyWith.fieldName(...)`
class _$LogWatchSettingsCWProxyImpl implements _$LogWatchSettingsCWProxy {
  const _$LogWatchSettingsCWProxyImpl(this._value);

  final LogWatchSettings _value;

  @override
  LogWatchSettings errors(LogMode errors) => this(errors: errors);

  @override
  LogWatchSettings security(LogMode security) => this(security: security);

  @override
  LogWatchSettings alwaysNotifyLeaks(bool alwaysNotifyLeaks) =>
      this(alwaysNotifyLeaks: alwaysNotifyLeaks);

  @override
  LogWatchSettings minSeverity(LogSeverity minSeverity) =>
      this(minSeverity: minSeverity);

  @override
  LogWatchSettings threshold(int threshold) => this(threshold: threshold);

  @override
  LogWatchSettings maxAutoPerDay(int maxAutoPerDay) =>
      this(maxAutoPerDay: maxAutoPerDay);

  @override
  LogWatchSettings attackTicketAfter(int attackTicketAfter) =>
      this(attackTicketAfter: attackTicketAfter);

  @override
  LogWatchSettings resolveAfterDays(int resolveAfterDays) =>
      this(resolveAfterDays: resolveAfterDays);

  @override
  LogWatchSettings digest(bool digest) => this(digest: digest);

  @override
  LogWatchSettings triagePerDay(int triagePerDay) =>
      this(triagePerDay: triagePerDay);

  @override
  LogWatchSettings patterns(List<LogPattern> patterns) =>
      this(patterns: patterns);

  @override
  LogWatchSettings overrides(List<LogOverride> overrides) =>
      this(overrides: overrides);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogWatchSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogWatchSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  LogWatchSettings call({
    Object? errors = const $CopyWithPlaceholder(),
    Object? security = const $CopyWithPlaceholder(),
    Object? alwaysNotifyLeaks = const $CopyWithPlaceholder(),
    Object? minSeverity = const $CopyWithPlaceholder(),
    Object? threshold = const $CopyWithPlaceholder(),
    Object? maxAutoPerDay = const $CopyWithPlaceholder(),
    Object? attackTicketAfter = const $CopyWithPlaceholder(),
    Object? resolveAfterDays = const $CopyWithPlaceholder(),
    Object? digest = const $CopyWithPlaceholder(),
    Object? triagePerDay = const $CopyWithPlaceholder(),
    Object? patterns = const $CopyWithPlaceholder(),
    Object? overrides = const $CopyWithPlaceholder(),
  }) {
    return LogWatchSettings(
      errors: errors == const $CopyWithPlaceholder()
          ? _value.errors
          // ignore: cast_nullable_to_non_nullable
          : errors as LogMode,
      security: security == const $CopyWithPlaceholder()
          ? _value.security
          // ignore: cast_nullable_to_non_nullable
          : security as LogMode,
      alwaysNotifyLeaks: alwaysNotifyLeaks == const $CopyWithPlaceholder()
          ? _value.alwaysNotifyLeaks
          // ignore: cast_nullable_to_non_nullable
          : alwaysNotifyLeaks as bool,
      minSeverity: minSeverity == const $CopyWithPlaceholder()
          ? _value.minSeverity
          // ignore: cast_nullable_to_non_nullable
          : minSeverity as LogSeverity,
      threshold: threshold == const $CopyWithPlaceholder()
          ? _value.threshold
          // ignore: cast_nullable_to_non_nullable
          : threshold as int,
      maxAutoPerDay: maxAutoPerDay == const $CopyWithPlaceholder()
          ? _value.maxAutoPerDay
          // ignore: cast_nullable_to_non_nullable
          : maxAutoPerDay as int,
      attackTicketAfter: attackTicketAfter == const $CopyWithPlaceholder()
          ? _value.attackTicketAfter
          // ignore: cast_nullable_to_non_nullable
          : attackTicketAfter as int,
      resolveAfterDays: resolveAfterDays == const $CopyWithPlaceholder()
          ? _value.resolveAfterDays
          // ignore: cast_nullable_to_non_nullable
          : resolveAfterDays as int,
      digest: digest == const $CopyWithPlaceholder()
          ? _value.digest
          // ignore: cast_nullable_to_non_nullable
          : digest as bool,
      triagePerDay: triagePerDay == const $CopyWithPlaceholder()
          ? _value.triagePerDay
          // ignore: cast_nullable_to_non_nullable
          : triagePerDay as int,
      patterns: patterns == const $CopyWithPlaceholder()
          ? _value.patterns
          // ignore: cast_nullable_to_non_nullable
          : patterns as List<LogPattern>,
      overrides: overrides == const $CopyWithPlaceholder()
          ? _value.overrides
          // ignore: cast_nullable_to_non_nullable
          : overrides as List<LogOverride>,
    );
  }
}

extension $LogWatchSettingsCopyWith on LogWatchSettings {
  /// Returns a callable class that can be used as follows: `instanceOfLogWatchSettings.copyWith(...)` or like so:`instanceOfLogWatchSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LogWatchSettingsCWProxy get copyWith => _$LogWatchSettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogWatchSettings _$LogWatchSettingsFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('LogWatchSettings', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'errors',
      'security',
      'alwaysNotifyLeaks',
      'minSeverity',
      'threshold',
      'maxAutoPerDay',
      'attackTicketAfter',
      'resolveAfterDays',
      'digest',
      'triagePerDay',
      'patterns',
      'overrides',
    ],
  );
  final val = LogWatchSettings(
    errors: $checkedConvert('errors', (v) => $enumDecode(_$LogModeEnumMap, v)),
    security: $checkedConvert(
      'security',
      (v) => $enumDecode(_$LogModeEnumMap, v),
    ),
    alwaysNotifyLeaks: $checkedConvert('alwaysNotifyLeaks', (v) => v as bool),
    minSeverity: $checkedConvert(
      'minSeverity',
      (v) => $enumDecode(_$LogSeverityEnumMap, v),
    ),
    threshold: $checkedConvert('threshold', (v) => (v as num).toInt()),
    maxAutoPerDay: $checkedConvert('maxAutoPerDay', (v) => (v as num).toInt()),
    attackTicketAfter: $checkedConvert(
      'attackTicketAfter',
      (v) => (v as num).toInt(),
    ),
    resolveAfterDays: $checkedConvert(
      'resolveAfterDays',
      (v) => (v as num).toInt(),
    ),
    digest: $checkedConvert('digest', (v) => v as bool),
    triagePerDay: $checkedConvert('triagePerDay', (v) => (v as num).toInt()),
    patterns: $checkedConvert(
      'patterns',
      (v) => (v as List<dynamic>)
          .map((e) => LogPattern.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    overrides: $checkedConvert(
      'overrides',
      (v) => (v as List<dynamic>)
          .map((e) => LogOverride.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$LogWatchSettingsToJson(LogWatchSettings instance) =>
    <String, dynamic>{
      'errors': _$LogModeEnumMap[instance.errors]!,
      'security': _$LogModeEnumMap[instance.security]!,
      'alwaysNotifyLeaks': instance.alwaysNotifyLeaks,
      'minSeverity': _$LogSeverityEnumMap[instance.minSeverity]!,
      'threshold': instance.threshold,
      'maxAutoPerDay': instance.maxAutoPerDay,
      'attackTicketAfter': instance.attackTicketAfter,
      'resolveAfterDays': instance.resolveAfterDays,
      'digest': instance.digest,
      'triagePerDay': instance.triagePerDay,
      'patterns': instance.patterns.map((e) => e.toJson()).toList(),
      'overrides': instance.overrides.map((e) => e.toJson()).toList(),
    };

const _$LogModeEnumMap = {
  LogMode.false_: 'false',
  LogMode.report: 'report',
  LogMode.ticket: 'ticket',
};

const _$LogSeverityEnumMap = {
  LogSeverity.low: 'low',
  LogSeverity.medium: 'medium',
  LogSeverity.high: 'high',
  LogSeverity.critical: 'critical',
};

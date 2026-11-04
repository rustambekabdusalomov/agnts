// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SecuritySettingsCWProxy {
  SecuritySettings schedule(SecuritySettingsScheduleEnum schedule);

  SecuritySettings exclude(List<String> exclude);

  SecuritySettings minNotify(SecSeverity minNotify);

  SecuritySettings nextAt(DateTime? nextAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SecuritySettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SecuritySettings(...).copyWith(id: 12, name: "My name")
  /// ````
  SecuritySettings call({
    SecuritySettingsScheduleEnum schedule,
    List<String> exclude,
    SecSeverity minNotify,
    DateTime? nextAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSecuritySettings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSecuritySettings.copyWith.fieldName(...)`
class _$SecuritySettingsCWProxyImpl implements _$SecuritySettingsCWProxy {
  const _$SecuritySettingsCWProxyImpl(this._value);

  final SecuritySettings _value;

  @override
  SecuritySettings schedule(SecuritySettingsScheduleEnum schedule) =>
      this(schedule: schedule);

  @override
  SecuritySettings exclude(List<String> exclude) => this(exclude: exclude);

  @override
  SecuritySettings minNotify(SecSeverity minNotify) =>
      this(minNotify: minNotify);

  @override
  SecuritySettings nextAt(DateTime? nextAt) => this(nextAt: nextAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SecuritySettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SecuritySettings(...).copyWith(id: 12, name: "My name")
  /// ````
  SecuritySettings call({
    Object? schedule = const $CopyWithPlaceholder(),
    Object? exclude = const $CopyWithPlaceholder(),
    Object? minNotify = const $CopyWithPlaceholder(),
    Object? nextAt = const $CopyWithPlaceholder(),
  }) {
    return SecuritySettings(
      schedule: schedule == const $CopyWithPlaceholder()
          ? _value.schedule
          // ignore: cast_nullable_to_non_nullable
          : schedule as SecuritySettingsScheduleEnum,
      exclude: exclude == const $CopyWithPlaceholder()
          ? _value.exclude
          // ignore: cast_nullable_to_non_nullable
          : exclude as List<String>,
      minNotify: minNotify == const $CopyWithPlaceholder()
          ? _value.minNotify
          // ignore: cast_nullable_to_non_nullable
          : minNotify as SecSeverity,
      nextAt: nextAt == const $CopyWithPlaceholder()
          ? _value.nextAt
          // ignore: cast_nullable_to_non_nullable
          : nextAt as DateTime?,
    );
  }
}

extension $SecuritySettingsCopyWith on SecuritySettings {
  /// Returns a callable class that can be used as follows: `instanceOfSecuritySettings.copyWith(...)` or like so:`instanceOfSecuritySettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SecuritySettingsCWProxy get copyWith => _$SecuritySettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SecuritySettings _$SecuritySettingsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SecuritySettings', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['schedule', 'exclude', 'minNotify'],
      );
      final val = SecuritySettings(
        schedule: $checkedConvert(
          'schedule',
          (v) => $enumDecode(_$SecuritySettingsScheduleEnumEnumMap, v),
        ),
        exclude: $checkedConvert(
          'exclude',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        minNotify: $checkedConvert(
          'minNotify',
          (v) => $enumDecode(_$SecSeverityEnumMap, v),
        ),
        nextAt: $checkedConvert(
          'nextAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SecuritySettingsToJson(SecuritySettings instance) =>
    <String, dynamic>{
      'schedule': _$SecuritySettingsScheduleEnumEnumMap[instance.schedule]!,
      'exclude': instance.exclude,
      'minNotify': _$SecSeverityEnumMap[instance.minNotify]!,
      'nextAt': ?instance.nextAt?.toIso8601String(),
    };

const _$SecuritySettingsScheduleEnumEnumMap = {
  SecuritySettingsScheduleEnum.off: 'off',
  SecuritySettingsScheduleEnum.daily: 'daily',
  SecuritySettingsScheduleEnum.weekly: 'weekly',
};

const _$SecSeverityEnumMap = {
  SecSeverity.critical: 'critical',
  SecSeverity.high: 'high',
  SecSeverity.medium: 'medium',
  SecSeverity.low: 'low',
  SecSeverity.info: 'info',
};

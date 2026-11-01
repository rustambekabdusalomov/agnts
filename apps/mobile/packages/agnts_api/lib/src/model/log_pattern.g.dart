// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_pattern.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LogPatternCWProxy {
  LogPattern name(String name);

  LogPattern pattern(String pattern);

  LogPattern category(LogPatternCategoryEnum category);

  LogPattern severity(LogSeverity severity);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogPattern(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogPattern(...).copyWith(id: 12, name: "My name")
  /// ````
  LogPattern call({
    String name,
    String pattern,
    LogPatternCategoryEnum category,
    LogSeverity severity,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLogPattern.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLogPattern.copyWith.fieldName(...)`
class _$LogPatternCWProxyImpl implements _$LogPatternCWProxy {
  const _$LogPatternCWProxyImpl(this._value);

  final LogPattern _value;

  @override
  LogPattern name(String name) => this(name: name);

  @override
  LogPattern pattern(String pattern) => this(pattern: pattern);

  @override
  LogPattern category(LogPatternCategoryEnum category) =>
      this(category: category);

  @override
  LogPattern severity(LogSeverity severity) => this(severity: severity);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogPattern(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogPattern(...).copyWith(id: 12, name: "My name")
  /// ````
  LogPattern call({
    Object? name = const $CopyWithPlaceholder(),
    Object? pattern = const $CopyWithPlaceholder(),
    Object? category = const $CopyWithPlaceholder(),
    Object? severity = const $CopyWithPlaceholder(),
  }) {
    return LogPattern(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      pattern: pattern == const $CopyWithPlaceholder()
          ? _value.pattern
          // ignore: cast_nullable_to_non_nullable
          : pattern as String,
      category: category == const $CopyWithPlaceholder()
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as LogPatternCategoryEnum,
      severity: severity == const $CopyWithPlaceholder()
          ? _value.severity
          // ignore: cast_nullable_to_non_nullable
          : severity as LogSeverity,
    );
  }
}

extension $LogPatternCopyWith on LogPattern {
  /// Returns a callable class that can be used as follows: `instanceOfLogPattern.copyWith(...)` or like so:`instanceOfLogPattern.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LogPatternCWProxy get copyWith => _$LogPatternCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogPattern _$LogPatternFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LogPattern', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['name', 'pattern', 'category', 'severity'],
      );
      final val = LogPattern(
        name: $checkedConvert('name', (v) => v as String),
        pattern: $checkedConvert('pattern', (v) => v as String),
        category: $checkedConvert(
          'category',
          (v) => $enumDecode(_$LogPatternCategoryEnumEnumMap, v),
        ),
        severity: $checkedConvert(
          'severity',
          (v) => $enumDecode(_$LogSeverityEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$LogPatternToJson(LogPattern instance) =>
    <String, dynamic>{
      'name': instance.name,
      'pattern': instance.pattern,
      'category': _$LogPatternCategoryEnumEnumMap[instance.category]!,
      'severity': _$LogSeverityEnumMap[instance.severity]!,
    };

const _$LogPatternCategoryEnumEnumMap = {
  LogPatternCategoryEnum.error: 'error',
  LogPatternCategoryEnum.security: 'security',
};

const _$LogSeverityEnumMap = {
  LogSeverity.low: 'low',
  LogSeverity.medium: 'medium',
  LogSeverity.high: 'high',
  LogSeverity.critical: 'critical',
};

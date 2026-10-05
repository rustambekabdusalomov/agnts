// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finding.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FindingCWProxy {
  Finding severity(FindingSeverityEnum severity);

  Finding category(FindingCategoryEnum category);

  Finding file(String? file);

  Finding line(int? line);

  Finding title(String title);

  Finding detail(String? detail);

  Finding suggestion(String? suggestion);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Finding(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Finding(...).copyWith(id: 12, name: "My name")
  /// ````
  Finding call({
    FindingSeverityEnum severity,
    FindingCategoryEnum category,
    String? file,
    int? line,
    String title,
    String? detail,
    String? suggestion,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFinding.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFinding.copyWith.fieldName(...)`
class _$FindingCWProxyImpl implements _$FindingCWProxy {
  const _$FindingCWProxyImpl(this._value);

  final Finding _value;

  @override
  Finding severity(FindingSeverityEnum severity) => this(severity: severity);

  @override
  Finding category(FindingCategoryEnum category) => this(category: category);

  @override
  Finding file(String? file) => this(file: file);

  @override
  Finding line(int? line) => this(line: line);

  @override
  Finding title(String title) => this(title: title);

  @override
  Finding detail(String? detail) => this(detail: detail);

  @override
  Finding suggestion(String? suggestion) => this(suggestion: suggestion);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Finding(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Finding(...).copyWith(id: 12, name: "My name")
  /// ````
  Finding call({
    Object? severity = const $CopyWithPlaceholder(),
    Object? category = const $CopyWithPlaceholder(),
    Object? file = const $CopyWithPlaceholder(),
    Object? line = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? detail = const $CopyWithPlaceholder(),
    Object? suggestion = const $CopyWithPlaceholder(),
  }) {
    return Finding(
      severity: severity == const $CopyWithPlaceholder()
          ? _value.severity
          // ignore: cast_nullable_to_non_nullable
          : severity as FindingSeverityEnum,
      category: category == const $CopyWithPlaceholder()
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as FindingCategoryEnum,
      file: file == const $CopyWithPlaceholder()
          ? _value.file
          // ignore: cast_nullable_to_non_nullable
          : file as String?,
      line: line == const $CopyWithPlaceholder()
          ? _value.line
          // ignore: cast_nullable_to_non_nullable
          : line as int?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      detail: detail == const $CopyWithPlaceholder()
          ? _value.detail
          // ignore: cast_nullable_to_non_nullable
          : detail as String?,
      suggestion: suggestion == const $CopyWithPlaceholder()
          ? _value.suggestion
          // ignore: cast_nullable_to_non_nullable
          : suggestion as String?,
    );
  }
}

extension $FindingCopyWith on Finding {
  /// Returns a callable class that can be used as follows: `instanceOfFinding.copyWith(...)` or like so:`instanceOfFinding.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FindingCWProxy get copyWith => _$FindingCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Finding _$FindingFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Finding', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['severity', 'category', 'title']);
      final val = Finding(
        severity: $checkedConvert(
          'severity',
          (v) => $enumDecode(_$FindingSeverityEnumEnumMap, v),
        ),
        category: $checkedConvert(
          'category',
          (v) => $enumDecode(_$FindingCategoryEnumEnumMap, v),
        ),
        file: $checkedConvert('file', (v) => v as String?),
        line: $checkedConvert('line', (v) => (v as num?)?.toInt()),
        title: $checkedConvert('title', (v) => v as String),
        detail: $checkedConvert('detail', (v) => v as String?),
        suggestion: $checkedConvert('suggestion', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$FindingToJson(Finding instance) => <String, dynamic>{
  'severity': _$FindingSeverityEnumEnumMap[instance.severity]!,
  'category': _$FindingCategoryEnumEnumMap[instance.category]!,
  'file': ?instance.file,
  'line': ?instance.line,
  'title': instance.title,
  'detail': ?instance.detail,
  'suggestion': ?instance.suggestion,
};

const _$FindingSeverityEnumEnumMap = {
  FindingSeverityEnum.blocker: 'blocker',
  FindingSeverityEnum.major: 'major',
  FindingSeverityEnum.minor: 'minor',
  FindingSeverityEnum.nit: 'nit',
};

const _$FindingCategoryEnumEnumMap = {
  FindingCategoryEnum.correctness: 'correctness',
  FindingCategoryEnum.security: 'security',
  FindingCategoryEnum.performance: 'performance',
  FindingCategoryEnum.tests: 'tests',
  FindingCategoryEnum.rules: 'rules',
  FindingCategoryEnum.maintainability: 'maintainability',
  FindingCategoryEnum.accuracy: 'accuracy',
  FindingCategoryEnum.completeness: 'completeness',
  FindingCategoryEnum.other: 'other',
};

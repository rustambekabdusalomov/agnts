// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preview_issue.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PreviewIssueCWProxy {
  PreviewIssue severity(PreviewIssueSeverityEnum severity);

  PreviewIssue description(String description);

  PreviewIssue shotId(String? shotId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PreviewIssue(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PreviewIssue(...).copyWith(id: 12, name: "My name")
  /// ````
  PreviewIssue call({
    PreviewIssueSeverityEnum severity,
    String description,
    String? shotId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPreviewIssue.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPreviewIssue.copyWith.fieldName(...)`
class _$PreviewIssueCWProxyImpl implements _$PreviewIssueCWProxy {
  const _$PreviewIssueCWProxyImpl(this._value);

  final PreviewIssue _value;

  @override
  PreviewIssue severity(PreviewIssueSeverityEnum severity) =>
      this(severity: severity);

  @override
  PreviewIssue description(String description) =>
      this(description: description);

  @override
  PreviewIssue shotId(String? shotId) => this(shotId: shotId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PreviewIssue(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PreviewIssue(...).copyWith(id: 12, name: "My name")
  /// ````
  PreviewIssue call({
    Object? severity = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? shotId = const $CopyWithPlaceholder(),
  }) {
    return PreviewIssue(
      severity: severity == const $CopyWithPlaceholder()
          ? _value.severity
          // ignore: cast_nullable_to_non_nullable
          : severity as PreviewIssueSeverityEnum,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String,
      shotId: shotId == const $CopyWithPlaceholder()
          ? _value.shotId
          // ignore: cast_nullable_to_non_nullable
          : shotId as String?,
    );
  }
}

extension $PreviewIssueCopyWith on PreviewIssue {
  /// Returns a callable class that can be used as follows: `instanceOfPreviewIssue.copyWith(...)` or like so:`instanceOfPreviewIssue.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PreviewIssueCWProxy get copyWith => _$PreviewIssueCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreviewIssue _$PreviewIssueFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PreviewIssue', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['severity', 'description']);
      final val = PreviewIssue(
        severity: $checkedConvert(
          'severity',
          (v) => $enumDecode(_$PreviewIssueSeverityEnumEnumMap, v),
        ),
        description: $checkedConvert('description', (v) => v as String),
        shotId: $checkedConvert('shotId', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$PreviewIssueToJson(PreviewIssue instance) =>
    <String, dynamic>{
      'severity': _$PreviewIssueSeverityEnumEnumMap[instance.severity]!,
      'description': instance.description,
      'shotId': ?instance.shotId,
    };

const _$PreviewIssueSeverityEnumEnumMap = {
  PreviewIssueSeverityEnum.high: 'high',
  PreviewIssueSeverityEnum.medium: 'medium',
  PreviewIssueSeverityEnum.low: 'low',
};

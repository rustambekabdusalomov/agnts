// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code_review.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CodeReviewCWProxy {
  CodeReview revision(int revision);

  CodeReview model(String model);

  CodeReview modelReason(String modelReason);

  CodeReview verdict(CodeReviewVerdictEnum verdict);

  CodeReview summary(String summary);

  CodeReview findings(List<Finding> findings);

  CodeReview strengths(List<String> strengths);

  CodeReview deep(bool? deep);

  CodeReview dropped(int? dropped);

  CodeReview createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CodeReview(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CodeReview(...).copyWith(id: 12, name: "My name")
  /// ````
  CodeReview call({
    int revision,
    String model,
    String modelReason,
    CodeReviewVerdictEnum verdict,
    String summary,
    List<Finding> findings,
    List<String> strengths,
    bool? deep,
    int? dropped,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCodeReview.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCodeReview.copyWith.fieldName(...)`
class _$CodeReviewCWProxyImpl implements _$CodeReviewCWProxy {
  const _$CodeReviewCWProxyImpl(this._value);

  final CodeReview _value;

  @override
  CodeReview revision(int revision) => this(revision: revision);

  @override
  CodeReview model(String model) => this(model: model);

  @override
  CodeReview modelReason(String modelReason) => this(modelReason: modelReason);

  @override
  CodeReview verdict(CodeReviewVerdictEnum verdict) => this(verdict: verdict);

  @override
  CodeReview summary(String summary) => this(summary: summary);

  @override
  CodeReview findings(List<Finding> findings) => this(findings: findings);

  @override
  CodeReview strengths(List<String> strengths) => this(strengths: strengths);

  @override
  CodeReview deep(bool? deep) => this(deep: deep);

  @override
  CodeReview dropped(int? dropped) => this(dropped: dropped);

  @override
  CodeReview createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CodeReview(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CodeReview(...).copyWith(id: 12, name: "My name")
  /// ````
  CodeReview call({
    Object? revision = const $CopyWithPlaceholder(),
    Object? model = const $CopyWithPlaceholder(),
    Object? modelReason = const $CopyWithPlaceholder(),
    Object? verdict = const $CopyWithPlaceholder(),
    Object? summary = const $CopyWithPlaceholder(),
    Object? findings = const $CopyWithPlaceholder(),
    Object? strengths = const $CopyWithPlaceholder(),
    Object? deep = const $CopyWithPlaceholder(),
    Object? dropped = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return CodeReview(
      revision: revision == const $CopyWithPlaceholder()
          ? _value.revision
          // ignore: cast_nullable_to_non_nullable
          : revision as int,
      model: model == const $CopyWithPlaceholder()
          ? _value.model
          // ignore: cast_nullable_to_non_nullable
          : model as String,
      modelReason: modelReason == const $CopyWithPlaceholder()
          ? _value.modelReason
          // ignore: cast_nullable_to_non_nullable
          : modelReason as String,
      verdict: verdict == const $CopyWithPlaceholder()
          ? _value.verdict
          // ignore: cast_nullable_to_non_nullable
          : verdict as CodeReviewVerdictEnum,
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as String,
      findings: findings == const $CopyWithPlaceholder()
          ? _value.findings
          // ignore: cast_nullable_to_non_nullable
          : findings as List<Finding>,
      strengths: strengths == const $CopyWithPlaceholder()
          ? _value.strengths
          // ignore: cast_nullable_to_non_nullable
          : strengths as List<String>,
      deep: deep == const $CopyWithPlaceholder()
          ? _value.deep
          // ignore: cast_nullable_to_non_nullable
          : deep as bool?,
      dropped: dropped == const $CopyWithPlaceholder()
          ? _value.dropped
          // ignore: cast_nullable_to_non_nullable
          : dropped as int?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $CodeReviewCopyWith on CodeReview {
  /// Returns a callable class that can be used as follows: `instanceOfCodeReview.copyWith(...)` or like so:`instanceOfCodeReview.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CodeReviewCWProxy get copyWith => _$CodeReviewCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CodeReview _$CodeReviewFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CodeReview', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'revision',
          'model',
          'modelReason',
          'verdict',
          'summary',
          'findings',
          'strengths',
          'createdAt',
        ],
      );
      final val = CodeReview(
        revision: $checkedConvert('revision', (v) => (v as num).toInt()),
        model: $checkedConvert('model', (v) => v as String),
        modelReason: $checkedConvert('modelReason', (v) => v as String),
        verdict: $checkedConvert(
          'verdict',
          (v) => $enumDecode(_$CodeReviewVerdictEnumEnumMap, v),
        ),
        summary: $checkedConvert('summary', (v) => v as String),
        findings: $checkedConvert(
          'findings',
          (v) => (v as List<dynamic>)
              .map((e) => Finding.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        strengths: $checkedConvert(
          'strengths',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        deep: $checkedConvert('deep', (v) => v as bool?),
        dropped: $checkedConvert('dropped', (v) => (v as num?)?.toInt()),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CodeReviewToJson(CodeReview instance) =>
    <String, dynamic>{
      'revision': instance.revision,
      'model': instance.model,
      'modelReason': instance.modelReason,
      'verdict': _$CodeReviewVerdictEnumEnumMap[instance.verdict]!,
      'summary': instance.summary,
      'findings': instance.findings.map((e) => e.toJson()).toList(),
      'strengths': instance.strengths,
      'deep': ?instance.deep,
      'dropped': ?instance.dropped,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$CodeReviewVerdictEnumEnumMap = {
  CodeReviewVerdictEnum.looksGood: 'looks_good',
  CodeReviewVerdictEnum.hasConcerns: 'has_concerns',
  CodeReviewVerdictEnum.needsChanges: 'needs_changes',
};

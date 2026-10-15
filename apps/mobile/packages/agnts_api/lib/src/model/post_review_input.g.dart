// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_review_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PostReviewInputCWProxy {
  PostReviewInput summary(bool? summary);

  PostReviewInput findings(List<int>? findings);

  PostReviewInput requestChanges(bool? requestChanges);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PostReviewInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PostReviewInput(...).copyWith(id: 12, name: "My name")
  /// ````
  PostReviewInput call({
    bool? summary,
    List<int>? findings,
    bool? requestChanges,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPostReviewInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPostReviewInput.copyWith.fieldName(...)`
class _$PostReviewInputCWProxyImpl implements _$PostReviewInputCWProxy {
  const _$PostReviewInputCWProxyImpl(this._value);

  final PostReviewInput _value;

  @override
  PostReviewInput summary(bool? summary) => this(summary: summary);

  @override
  PostReviewInput findings(List<int>? findings) => this(findings: findings);

  @override
  PostReviewInput requestChanges(bool? requestChanges) =>
      this(requestChanges: requestChanges);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PostReviewInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PostReviewInput(...).copyWith(id: 12, name: "My name")
  /// ````
  PostReviewInput call({
    Object? summary = const $CopyWithPlaceholder(),
    Object? findings = const $CopyWithPlaceholder(),
    Object? requestChanges = const $CopyWithPlaceholder(),
  }) {
    return PostReviewInput(
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as bool?,
      findings: findings == const $CopyWithPlaceholder()
          ? _value.findings
          // ignore: cast_nullable_to_non_nullable
          : findings as List<int>?,
      requestChanges: requestChanges == const $CopyWithPlaceholder()
          ? _value.requestChanges
          // ignore: cast_nullable_to_non_nullable
          : requestChanges as bool?,
    );
  }
}

extension $PostReviewInputCopyWith on PostReviewInput {
  /// Returns a callable class that can be used as follows: `instanceOfPostReviewInput.copyWith(...)` or like so:`instanceOfPostReviewInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PostReviewInputCWProxy get copyWith => _$PostReviewInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostReviewInput _$PostReviewInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PostReviewInput', json, ($checkedConvert) {
      final val = PostReviewInput(
        summary: $checkedConvert('summary', (v) => v as bool? ?? true),
        findings: $checkedConvert(
          'findings',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
        requestChanges: $checkedConvert('requestChanges', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$PostReviewInputToJson(PostReviewInput instance) =>
    <String, dynamic>{
      'summary': ?instance.summary,
      'findings': ?instance.findings,
      'requestChanges': ?instance.requestChanges,
    };

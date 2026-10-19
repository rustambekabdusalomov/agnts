// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_pull_row.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReviewPullRowCWProxy {
  ReviewPullRow repoId(int repoId);

  ReviewPullRow repoName(String repoName);

  ReviewPullRow provider(ReviewPullRowProviderEnum provider);

  ReviewPullRow pull(PullItem pull);

  ReviewPullRow review(PullReviewRef? review);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReviewPullRow(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReviewPullRow(...).copyWith(id: 12, name: "My name")
  /// ````
  ReviewPullRow call({
    int repoId,
    String repoName,
    ReviewPullRowProviderEnum provider,
    PullItem pull,
    PullReviewRef? review,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReviewPullRow.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReviewPullRow.copyWith.fieldName(...)`
class _$ReviewPullRowCWProxyImpl implements _$ReviewPullRowCWProxy {
  const _$ReviewPullRowCWProxyImpl(this._value);

  final ReviewPullRow _value;

  @override
  ReviewPullRow repoId(int repoId) => this(repoId: repoId);

  @override
  ReviewPullRow repoName(String repoName) => this(repoName: repoName);

  @override
  ReviewPullRow provider(ReviewPullRowProviderEnum provider) =>
      this(provider: provider);

  @override
  ReviewPullRow pull(PullItem pull) => this(pull: pull);

  @override
  ReviewPullRow review(PullReviewRef? review) => this(review: review);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReviewPullRow(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReviewPullRow(...).copyWith(id: 12, name: "My name")
  /// ````
  ReviewPullRow call({
    Object? repoId = const $CopyWithPlaceholder(),
    Object? repoName = const $CopyWithPlaceholder(),
    Object? provider = const $CopyWithPlaceholder(),
    Object? pull = const $CopyWithPlaceholder(),
    Object? review = const $CopyWithPlaceholder(),
  }) {
    return ReviewPullRow(
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int,
      repoName: repoName == const $CopyWithPlaceholder()
          ? _value.repoName
          // ignore: cast_nullable_to_non_nullable
          : repoName as String,
      provider: provider == const $CopyWithPlaceholder()
          ? _value.provider
          // ignore: cast_nullable_to_non_nullable
          : provider as ReviewPullRowProviderEnum,
      pull: pull == const $CopyWithPlaceholder()
          ? _value.pull
          // ignore: cast_nullable_to_non_nullable
          : pull as PullItem,
      review: review == const $CopyWithPlaceholder()
          ? _value.review
          // ignore: cast_nullable_to_non_nullable
          : review as PullReviewRef?,
    );
  }
}

extension $ReviewPullRowCopyWith on ReviewPullRow {
  /// Returns a callable class that can be used as follows: `instanceOfReviewPullRow.copyWith(...)` or like so:`instanceOfReviewPullRow.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReviewPullRowCWProxy get copyWith => _$ReviewPullRowCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewPullRow _$ReviewPullRowFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ReviewPullRow', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['repoId', 'repoName', 'provider', 'pull'],
      );
      final val = ReviewPullRow(
        repoId: $checkedConvert('repoId', (v) => (v as num).toInt()),
        repoName: $checkedConvert('repoName', (v) => v as String),
        provider: $checkedConvert(
          'provider',
          (v) => $enumDecode(_$ReviewPullRowProviderEnumEnumMap, v),
        ),
        pull: $checkedConvert(
          'pull',
          (v) => PullItem.fromJson(v as Map<String, dynamic>),
        ),
        review: $checkedConvert(
          'review',
          (v) => v == null
              ? null
              : PullReviewRef.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ReviewPullRowToJson(ReviewPullRow instance) =>
    <String, dynamic>{
      'repoId': instance.repoId,
      'repoName': instance.repoName,
      'provider': _$ReviewPullRowProviderEnumEnumMap[instance.provider]!,
      'pull': instance.pull.toJson(),
      'review': ?instance.review?.toJson(),
    };

const _$ReviewPullRowProviderEnumEnumMap = {
  ReviewPullRowProviderEnum.github: 'github',
  ReviewPullRowProviderEnum.gitlab: 'gitlab',
};

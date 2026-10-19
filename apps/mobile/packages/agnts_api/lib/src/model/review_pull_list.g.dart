// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_pull_list.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReviewPullListCWProxy {
  ReviewPullList pulls(List<ReviewPullRow> pulls);

  ReviewPullList errors(List<String> errors);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReviewPullList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReviewPullList(...).copyWith(id: 12, name: "My name")
  /// ````
  ReviewPullList call({List<ReviewPullRow> pulls, List<String> errors});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReviewPullList.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReviewPullList.copyWith.fieldName(...)`
class _$ReviewPullListCWProxyImpl implements _$ReviewPullListCWProxy {
  const _$ReviewPullListCWProxyImpl(this._value);

  final ReviewPullList _value;

  @override
  ReviewPullList pulls(List<ReviewPullRow> pulls) => this(pulls: pulls);

  @override
  ReviewPullList errors(List<String> errors) => this(errors: errors);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReviewPullList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReviewPullList(...).copyWith(id: 12, name: "My name")
  /// ````
  ReviewPullList call({
    Object? pulls = const $CopyWithPlaceholder(),
    Object? errors = const $CopyWithPlaceholder(),
  }) {
    return ReviewPullList(
      pulls: pulls == const $CopyWithPlaceholder()
          ? _value.pulls
          // ignore: cast_nullable_to_non_nullable
          : pulls as List<ReviewPullRow>,
      errors: errors == const $CopyWithPlaceholder()
          ? _value.errors
          // ignore: cast_nullable_to_non_nullable
          : errors as List<String>,
    );
  }
}

extension $ReviewPullListCopyWith on ReviewPullList {
  /// Returns a callable class that can be used as follows: `instanceOfReviewPullList.copyWith(...)` or like so:`instanceOfReviewPullList.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReviewPullListCWProxy get copyWith => _$ReviewPullListCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewPullList _$ReviewPullListFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ReviewPullList', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['pulls', 'errors']);
      final val = ReviewPullList(
        pulls: $checkedConvert(
          'pulls',
          (v) => (v as List<dynamic>)
              .map((e) => ReviewPullRow.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        errors: $checkedConvert(
          'errors',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ReviewPullListToJson(ReviewPullList instance) =>
    <String, dynamic>{
      'pulls': instance.pulls.map((e) => e.toJson()).toList(),
      'errors': instance.errors,
    };

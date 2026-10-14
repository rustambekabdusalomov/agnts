// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_rating.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantRatingCWProxy {
  AssistantRating rating(AssistantRatingRatingEnum rating);

  AssistantRating comment(String? comment);

  AssistantRating share(bool? share);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantRating(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantRating(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantRating call({
    AssistantRatingRatingEnum rating,
    String? comment,
    bool? share,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantRating.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantRating.copyWith.fieldName(...)`
class _$AssistantRatingCWProxyImpl implements _$AssistantRatingCWProxy {
  const _$AssistantRatingCWProxyImpl(this._value);

  final AssistantRating _value;

  @override
  AssistantRating rating(AssistantRatingRatingEnum rating) =>
      this(rating: rating);

  @override
  AssistantRating comment(String? comment) => this(comment: comment);

  @override
  AssistantRating share(bool? share) => this(share: share);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantRating(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantRating(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantRating call({
    Object? rating = const $CopyWithPlaceholder(),
    Object? comment = const $CopyWithPlaceholder(),
    Object? share = const $CopyWithPlaceholder(),
  }) {
    return AssistantRating(
      rating: rating == const $CopyWithPlaceholder()
          ? _value.rating
          // ignore: cast_nullable_to_non_nullable
          : rating as AssistantRatingRatingEnum,
      comment: comment == const $CopyWithPlaceholder()
          ? _value.comment
          // ignore: cast_nullable_to_non_nullable
          : comment as String?,
      share: share == const $CopyWithPlaceholder()
          ? _value.share
          // ignore: cast_nullable_to_non_nullable
          : share as bool?,
    );
  }
}

extension $AssistantRatingCopyWith on AssistantRating {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantRating.copyWith(...)` or like so:`instanceOfAssistantRating.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantRatingCWProxy get copyWith => _$AssistantRatingCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantRating _$AssistantRatingFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AssistantRating', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['rating']);
      final val = AssistantRating(
        rating: $checkedConvert(
          'rating',
          (v) => $enumDecode(_$AssistantRatingRatingEnumEnumMap, v),
        ),
        comment: $checkedConvert('comment', (v) => v as String?),
        share: $checkedConvert('share', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$AssistantRatingToJson(AssistantRating instance) =>
    <String, dynamic>{
      'rating': _$AssistantRatingRatingEnumEnumMap[instance.rating]!,
      'comment': ?instance.comment,
      'share': ?instance.share,
    };

const _$AssistantRatingRatingEnumEnumMap = {
  AssistantRatingRatingEnum.numberNegative1: -1,
  AssistantRatingRatingEnum.number0: 0,
  AssistantRatingRatingEnum.number1: 1,
};

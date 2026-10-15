// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_repo_pull_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReviewRepoPullRequestCWProxy {
  ReviewRepoPullRequest focus(String? focus);

  ReviewRepoPullRequest deep(ReviewRepoPullRequestDeepEnum? deep);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReviewRepoPullRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReviewRepoPullRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ReviewRepoPullRequest call({
    String? focus,
    ReviewRepoPullRequestDeepEnum? deep,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReviewRepoPullRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReviewRepoPullRequest.copyWith.fieldName(...)`
class _$ReviewRepoPullRequestCWProxyImpl
    implements _$ReviewRepoPullRequestCWProxy {
  const _$ReviewRepoPullRequestCWProxyImpl(this._value);

  final ReviewRepoPullRequest _value;

  @override
  ReviewRepoPullRequest focus(String? focus) => this(focus: focus);

  @override
  ReviewRepoPullRequest deep(ReviewRepoPullRequestDeepEnum? deep) =>
      this(deep: deep);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReviewRepoPullRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReviewRepoPullRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ReviewRepoPullRequest call({
    Object? focus = const $CopyWithPlaceholder(),
    Object? deep = const $CopyWithPlaceholder(),
  }) {
    return ReviewRepoPullRequest(
      focus: focus == const $CopyWithPlaceholder()
          ? _value.focus
          // ignore: cast_nullable_to_non_nullable
          : focus as String?,
      deep: deep == const $CopyWithPlaceholder()
          ? _value.deep
          // ignore: cast_nullable_to_non_nullable
          : deep as ReviewRepoPullRequestDeepEnum?,
    );
  }
}

extension $ReviewRepoPullRequestCopyWith on ReviewRepoPullRequest {
  /// Returns a callable class that can be used as follows: `instanceOfReviewRepoPullRequest.copyWith(...)` or like so:`instanceOfReviewRepoPullRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReviewRepoPullRequestCWProxy get copyWith =>
      _$ReviewRepoPullRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewRepoPullRequest _$ReviewRepoPullRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ReviewRepoPullRequest', json, ($checkedConvert) {
  final val = ReviewRepoPullRequest(
    focus: $checkedConvert('focus', (v) => v as String?),
    deep: $checkedConvert(
      'deep',
      (v) => $enumDecodeNullable(_$ReviewRepoPullRequestDeepEnumEnumMap, v),
    ),
  );
  return val;
});

Map<String, dynamic> _$ReviewRepoPullRequestToJson(
  ReviewRepoPullRequest instance,
) => <String, dynamic>{
  'focus': ?instance.focus,
  'deep': ?_$ReviewRepoPullRequestDeepEnumEnumMap[instance.deep],
};

const _$ReviewRepoPullRequestDeepEnumEnumMap = {
  ReviewRepoPullRequestDeepEnum.empty: '',
  ReviewRepoPullRequestDeepEnum.off: 'off',
  ReviewRepoPullRequestDeepEnum.always: 'always',
};

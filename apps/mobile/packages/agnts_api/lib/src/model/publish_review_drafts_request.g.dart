// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publish_review_drafts_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublishReviewDraftsRequestCWProxy {
  PublishReviewDraftsRequest requestChanges(bool? requestChanges);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublishReviewDraftsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublishReviewDraftsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PublishReviewDraftsRequest call({bool? requestChanges});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublishReviewDraftsRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublishReviewDraftsRequest.copyWith.fieldName(...)`
class _$PublishReviewDraftsRequestCWProxyImpl
    implements _$PublishReviewDraftsRequestCWProxy {
  const _$PublishReviewDraftsRequestCWProxyImpl(this._value);

  final PublishReviewDraftsRequest _value;

  @override
  PublishReviewDraftsRequest requestChanges(bool? requestChanges) =>
      this(requestChanges: requestChanges);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublishReviewDraftsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublishReviewDraftsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PublishReviewDraftsRequest call({
    Object? requestChanges = const $CopyWithPlaceholder(),
  }) {
    return PublishReviewDraftsRequest(
      requestChanges: requestChanges == const $CopyWithPlaceholder()
          ? _value.requestChanges
          // ignore: cast_nullable_to_non_nullable
          : requestChanges as bool?,
    );
  }
}

extension $PublishReviewDraftsRequestCopyWith on PublishReviewDraftsRequest {
  /// Returns a callable class that can be used as follows: `instanceOfPublishReviewDraftsRequest.copyWith(...)` or like so:`instanceOfPublishReviewDraftsRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublishReviewDraftsRequestCWProxy get copyWith =>
      _$PublishReviewDraftsRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublishReviewDraftsRequest _$PublishReviewDraftsRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PublishReviewDraftsRequest', json, ($checkedConvert) {
  final val = PublishReviewDraftsRequest(
    requestChanges: $checkedConvert('requestChanges', (v) => v as bool?),
  );
  return val;
});

Map<String, dynamic> _$PublishReviewDraftsRequestToJson(
  PublishReviewDraftsRequest instance,
) => <String, dynamic>{'requestChanges': ?instance.requestChanges};

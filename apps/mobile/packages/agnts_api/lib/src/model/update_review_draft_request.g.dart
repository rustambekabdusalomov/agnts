// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_review_draft_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpdateReviewDraftRequestCWProxy {
  UpdateReviewDraftRequest state(UpdateReviewDraftRequestStateEnum? state);

  UpdateReviewDraftRequest body(String? body);

  UpdateReviewDraftRequest dismissReason(String? dismissReason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateReviewDraftRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateReviewDraftRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateReviewDraftRequest call({
    UpdateReviewDraftRequestStateEnum? state,
    String? body,
    String? dismissReason,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpdateReviewDraftRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpdateReviewDraftRequest.copyWith.fieldName(...)`
class _$UpdateReviewDraftRequestCWProxyImpl
    implements _$UpdateReviewDraftRequestCWProxy {
  const _$UpdateReviewDraftRequestCWProxyImpl(this._value);

  final UpdateReviewDraftRequest _value;

  @override
  UpdateReviewDraftRequest state(UpdateReviewDraftRequestStateEnum? state) =>
      this(state: state);

  @override
  UpdateReviewDraftRequest body(String? body) => this(body: body);

  @override
  UpdateReviewDraftRequest dismissReason(String? dismissReason) =>
      this(dismissReason: dismissReason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateReviewDraftRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateReviewDraftRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateReviewDraftRequest call({
    Object? state = const $CopyWithPlaceholder(),
    Object? body = const $CopyWithPlaceholder(),
    Object? dismissReason = const $CopyWithPlaceholder(),
  }) {
    return UpdateReviewDraftRequest(
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as UpdateReviewDraftRequestStateEnum?,
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String?,
      dismissReason: dismissReason == const $CopyWithPlaceholder()
          ? _value.dismissReason
          // ignore: cast_nullable_to_non_nullable
          : dismissReason as String?,
    );
  }
}

extension $UpdateReviewDraftRequestCopyWith on UpdateReviewDraftRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUpdateReviewDraftRequest.copyWith(...)` or like so:`instanceOfUpdateReviewDraftRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpdateReviewDraftRequestCWProxy get copyWith =>
      _$UpdateReviewDraftRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateReviewDraftRequest _$UpdateReviewDraftRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UpdateReviewDraftRequest', json, ($checkedConvert) {
  final val = UpdateReviewDraftRequest(
    state: $checkedConvert(
      'state',
      (v) => $enumDecodeNullable(_$UpdateReviewDraftRequestStateEnumEnumMap, v),
    ),
    body: $checkedConvert('body', (v) => v as String?),
    dismissReason: $checkedConvert('dismissReason', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$UpdateReviewDraftRequestToJson(
  UpdateReviewDraftRequest instance,
) => <String, dynamic>{
  'state': ?_$UpdateReviewDraftRequestStateEnumEnumMap[instance.state],
  'body': ?instance.body,
  'dismissReason': ?instance.dismissReason,
};

const _$UpdateReviewDraftRequestStateEnumEnumMap = {
  UpdateReviewDraftRequestStateEnum.draft: 'draft',
  UpdateReviewDraftRequestStateEnum.accepted: 'accepted',
  UpdateReviewDraftRequestStateEnum.dismissed: 'dismissed',
};

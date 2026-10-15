// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accept_all_review_drafts_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AcceptAllReviewDraftsRequestCWProxy {
  AcceptAllReviewDraftsRequest minSeverity(
    AcceptAllReviewDraftsRequestMinSeverityEnum? minSeverity,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AcceptAllReviewDraftsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AcceptAllReviewDraftsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AcceptAllReviewDraftsRequest call({
    AcceptAllReviewDraftsRequestMinSeverityEnum? minSeverity,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAcceptAllReviewDraftsRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAcceptAllReviewDraftsRequest.copyWith.fieldName(...)`
class _$AcceptAllReviewDraftsRequestCWProxyImpl
    implements _$AcceptAllReviewDraftsRequestCWProxy {
  const _$AcceptAllReviewDraftsRequestCWProxyImpl(this._value);

  final AcceptAllReviewDraftsRequest _value;

  @override
  AcceptAllReviewDraftsRequest minSeverity(
    AcceptAllReviewDraftsRequestMinSeverityEnum? minSeverity,
  ) => this(minSeverity: minSeverity);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AcceptAllReviewDraftsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AcceptAllReviewDraftsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AcceptAllReviewDraftsRequest call({
    Object? minSeverity = const $CopyWithPlaceholder(),
  }) {
    return AcceptAllReviewDraftsRequest(
      minSeverity: minSeverity == const $CopyWithPlaceholder()
          ? _value.minSeverity
          // ignore: cast_nullable_to_non_nullable
          : minSeverity as AcceptAllReviewDraftsRequestMinSeverityEnum?,
    );
  }
}

extension $AcceptAllReviewDraftsRequestCopyWith
    on AcceptAllReviewDraftsRequest {
  /// Returns a callable class that can be used as follows: `instanceOfAcceptAllReviewDraftsRequest.copyWith(...)` or like so:`instanceOfAcceptAllReviewDraftsRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AcceptAllReviewDraftsRequestCWProxy get copyWith =>
      _$AcceptAllReviewDraftsRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcceptAllReviewDraftsRequest _$AcceptAllReviewDraftsRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AcceptAllReviewDraftsRequest', json, ($checkedConvert) {
  final val = AcceptAllReviewDraftsRequest(
    minSeverity: $checkedConvert(
      'minSeverity',
      (v) => $enumDecodeNullable(
        _$AcceptAllReviewDraftsRequestMinSeverityEnumEnumMap,
        v,
      ),
    ),
  );
  return val;
});

Map<String, dynamic> _$AcceptAllReviewDraftsRequestToJson(
  AcceptAllReviewDraftsRequest instance,
) => <String, dynamic>{
  'minSeverity':
      ?_$AcceptAllReviewDraftsRequestMinSeverityEnumEnumMap[instance
          .minSeverity],
};

const _$AcceptAllReviewDraftsRequestMinSeverityEnumEnumMap = {
  AcceptAllReviewDraftsRequestMinSeverityEnum.blocker: 'blocker',
  AcceptAllReviewDraftsRequestMinSeverityEnum.major: 'major',
  AcceptAllReviewDraftsRequestMinSeverityEnum.minor: 'minor',
  AcceptAllReviewDraftsRequestMinSeverityEnum.nit: 'nit',
};

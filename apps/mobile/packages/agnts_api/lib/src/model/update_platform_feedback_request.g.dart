// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_platform_feedback_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpdatePlatformFeedbackRequestCWProxy {
  UpdatePlatformFeedbackRequest status(
    UpdatePlatformFeedbackRequestStatusEnum status,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdatePlatformFeedbackRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdatePlatformFeedbackRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdatePlatformFeedbackRequest call({
    UpdatePlatformFeedbackRequestStatusEnum status,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpdatePlatformFeedbackRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpdatePlatformFeedbackRequest.copyWith.fieldName(...)`
class _$UpdatePlatformFeedbackRequestCWProxyImpl
    implements _$UpdatePlatformFeedbackRequestCWProxy {
  const _$UpdatePlatformFeedbackRequestCWProxyImpl(this._value);

  final UpdatePlatformFeedbackRequest _value;

  @override
  UpdatePlatformFeedbackRequest status(
    UpdatePlatformFeedbackRequestStatusEnum status,
  ) => this(status: status);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdatePlatformFeedbackRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdatePlatformFeedbackRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdatePlatformFeedbackRequest call({
    Object? status = const $CopyWithPlaceholder(),
  }) {
    return UpdatePlatformFeedbackRequest(
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as UpdatePlatformFeedbackRequestStatusEnum,
    );
  }
}

extension $UpdatePlatformFeedbackRequestCopyWith
    on UpdatePlatformFeedbackRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUpdatePlatformFeedbackRequest.copyWith(...)` or like so:`instanceOfUpdatePlatformFeedbackRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpdatePlatformFeedbackRequestCWProxy get copyWith =>
      _$UpdatePlatformFeedbackRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePlatformFeedbackRequest _$UpdatePlatformFeedbackRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UpdatePlatformFeedbackRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['status']);
  final val = UpdatePlatformFeedbackRequest(
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$UpdatePlatformFeedbackRequestStatusEnumEnumMap, v),
    ),
  );
  return val;
});

Map<String, dynamic> _$UpdatePlatformFeedbackRequestToJson(
  UpdatePlatformFeedbackRequest instance,
) => <String, dynamic>{
  'status': _$UpdatePlatformFeedbackRequestStatusEnumEnumMap[instance.status]!,
};

const _$UpdatePlatformFeedbackRequestStatusEnumEnumMap = {
  UpdatePlatformFeedbackRequestStatusEnum.new_: 'new',
  UpdatePlatformFeedbackRequestStatusEnum.done: 'done',
};

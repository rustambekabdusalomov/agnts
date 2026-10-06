// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_changes_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RequestChangesRequestCWProxy {
  RequestChangesRequest feedback(String feedback);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RequestChangesRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RequestChangesRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RequestChangesRequest call({String feedback});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRequestChangesRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRequestChangesRequest.copyWith.fieldName(...)`
class _$RequestChangesRequestCWProxyImpl
    implements _$RequestChangesRequestCWProxy {
  const _$RequestChangesRequestCWProxyImpl(this._value);

  final RequestChangesRequest _value;

  @override
  RequestChangesRequest feedback(String feedback) => this(feedback: feedback);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RequestChangesRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RequestChangesRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RequestChangesRequest call({
    Object? feedback = const $CopyWithPlaceholder(),
  }) {
    return RequestChangesRequest(
      feedback: feedback == const $CopyWithPlaceholder()
          ? _value.feedback
          // ignore: cast_nullable_to_non_nullable
          : feedback as String,
    );
  }
}

extension $RequestChangesRequestCopyWith on RequestChangesRequest {
  /// Returns a callable class that can be used as follows: `instanceOfRequestChangesRequest.copyWith(...)` or like so:`instanceOfRequestChangesRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RequestChangesRequestCWProxy get copyWith =>
      _$RequestChangesRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestChangesRequest _$RequestChangesRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RequestChangesRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['feedback']);
  final val = RequestChangesRequest(
    feedback: $checkedConvert('feedback', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$RequestChangesRequestToJson(
  RequestChangesRequest instance,
) => <String, dynamic>{'feedback': instance.feedback};

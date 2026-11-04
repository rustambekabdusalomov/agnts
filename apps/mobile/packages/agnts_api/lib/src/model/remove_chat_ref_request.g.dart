// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remove_chat_ref_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RemoveChatRefRequestCWProxy {
  RemoveChatRefRequest type(String type);

  RemoveChatRefRequest id(String id);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RemoveChatRefRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RemoveChatRefRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RemoveChatRefRequest call({String type, String id});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRemoveChatRefRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRemoveChatRefRequest.copyWith.fieldName(...)`
class _$RemoveChatRefRequestCWProxyImpl
    implements _$RemoveChatRefRequestCWProxy {
  const _$RemoveChatRefRequestCWProxyImpl(this._value);

  final RemoveChatRefRequest _value;

  @override
  RemoveChatRefRequest type(String type) => this(type: type);

  @override
  RemoveChatRefRequest id(String id) => this(id: id);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RemoveChatRefRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RemoveChatRefRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RemoveChatRefRequest call({
    Object? type = const $CopyWithPlaceholder(),
    Object? id = const $CopyWithPlaceholder(),
  }) {
    return RemoveChatRefRequest(
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as String,
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
    );
  }
}

extension $RemoveChatRefRequestCopyWith on RemoveChatRefRequest {
  /// Returns a callable class that can be used as follows: `instanceOfRemoveChatRefRequest.copyWith(...)` or like so:`instanceOfRemoveChatRefRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RemoveChatRefRequestCWProxy get copyWith =>
      _$RemoveChatRefRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RemoveChatRefRequest _$RemoveChatRefRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RemoveChatRefRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['type', 'id']);
  final val = RemoveChatRefRequest(
    type: $checkedConvert('type', (v) => v as String),
    id: $checkedConvert('id', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$RemoveChatRefRequestToJson(
  RemoveChatRefRequest instance,
) => <String, dynamic>{'type': instance.type, 'id': instance.id};

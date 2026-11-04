// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mark_chat_read_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MarkChatReadRequestCWProxy {
  MarkChatReadRequest lastReadId(int lastReadId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MarkChatReadRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MarkChatReadRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  MarkChatReadRequest call({int lastReadId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMarkChatReadRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMarkChatReadRequest.copyWith.fieldName(...)`
class _$MarkChatReadRequestCWProxyImpl implements _$MarkChatReadRequestCWProxy {
  const _$MarkChatReadRequestCWProxyImpl(this._value);

  final MarkChatReadRequest _value;

  @override
  MarkChatReadRequest lastReadId(int lastReadId) =>
      this(lastReadId: lastReadId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MarkChatReadRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MarkChatReadRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  MarkChatReadRequest call({
    Object? lastReadId = const $CopyWithPlaceholder(),
  }) {
    return MarkChatReadRequest(
      lastReadId: lastReadId == const $CopyWithPlaceholder()
          ? _value.lastReadId
          // ignore: cast_nullable_to_non_nullable
          : lastReadId as int,
    );
  }
}

extension $MarkChatReadRequestCopyWith on MarkChatReadRequest {
  /// Returns a callable class that can be used as follows: `instanceOfMarkChatReadRequest.copyWith(...)` or like so:`instanceOfMarkChatReadRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MarkChatReadRequestCWProxy get copyWith =>
      _$MarkChatReadRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarkChatReadRequest _$MarkChatReadRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MarkChatReadRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['lastReadId']);
      final val = MarkChatReadRequest(
        lastReadId: $checkedConvert('lastReadId', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$MarkChatReadRequestToJson(
  MarkChatReadRequest instance,
) => <String, dynamic>{'lastReadId': instance.lastReadId};

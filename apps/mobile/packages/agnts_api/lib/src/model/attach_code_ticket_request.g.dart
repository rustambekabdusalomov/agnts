// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attach_code_ticket_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AttachCodeTicketRequestCWProxy {
  AttachCodeTicketRequest key(String key);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AttachCodeTicketRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AttachCodeTicketRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AttachCodeTicketRequest call({String key});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAttachCodeTicketRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAttachCodeTicketRequest.copyWith.fieldName(...)`
class _$AttachCodeTicketRequestCWProxyImpl
    implements _$AttachCodeTicketRequestCWProxy {
  const _$AttachCodeTicketRequestCWProxyImpl(this._value);

  final AttachCodeTicketRequest _value;

  @override
  AttachCodeTicketRequest key(String key) => this(key: key);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AttachCodeTicketRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AttachCodeTicketRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AttachCodeTicketRequest call({Object? key = const $CopyWithPlaceholder()}) {
    return AttachCodeTicketRequest(
      key: key == const $CopyWithPlaceholder()
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
    );
  }
}

extension $AttachCodeTicketRequestCopyWith on AttachCodeTicketRequest {
  /// Returns a callable class that can be used as follows: `instanceOfAttachCodeTicketRequest.copyWith(...)` or like so:`instanceOfAttachCodeTicketRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AttachCodeTicketRequestCWProxy get copyWith =>
      _$AttachCodeTicketRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttachCodeTicketRequest _$AttachCodeTicketRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AttachCodeTicketRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['key']);
  final val = AttachCodeTicketRequest(
    key: $checkedConvert('key', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$AttachCodeTicketRequestToJson(
  AttachCodeTicketRequest instance,
) => <String, dynamic>{'key': instance.key};

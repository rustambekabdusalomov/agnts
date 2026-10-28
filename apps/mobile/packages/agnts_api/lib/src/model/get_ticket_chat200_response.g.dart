// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_ticket_chat200_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GetTicketChat200ResponseCWProxy {
  GetTicketChat200Response conversationId(int conversationId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GetTicketChat200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GetTicketChat200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  GetTicketChat200Response call({int conversationId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGetTicketChat200Response.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGetTicketChat200Response.copyWith.fieldName(...)`
class _$GetTicketChat200ResponseCWProxyImpl
    implements _$GetTicketChat200ResponseCWProxy {
  const _$GetTicketChat200ResponseCWProxyImpl(this._value);

  final GetTicketChat200Response _value;

  @override
  GetTicketChat200Response conversationId(int conversationId) =>
      this(conversationId: conversationId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GetTicketChat200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GetTicketChat200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  GetTicketChat200Response call({
    Object? conversationId = const $CopyWithPlaceholder(),
  }) {
    return GetTicketChat200Response(
      conversationId: conversationId == const $CopyWithPlaceholder()
          ? _value.conversationId
          // ignore: cast_nullable_to_non_nullable
          : conversationId as int,
    );
  }
}

extension $GetTicketChat200ResponseCopyWith on GetTicketChat200Response {
  /// Returns a callable class that can be used as follows: `instanceOfGetTicketChat200Response.copyWith(...)` or like so:`instanceOfGetTicketChat200Response.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GetTicketChat200ResponseCWProxy get copyWith =>
      _$GetTicketChat200ResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetTicketChat200Response _$GetTicketChat200ResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('GetTicketChat200Response', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['conversationId']);
  final val = GetTicketChat200Response(
    conversationId: $checkedConvert(
      'conversationId',
      (v) => (v as num).toInt(),
    ),
  );
  return val;
});

Map<String, dynamic> _$GetTicketChat200ResponseToJson(
  GetTicketChat200Response instance,
) => <String, dynamic>{'conversationId': instance.conversationId};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_consent200_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GetConsent200ResponseCWProxy {
  GetConsent200Response clientName(String clientName);

  GetConsent200Response redirectHost(String redirectHost);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GetConsent200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GetConsent200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  GetConsent200Response call({String clientName, String redirectHost});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGetConsent200Response.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGetConsent200Response.copyWith.fieldName(...)`
class _$GetConsent200ResponseCWProxyImpl
    implements _$GetConsent200ResponseCWProxy {
  const _$GetConsent200ResponseCWProxyImpl(this._value);

  final GetConsent200Response _value;

  @override
  GetConsent200Response clientName(String clientName) =>
      this(clientName: clientName);

  @override
  GetConsent200Response redirectHost(String redirectHost) =>
      this(redirectHost: redirectHost);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GetConsent200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GetConsent200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  GetConsent200Response call({
    Object? clientName = const $CopyWithPlaceholder(),
    Object? redirectHost = const $CopyWithPlaceholder(),
  }) {
    return GetConsent200Response(
      clientName: clientName == const $CopyWithPlaceholder()
          ? _value.clientName
          // ignore: cast_nullable_to_non_nullable
          : clientName as String,
      redirectHost: redirectHost == const $CopyWithPlaceholder()
          ? _value.redirectHost
          // ignore: cast_nullable_to_non_nullable
          : redirectHost as String,
    );
  }
}

extension $GetConsent200ResponseCopyWith on GetConsent200Response {
  /// Returns a callable class that can be used as follows: `instanceOfGetConsent200Response.copyWith(...)` or like so:`instanceOfGetConsent200Response.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GetConsent200ResponseCWProxy get copyWith =>
      _$GetConsent200ResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetConsent200Response _$GetConsent200ResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('GetConsent200Response', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['clientName', 'redirectHost']);
  final val = GetConsent200Response(
    clientName: $checkedConvert('clientName', (v) => v as String),
    redirectHost: $checkedConvert('redirectHost', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$GetConsent200ResponseToJson(
  GetConsent200Response instance,
) => <String, dynamic>{
  'clientName': instance.clientName,
  'redirectHost': instance.redirectHost,
};

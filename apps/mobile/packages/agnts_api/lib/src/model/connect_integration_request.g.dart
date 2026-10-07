// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connect_integration_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ConnectIntegrationRequestCWProxy {
  ConnectIntegrationRequest token(String token);

  ConnectIntegrationRequest webhookSecret(String? webhookSecret);

  ConnectIntegrationRequest settings(Map<String, String>? settings);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConnectIntegrationRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConnectIntegrationRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ConnectIntegrationRequest call({
    String token,
    String? webhookSecret,
    Map<String, String>? settings,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfConnectIntegrationRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfConnectIntegrationRequest.copyWith.fieldName(...)`
class _$ConnectIntegrationRequestCWProxyImpl
    implements _$ConnectIntegrationRequestCWProxy {
  const _$ConnectIntegrationRequestCWProxyImpl(this._value);

  final ConnectIntegrationRequest _value;

  @override
  ConnectIntegrationRequest token(String token) => this(token: token);

  @override
  ConnectIntegrationRequest webhookSecret(String? webhookSecret) =>
      this(webhookSecret: webhookSecret);

  @override
  ConnectIntegrationRequest settings(Map<String, String>? settings) =>
      this(settings: settings);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConnectIntegrationRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConnectIntegrationRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ConnectIntegrationRequest call({
    Object? token = const $CopyWithPlaceholder(),
    Object? webhookSecret = const $CopyWithPlaceholder(),
    Object? settings = const $CopyWithPlaceholder(),
  }) {
    return ConnectIntegrationRequest(
      token: token == const $CopyWithPlaceholder()
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String,
      webhookSecret: webhookSecret == const $CopyWithPlaceholder()
          ? _value.webhookSecret
          // ignore: cast_nullable_to_non_nullable
          : webhookSecret as String?,
      settings: settings == const $CopyWithPlaceholder()
          ? _value.settings
          // ignore: cast_nullable_to_non_nullable
          : settings as Map<String, String>?,
    );
  }
}

extension $ConnectIntegrationRequestCopyWith on ConnectIntegrationRequest {
  /// Returns a callable class that can be used as follows: `instanceOfConnectIntegrationRequest.copyWith(...)` or like so:`instanceOfConnectIntegrationRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ConnectIntegrationRequestCWProxy get copyWith =>
      _$ConnectIntegrationRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConnectIntegrationRequest _$ConnectIntegrationRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ConnectIntegrationRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['token']);
  final val = ConnectIntegrationRequest(
    token: $checkedConvert('token', (v) => v as String),
    webhookSecret: $checkedConvert('webhookSecret', (v) => v as String?),
    settings: $checkedConvert(
      'settings',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as String)),
    ),
  );
  return val;
});

Map<String, dynamic> _$ConnectIntegrationRequestToJson(
  ConnectIntegrationRequest instance,
) => <String, dynamic>{
  'token': instance.token,
  'webhookSecret': ?instance.webhookSecret,
  'settings': ?instance.settings,
};

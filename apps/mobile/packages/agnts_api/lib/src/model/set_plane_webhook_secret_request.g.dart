// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_plane_webhook_secret_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SetPlaneWebhookSecretRequestCWProxy {
  SetPlaneWebhookSecretRequest secret(String secret);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetPlaneWebhookSecretRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetPlaneWebhookSecretRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetPlaneWebhookSecretRequest call({String secret});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSetPlaneWebhookSecretRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSetPlaneWebhookSecretRequest.copyWith.fieldName(...)`
class _$SetPlaneWebhookSecretRequestCWProxyImpl
    implements _$SetPlaneWebhookSecretRequestCWProxy {
  const _$SetPlaneWebhookSecretRequestCWProxyImpl(this._value);

  final SetPlaneWebhookSecretRequest _value;

  @override
  SetPlaneWebhookSecretRequest secret(String secret) => this(secret: secret);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetPlaneWebhookSecretRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetPlaneWebhookSecretRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetPlaneWebhookSecretRequest call({
    Object? secret = const $CopyWithPlaceholder(),
  }) {
    return SetPlaneWebhookSecretRequest(
      secret: secret == const $CopyWithPlaceholder()
          ? _value.secret
          // ignore: cast_nullable_to_non_nullable
          : secret as String,
    );
  }
}

extension $SetPlaneWebhookSecretRequestCopyWith
    on SetPlaneWebhookSecretRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSetPlaneWebhookSecretRequest.copyWith(...)` or like so:`instanceOfSetPlaneWebhookSecretRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SetPlaneWebhookSecretRequestCWProxy get copyWith =>
      _$SetPlaneWebhookSecretRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetPlaneWebhookSecretRequest _$SetPlaneWebhookSecretRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SetPlaneWebhookSecretRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['secret']);
  final val = SetPlaneWebhookSecretRequest(
    secret: $checkedConvert('secret', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$SetPlaneWebhookSecretRequestToJson(
  SetPlaneWebhookSecretRequest instance,
) => <String, dynamic>{'secret': instance.secret};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unregister_device_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UnregisterDeviceRequestCWProxy {
  UnregisterDeviceRequest fcmToken(String fcmToken);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UnregisterDeviceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UnregisterDeviceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UnregisterDeviceRequest call({String fcmToken});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUnregisterDeviceRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUnregisterDeviceRequest.copyWith.fieldName(...)`
class _$UnregisterDeviceRequestCWProxyImpl
    implements _$UnregisterDeviceRequestCWProxy {
  const _$UnregisterDeviceRequestCWProxyImpl(this._value);

  final UnregisterDeviceRequest _value;

  @override
  UnregisterDeviceRequest fcmToken(String fcmToken) => this(fcmToken: fcmToken);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UnregisterDeviceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UnregisterDeviceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UnregisterDeviceRequest call({
    Object? fcmToken = const $CopyWithPlaceholder(),
  }) {
    return UnregisterDeviceRequest(
      fcmToken: fcmToken == const $CopyWithPlaceholder()
          ? _value.fcmToken
          // ignore: cast_nullable_to_non_nullable
          : fcmToken as String,
    );
  }
}

extension $UnregisterDeviceRequestCopyWith on UnregisterDeviceRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUnregisterDeviceRequest.copyWith(...)` or like so:`instanceOfUnregisterDeviceRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UnregisterDeviceRequestCWProxy get copyWith =>
      _$UnregisterDeviceRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnregisterDeviceRequest _$UnregisterDeviceRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UnregisterDeviceRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['fcmToken']);
  final val = UnregisterDeviceRequest(
    fcmToken: $checkedConvert('fcmToken', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$UnregisterDeviceRequestToJson(
  UnregisterDeviceRequest instance,
) => <String, dynamic>{'fcmToken': instance.fcmToken};

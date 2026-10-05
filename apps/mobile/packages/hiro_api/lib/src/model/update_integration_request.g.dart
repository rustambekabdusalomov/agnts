// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_integration_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpdateIntegrationRequestCWProxy {
  UpdateIntegrationRequest settings(Map<String, String> settings);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateIntegrationRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateIntegrationRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateIntegrationRequest call({Map<String, String> settings});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpdateIntegrationRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpdateIntegrationRequest.copyWith.fieldName(...)`
class _$UpdateIntegrationRequestCWProxyImpl
    implements _$UpdateIntegrationRequestCWProxy {
  const _$UpdateIntegrationRequestCWProxyImpl(this._value);

  final UpdateIntegrationRequest _value;

  @override
  UpdateIntegrationRequest settings(Map<String, String> settings) =>
      this(settings: settings);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateIntegrationRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateIntegrationRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateIntegrationRequest call({
    Object? settings = const $CopyWithPlaceholder(),
  }) {
    return UpdateIntegrationRequest(
      settings: settings == const $CopyWithPlaceholder()
          ? _value.settings
          // ignore: cast_nullable_to_non_nullable
          : settings as Map<String, String>,
    );
  }
}

extension $UpdateIntegrationRequestCopyWith on UpdateIntegrationRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUpdateIntegrationRequest.copyWith(...)` or like so:`instanceOfUpdateIntegrationRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpdateIntegrationRequestCWProxy get copyWith =>
      _$UpdateIntegrationRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateIntegrationRequest _$UpdateIntegrationRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UpdateIntegrationRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['settings']);
  final val = UpdateIntegrationRequest(
    settings: $checkedConvert(
      'settings',
      (v) => Map<String, String>.from(v as Map),
    ),
  );
  return val;
});

Map<String, dynamic> _$UpdateIntegrationRequestToJson(
  UpdateIntegrationRequest instance,
) => <String, dynamic>{'settings': instance.settings};

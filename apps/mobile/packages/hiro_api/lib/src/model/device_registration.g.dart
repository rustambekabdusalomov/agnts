// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_registration.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DeviceRegistrationCWProxy {
  DeviceRegistration platform(DeviceRegistrationPlatformEnum platform);

  DeviceRegistration fcmToken(String fcmToken);

  DeviceRegistration appVersion(String? appVersion);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeviceRegistration(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeviceRegistration(...).copyWith(id: 12, name: "My name")
  /// ````
  DeviceRegistration call({
    DeviceRegistrationPlatformEnum platform,
    String fcmToken,
    String? appVersion,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDeviceRegistration.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDeviceRegistration.copyWith.fieldName(...)`
class _$DeviceRegistrationCWProxyImpl implements _$DeviceRegistrationCWProxy {
  const _$DeviceRegistrationCWProxyImpl(this._value);

  final DeviceRegistration _value;

  @override
  DeviceRegistration platform(DeviceRegistrationPlatformEnum platform) =>
      this(platform: platform);

  @override
  DeviceRegistration fcmToken(String fcmToken) => this(fcmToken: fcmToken);

  @override
  DeviceRegistration appVersion(String? appVersion) =>
      this(appVersion: appVersion);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeviceRegistration(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeviceRegistration(...).copyWith(id: 12, name: "My name")
  /// ````
  DeviceRegistration call({
    Object? platform = const $CopyWithPlaceholder(),
    Object? fcmToken = const $CopyWithPlaceholder(),
    Object? appVersion = const $CopyWithPlaceholder(),
  }) {
    return DeviceRegistration(
      platform: platform == const $CopyWithPlaceholder()
          ? _value.platform
          // ignore: cast_nullable_to_non_nullable
          : platform as DeviceRegistrationPlatformEnum,
      fcmToken: fcmToken == const $CopyWithPlaceholder()
          ? _value.fcmToken
          // ignore: cast_nullable_to_non_nullable
          : fcmToken as String,
      appVersion: appVersion == const $CopyWithPlaceholder()
          ? _value.appVersion
          // ignore: cast_nullable_to_non_nullable
          : appVersion as String?,
    );
  }
}

extension $DeviceRegistrationCopyWith on DeviceRegistration {
  /// Returns a callable class that can be used as follows: `instanceOfDeviceRegistration.copyWith(...)` or like so:`instanceOfDeviceRegistration.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DeviceRegistrationCWProxy get copyWith =>
      _$DeviceRegistrationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceRegistration _$DeviceRegistrationFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DeviceRegistration', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['platform', 'fcmToken']);
      final val = DeviceRegistration(
        platform: $checkedConvert(
          'platform',
          (v) => $enumDecode(_$DeviceRegistrationPlatformEnumEnumMap, v),
        ),
        fcmToken: $checkedConvert('fcmToken', (v) => v as String),
        appVersion: $checkedConvert('appVersion', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$DeviceRegistrationToJson(DeviceRegistration instance) =>
    <String, dynamic>{
      'platform': _$DeviceRegistrationPlatformEnumEnumMap[instance.platform]!,
      'fcmToken': instance.fcmToken,
      'appVersion': ?instance.appVersion,
    };

const _$DeviceRegistrationPlatformEnumEnumMap = {
  DeviceRegistrationPlatformEnum.ios: 'ios',
  DeviceRegistrationPlatformEnum.android: 'android',
};

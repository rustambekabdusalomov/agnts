// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_platform_user_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpdatePlatformUserRequestCWProxy {
  UpdatePlatformUserRequest isAdmin(bool isAdmin);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdatePlatformUserRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdatePlatformUserRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdatePlatformUserRequest call({bool isAdmin});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpdatePlatformUserRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpdatePlatformUserRequest.copyWith.fieldName(...)`
class _$UpdatePlatformUserRequestCWProxyImpl
    implements _$UpdatePlatformUserRequestCWProxy {
  const _$UpdatePlatformUserRequestCWProxyImpl(this._value);

  final UpdatePlatformUserRequest _value;

  @override
  UpdatePlatformUserRequest isAdmin(bool isAdmin) => this(isAdmin: isAdmin);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdatePlatformUserRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdatePlatformUserRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdatePlatformUserRequest call({
    Object? isAdmin = const $CopyWithPlaceholder(),
  }) {
    return UpdatePlatformUserRequest(
      isAdmin: isAdmin == const $CopyWithPlaceholder()
          ? _value.isAdmin
          // ignore: cast_nullable_to_non_nullable
          : isAdmin as bool,
    );
  }
}

extension $UpdatePlatformUserRequestCopyWith on UpdatePlatformUserRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUpdatePlatformUserRequest.copyWith(...)` or like so:`instanceOfUpdatePlatformUserRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpdatePlatformUserRequestCWProxy get copyWith =>
      _$UpdatePlatformUserRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePlatformUserRequest _$UpdatePlatformUserRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UpdatePlatformUserRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['isAdmin']);
  final val = UpdatePlatformUserRequest(
    isAdmin: $checkedConvert('isAdmin', (v) => v as bool),
  );
  return val;
});

Map<String, dynamic> _$UpdatePlatformUserRequestToJson(
  UpdatePlatformUserRequest instance,
) => <String, dynamic>{'isAdmin': instance.isAdmin};

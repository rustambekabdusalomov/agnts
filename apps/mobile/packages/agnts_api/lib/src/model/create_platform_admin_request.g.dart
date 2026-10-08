// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_platform_admin_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreatePlatformAdminRequestCWProxy {
  CreatePlatformAdminRequest username(String username);

  CreatePlatformAdminRequest email(String? email);

  CreatePlatformAdminRequest displayName(String? displayName);

  CreatePlatformAdminRequest password(String password);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreatePlatformAdminRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreatePlatformAdminRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreatePlatformAdminRequest call({
    String username,
    String? email,
    String? displayName,
    String password,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreatePlatformAdminRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreatePlatformAdminRequest.copyWith.fieldName(...)`
class _$CreatePlatformAdminRequestCWProxyImpl
    implements _$CreatePlatformAdminRequestCWProxy {
  const _$CreatePlatformAdminRequestCWProxyImpl(this._value);

  final CreatePlatformAdminRequest _value;

  @override
  CreatePlatformAdminRequest username(String username) =>
      this(username: username);

  @override
  CreatePlatformAdminRequest email(String? email) => this(email: email);

  @override
  CreatePlatformAdminRequest displayName(String? displayName) =>
      this(displayName: displayName);

  @override
  CreatePlatformAdminRequest password(String password) =>
      this(password: password);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreatePlatformAdminRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreatePlatformAdminRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreatePlatformAdminRequest call({
    Object? username = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
    Object? password = const $CopyWithPlaceholder(),
  }) {
    return CreatePlatformAdminRequest(
      username: username == const $CopyWithPlaceholder()
          ? _value.username
          // ignore: cast_nullable_to_non_nullable
          : username as String,
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String?,
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String?,
      password: password == const $CopyWithPlaceholder()
          ? _value.password
          // ignore: cast_nullable_to_non_nullable
          : password as String,
    );
  }
}

extension $CreatePlatformAdminRequestCopyWith on CreatePlatformAdminRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreatePlatformAdminRequest.copyWith(...)` or like so:`instanceOfCreatePlatformAdminRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreatePlatformAdminRequestCWProxy get copyWith =>
      _$CreatePlatformAdminRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePlatformAdminRequest _$CreatePlatformAdminRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreatePlatformAdminRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['username', 'password']);
  final val = CreatePlatformAdminRequest(
    username: $checkedConvert('username', (v) => v as String),
    email: $checkedConvert('email', (v) => v as String?),
    displayName: $checkedConvert('displayName', (v) => v as String?),
    password: $checkedConvert('password', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$CreatePlatformAdminRequestToJson(
  CreatePlatformAdminRequest instance,
) => <String, dynamic>{
  'username': instance.username,
  'email': ?instance.email,
  'displayName': ?instance.displayName,
  'password': instance.password,
};

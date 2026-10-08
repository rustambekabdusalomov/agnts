// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RegisterRequestCWProxy {
  RegisterRequest email(String email);

  RegisterRequest username(String? username);

  RegisterRequest displayName(String? displayName);

  RegisterRequest password(String password);

  RegisterRequest workspaceName(String? workspaceName);

  RegisterRequest invite(String? invite);

  RegisterRequest client(RegisterRequestClientEnum client);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RegisterRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RegisterRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RegisterRequest call({
    String email,
    String? username,
    String? displayName,
    String password,
    String? workspaceName,
    String? invite,
    RegisterRequestClientEnum client,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRegisterRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRegisterRequest.copyWith.fieldName(...)`
class _$RegisterRequestCWProxyImpl implements _$RegisterRequestCWProxy {
  const _$RegisterRequestCWProxyImpl(this._value);

  final RegisterRequest _value;

  @override
  RegisterRequest email(String email) => this(email: email);

  @override
  RegisterRequest username(String? username) => this(username: username);

  @override
  RegisterRequest displayName(String? displayName) =>
      this(displayName: displayName);

  @override
  RegisterRequest password(String password) => this(password: password);

  @override
  RegisterRequest workspaceName(String? workspaceName) =>
      this(workspaceName: workspaceName);

  @override
  RegisterRequest invite(String? invite) => this(invite: invite);

  @override
  RegisterRequest client(RegisterRequestClientEnum client) =>
      this(client: client);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RegisterRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RegisterRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RegisterRequest call({
    Object? email = const $CopyWithPlaceholder(),
    Object? username = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
    Object? password = const $CopyWithPlaceholder(),
    Object? workspaceName = const $CopyWithPlaceholder(),
    Object? invite = const $CopyWithPlaceholder(),
    Object? client = const $CopyWithPlaceholder(),
  }) {
    return RegisterRequest(
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String,
      username: username == const $CopyWithPlaceholder()
          ? _value.username
          // ignore: cast_nullable_to_non_nullable
          : username as String?,
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String?,
      password: password == const $CopyWithPlaceholder()
          ? _value.password
          // ignore: cast_nullable_to_non_nullable
          : password as String,
      workspaceName: workspaceName == const $CopyWithPlaceholder()
          ? _value.workspaceName
          // ignore: cast_nullable_to_non_nullable
          : workspaceName as String?,
      invite: invite == const $CopyWithPlaceholder()
          ? _value.invite
          // ignore: cast_nullable_to_non_nullable
          : invite as String?,
      client: client == const $CopyWithPlaceholder()
          ? _value.client
          // ignore: cast_nullable_to_non_nullable
          : client as RegisterRequestClientEnum,
    );
  }
}

extension $RegisterRequestCopyWith on RegisterRequest {
  /// Returns a callable class that can be used as follows: `instanceOfRegisterRequest.copyWith(...)` or like so:`instanceOfRegisterRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RegisterRequestCWProxy get copyWith => _$RegisterRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RegisterRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['email', 'password', 'client']);
      final val = RegisterRequest(
        email: $checkedConvert('email', (v) => v as String),
        username: $checkedConvert('username', (v) => v as String?),
        displayName: $checkedConvert('displayName', (v) => v as String?),
        password: $checkedConvert('password', (v) => v as String),
        workspaceName: $checkedConvert('workspaceName', (v) => v as String?),
        invite: $checkedConvert('invite', (v) => v as String?),
        client: $checkedConvert(
          'client',
          (v) => $enumDecode(_$RegisterRequestClientEnumEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'username': ?instance.username,
      'displayName': ?instance.displayName,
      'password': instance.password,
      'workspaceName': ?instance.workspaceName,
      'invite': ?instance.invite,
      'client': _$RegisterRequestClientEnumEnumMap[instance.client]!,
    };

const _$RegisterRequestClientEnumEnumMap = {
  RegisterRequestClientEnum.web: 'web',
  RegisterRequestClientEnum.mobile: 'mobile',
};

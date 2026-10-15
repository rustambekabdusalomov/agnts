// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swagger_spec_input_login.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SwaggerSpecInputLoginCWProxy {
  SwaggerSpecInputLogin username(String username);

  SwaggerSpecInputLogin password(String password);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerSpecInputLogin(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerSpecInputLogin(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerSpecInputLogin call({String username, String password});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSwaggerSpecInputLogin.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSwaggerSpecInputLogin.copyWith.fieldName(...)`
class _$SwaggerSpecInputLoginCWProxyImpl
    implements _$SwaggerSpecInputLoginCWProxy {
  const _$SwaggerSpecInputLoginCWProxyImpl(this._value);

  final SwaggerSpecInputLogin _value;

  @override
  SwaggerSpecInputLogin username(String username) => this(username: username);

  @override
  SwaggerSpecInputLogin password(String password) => this(password: password);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerSpecInputLogin(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerSpecInputLogin(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerSpecInputLogin call({
    Object? username = const $CopyWithPlaceholder(),
    Object? password = const $CopyWithPlaceholder(),
  }) {
    return SwaggerSpecInputLogin(
      username: username == const $CopyWithPlaceholder()
          ? _value.username
          // ignore: cast_nullable_to_non_nullable
          : username as String,
      password: password == const $CopyWithPlaceholder()
          ? _value.password
          // ignore: cast_nullable_to_non_nullable
          : password as String,
    );
  }
}

extension $SwaggerSpecInputLoginCopyWith on SwaggerSpecInputLogin {
  /// Returns a callable class that can be used as follows: `instanceOfSwaggerSpecInputLogin.copyWith(...)` or like so:`instanceOfSwaggerSpecInputLogin.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SwaggerSpecInputLoginCWProxy get copyWith =>
      _$SwaggerSpecInputLoginCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwaggerSpecInputLogin _$SwaggerSpecInputLoginFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SwaggerSpecInputLogin', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['username', 'password']);
  final val = SwaggerSpecInputLogin(
    username: $checkedConvert('username', (v) => v as String),
    password: $checkedConvert('password', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$SwaggerSpecInputLoginToJson(
  SwaggerSpecInputLogin instance,
) => <String, dynamic>{
  'username': instance.username,
  'password': instance.password,
};

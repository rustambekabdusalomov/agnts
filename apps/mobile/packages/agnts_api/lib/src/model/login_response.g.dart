// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LoginResponseCWProxy {
  LoginResponse user(User user);

  LoginResponse expiresAt(DateTime expiresAt);

  LoginResponse token(String? token);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LoginResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LoginResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  LoginResponse call({User user, DateTime expiresAt, String? token});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLoginResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLoginResponse.copyWith.fieldName(...)`
class _$LoginResponseCWProxyImpl implements _$LoginResponseCWProxy {
  const _$LoginResponseCWProxyImpl(this._value);

  final LoginResponse _value;

  @override
  LoginResponse user(User user) => this(user: user);

  @override
  LoginResponse expiresAt(DateTime expiresAt) => this(expiresAt: expiresAt);

  @override
  LoginResponse token(String? token) => this(token: token);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LoginResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LoginResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  LoginResponse call({
    Object? user = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? token = const $CopyWithPlaceholder(),
  }) {
    return LoginResponse(
      user: user == const $CopyWithPlaceholder()
          ? _value.user
          // ignore: cast_nullable_to_non_nullable
          : user as User,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime,
      token: token == const $CopyWithPlaceholder()
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String?,
    );
  }
}

extension $LoginResponseCopyWith on LoginResponse {
  /// Returns a callable class that can be used as follows: `instanceOfLoginResponse.copyWith(...)` or like so:`instanceOfLoginResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LoginResponseCWProxy get copyWith => _$LoginResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LoginResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['user', 'expiresAt']);
      final val = LoginResponse(
        user: $checkedConvert(
          'user',
          (v) => User.fromJson(v as Map<String, dynamic>),
        ),
        expiresAt: $checkedConvert(
          'expiresAt',
          (v) => DateTime.parse(v as String),
        ),
        token: $checkedConvert('token', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'token': ?instance.token,
    };

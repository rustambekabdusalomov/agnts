// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'begin_login_totp_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BeginLoginTotpRequestCWProxy {
  BeginLoginTotpRequest username(String username);

  BeginLoginTotpRequest password(String password);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BeginLoginTotpRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BeginLoginTotpRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  BeginLoginTotpRequest call({String username, String password});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBeginLoginTotpRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBeginLoginTotpRequest.copyWith.fieldName(...)`
class _$BeginLoginTotpRequestCWProxyImpl
    implements _$BeginLoginTotpRequestCWProxy {
  const _$BeginLoginTotpRequestCWProxyImpl(this._value);

  final BeginLoginTotpRequest _value;

  @override
  BeginLoginTotpRequest username(String username) => this(username: username);

  @override
  BeginLoginTotpRequest password(String password) => this(password: password);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BeginLoginTotpRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BeginLoginTotpRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  BeginLoginTotpRequest call({
    Object? username = const $CopyWithPlaceholder(),
    Object? password = const $CopyWithPlaceholder(),
  }) {
    return BeginLoginTotpRequest(
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

extension $BeginLoginTotpRequestCopyWith on BeginLoginTotpRequest {
  /// Returns a callable class that can be used as follows: `instanceOfBeginLoginTotpRequest.copyWith(...)` or like so:`instanceOfBeginLoginTotpRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BeginLoginTotpRequestCWProxy get copyWith =>
      _$BeginLoginTotpRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BeginLoginTotpRequest _$BeginLoginTotpRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('BeginLoginTotpRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['username', 'password']);
  final val = BeginLoginTotpRequest(
    username: $checkedConvert('username', (v) => v as String),
    password: $checkedConvert('password', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$BeginLoginTotpRequestToJson(
  BeginLoginTotpRequest instance,
) => <String, dynamic>{
  'username': instance.username,
  'password': instance.password,
};

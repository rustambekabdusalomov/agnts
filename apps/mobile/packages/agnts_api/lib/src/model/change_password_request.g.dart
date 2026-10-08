// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_password_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChangePasswordRequestCWProxy {
  ChangePasswordRequest current(String current);

  ChangePasswordRequest password(String password);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChangePasswordRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChangePasswordRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ChangePasswordRequest call({String current, String password});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfChangePasswordRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfChangePasswordRequest.copyWith.fieldName(...)`
class _$ChangePasswordRequestCWProxyImpl
    implements _$ChangePasswordRequestCWProxy {
  const _$ChangePasswordRequestCWProxyImpl(this._value);

  final ChangePasswordRequest _value;

  @override
  ChangePasswordRequest current(String current) => this(current: current);

  @override
  ChangePasswordRequest password(String password) => this(password: password);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChangePasswordRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChangePasswordRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ChangePasswordRequest call({
    Object? current = const $CopyWithPlaceholder(),
    Object? password = const $CopyWithPlaceholder(),
  }) {
    return ChangePasswordRequest(
      current: current == const $CopyWithPlaceholder()
          ? _value.current
          // ignore: cast_nullable_to_non_nullable
          : current as String,
      password: password == const $CopyWithPlaceholder()
          ? _value.password
          // ignore: cast_nullable_to_non_nullable
          : password as String,
    );
  }
}

extension $ChangePasswordRequestCopyWith on ChangePasswordRequest {
  /// Returns a callable class that can be used as follows: `instanceOfChangePasswordRequest.copyWith(...)` or like so:`instanceOfChangePasswordRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ChangePasswordRequestCWProxy get copyWith =>
      _$ChangePasswordRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangePasswordRequest _$ChangePasswordRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ChangePasswordRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['current', 'password']);
  final val = ChangePasswordRequest(
    current: $checkedConvert('current', (v) => v as String),
    password: $checkedConvert('password', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$ChangePasswordRequestToJson(
  ChangePasswordRequest instance,
) => <String, dynamic>{
  'current': instance.current,
  'password': instance.password,
};

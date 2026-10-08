// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'disable_totp_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DisableTotpRequestCWProxy {
  DisableTotpRequest password(String password);

  DisableTotpRequest code(String? code);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DisableTotpRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DisableTotpRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  DisableTotpRequest call({String password, String? code});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDisableTotpRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDisableTotpRequest.copyWith.fieldName(...)`
class _$DisableTotpRequestCWProxyImpl implements _$DisableTotpRequestCWProxy {
  const _$DisableTotpRequestCWProxyImpl(this._value);

  final DisableTotpRequest _value;

  @override
  DisableTotpRequest password(String password) => this(password: password);

  @override
  DisableTotpRequest code(String? code) => this(code: code);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DisableTotpRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DisableTotpRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  DisableTotpRequest call({
    Object? password = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
  }) {
    return DisableTotpRequest(
      password: password == const $CopyWithPlaceholder()
          ? _value.password
          // ignore: cast_nullable_to_non_nullable
          : password as String,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String?,
    );
  }
}

extension $DisableTotpRequestCopyWith on DisableTotpRequest {
  /// Returns a callable class that can be used as follows: `instanceOfDisableTotpRequest.copyWith(...)` or like so:`instanceOfDisableTotpRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DisableTotpRequestCWProxy get copyWith =>
      _$DisableTotpRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DisableTotpRequest _$DisableTotpRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DisableTotpRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['password']);
      final val = DisableTotpRequest(
        password: $checkedConvert('password', (v) => v as String),
        code: $checkedConvert('code', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$DisableTotpRequestToJson(DisableTotpRequest instance) =>
    <String, dynamic>{'password': instance.password, 'code': ?instance.code};

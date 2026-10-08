// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_totp_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ConfirmTotpRequestCWProxy {
  ConfirmTotpRequest secret(String secret);

  ConfirmTotpRequest code(String code);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConfirmTotpRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConfirmTotpRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ConfirmTotpRequest call({String secret, String code});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfConfirmTotpRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfConfirmTotpRequest.copyWith.fieldName(...)`
class _$ConfirmTotpRequestCWProxyImpl implements _$ConfirmTotpRequestCWProxy {
  const _$ConfirmTotpRequestCWProxyImpl(this._value);

  final ConfirmTotpRequest _value;

  @override
  ConfirmTotpRequest secret(String secret) => this(secret: secret);

  @override
  ConfirmTotpRequest code(String code) => this(code: code);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConfirmTotpRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConfirmTotpRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ConfirmTotpRequest call({
    Object? secret = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
  }) {
    return ConfirmTotpRequest(
      secret: secret == const $CopyWithPlaceholder()
          ? _value.secret
          // ignore: cast_nullable_to_non_nullable
          : secret as String,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
    );
  }
}

extension $ConfirmTotpRequestCopyWith on ConfirmTotpRequest {
  /// Returns a callable class that can be used as follows: `instanceOfConfirmTotpRequest.copyWith(...)` or like so:`instanceOfConfirmTotpRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ConfirmTotpRequestCWProxy get copyWith =>
      _$ConfirmTotpRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfirmTotpRequest _$ConfirmTotpRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ConfirmTotpRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['secret', 'code']);
      final val = ConfirmTotpRequest(
        secret: $checkedConvert('secret', (v) => v as String),
        code: $checkedConvert('code', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ConfirmTotpRequestToJson(ConfirmTotpRequest instance) =>
    <String, dynamic>{'secret': instance.secret, 'code': instance.code};

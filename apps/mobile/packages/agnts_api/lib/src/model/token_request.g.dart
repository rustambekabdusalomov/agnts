// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TokenRequestCWProxy {
  TokenRequest token(String token);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TokenRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TokenRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  TokenRequest call({String token});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTokenRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTokenRequest.copyWith.fieldName(...)`
class _$TokenRequestCWProxyImpl implements _$TokenRequestCWProxy {
  const _$TokenRequestCWProxyImpl(this._value);

  final TokenRequest _value;

  @override
  TokenRequest token(String token) => this(token: token);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TokenRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TokenRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  TokenRequest call({Object? token = const $CopyWithPlaceholder()}) {
    return TokenRequest(
      token: token == const $CopyWithPlaceholder()
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String,
    );
  }
}

extension $TokenRequestCopyWith on TokenRequest {
  /// Returns a callable class that can be used as follows: `instanceOfTokenRequest.copyWith(...)` or like so:`instanceOfTokenRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TokenRequestCWProxy get copyWith => _$TokenRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenRequest _$TokenRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TokenRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['token']);
      final val = TokenRequest(
        token: $checkedConvert('token', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$TokenRequestToJson(TokenRequest instance) =>
    <String, dynamic>{'token': instance.token};

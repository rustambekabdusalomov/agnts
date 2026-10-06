// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rotate_mcp_token200_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RotateMcpToken200ResponseCWProxy {
  RotateMcpToken200Response token(String token);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RotateMcpToken200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RotateMcpToken200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  RotateMcpToken200Response call({String token});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRotateMcpToken200Response.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRotateMcpToken200Response.copyWith.fieldName(...)`
class _$RotateMcpToken200ResponseCWProxyImpl
    implements _$RotateMcpToken200ResponseCWProxy {
  const _$RotateMcpToken200ResponseCWProxyImpl(this._value);

  final RotateMcpToken200Response _value;

  @override
  RotateMcpToken200Response token(String token) => this(token: token);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RotateMcpToken200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RotateMcpToken200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  RotateMcpToken200Response call({
    Object? token = const $CopyWithPlaceholder(),
  }) {
    return RotateMcpToken200Response(
      token: token == const $CopyWithPlaceholder()
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String,
    );
  }
}

extension $RotateMcpToken200ResponseCopyWith on RotateMcpToken200Response {
  /// Returns a callable class that can be used as follows: `instanceOfRotateMcpToken200Response.copyWith(...)` or like so:`instanceOfRotateMcpToken200Response.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RotateMcpToken200ResponseCWProxy get copyWith =>
      _$RotateMcpToken200ResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RotateMcpToken200Response _$RotateMcpToken200ResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RotateMcpToken200Response', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['token']);
  final val = RotateMcpToken200Response(
    token: $checkedConvert('token', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$RotateMcpToken200ResponseToJson(
  RotateMcpToken200Response instance,
) => <String, dynamic>{'token': instance.token};

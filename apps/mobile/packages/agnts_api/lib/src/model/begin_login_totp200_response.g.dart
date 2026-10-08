// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'begin_login_totp200_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BeginLoginTotp200ResponseCWProxy {
  BeginLoginTotp200Response secret(String secret);

  BeginLoginTotp200Response url(String url);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BeginLoginTotp200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BeginLoginTotp200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  BeginLoginTotp200Response call({String secret, String url});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBeginLoginTotp200Response.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBeginLoginTotp200Response.copyWith.fieldName(...)`
class _$BeginLoginTotp200ResponseCWProxyImpl
    implements _$BeginLoginTotp200ResponseCWProxy {
  const _$BeginLoginTotp200ResponseCWProxyImpl(this._value);

  final BeginLoginTotp200Response _value;

  @override
  BeginLoginTotp200Response secret(String secret) => this(secret: secret);

  @override
  BeginLoginTotp200Response url(String url) => this(url: url);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BeginLoginTotp200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BeginLoginTotp200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  BeginLoginTotp200Response call({
    Object? secret = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
  }) {
    return BeginLoginTotp200Response(
      secret: secret == const $CopyWithPlaceholder()
          ? _value.secret
          // ignore: cast_nullable_to_non_nullable
          : secret as String,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
    );
  }
}

extension $BeginLoginTotp200ResponseCopyWith on BeginLoginTotp200Response {
  /// Returns a callable class that can be used as follows: `instanceOfBeginLoginTotp200Response.copyWith(...)` or like so:`instanceOfBeginLoginTotp200Response.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BeginLoginTotp200ResponseCWProxy get copyWith =>
      _$BeginLoginTotp200ResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BeginLoginTotp200Response _$BeginLoginTotp200ResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('BeginLoginTotp200Response', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['secret', 'url']);
  final val = BeginLoginTotp200Response(
    secret: $checkedConvert('secret', (v) => v as String),
    url: $checkedConvert('url', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$BeginLoginTotp200ResponseToJson(
  BeginLoginTotp200Response instance,
) => <String, dynamic>{'secret': instance.secret, 'url': instance.url};

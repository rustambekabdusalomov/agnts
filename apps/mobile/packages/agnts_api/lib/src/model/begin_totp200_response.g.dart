// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'begin_totp200_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BeginTotp200ResponseCWProxy {
  BeginTotp200Response secret(String secret);

  BeginTotp200Response url(String url);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BeginTotp200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BeginTotp200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  BeginTotp200Response call({String secret, String url});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBeginTotp200Response.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBeginTotp200Response.copyWith.fieldName(...)`
class _$BeginTotp200ResponseCWProxyImpl
    implements _$BeginTotp200ResponseCWProxy {
  const _$BeginTotp200ResponseCWProxyImpl(this._value);

  final BeginTotp200Response _value;

  @override
  BeginTotp200Response secret(String secret) => this(secret: secret);

  @override
  BeginTotp200Response url(String url) => this(url: url);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BeginTotp200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BeginTotp200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  BeginTotp200Response call({
    Object? secret = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
  }) {
    return BeginTotp200Response(
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

extension $BeginTotp200ResponseCopyWith on BeginTotp200Response {
  /// Returns a callable class that can be used as follows: `instanceOfBeginTotp200Response.copyWith(...)` or like so:`instanceOfBeginTotp200Response.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BeginTotp200ResponseCWProxy get copyWith =>
      _$BeginTotp200ResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BeginTotp200Response _$BeginTotp200ResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('BeginTotp200Response', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['secret', 'url']);
  final val = BeginTotp200Response(
    secret: $checkedConvert('secret', (v) => v as String),
    url: $checkedConvert('url', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$BeginTotp200ResponseToJson(
  BeginTotp200Response instance,
) => <String, dynamic>{'secret': instance.secret, 'url': instance.url};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decide_consent200_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DecideConsent200ResponseCWProxy {
  DecideConsent200Response redirect(String redirect);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DecideConsent200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DecideConsent200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  DecideConsent200Response call({String redirect});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDecideConsent200Response.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDecideConsent200Response.copyWith.fieldName(...)`
class _$DecideConsent200ResponseCWProxyImpl
    implements _$DecideConsent200ResponseCWProxy {
  const _$DecideConsent200ResponseCWProxyImpl(this._value);

  final DecideConsent200Response _value;

  @override
  DecideConsent200Response redirect(String redirect) =>
      this(redirect: redirect);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DecideConsent200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DecideConsent200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  DecideConsent200Response call({
    Object? redirect = const $CopyWithPlaceholder(),
  }) {
    return DecideConsent200Response(
      redirect: redirect == const $CopyWithPlaceholder()
          ? _value.redirect
          // ignore: cast_nullable_to_non_nullable
          : redirect as String,
    );
  }
}

extension $DecideConsent200ResponseCopyWith on DecideConsent200Response {
  /// Returns a callable class that can be used as follows: `instanceOfDecideConsent200Response.copyWith(...)` or like so:`instanceOfDecideConsent200Response.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DecideConsent200ResponseCWProxy get copyWith =>
      _$DecideConsent200ResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DecideConsent200Response _$DecideConsent200ResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DecideConsent200Response', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['redirect']);
  final val = DecideConsent200Response(
    redirect: $checkedConvert('redirect', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$DecideConsent200ResponseToJson(
  DecideConsent200Response instance,
) => <String, dynamic>{'redirect': instance.redirect};

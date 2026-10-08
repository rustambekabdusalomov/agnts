// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_credits200_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CheckoutCredits200ResponseCWProxy {
  CheckoutCredits200Response url(String url);

  CheckoutCredits200Response paymentId(int paymentId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CheckoutCredits200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CheckoutCredits200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  CheckoutCredits200Response call({String url, int paymentId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCheckoutCredits200Response.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCheckoutCredits200Response.copyWith.fieldName(...)`
class _$CheckoutCredits200ResponseCWProxyImpl
    implements _$CheckoutCredits200ResponseCWProxy {
  const _$CheckoutCredits200ResponseCWProxyImpl(this._value);

  final CheckoutCredits200Response _value;

  @override
  CheckoutCredits200Response url(String url) => this(url: url);

  @override
  CheckoutCredits200Response paymentId(int paymentId) =>
      this(paymentId: paymentId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CheckoutCredits200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CheckoutCredits200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  CheckoutCredits200Response call({
    Object? url = const $CopyWithPlaceholder(),
    Object? paymentId = const $CopyWithPlaceholder(),
  }) {
    return CheckoutCredits200Response(
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      paymentId: paymentId == const $CopyWithPlaceholder()
          ? _value.paymentId
          // ignore: cast_nullable_to_non_nullable
          : paymentId as int,
    );
  }
}

extension $CheckoutCredits200ResponseCopyWith on CheckoutCredits200Response {
  /// Returns a callable class that can be used as follows: `instanceOfCheckoutCredits200Response.copyWith(...)` or like so:`instanceOfCheckoutCredits200Response.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CheckoutCredits200ResponseCWProxy get copyWith =>
      _$CheckoutCredits200ResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckoutCredits200Response _$CheckoutCredits200ResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CheckoutCredits200Response', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['url', 'paymentId']);
  final val = CheckoutCredits200Response(
    url: $checkedConvert('url', (v) => v as String),
    paymentId: $checkedConvert('paymentId', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$CheckoutCredits200ResponseToJson(
  CheckoutCredits200Response instance,
) => <String, dynamic>{'url': instance.url, 'paymentId': instance.paymentId};

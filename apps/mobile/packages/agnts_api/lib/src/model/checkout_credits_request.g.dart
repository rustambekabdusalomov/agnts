// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_credits_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CheckoutCreditsRequestCWProxy {
  CheckoutCreditsRequest amountUzs(int amountUzs);

  CheckoutCreditsRequest provider(CheckoutCreditsRequestProviderEnum provider);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CheckoutCreditsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CheckoutCreditsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CheckoutCreditsRequest call({
    int amountUzs,
    CheckoutCreditsRequestProviderEnum provider,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCheckoutCreditsRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCheckoutCreditsRequest.copyWith.fieldName(...)`
class _$CheckoutCreditsRequestCWProxyImpl
    implements _$CheckoutCreditsRequestCWProxy {
  const _$CheckoutCreditsRequestCWProxyImpl(this._value);

  final CheckoutCreditsRequest _value;

  @override
  CheckoutCreditsRequest amountUzs(int amountUzs) => this(amountUzs: amountUzs);

  @override
  CheckoutCreditsRequest provider(
    CheckoutCreditsRequestProviderEnum provider,
  ) => this(provider: provider);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CheckoutCreditsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CheckoutCreditsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CheckoutCreditsRequest call({
    Object? amountUzs = const $CopyWithPlaceholder(),
    Object? provider = const $CopyWithPlaceholder(),
  }) {
    return CheckoutCreditsRequest(
      amountUzs: amountUzs == const $CopyWithPlaceholder()
          ? _value.amountUzs
          // ignore: cast_nullable_to_non_nullable
          : amountUzs as int,
      provider: provider == const $CopyWithPlaceholder()
          ? _value.provider
          // ignore: cast_nullable_to_non_nullable
          : provider as CheckoutCreditsRequestProviderEnum,
    );
  }
}

extension $CheckoutCreditsRequestCopyWith on CheckoutCreditsRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCheckoutCreditsRequest.copyWith(...)` or like so:`instanceOfCheckoutCreditsRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CheckoutCreditsRequestCWProxy get copyWith =>
      _$CheckoutCreditsRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckoutCreditsRequest _$CheckoutCreditsRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CheckoutCreditsRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['amountUzs', 'provider']);
  final val = CheckoutCreditsRequest(
    amountUzs: $checkedConvert('amountUzs', (v) => (v as num).toInt()),
    provider: $checkedConvert(
      'provider',
      (v) => $enumDecode(_$CheckoutCreditsRequestProviderEnumEnumMap, v),
    ),
  );
  return val;
});

Map<String, dynamic> _$CheckoutCreditsRequestToJson(
  CheckoutCreditsRequest instance,
) => <String, dynamic>{
  'amountUzs': instance.amountUzs,
  'provider': _$CheckoutCreditsRequestProviderEnumEnumMap[instance.provider]!,
};

const _$CheckoutCreditsRequestProviderEnumEnumMap = {
  CheckoutCreditsRequestProviderEnum.payme: 'payme',
  CheckoutCreditsRequestProviderEnum.click: 'click',
};

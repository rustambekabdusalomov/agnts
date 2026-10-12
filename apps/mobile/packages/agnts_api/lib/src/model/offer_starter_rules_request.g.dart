// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer_starter_rules_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OfferStarterRulesRequestCWProxy {
  OfferStarterRulesRequest pack(String pack);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OfferStarterRulesRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OfferStarterRulesRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  OfferStarterRulesRequest call({String pack});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOfferStarterRulesRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOfferStarterRulesRequest.copyWith.fieldName(...)`
class _$OfferStarterRulesRequestCWProxyImpl
    implements _$OfferStarterRulesRequestCWProxy {
  const _$OfferStarterRulesRequestCWProxyImpl(this._value);

  final OfferStarterRulesRequest _value;

  @override
  OfferStarterRulesRequest pack(String pack) => this(pack: pack);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OfferStarterRulesRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OfferStarterRulesRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  OfferStarterRulesRequest call({Object? pack = const $CopyWithPlaceholder()}) {
    return OfferStarterRulesRequest(
      pack: pack == const $CopyWithPlaceholder()
          ? _value.pack
          // ignore: cast_nullable_to_non_nullable
          : pack as String,
    );
  }
}

extension $OfferStarterRulesRequestCopyWith on OfferStarterRulesRequest {
  /// Returns a callable class that can be used as follows: `instanceOfOfferStarterRulesRequest.copyWith(...)` or like so:`instanceOfOfferStarterRulesRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OfferStarterRulesRequestCWProxy get copyWith =>
      _$OfferStarterRulesRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OfferStarterRulesRequest _$OfferStarterRulesRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('OfferStarterRulesRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['pack']);
  final val = OfferStarterRulesRequest(
    pack: $checkedConvert('pack', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$OfferStarterRulesRequestToJson(
  OfferStarterRulesRequest instance,
) => <String, dynamic>{'pack': instance.pack};

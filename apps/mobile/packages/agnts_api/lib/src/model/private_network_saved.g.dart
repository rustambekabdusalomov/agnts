// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'private_network_saved.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PrivateNetworkSavedCWProxy {
  PrivateNetworkSaved network(PrivateNetwork network);

  PrivateNetworkSaved token(String? token);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PrivateNetworkSaved(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PrivateNetworkSaved(...).copyWith(id: 12, name: "My name")
  /// ````
  PrivateNetworkSaved call({PrivateNetwork network, String? token});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPrivateNetworkSaved.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPrivateNetworkSaved.copyWith.fieldName(...)`
class _$PrivateNetworkSavedCWProxyImpl implements _$PrivateNetworkSavedCWProxy {
  const _$PrivateNetworkSavedCWProxyImpl(this._value);

  final PrivateNetworkSaved _value;

  @override
  PrivateNetworkSaved network(PrivateNetwork network) => this(network: network);

  @override
  PrivateNetworkSaved token(String? token) => this(token: token);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PrivateNetworkSaved(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PrivateNetworkSaved(...).copyWith(id: 12, name: "My name")
  /// ````
  PrivateNetworkSaved call({
    Object? network = const $CopyWithPlaceholder(),
    Object? token = const $CopyWithPlaceholder(),
  }) {
    return PrivateNetworkSaved(
      network: network == const $CopyWithPlaceholder()
          ? _value.network
          // ignore: cast_nullable_to_non_nullable
          : network as PrivateNetwork,
      token: token == const $CopyWithPlaceholder()
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String?,
    );
  }
}

extension $PrivateNetworkSavedCopyWith on PrivateNetworkSaved {
  /// Returns a callable class that can be used as follows: `instanceOfPrivateNetworkSaved.copyWith(...)` or like so:`instanceOfPrivateNetworkSaved.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PrivateNetworkSavedCWProxy get copyWith =>
      _$PrivateNetworkSavedCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivateNetworkSaved _$PrivateNetworkSavedFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PrivateNetworkSaved', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['network']);
      final val = PrivateNetworkSaved(
        network: $checkedConvert(
          'network',
          (v) => PrivateNetwork.fromJson(v as Map<String, dynamic>),
        ),
        token: $checkedConvert('token', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$PrivateNetworkSavedToJson(
  PrivateNetworkSaved instance,
) => <String, dynamic>{
  'network': instance.network.toJson(),
  'token': ?instance.token,
};

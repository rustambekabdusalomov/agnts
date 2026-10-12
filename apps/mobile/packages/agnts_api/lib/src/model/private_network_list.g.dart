// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'private_network_list.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PrivateNetworkListCWProxy {
  PrivateNetworkList available(bool available);

  PrivateNetworkList linkUrl(String linkUrl);

  PrivateNetworkList max(int max);

  PrivateNetworkList networks(List<PrivateNetwork> networks);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PrivateNetworkList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PrivateNetworkList(...).copyWith(id: 12, name: "My name")
  /// ````
  PrivateNetworkList call({
    bool available,
    String linkUrl,
    int max,
    List<PrivateNetwork> networks,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPrivateNetworkList.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPrivateNetworkList.copyWith.fieldName(...)`
class _$PrivateNetworkListCWProxyImpl implements _$PrivateNetworkListCWProxy {
  const _$PrivateNetworkListCWProxyImpl(this._value);

  final PrivateNetworkList _value;

  @override
  PrivateNetworkList available(bool available) => this(available: available);

  @override
  PrivateNetworkList linkUrl(String linkUrl) => this(linkUrl: linkUrl);

  @override
  PrivateNetworkList max(int max) => this(max: max);

  @override
  PrivateNetworkList networks(List<PrivateNetwork> networks) =>
      this(networks: networks);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PrivateNetworkList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PrivateNetworkList(...).copyWith(id: 12, name: "My name")
  /// ````
  PrivateNetworkList call({
    Object? available = const $CopyWithPlaceholder(),
    Object? linkUrl = const $CopyWithPlaceholder(),
    Object? max = const $CopyWithPlaceholder(),
    Object? networks = const $CopyWithPlaceholder(),
  }) {
    return PrivateNetworkList(
      available: available == const $CopyWithPlaceholder()
          ? _value.available
          // ignore: cast_nullable_to_non_nullable
          : available as bool,
      linkUrl: linkUrl == const $CopyWithPlaceholder()
          ? _value.linkUrl
          // ignore: cast_nullable_to_non_nullable
          : linkUrl as String,
      max: max == const $CopyWithPlaceholder()
          ? _value.max
          // ignore: cast_nullable_to_non_nullable
          : max as int,
      networks: networks == const $CopyWithPlaceholder()
          ? _value.networks
          // ignore: cast_nullable_to_non_nullable
          : networks as List<PrivateNetwork>,
    );
  }
}

extension $PrivateNetworkListCopyWith on PrivateNetworkList {
  /// Returns a callable class that can be used as follows: `instanceOfPrivateNetworkList.copyWith(...)` or like so:`instanceOfPrivateNetworkList.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PrivateNetworkListCWProxy get copyWith =>
      _$PrivateNetworkListCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivateNetworkList _$PrivateNetworkListFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PrivateNetworkList', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['available', 'linkUrl', 'max', 'networks'],
      );
      final val = PrivateNetworkList(
        available: $checkedConvert('available', (v) => v as bool),
        linkUrl: $checkedConvert('linkUrl', (v) => v as String),
        max: $checkedConvert('max', (v) => (v as num).toInt()),
        networks: $checkedConvert(
          'networks',
          (v) => (v as List<dynamic>)
              .map((e) => PrivateNetwork.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PrivateNetworkListToJson(PrivateNetworkList instance) =>
    <String, dynamic>{
      'available': instance.available,
      'linkUrl': instance.linkUrl,
      'max': instance.max,
      'networks': instance.networks.map((e) => e.toJson()).toList(),
    };

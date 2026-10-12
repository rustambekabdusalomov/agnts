// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_test_network.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NetworkTestNetworkCWProxy {
  NetworkTestNetwork id(int id);

  NetworkTestNetwork name(String name);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NetworkTestNetwork(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NetworkTestNetwork(...).copyWith(id: 12, name: "My name")
  /// ````
  NetworkTestNetwork call({int id, String name});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNetworkTestNetwork.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNetworkTestNetwork.copyWith.fieldName(...)`
class _$NetworkTestNetworkCWProxyImpl implements _$NetworkTestNetworkCWProxy {
  const _$NetworkTestNetworkCWProxyImpl(this._value);

  final NetworkTestNetwork _value;

  @override
  NetworkTestNetwork id(int id) => this(id: id);

  @override
  NetworkTestNetwork name(String name) => this(name: name);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NetworkTestNetwork(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NetworkTestNetwork(...).copyWith(id: 12, name: "My name")
  /// ````
  NetworkTestNetwork call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
  }) {
    return NetworkTestNetwork(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
    );
  }
}

extension $NetworkTestNetworkCopyWith on NetworkTestNetwork {
  /// Returns a callable class that can be used as follows: `instanceOfNetworkTestNetwork.copyWith(...)` or like so:`instanceOfNetworkTestNetwork.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NetworkTestNetworkCWProxy get copyWith =>
      _$NetworkTestNetworkCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkTestNetwork _$NetworkTestNetworkFromJson(Map<String, dynamic> json) =>
    $checkedCreate('NetworkTestNetwork', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'name']);
      final val = NetworkTestNetwork(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        name: $checkedConvert('name', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$NetworkTestNetworkToJson(NetworkTestNetwork instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

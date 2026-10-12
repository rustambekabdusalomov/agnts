// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_private_network_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TestPrivateNetworkRequestCWProxy {
  TestPrivateNetworkRequest target(String target);

  TestPrivateNetworkRequest network(int? network);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TestPrivateNetworkRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TestPrivateNetworkRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  TestPrivateNetworkRequest call({String target, int? network});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTestPrivateNetworkRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTestPrivateNetworkRequest.copyWith.fieldName(...)`
class _$TestPrivateNetworkRequestCWProxyImpl
    implements _$TestPrivateNetworkRequestCWProxy {
  const _$TestPrivateNetworkRequestCWProxyImpl(this._value);

  final TestPrivateNetworkRequest _value;

  @override
  TestPrivateNetworkRequest target(String target) => this(target: target);

  @override
  TestPrivateNetworkRequest network(int? network) => this(network: network);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TestPrivateNetworkRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TestPrivateNetworkRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  TestPrivateNetworkRequest call({
    Object? target = const $CopyWithPlaceholder(),
    Object? network = const $CopyWithPlaceholder(),
  }) {
    return TestPrivateNetworkRequest(
      target: target == const $CopyWithPlaceholder()
          ? _value.target
          // ignore: cast_nullable_to_non_nullable
          : target as String,
      network: network == const $CopyWithPlaceholder()
          ? _value.network
          // ignore: cast_nullable_to_non_nullable
          : network as int?,
    );
  }
}

extension $TestPrivateNetworkRequestCopyWith on TestPrivateNetworkRequest {
  /// Returns a callable class that can be used as follows: `instanceOfTestPrivateNetworkRequest.copyWith(...)` or like so:`instanceOfTestPrivateNetworkRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TestPrivateNetworkRequestCWProxy get copyWith =>
      _$TestPrivateNetworkRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestPrivateNetworkRequest _$TestPrivateNetworkRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('TestPrivateNetworkRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['target']);
  final val = TestPrivateNetworkRequest(
    target: $checkedConvert('target', (v) => v as String),
    network: $checkedConvert('network', (v) => (v as num?)?.toInt()),
  );
  return val;
});

Map<String, dynamic> _$TestPrivateNetworkRequestToJson(
  TestPrivateNetworkRequest instance,
) => <String, dynamic>{'target': instance.target, 'network': ?instance.network};

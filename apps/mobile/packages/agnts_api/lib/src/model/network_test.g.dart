// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_test.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NetworkTestCWProxy {
  NetworkTest ok(bool ok);

  NetworkTest via(String? via);

  NetworkTest network(NetworkTestNetwork? network);

  NetworkTest resolved(String? resolved);

  NetworkTest connectMs(int? connectMs);

  NetworkTest error(String? error);

  NetworkTest tls(NetworkTestTls? tls);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NetworkTest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NetworkTest(...).copyWith(id: 12, name: "My name")
  /// ````
  NetworkTest call({
    bool ok,
    String? via,
    NetworkTestNetwork? network,
    String? resolved,
    int? connectMs,
    String? error,
    NetworkTestTls? tls,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNetworkTest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNetworkTest.copyWith.fieldName(...)`
class _$NetworkTestCWProxyImpl implements _$NetworkTestCWProxy {
  const _$NetworkTestCWProxyImpl(this._value);

  final NetworkTest _value;

  @override
  NetworkTest ok(bool ok) => this(ok: ok);

  @override
  NetworkTest via(String? via) => this(via: via);

  @override
  NetworkTest network(NetworkTestNetwork? network) => this(network: network);

  @override
  NetworkTest resolved(String? resolved) => this(resolved: resolved);

  @override
  NetworkTest connectMs(int? connectMs) => this(connectMs: connectMs);

  @override
  NetworkTest error(String? error) => this(error: error);

  @override
  NetworkTest tls(NetworkTestTls? tls) => this(tls: tls);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NetworkTest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NetworkTest(...).copyWith(id: 12, name: "My name")
  /// ````
  NetworkTest call({
    Object? ok = const $CopyWithPlaceholder(),
    Object? via = const $CopyWithPlaceholder(),
    Object? network = const $CopyWithPlaceholder(),
    Object? resolved = const $CopyWithPlaceholder(),
    Object? connectMs = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
    Object? tls = const $CopyWithPlaceholder(),
  }) {
    return NetworkTest(
      ok: ok == const $CopyWithPlaceholder()
          ? _value.ok
          // ignore: cast_nullable_to_non_nullable
          : ok as bool,
      via: via == const $CopyWithPlaceholder()
          ? _value.via
          // ignore: cast_nullable_to_non_nullable
          : via as String?,
      network: network == const $CopyWithPlaceholder()
          ? _value.network
          // ignore: cast_nullable_to_non_nullable
          : network as NetworkTestNetwork?,
      resolved: resolved == const $CopyWithPlaceholder()
          ? _value.resolved
          // ignore: cast_nullable_to_non_nullable
          : resolved as String?,
      connectMs: connectMs == const $CopyWithPlaceholder()
          ? _value.connectMs
          // ignore: cast_nullable_to_non_nullable
          : connectMs as int?,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String?,
      tls: tls == const $CopyWithPlaceholder()
          ? _value.tls
          // ignore: cast_nullable_to_non_nullable
          : tls as NetworkTestTls?,
    );
  }
}

extension $NetworkTestCopyWith on NetworkTest {
  /// Returns a callable class that can be used as follows: `instanceOfNetworkTest.copyWith(...)` or like so:`instanceOfNetworkTest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NetworkTestCWProxy get copyWith => _$NetworkTestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkTest _$NetworkTestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('NetworkTest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['ok']);
      final val = NetworkTest(
        ok: $checkedConvert('ok', (v) => v as bool),
        via: $checkedConvert('via', (v) => v as String?),
        network: $checkedConvert(
          'network',
          (v) => v == null
              ? null
              : NetworkTestNetwork.fromJson(v as Map<String, dynamic>),
        ),
        resolved: $checkedConvert('resolved', (v) => v as String?),
        connectMs: $checkedConvert('connectMs', (v) => (v as num?)?.toInt()),
        error: $checkedConvert('error', (v) => v as String?),
        tls: $checkedConvert(
          'tls',
          (v) => v == null
              ? null
              : NetworkTestTls.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$NetworkTestToJson(NetworkTest instance) =>
    <String, dynamic>{
      'ok': instance.ok,
      'via': ?instance.via,
      'network': ?instance.network?.toJson(),
      'resolved': ?instance.resolved,
      'connectMs': ?instance.connectMs,
      'error': ?instance.error,
      'tls': ?instance.tls?.toJson(),
    };

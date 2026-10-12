// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_route.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NetworkRouteCWProxy {
  NetworkRoute host(String? host);

  NetworkRoute cidr(String? cidr);

  NetworkRoute ports(List<int>? ports);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NetworkRoute(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NetworkRoute(...).copyWith(id: 12, name: "My name")
  /// ````
  NetworkRoute call({String? host, String? cidr, List<int>? ports});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNetworkRoute.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNetworkRoute.copyWith.fieldName(...)`
class _$NetworkRouteCWProxyImpl implements _$NetworkRouteCWProxy {
  const _$NetworkRouteCWProxyImpl(this._value);

  final NetworkRoute _value;

  @override
  NetworkRoute host(String? host) => this(host: host);

  @override
  NetworkRoute cidr(String? cidr) => this(cidr: cidr);

  @override
  NetworkRoute ports(List<int>? ports) => this(ports: ports);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NetworkRoute(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NetworkRoute(...).copyWith(id: 12, name: "My name")
  /// ````
  NetworkRoute call({
    Object? host = const $CopyWithPlaceholder(),
    Object? cidr = const $CopyWithPlaceholder(),
    Object? ports = const $CopyWithPlaceholder(),
  }) {
    return NetworkRoute(
      host: host == const $CopyWithPlaceholder()
          ? _value.host
          // ignore: cast_nullable_to_non_nullable
          : host as String?,
      cidr: cidr == const $CopyWithPlaceholder()
          ? _value.cidr
          // ignore: cast_nullable_to_non_nullable
          : cidr as String?,
      ports: ports == const $CopyWithPlaceholder()
          ? _value.ports
          // ignore: cast_nullable_to_non_nullable
          : ports as List<int>?,
    );
  }
}

extension $NetworkRouteCopyWith on NetworkRoute {
  /// Returns a callable class that can be used as follows: `instanceOfNetworkRoute.copyWith(...)` or like so:`instanceOfNetworkRoute.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NetworkRouteCWProxy get copyWith => _$NetworkRouteCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkRoute _$NetworkRouteFromJson(Map<String, dynamic> json) =>
    $checkedCreate('NetworkRoute', json, ($checkedConvert) {
      final val = NetworkRoute(
        host: $checkedConvert('host', (v) => v as String?),
        cidr: $checkedConvert('cidr', (v) => v as String?),
        ports: $checkedConvert(
          'ports',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$NetworkRouteToJson(NetworkRoute instance) =>
    <String, dynamic>{
      'host': ?instance.host,
      'cidr': ?instance.cidr,
      'ports': ?instance.ports,
    };

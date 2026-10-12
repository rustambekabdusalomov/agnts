// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'private_network_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PrivateNetworkInputCWProxy {
  PrivateNetworkInput name(String name);

  PrivateNetworkInput kind(PrivateNetworkInputKindEnum kind);

  PrivateNetworkInput enabled(bool enabled);

  PrivateNetworkInput config(String? config);

  PrivateNetworkInput username(String? username);

  PrivateNetworkInput password(String? password);

  PrivateNetworkInput routes(List<NetworkRoute> routes);

  PrivateNetworkInput caPem(String? caPem);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PrivateNetworkInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PrivateNetworkInput(...).copyWith(id: 12, name: "My name")
  /// ````
  PrivateNetworkInput call({
    String name,
    PrivateNetworkInputKindEnum kind,
    bool enabled,
    String? config,
    String? username,
    String? password,
    List<NetworkRoute> routes,
    String? caPem,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPrivateNetworkInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPrivateNetworkInput.copyWith.fieldName(...)`
class _$PrivateNetworkInputCWProxyImpl implements _$PrivateNetworkInputCWProxy {
  const _$PrivateNetworkInputCWProxyImpl(this._value);

  final PrivateNetworkInput _value;

  @override
  PrivateNetworkInput name(String name) => this(name: name);

  @override
  PrivateNetworkInput kind(PrivateNetworkInputKindEnum kind) =>
      this(kind: kind);

  @override
  PrivateNetworkInput enabled(bool enabled) => this(enabled: enabled);

  @override
  PrivateNetworkInput config(String? config) => this(config: config);

  @override
  PrivateNetworkInput username(String? username) => this(username: username);

  @override
  PrivateNetworkInput password(String? password) => this(password: password);

  @override
  PrivateNetworkInput routes(List<NetworkRoute> routes) => this(routes: routes);

  @override
  PrivateNetworkInput caPem(String? caPem) => this(caPem: caPem);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PrivateNetworkInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PrivateNetworkInput(...).copyWith(id: 12, name: "My name")
  /// ````
  PrivateNetworkInput call({
    Object? name = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? enabled = const $CopyWithPlaceholder(),
    Object? config = const $CopyWithPlaceholder(),
    Object? username = const $CopyWithPlaceholder(),
    Object? password = const $CopyWithPlaceholder(),
    Object? routes = const $CopyWithPlaceholder(),
    Object? caPem = const $CopyWithPlaceholder(),
  }) {
    return PrivateNetworkInput(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as PrivateNetworkInputKindEnum,
      enabled: enabled == const $CopyWithPlaceholder()
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool,
      config: config == const $CopyWithPlaceholder()
          ? _value.config
          // ignore: cast_nullable_to_non_nullable
          : config as String?,
      username: username == const $CopyWithPlaceholder()
          ? _value.username
          // ignore: cast_nullable_to_non_nullable
          : username as String?,
      password: password == const $CopyWithPlaceholder()
          ? _value.password
          // ignore: cast_nullable_to_non_nullable
          : password as String?,
      routes: routes == const $CopyWithPlaceholder()
          ? _value.routes
          // ignore: cast_nullable_to_non_nullable
          : routes as List<NetworkRoute>,
      caPem: caPem == const $CopyWithPlaceholder()
          ? _value.caPem
          // ignore: cast_nullable_to_non_nullable
          : caPem as String?,
    );
  }
}

extension $PrivateNetworkInputCopyWith on PrivateNetworkInput {
  /// Returns a callable class that can be used as follows: `instanceOfPrivateNetworkInput.copyWith(...)` or like so:`instanceOfPrivateNetworkInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PrivateNetworkInputCWProxy get copyWith =>
      _$PrivateNetworkInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivateNetworkInput _$PrivateNetworkInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PrivateNetworkInput', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['name', 'kind', 'enabled', 'routes'],
      );
      final val = PrivateNetworkInput(
        name: $checkedConvert('name', (v) => v as String),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$PrivateNetworkInputKindEnumEnumMap, v),
        ),
        enabled: $checkedConvert('enabled', (v) => v as bool),
        config: $checkedConvert('config', (v) => v as String?),
        username: $checkedConvert('username', (v) => v as String?),
        password: $checkedConvert('password', (v) => v as String?),
        routes: $checkedConvert(
          'routes',
          (v) => (v as List<dynamic>)
              .map((e) => NetworkRoute.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        caPem: $checkedConvert('caPem', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$PrivateNetworkInputToJson(
  PrivateNetworkInput instance,
) => <String, dynamic>{
  'name': instance.name,
  'kind': _$PrivateNetworkInputKindEnumEnumMap[instance.kind]!,
  'enabled': instance.enabled,
  'config': ?instance.config,
  'username': ?instance.username,
  'password': ?instance.password,
  'routes': instance.routes.map((e) => e.toJson()).toList(),
  'caPem': ?instance.caPem,
};

const _$PrivateNetworkInputKindEnumEnumMap = {
  PrivateNetworkInputKindEnum.wireguard: 'wireguard',
  PrivateNetworkInputKindEnum.openvpn: 'openvpn',
  PrivateNetworkInputKindEnum.connector: 'connector',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'private_network.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PrivateNetworkCWProxy {
  PrivateNetwork id(int id);

  PrivateNetwork name(String name);

  PrivateNetwork kind(PrivateNetworkKindEnum kind);

  PrivateNetwork enabled(bool enabled);

  PrivateNetwork summary(String? summary);

  PrivateNetwork routes(List<NetworkRoute> routes);

  PrivateNetwork ca(PrivateNetworkCa? ca);

  PrivateNetwork status(PrivateNetworkStatusEnum status);

  PrivateNetwork lastError(String? lastError);

  PrivateNetwork upAt(DateTime? upAt);

  PrivateNetwork handshakeAt(DateTime? handshakeAt);

  PrivateNetwork detail(String? detail);

  PrivateNetwork tokenSet(bool tokenSet);

  PrivateNetwork webhooks(PrivateNetworkWebhooksEnum webhooks);

  PrivateNetwork pollMinutes(int pollMinutes);

  PrivateNetwork updatedAt(DateTime updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PrivateNetwork(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PrivateNetwork(...).copyWith(id: 12, name: "My name")
  /// ````
  PrivateNetwork call({
    int id,
    String name,
    PrivateNetworkKindEnum kind,
    bool enabled,
    String? summary,
    List<NetworkRoute> routes,
    PrivateNetworkCa? ca,
    PrivateNetworkStatusEnum status,
    String? lastError,
    DateTime? upAt,
    DateTime? handshakeAt,
    String? detail,
    bool tokenSet,
    PrivateNetworkWebhooksEnum webhooks,
    int pollMinutes,
    DateTime updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPrivateNetwork.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPrivateNetwork.copyWith.fieldName(...)`
class _$PrivateNetworkCWProxyImpl implements _$PrivateNetworkCWProxy {
  const _$PrivateNetworkCWProxyImpl(this._value);

  final PrivateNetwork _value;

  @override
  PrivateNetwork id(int id) => this(id: id);

  @override
  PrivateNetwork name(String name) => this(name: name);

  @override
  PrivateNetwork kind(PrivateNetworkKindEnum kind) => this(kind: kind);

  @override
  PrivateNetwork enabled(bool enabled) => this(enabled: enabled);

  @override
  PrivateNetwork summary(String? summary) => this(summary: summary);

  @override
  PrivateNetwork routes(List<NetworkRoute> routes) => this(routes: routes);

  @override
  PrivateNetwork ca(PrivateNetworkCa? ca) => this(ca: ca);

  @override
  PrivateNetwork status(PrivateNetworkStatusEnum status) =>
      this(status: status);

  @override
  PrivateNetwork lastError(String? lastError) => this(lastError: lastError);

  @override
  PrivateNetwork upAt(DateTime? upAt) => this(upAt: upAt);

  @override
  PrivateNetwork handshakeAt(DateTime? handshakeAt) =>
      this(handshakeAt: handshakeAt);

  @override
  PrivateNetwork detail(String? detail) => this(detail: detail);

  @override
  PrivateNetwork tokenSet(bool tokenSet) => this(tokenSet: tokenSet);

  @override
  PrivateNetwork webhooks(PrivateNetworkWebhooksEnum webhooks) =>
      this(webhooks: webhooks);

  @override
  PrivateNetwork pollMinutes(int pollMinutes) => this(pollMinutes: pollMinutes);

  @override
  PrivateNetwork updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PrivateNetwork(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PrivateNetwork(...).copyWith(id: 12, name: "My name")
  /// ````
  PrivateNetwork call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? enabled = const $CopyWithPlaceholder(),
    Object? summary = const $CopyWithPlaceholder(),
    Object? routes = const $CopyWithPlaceholder(),
    Object? ca = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? lastError = const $CopyWithPlaceholder(),
    Object? upAt = const $CopyWithPlaceholder(),
    Object? handshakeAt = const $CopyWithPlaceholder(),
    Object? detail = const $CopyWithPlaceholder(),
    Object? tokenSet = const $CopyWithPlaceholder(),
    Object? webhooks = const $CopyWithPlaceholder(),
    Object? pollMinutes = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return PrivateNetwork(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as PrivateNetworkKindEnum,
      enabled: enabled == const $CopyWithPlaceholder()
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool,
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as String?,
      routes: routes == const $CopyWithPlaceholder()
          ? _value.routes
          // ignore: cast_nullable_to_non_nullable
          : routes as List<NetworkRoute>,
      ca: ca == const $CopyWithPlaceholder()
          ? _value.ca
          // ignore: cast_nullable_to_non_nullable
          : ca as PrivateNetworkCa?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as PrivateNetworkStatusEnum,
      lastError: lastError == const $CopyWithPlaceholder()
          ? _value.lastError
          // ignore: cast_nullable_to_non_nullable
          : lastError as String?,
      upAt: upAt == const $CopyWithPlaceholder()
          ? _value.upAt
          // ignore: cast_nullable_to_non_nullable
          : upAt as DateTime?,
      handshakeAt: handshakeAt == const $CopyWithPlaceholder()
          ? _value.handshakeAt
          // ignore: cast_nullable_to_non_nullable
          : handshakeAt as DateTime?,
      detail: detail == const $CopyWithPlaceholder()
          ? _value.detail
          // ignore: cast_nullable_to_non_nullable
          : detail as String?,
      tokenSet: tokenSet == const $CopyWithPlaceholder()
          ? _value.tokenSet
          // ignore: cast_nullable_to_non_nullable
          : tokenSet as bool,
      webhooks: webhooks == const $CopyWithPlaceholder()
          ? _value.webhooks
          // ignore: cast_nullable_to_non_nullable
          : webhooks as PrivateNetworkWebhooksEnum,
      pollMinutes: pollMinutes == const $CopyWithPlaceholder()
          ? _value.pollMinutes
          // ignore: cast_nullable_to_non_nullable
          : pollMinutes as int,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
    );
  }
}

extension $PrivateNetworkCopyWith on PrivateNetwork {
  /// Returns a callable class that can be used as follows: `instanceOfPrivateNetwork.copyWith(...)` or like so:`instanceOfPrivateNetwork.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PrivateNetworkCWProxy get copyWith => _$PrivateNetworkCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivateNetwork _$PrivateNetworkFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PrivateNetwork', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'name',
          'kind',
          'enabled',
          'routes',
          'status',
          'tokenSet',
          'webhooks',
          'pollMinutes',
          'updatedAt',
        ],
      );
      final val = PrivateNetwork(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        name: $checkedConvert('name', (v) => v as String),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$PrivateNetworkKindEnumEnumMap, v),
        ),
        enabled: $checkedConvert('enabled', (v) => v as bool),
        summary: $checkedConvert('summary', (v) => v as String?),
        routes: $checkedConvert(
          'routes',
          (v) => (v as List<dynamic>)
              .map((e) => NetworkRoute.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        ca: $checkedConvert(
          'ca',
          (v) => v == null
              ? null
              : PrivateNetworkCa.fromJson(v as Map<String, dynamic>),
        ),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$PrivateNetworkStatusEnumEnumMap, v),
        ),
        lastError: $checkedConvert('lastError', (v) => v as String?),
        upAt: $checkedConvert(
          'upAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        handshakeAt: $checkedConvert(
          'handshakeAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        detail: $checkedConvert('detail', (v) => v as String?),
        tokenSet: $checkedConvert('tokenSet', (v) => v as bool),
        webhooks: $checkedConvert(
          'webhooks',
          (v) => $enumDecode(_$PrivateNetworkWebhooksEnumEnumMap, v),
        ),
        pollMinutes: $checkedConvert('pollMinutes', (v) => (v as num).toInt()),
        updatedAt: $checkedConvert(
          'updatedAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PrivateNetworkToJson(PrivateNetwork instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'kind': _$PrivateNetworkKindEnumEnumMap[instance.kind]!,
      'enabled': instance.enabled,
      'summary': ?instance.summary,
      'routes': instance.routes.map((e) => e.toJson()).toList(),
      'ca': ?instance.ca?.toJson(),
      'status': _$PrivateNetworkStatusEnumEnumMap[instance.status]!,
      'lastError': ?instance.lastError,
      'upAt': ?instance.upAt?.toIso8601String(),
      'handshakeAt': ?instance.handshakeAt?.toIso8601String(),
      'detail': ?instance.detail,
      'tokenSet': instance.tokenSet,
      'webhooks': _$PrivateNetworkWebhooksEnumEnumMap[instance.webhooks]!,
      'pollMinutes': instance.pollMinutes,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$PrivateNetworkKindEnumEnumMap = {
  PrivateNetworkKindEnum.wireguard: 'wireguard',
  PrivateNetworkKindEnum.openvpn: 'openvpn',
  PrivateNetworkKindEnum.connector: 'connector',
};

const _$PrivateNetworkStatusEnumEnumMap = {
  PrivateNetworkStatusEnum.connecting: 'connecting',
  PrivateNetworkStatusEnum.up: 'up',
  PrivateNetworkStatusEnum.error: 'error',
  PrivateNetworkStatusEnum.disabled: 'disabled',
  PrivateNetworkStatusEnum.gatewayDown: 'gateway_down',
};

const _$PrivateNetworkWebhooksEnumEnumMap = {
  PrivateNetworkWebhooksEnum.relay: 'relay',
  PrivateNetworkWebhooksEnum.polling: 'polling',
};

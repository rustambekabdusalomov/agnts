//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/private_network_ca.dart';
import 'package:agnts_api/src/model/network_route.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'private_network.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PrivateNetwork {
  /// Returns a new [PrivateNetwork] instance.
  PrivateNetwork({

    required  this.id,

    required  this.name,

    required  this.kind,

    required  this.enabled,

     this.summary,

    required  this.routes,

     this.ca,

    required  this.status,

     this.lastError,

     this.upAt,

     this.handshakeAt,

     this.detail,

    required  this.tokenSet,

    required  this.webhooks,

    required  this.pollMinutes,

    required  this.updatedAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final PrivateNetworkKindEnum kind;



  @JsonKey(
    
    name: r'enabled',
    required: true,
    includeIfNull: false,
  )


  final bool enabled;



      /// The config without its keys, e.g. peer vpn.corp.com:51820
  @JsonKey(
    
    name: r'summary',
    required: false,
    includeIfNull: false,
  )


  final String? summary;



  @JsonKey(
    
    name: r'routes',
    required: true,
    includeIfNull: false,
  )


  final List<NetworkRoute> routes;



  @JsonKey(
    
    name: r'ca',
    required: false,
    includeIfNull: false,
  )


  final PrivateNetworkCa? ca;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final PrivateNetworkStatusEnum status;



  @JsonKey(
    
    name: r'lastError',
    required: false,
    includeIfNull: false,
  )


  final String? lastError;



  @JsonKey(
    
    name: r'upAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? upAt;



      /// WireGuard's last handshake, or agnts-link's last heartbeat
  @JsonKey(
    
    name: r'handshakeAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? handshakeAt;



  @JsonKey(
    
    name: r'detail',
    required: false,
    includeIfNull: false,
  )


  final String? detail;



      /// An agnts-link token exists
  @JsonKey(
    
    name: r'tokenSet',
    required: true,
    includeIfNull: false,
  )


  final bool tokenSet;



      /// relay — agnts-link forwards webhooks; polling — trackers reached through it are read every pollMinutes
  @JsonKey(
    
    name: r'webhooks',
    required: true,
    includeIfNull: false,
  )


  final PrivateNetworkWebhooksEnum webhooks;



  @JsonKey(
    
    name: r'pollMinutes',
    required: true,
    includeIfNull: false,
  )


  final int pollMinutes;



  @JsonKey(
    
    name: r'updatedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime updatedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PrivateNetwork &&
      other.id == id &&
      other.name == name &&
      other.kind == kind &&
      other.enabled == enabled &&
      other.summary == summary &&
      other.routes == routes &&
      other.ca == ca &&
      other.status == status &&
      other.lastError == lastError &&
      other.upAt == upAt &&
      other.handshakeAt == handshakeAt &&
      other.detail == detail &&
      other.tokenSet == tokenSet &&
      other.webhooks == webhooks &&
      other.pollMinutes == pollMinutes &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        kind.hashCode +
        enabled.hashCode +
        summary.hashCode +
        routes.hashCode +
        ca.hashCode +
        status.hashCode +
        lastError.hashCode +
        upAt.hashCode +
        handshakeAt.hashCode +
        detail.hashCode +
        tokenSet.hashCode +
        webhooks.hashCode +
        pollMinutes.hashCode +
        updatedAt.hashCode;

  factory PrivateNetwork.fromJson(Map<String, dynamic> json) => _$PrivateNetworkFromJson(json);

  Map<String, dynamic> toJson() => _$PrivateNetworkToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum PrivateNetworkKindEnum {
@JsonValue(r'wireguard')
wireguard(r'wireguard'),
@JsonValue(r'openvpn')
openvpn(r'openvpn'),
@JsonValue(r'connector')
connector(r'connector');

const PrivateNetworkKindEnum(this.value);

final String value;

@override
String toString() => value;
}


enum PrivateNetworkStatusEnum {
@JsonValue(r'connecting')
connecting(r'connecting'),
@JsonValue(r'up')
up(r'up'),
@JsonValue(r'error')
error(r'error'),
@JsonValue(r'disabled')
disabled(r'disabled'),
@JsonValue(r'gateway_down')
gatewayDown(r'gateway_down');

const PrivateNetworkStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


/// relay — agnts-link forwards webhooks; polling — trackers reached through it are read every pollMinutes
enum PrivateNetworkWebhooksEnum {
@JsonValue(r'relay')
relay(r'relay'),
@JsonValue(r'polling')
polling(r'polling');

const PrivateNetworkWebhooksEnum(this.value);

final String value;

@override
String toString() => value;
}



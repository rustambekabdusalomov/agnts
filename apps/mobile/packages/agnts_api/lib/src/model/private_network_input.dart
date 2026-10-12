//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/network_route.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'private_network_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PrivateNetworkInput {
  /// Returns a new [PrivateNetworkInput] instance.
  PrivateNetworkInput({

    required  this.name,

    required  this.kind,

    required  this.enabled,

     this.config,

     this.username,

     this.password,

    required  this.routes,

     this.caPem,
  });

      /// Unique in the workspace, e.g. the company or office it reaches
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


  final PrivateNetworkInputKindEnum kind;



  @JsonKey(
    
    name: r'enabled',
    required: true,
    includeIfNull: false,
  )


  final bool enabled;



      /// The WireGuard or OpenVPN config; left out keeps the saved one
  @JsonKey(
    
    name: r'config',
    required: false,
    includeIfNull: false,
  )


  final String? config;



      /// OpenVPN auth-user-pass
  @JsonKey(
    
    name: r'username',
    required: false,
    includeIfNull: false,
  )


  final String? username;



      /// OpenVPN auth-user-pass; left out or empty keeps the saved one
  @JsonKey(
    
    name: r'password',
    required: false,
    includeIfNull: false,
  )


  final String? password;



  @JsonKey(
    
    name: r'routes',
    required: true,
    includeIfNull: false,
  )


  final List<NetworkRoute> routes;



      /// Company CA certificates (PEM); \"\" removes them, left out keeps them
  @JsonKey(
    
    name: r'caPem',
    required: false,
    includeIfNull: false,
  )


  final String? caPem;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PrivateNetworkInput &&
      other.name == name &&
      other.kind == kind &&
      other.enabled == enabled &&
      other.config == config &&
      other.username == username &&
      other.password == password &&
      other.routes == routes &&
      other.caPem == caPem;

    @override
    int get hashCode =>
        name.hashCode +
        kind.hashCode +
        enabled.hashCode +
        config.hashCode +
        username.hashCode +
        password.hashCode +
        routes.hashCode +
        caPem.hashCode;

  factory PrivateNetworkInput.fromJson(Map<String, dynamic> json) => _$PrivateNetworkInputFromJson(json);

  Map<String, dynamic> toJson() => _$PrivateNetworkInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum PrivateNetworkInputKindEnum {
@JsonValue(r'wireguard')
wireguard(r'wireguard'),
@JsonValue(r'openvpn')
openvpn(r'openvpn'),
@JsonValue(r'connector')
connector(r'connector');

const PrivateNetworkInputKindEnum(this.value);

final String value;

@override
String toString() => value;
}



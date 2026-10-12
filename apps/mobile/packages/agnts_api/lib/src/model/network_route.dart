//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'network_route.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NetworkRoute {
  /// Returns a new [NetworkRoute] instance.
  NetworkRoute({

     this.host,

     this.cidr,

     this.ports,
  });

  @JsonKey(
    
    name: r'host',
    required: false,
    includeIfNull: false,
  )


  final String? host;



  @JsonKey(
    
    name: r'cidr',
    required: false,
    includeIfNull: false,
  )


  final String? cidr;



  @JsonKey(
    
    name: r'ports',
    required: false,
    includeIfNull: false,
  )


  final List<int>? ports;





    @override
    bool operator ==(Object other) => identical(this, other) || other is NetworkRoute &&
      other.host == host &&
      other.cidr == cidr &&
      other.ports == ports;

    @override
    int get hashCode =>
        host.hashCode +
        cidr.hashCode +
        ports.hashCode;

  factory NetworkRoute.fromJson(Map<String, dynamic> json) => _$NetworkRouteFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkRouteToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


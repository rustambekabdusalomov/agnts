//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/private_network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'private_network_list.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PrivateNetworkList {
  /// Returns a new [PrivateNetworkList] instance.
  PrivateNetworkList({

    required  this.available,

    required  this.linkUrl,

    required  this.max,

    required  this.networks,
  });

      /// The server runs the gateway (private networks can be used)
  @JsonKey(
    
    name: r'available',
    required: true,
    includeIfNull: false,
  )


  final bool available;



      /// Where agnts-link connects
  @JsonKey(
    
    name: r'linkUrl',
    required: true,
    includeIfNull: false,
  )


  final String linkUrl;



      /// How many networks a workspace may keep
  @JsonKey(
    
    name: r'max',
    required: true,
    includeIfNull: false,
  )


  final int max;



  @JsonKey(
    
    name: r'networks',
    required: true,
    includeIfNull: false,
  )


  final List<PrivateNetwork> networks;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PrivateNetworkList &&
      other.available == available &&
      other.linkUrl == linkUrl &&
      other.max == max &&
      other.networks == networks;

    @override
    int get hashCode =>
        available.hashCode +
        linkUrl.hashCode +
        max.hashCode +
        networks.hashCode;

  factory PrivateNetworkList.fromJson(Map<String, dynamic> json) => _$PrivateNetworkListFromJson(json);

  Map<String, dynamic> toJson() => _$PrivateNetworkListToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


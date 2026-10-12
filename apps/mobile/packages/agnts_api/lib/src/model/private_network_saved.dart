//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/private_network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'private_network_saved.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PrivateNetworkSaved {
  /// Returns a new [PrivateNetworkSaved] instance.
  PrivateNetworkSaved({

    required  this.network,

     this.token,
  });

  @JsonKey(
    
    name: r'network',
    required: true,
    includeIfNull: false,
  )


  final PrivateNetwork network;



      /// A new agnts-link token, shown once
  @JsonKey(
    
    name: r'token',
    required: false,
    includeIfNull: false,
  )


  final String? token;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PrivateNetworkSaved &&
      other.network == network &&
      other.token == token;

    @override
    int get hashCode =>
        network.hashCode +
        token.hashCode;

  factory PrivateNetworkSaved.fromJson(Map<String, dynamic> json) => _$PrivateNetworkSavedFromJson(json);

  Map<String, dynamic> toJson() => _$PrivateNetworkSavedToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


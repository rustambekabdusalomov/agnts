//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'test_private_network_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TestPrivateNetworkRequest {
  /// Returns a new [TestPrivateNetworkRequest] instance.
  TestPrivateNetworkRequest({

    required  this.target,

     this.network,
  });

      /// host:port, e.g. gitlab.corp.local:443
  @JsonKey(
    
    name: r'target',
    required: true,
    includeIfNull: false,
  )


  final String target;



      /// The network expected to carry it; the result says if another one would
  @JsonKey(
    
    name: r'network',
    required: false,
    includeIfNull: false,
  )


  final int? network;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TestPrivateNetworkRequest &&
      other.target == target &&
      other.network == network;

    @override
    int get hashCode =>
        target.hashCode +
        network.hashCode;

  factory TestPrivateNetworkRequest.fromJson(Map<String, dynamic> json) => _$TestPrivateNetworkRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TestPrivateNetworkRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


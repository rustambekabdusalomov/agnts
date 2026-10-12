//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/network_test_network.dart';
import 'package:agnts_api/src/model/network_test_tls.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'network_test.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NetworkTest {
  /// Returns a new [NetworkTest] instance.
  NetworkTest({

    required  this.ok,

     this.via,

     this.network,

     this.resolved,

     this.connectMs,

     this.error,

     this.tls,
  });

      /// The connection was made
  @JsonKey(
    
    name: r'ok',
    required: true,
    includeIfNull: false,
  )


  final bool ok;



  @JsonKey(
    
    name: r'via',
    required: false,
    includeIfNull: false,
  )


  final String? via;



  @JsonKey(
    
    name: r'network',
    required: false,
    includeIfNull: false,
  )


  final NetworkTestNetwork? network;



      /// The address the name resolved to inside the tunnel
  @JsonKey(
    
    name: r'resolved',
    required: false,
    includeIfNull: false,
  )


  final String? resolved;



  @JsonKey(
    
    name: r'connectMs',
    required: false,
    includeIfNull: false,
  )


  final int? connectMs;



  @JsonKey(
    
    name: r'error',
    required: false,
    includeIfNull: false,
  )


  final String? error;



  @JsonKey(
    
    name: r'tls',
    required: false,
    includeIfNull: false,
  )


  final NetworkTestTls? tls;





    @override
    bool operator ==(Object other) => identical(this, other) || other is NetworkTest &&
      other.ok == ok &&
      other.via == via &&
      other.network == network &&
      other.resolved == resolved &&
      other.connectMs == connectMs &&
      other.error == error &&
      other.tls == tls;

    @override
    int get hashCode =>
        ok.hashCode +
        via.hashCode +
        network.hashCode +
        resolved.hashCode +
        connectMs.hashCode +
        error.hashCode +
        tls.hashCode;

  factory NetworkTest.fromJson(Map<String, dynamic> json) => _$NetworkTestFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkTestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


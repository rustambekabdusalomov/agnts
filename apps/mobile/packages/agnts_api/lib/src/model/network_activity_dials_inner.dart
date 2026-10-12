//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'network_activity_dials_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NetworkActivityDialsInner {
  /// Returns a new [NetworkActivityDialsInner] instance.
  NetworkActivityDialsInner({

    required  this.at,

    required  this.target,

     this.network,

     this.ticket,

    required  this.source_,

    required  this.ok,

     this.error,

    required  this.bytesIn,

    required  this.bytesOut,
  });

  @JsonKey(
    
    name: r'at',
    required: true,
    includeIfNull: false,
  )


  final DateTime at;



  @JsonKey(
    
    name: r'target',
    required: true,
    includeIfNull: false,
  )


  final String target;



      /// The network that carried it (none: refused before one was picked, or since removed)
  @JsonKey(
    
    name: r'network',
    required: false,
    includeIfNull: false,
  )


  final int? network;



  @JsonKey(
    
    name: r'ticket',
    required: false,
    includeIfNull: false,
  )


  final String? ticket;



      /// run, server, test or webhook
  @JsonKey(
    
    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final String source_;



  @JsonKey(
    
    name: r'ok',
    required: true,
    includeIfNull: false,
  )


  final bool ok;



  @JsonKey(
    
    name: r'error',
    required: false,
    includeIfNull: false,
  )


  final String? error;



  @JsonKey(
    
    name: r'bytesIn',
    required: true,
    includeIfNull: false,
  )


  final int bytesIn;



  @JsonKey(
    
    name: r'bytesOut',
    required: true,
    includeIfNull: false,
  )


  final int bytesOut;





    @override
    bool operator ==(Object other) => identical(this, other) || other is NetworkActivityDialsInner &&
      other.at == at &&
      other.target == target &&
      other.network == network &&
      other.ticket == ticket &&
      other.source_ == source_ &&
      other.ok == ok &&
      other.error == error &&
      other.bytesIn == bytesIn &&
      other.bytesOut == bytesOut;

    @override
    int get hashCode =>
        at.hashCode +
        target.hashCode +
        network.hashCode +
        ticket.hashCode +
        source_.hashCode +
        ok.hashCode +
        error.hashCode +
        bytesIn.hashCode +
        bytesOut.hashCode;

  factory NetworkActivityDialsInner.fromJson(Map<String, dynamic> json) => _$NetworkActivityDialsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkActivityDialsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


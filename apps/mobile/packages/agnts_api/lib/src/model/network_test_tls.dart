//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'network_test_tls.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NetworkTestTls {
  /// Returns a new [NetworkTestTls] instance.
  NetworkTestTls({

    required  this.verified,

     this.subject,

     this.issuer,

     this.notAfter,

     this.error,
  });

  @JsonKey(
    
    name: r'verified',
    required: true,
    includeIfNull: false,
  )


  final bool verified;



  @JsonKey(
    
    name: r'subject',
    required: false,
    includeIfNull: false,
  )


  final String? subject;



  @JsonKey(
    
    name: r'issuer',
    required: false,
    includeIfNull: false,
  )


  final String? issuer;



  @JsonKey(
    
    name: r'notAfter',
    required: false,
    includeIfNull: false,
  )


  final DateTime? notAfter;



  @JsonKey(
    
    name: r'error',
    required: false,
    includeIfNull: false,
  )


  final String? error;





    @override
    bool operator ==(Object other) => identical(this, other) || other is NetworkTestTls &&
      other.verified == verified &&
      other.subject == subject &&
      other.issuer == issuer &&
      other.notAfter == notAfter &&
      other.error == error;

    @override
    int get hashCode =>
        verified.hashCode +
        subject.hashCode +
        issuer.hashCode +
        notAfter.hashCode +
        error.hashCode;

  factory NetworkTestTls.fromJson(Map<String, dynamic> json) => _$NetworkTestTlsFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkTestTlsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'egress_upstream_exit.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EgressUpstreamExit {
  /// Returns a new [EgressUpstreamExit] instance.
  EgressUpstreamExit({

    required  this.ip,

     this.org,

     this.city,

     this.country,

    required  this.at,
  });

  @JsonKey(
    
    name: r'ip',
    required: true,
    includeIfNull: false,
  )


  final String ip;



  @JsonKey(
    
    name: r'org',
    required: false,
    includeIfNull: false,
  )


  final String? org;



  @JsonKey(
    
    name: r'city',
    required: false,
    includeIfNull: false,
  )


  final String? city;



  @JsonKey(
    
    name: r'country',
    required: false,
    includeIfNull: false,
  )


  final String? country;



  @JsonKey(
    
    name: r'at',
    required: true,
    includeIfNull: false,
  )


  final DateTime at;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EgressUpstreamExit &&
      other.ip == ip &&
      other.org == org &&
      other.city == city &&
      other.country == country &&
      other.at == at;

    @override
    int get hashCode =>
        ip.hashCode +
        org.hashCode +
        city.hashCode +
        country.hashCode +
        at.hashCode;

  factory EgressUpstreamExit.fromJson(Map<String, dynamic> json) => _$EgressUpstreamExitFromJson(json);

  Map<String, dynamic> toJson() => _$EgressUpstreamExitToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


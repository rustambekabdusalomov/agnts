//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'private_network_ca.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PrivateNetworkCa {
  /// Returns a new [PrivateNetworkCa] instance.
  PrivateNetworkCa({

    required  this.subjects,

    required  this.notAfter,
  });

  @JsonKey(
    
    name: r'subjects',
    required: true,
    includeIfNull: false,
  )


  final List<String> subjects;



  @JsonKey(
    
    name: r'notAfter',
    required: true,
    includeIfNull: false,
  )


  final DateTime notAfter;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PrivateNetworkCa &&
      other.subjects == subjects &&
      other.notAfter == notAfter;

    @override
    int get hashCode =>
        subjects.hashCode +
        notAfter.hashCode;

  factory PrivateNetworkCa.fromJson(Map<String, dynamic> json) => _$PrivateNetworkCaFromJson(json);

  Map<String, dynamic> toJson() => _$PrivateNetworkCaToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


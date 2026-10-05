//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'environment.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Environment {
  /// Returns a new [Environment] instance.
  Environment({

    required  this.name,

    required  this.sha,

     this.deployedAt,

    required  this.url,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'sha',
    required: true,
    includeIfNull: false,
  )


  final String sha;



  @JsonKey(
    
    name: r'deployedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? deployedAt;



  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Environment &&
      other.name == name &&
      other.sha == sha &&
      other.deployedAt == deployedAt &&
      other.url == url;

    @override
    int get hashCode =>
        name.hashCode +
        sha.hashCode +
        deployedAt.hashCode +
        url.hashCode;

  factory Environment.fromJson(Map<String, dynamic> json) => _$EnvironmentFromJson(json);

  Map<String, dynamic> toJson() => _$EnvironmentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


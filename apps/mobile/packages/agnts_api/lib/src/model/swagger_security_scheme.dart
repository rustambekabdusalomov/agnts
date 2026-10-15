//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/api_auth_kind.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'swagger_security_scheme.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SwaggerSecurityScheme {
  /// Returns a new [SwaggerSecurityScheme] instance.
  SwaggerSecurityScheme({

    required  this.name,

    required  this.type,

     this.scheme,

     this.in_,

     this.param,

     this.authKind,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final String type;



  @JsonKey(
    
    name: r'scheme',
    required: false,
    includeIfNull: false,
  )


  final String? scheme;



  @JsonKey(
    
    name: r'in',
    required: false,
    includeIfNull: false,
  )


  final String? in_;



  @JsonKey(
    
    name: r'param',
    required: false,
    includeIfNull: false,
  )


  final String? param;



  @JsonKey(
    
    name: r'authKind',
    required: false,
    includeIfNull: false,
  )


  final ApiAuthKind? authKind;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SwaggerSecurityScheme &&
      other.name == name &&
      other.type == type &&
      other.scheme == scheme &&
      other.in_ == in_ &&
      other.param == param &&
      other.authKind == authKind;

    @override
    int get hashCode =>
        name.hashCode +
        type.hashCode +
        scheme.hashCode +
        in_.hashCode +
        param.hashCode +
        authKind.hashCode;

  factory SwaggerSecurityScheme.fromJson(Map<String, dynamic> json) => _$SwaggerSecuritySchemeFromJson(json);

  Map<String, dynamic> toJson() => _$SwaggerSecuritySchemeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


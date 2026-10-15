//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/swagger_auth_input.dart';
import 'package:agnts_api/src/model/swagger_spec_input_login.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'swagger_spec_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SwaggerSpecInput {
  /// Returns a new [SwaggerSpecInput] instance.
  SwaggerSpecInput({

     this.url,

     this.spec,

     this.auth,

     this.login,
  });

  @JsonKey(
    
    name: r'url',
    required: false,
    includeIfNull: false,
  )


  final String? url;



  @JsonKey(
    
    name: r'spec',
    required: false,
    includeIfNull: false,
  )


  final String? spec;



  @JsonKey(
    
    name: r'auth',
    required: false,
    includeIfNull: false,
  )


  final SwaggerAuthInput? auth;



  @JsonKey(
    
    name: r'login',
    required: false,
    includeIfNull: false,
  )


  final SwaggerSpecInputLogin? login;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SwaggerSpecInput &&
      other.url == url &&
      other.spec == spec &&
      other.auth == auth &&
      other.login == login;

    @override
    int get hashCode =>
        url.hashCode +
        spec.hashCode +
        auth.hashCode +
        login.hashCode;

  factory SwaggerSpecInput.fromJson(Map<String, dynamic> json) => _$SwaggerSpecInputFromJson(json);

  Map<String, dynamic> toJson() => _$SwaggerSpecInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


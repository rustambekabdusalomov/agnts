//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LoginRequest {
  /// Returns a new [LoginRequest] instance.
  LoginRequest({

    required  this.username,

    required  this.password,

     this.code,

    required  this.client,
  });

      /// Username or email
  @JsonKey(
    
    name: r'username',
    required: true,
    includeIfNull: false,
  )


  final String username;



  @JsonKey(
    
    name: r'password',
    required: true,
    includeIfNull: false,
  )


  final String password;



      /// Six-digit code from the authenticator app, when two-factor sign-in is on
  @JsonKey(
    
    name: r'code',
    required: false,
    includeIfNull: false,
  )


  final String? code;



  @JsonKey(
    
    name: r'client',
    required: true,
    includeIfNull: false,
  )


  final LoginRequestClientEnum client;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LoginRequest &&
      other.username == username &&
      other.password == password &&
      other.code == code &&
      other.client == client;

    @override
    int get hashCode =>
        username.hashCode +
        password.hashCode +
        code.hashCode +
        client.hashCode;

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum LoginRequestClientEnum {
@JsonValue(r'web')
web(r'web'),
@JsonValue(r'mobile')
mobile(r'mobile');

const LoginRequestClientEnum(this.value);

final String value;

@override
String toString() => value;
}



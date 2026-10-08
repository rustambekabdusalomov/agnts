//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'register_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RegisterRequest {
  /// Returns a new [RegisterRequest] instance.
  RegisterRequest({

    required  this.email,

     this.username,

     this.displayName,

    required  this.password,

     this.workspaceName,

     this.invite,

    required  this.client,
  });

  @JsonKey(
    
    name: r'email',
    required: true,
    includeIfNull: false,
  )


  final String email;



      /// Derived from the email when empty
  @JsonKey(
    
    name: r'username',
    required: false,
    includeIfNull: false,
  )


  final String? username;



  @JsonKey(
    
    name: r'displayName',
    required: false,
    includeIfNull: false,
  )


  final String? displayName;



  @JsonKey(
    
    name: r'password',
    required: true,
    includeIfNull: false,
  )


  final String password;



      /// Name of the first workspace; not created when joining by invite
  @JsonKey(
    
    name: r'workspaceName',
    required: false,
    includeIfNull: false,
  )


  final String? workspaceName;



      /// An invite token to join with
  @JsonKey(
    
    name: r'invite',
    required: false,
    includeIfNull: false,
  )


  final String? invite;



  @JsonKey(
    
    name: r'client',
    required: true,
    includeIfNull: false,
  )


  final RegisterRequestClientEnum client;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RegisterRequest &&
      other.email == email &&
      other.username == username &&
      other.displayName == displayName &&
      other.password == password &&
      other.workspaceName == workspaceName &&
      other.invite == invite &&
      other.client == client;

    @override
    int get hashCode =>
        email.hashCode +
        username.hashCode +
        displayName.hashCode +
        password.hashCode +
        workspaceName.hashCode +
        invite.hashCode +
        client.hashCode;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum RegisterRequestClientEnum {
@JsonValue(r'web')
web(r'web'),
@JsonValue(r'mobile')
mobile(r'mobile');

const RegisterRequestClientEnum(this.value);

final String value;

@override
String toString() => value;
}



//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_platform_admin_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreatePlatformAdminRequest {
  /// Returns a new [CreatePlatformAdminRequest] instance.
  CreatePlatformAdminRequest({

    required  this.username,

     this.email,

     this.displayName,

    required  this.password,
  });

  @JsonKey(
    
    name: r'username',
    required: true,
    includeIfNull: false,
  )


  final String username;



  @JsonKey(
    
    name: r'email',
    required: false,
    includeIfNull: false,
  )


  final String? email;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreatePlatformAdminRequest &&
      other.username == username &&
      other.email == email &&
      other.displayName == displayName &&
      other.password == password;

    @override
    int get hashCode =>
        username.hashCode +
        email.hashCode +
        displayName.hashCode +
        password.hashCode;

  factory CreatePlatformAdminRequest.fromJson(Map<String, dynamic> json) => _$CreatePlatformAdminRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePlatformAdminRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


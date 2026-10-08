//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_invite_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateInviteRequest {
  /// Returns a new [CreateInviteRequest] instance.
  CreateInviteRequest({

     this.email,

     this.role,
  });

      /// Sends the link by email; empty makes a link to share yourself
  @JsonKey(
    
    name: r'email',
    required: false,
    includeIfNull: false,
  )


  final String? email;



      /// The role the invite joins as (user when omitted)
  @JsonKey(
    
    name: r'role',
    required: false,
    includeIfNull: false,
  )


  final CreateInviteRequestRoleEnum? role;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateInviteRequest &&
      other.email == email &&
      other.role == role;

    @override
    int get hashCode =>
        email.hashCode +
        role.hashCode;

  factory CreateInviteRequest.fromJson(Map<String, dynamic> json) => _$CreateInviteRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateInviteRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// The role the invite joins as (user when omitted)
enum CreateInviteRequestRoleEnum {
@JsonValue(r'user')
user(r'user'),
@JsonValue(r'viewer')
viewer(r'viewer');

const CreateInviteRequestRoleEnum(this.value);

final String value;

@override
String toString() => value;
}



//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'set_member_role_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SetMemberRoleRequest {
  /// Returns a new [SetMemberRoleRequest] instance.
  SetMemberRoleRequest({

    required  this.role,
  });

  @JsonKey(
    
    name: r'role',
    required: true,
    includeIfNull: false,
  )


  final SetMemberRoleRequestRoleEnum role;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SetMemberRoleRequest &&
      other.role == role;

    @override
    int get hashCode =>
        role.hashCode;

  factory SetMemberRoleRequest.fromJson(Map<String, dynamic> json) => _$SetMemberRoleRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SetMemberRoleRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum SetMemberRoleRequestRoleEnum {
@JsonValue(r'user')
user(r'user'),
@JsonValue(r'viewer')
viewer(r'viewer');

const SetMemberRoleRequestRoleEnum(this.value);

final String value;

@override
String toString() => value;
}



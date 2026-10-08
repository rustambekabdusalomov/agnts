//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/workspace_role.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'member.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Member {
  /// Returns a new [Member] instance.
  Member({

    required  this.userId,

    required  this.username,

     this.displayName,

     this.email,

    required  this.role,

    required  this.joinedAt,

    required  this.claudeConnected,
  });

  @JsonKey(
    
    name: r'userId',
    required: true,
    includeIfNull: false,
  )


  final int userId;



  @JsonKey(
    
    name: r'username',
    required: true,
    includeIfNull: false,
  )


  final String username;



  @JsonKey(
    
    name: r'displayName',
    required: false,
    includeIfNull: false,
  )


  final String? displayName;



      /// Shown to the owner only
  @JsonKey(
    
    name: r'email',
    required: false,
    includeIfNull: false,
  )


  final String? email;



  @JsonKey(
    
    name: r'role',
    required: true,
    includeIfNull: false,
  )


  final WorkspaceRole role;



  @JsonKey(
    
    name: r'joinedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime joinedAt;



      /// Has a personal Claude connection (per-member mode)
  @JsonKey(
    
    name: r'claudeConnected',
    required: true,
    includeIfNull: false,
  )


  final bool claudeConnected;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Member &&
      other.userId == userId &&
      other.username == username &&
      other.displayName == displayName &&
      other.email == email &&
      other.role == role &&
      other.joinedAt == joinedAt &&
      other.claudeConnected == claudeConnected;

    @override
    int get hashCode =>
        userId.hashCode +
        username.hashCode +
        displayName.hashCode +
        email.hashCode +
        role.hashCode +
        joinedAt.hashCode +
        claudeConnected.hashCode;

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

  Map<String, dynamic> toJson() => _$MemberToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


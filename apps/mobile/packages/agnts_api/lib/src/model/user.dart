//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/workspace_summary.dart';
import 'package:agnts_api/src/model/module.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class User {
  /// Returns a new [User] instance.
  User({

    required  this.id,

    required  this.username,

     this.displayName,

     this.email,

     this.emailVerified,

     this.isAdmin,

     this.hasTotp,

     this.lastWorkspace,

     this.modules,

     this.workspaces,

     this.createdAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



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



  @JsonKey(
    
    name: r'email',
    required: false,
    includeIfNull: false,
  )


  final String? email;



  @JsonKey(
    
    name: r'emailVerified',
    required: false,
    includeIfNull: false,
  )


  final bool? emailVerified;



      /// The platform operator (system role Admin)
  @JsonKey(
    
    name: r'isAdmin',
    required: false,
    includeIfNull: false,
  )


  final bool? isAdmin;



      /// Signs in with a second factor
  @JsonKey(
    
    name: r'hasTotp',
    required: false,
    includeIfNull: false,
  )


  final bool? hasTotp;



      /// The slug of the workspace opened last
  @JsonKey(
    
    name: r'lastWorkspace',
    required: false,
    includeIfNull: false,
  )


  final String? lastWorkspace;



      /// The coding modules the user may use, the default first (on /auth/me only)
  @JsonKey(
    
    name: r'modules',
    required: false,
    includeIfNull: false,
  )


  final List<Module>? modules;



      /// The workspaces the user is a member of (on /auth/me only)
  @JsonKey(
    
    name: r'workspaces',
    required: false,
    includeIfNull: false,
  )


  final List<WorkspaceSummary>? workspaces;



  @JsonKey(
    
    name: r'createdAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is User &&
      other.id == id &&
      other.username == username &&
      other.displayName == displayName &&
      other.email == email &&
      other.emailVerified == emailVerified &&
      other.isAdmin == isAdmin &&
      other.hasTotp == hasTotp &&
      other.lastWorkspace == lastWorkspace &&
      other.modules == modules &&
      other.workspaces == workspaces &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        username.hashCode +
        displayName.hashCode +
        email.hashCode +
        emailVerified.hashCode +
        isAdmin.hashCode +
        hasTotp.hashCode +
        lastWorkspace.hashCode +
        modules.hashCode +
        workspaces.hashCode +
        createdAt.hashCode;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


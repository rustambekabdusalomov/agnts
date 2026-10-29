//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/workspace_summary.dart';
import 'package:agnts_api/src/model/credit_usage.dart';
import 'package:agnts_api/src/model/user.dart';
import 'package:agnts_api/src/model/free_credits.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'platform_user.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlatformUser {
  /// Returns a new [PlatformUser] instance.
  PlatformUser({

    required  this.user,

    required  this.hasPassword,

     this.lastSignInAt,

    required  this.workspaces,

     this.freeCredits,

     this.creditUsage,
  });

  @JsonKey(
    
    name: r'user',
    required: true,
    includeIfNull: false,
  )


  final User user;



      /// Can sign in with a password; false for accounts made with Google sign-in
  @JsonKey(
    
    name: r'hasPassword',
    required: true,
    includeIfNull: false,
  )


  final bool hasPassword;



      /// The newest session still on record
  @JsonKey(
    
    name: r'lastSignInAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? lastSignInAt;



      /// The workspaces they belong to (not deleted), with their role
  @JsonKey(
    
    name: r'workspaces',
    required: true,
    includeIfNull: false,
  )


  final List<WorkspaceSummary> workspaces;



  @JsonKey(
    
    name: r'freeCredits',
    required: false,
    includeIfNull: false,
  )


  final FreeCredits? freeCredits;



  @JsonKey(
    
    name: r'creditUsage',
    required: false,
    includeIfNull: false,
  )


  final CreditUsage? creditUsage;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PlatformUser &&
      other.user == user &&
      other.hasPassword == hasPassword &&
      other.lastSignInAt == lastSignInAt &&
      other.workspaces == workspaces &&
      other.freeCredits == freeCredits &&
      other.creditUsage == creditUsage;

    @override
    int get hashCode =>
        user.hashCode +
        hasPassword.hashCode +
        lastSignInAt.hashCode +
        workspaces.hashCode +
        freeCredits.hashCode +
        creditUsage.hashCode;

  factory PlatformUser.fromJson(Map<String, dynamic> json) => _$PlatformUserFromJson(json);

  Map<String, dynamic> toJson() => _$PlatformUserToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


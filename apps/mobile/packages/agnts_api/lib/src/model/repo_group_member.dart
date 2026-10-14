//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'repo_group_member.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RepoGroupMember {
  /// Returns a new [RepoGroupMember] instance.
  RepoGroupMember({

    required  this.repoId,

    required  this.repoName,

    required  this.role,

    required  this.archived,
  });

  @JsonKey(
    
    name: r'repoId',
    required: true,
    includeIfNull: false,
  )


  final int repoId;



  @JsonKey(
    
    name: r'repoName',
    required: true,
    includeIfNull: false,
  )


  final String repoName;



  @JsonKey(
    
    name: r'role',
    required: true,
    includeIfNull: false,
  )


  final String role;



      /// Archived: tickets made from the group leave it out
  @JsonKey(
    
    name: r'archived',
    required: true,
    includeIfNull: false,
  )


  final bool archived;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RepoGroupMember &&
      other.repoId == repoId &&
      other.repoName == repoName &&
      other.role == role &&
      other.archived == archived;

    @override
    int get hashCode =>
        repoId.hashCode +
        repoName.hashCode +
        role.hashCode +
        archived.hashCode;

  factory RepoGroupMember.fromJson(Map<String, dynamic> json) => _$RepoGroupMemberFromJson(json);

  Map<String, dynamic> toJson() => _$RepoGroupMemberToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


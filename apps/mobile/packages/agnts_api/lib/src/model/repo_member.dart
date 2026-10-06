//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'repo_member.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RepoMember {
  /// Returns a new [RepoMember] instance.
  RepoMember({

    required  this.username,

     this.name,

     this.avatarUrl,

     this.url,

    required  this.role,
  });

  @JsonKey(
    
    name: r'username',
    required: true,
    includeIfNull: false,
  )


  final String username;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'avatarUrl',
    required: false,
    includeIfNull: false,
  )


  final String? avatarUrl;



      /// Profile page on the git host
  @JsonKey(
    
    name: r'url',
    required: false,
    includeIfNull: false,
  )


  final String? url;



      /// The host's role name, e.g. admin, write (GitHub) or Maintainer, Developer (GitLab)
  @JsonKey(
    
    name: r'role',
    required: true,
    includeIfNull: false,
  )


  final String role;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RepoMember &&
      other.username == username &&
      other.name == name &&
      other.avatarUrl == avatarUrl &&
      other.url == url &&
      other.role == role;

    @override
    int get hashCode =>
        username.hashCode +
        name.hashCode +
        avatarUrl.hashCode +
        url.hashCode +
        role.hashCode;

  factory RepoMember.fromJson(Map<String, dynamic> json) => _$RepoMemberFromJson(json);

  Map<String, dynamic> toJson() => _$RepoMemberToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


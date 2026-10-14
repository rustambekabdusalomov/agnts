//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'repo_group_input_members_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RepoGroupInputMembersInner {
  /// Returns a new [RepoGroupInputMembersInner] instance.
  RepoGroupInputMembersInner({

    required  this.repoId,

     this.role,
  });

  @JsonKey(
    
    name: r'repoId',
    required: true,
    includeIfNull: false,
  )


  final int repoId;



  @JsonKey(
    
    name: r'role',
    required: false,
    includeIfNull: false,
  )


  final String? role;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RepoGroupInputMembersInner &&
      other.repoId == repoId &&
      other.role == role;

    @override
    int get hashCode =>
        repoId.hashCode +
        role.hashCode;

  factory RepoGroupInputMembersInner.fromJson(Map<String, dynamic> json) => _$RepoGroupInputMembersInnerFromJson(json);

  Map<String, dynamic> toJson() => _$RepoGroupInputMembersInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


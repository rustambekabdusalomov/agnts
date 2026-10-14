//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/repo_group_member.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'repo_group.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RepoGroup {
  /// Returns a new [RepoGroup] instance.
  RepoGroup({

    required  this.id,

    required  this.name,

    required  this.description,

    required  this.instructions,

    required  this.taskPrefix,

    required  this.members,

    required  this.warnings,

    required  this.createdAt,

    required  this.updatedAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'description',
    required: true,
    includeIfNull: false,
  )


  final String description;



      /// How the repositories fit together; added to every prompt of its tickets
  @JsonKey(
    
    name: r'instructions',
    required: true,
    includeIfNull: false,
  )


  final String instructions;



      /// Key prefix of tasks made from the group; empty uses the first repository's
  @JsonKey(
    
    name: r'taskPrefix',
    required: true,
    includeIfNull: false,
  )


  final String taskPrefix;



  @JsonKey(
    
    name: r'members',
    required: true,
    includeIfNull: false,
  )


  final List<RepoGroupMember> members;



      /// What the repositories share uneasily in one run container (a build variable both set)
  @JsonKey(
    
    name: r'warnings',
    required: true,
    includeIfNull: false,
  )


  final List<String> warnings;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;



  @JsonKey(
    
    name: r'updatedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime updatedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RepoGroup &&
      other.id == id &&
      other.name == name &&
      other.description == description &&
      other.instructions == instructions &&
      other.taskPrefix == taskPrefix &&
      other.members == members &&
      other.warnings == warnings &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        description.hashCode +
        instructions.hashCode +
        taskPrefix.hashCode +
        members.hashCode +
        warnings.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode;

  factory RepoGroup.fromJson(Map<String, dynamic> json) => _$RepoGroupFromJson(json);

  Map<String, dynamic> toJson() => _$RepoGroupToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/repo_group_input_members_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'repo_group_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RepoGroupInput {
  /// Returns a new [RepoGroupInput] instance.
  RepoGroupInput({

    required  this.name,

     this.description,

     this.instructions,

     this.taskPrefix,

     this.branchTemplate,

     this.commitTemplate,

     this.prTemplate,

    required  this.members,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



  @JsonKey(
    
    name: r'instructions',
    required: false,
    includeIfNull: false,
  )


  final String? instructions;



  @JsonKey(
    
    name: r'taskPrefix',
    required: false,
    includeIfNull: false,
  )


  final String? taskPrefix;



      /// Branch name template (as a repository's); must contain {key} or {number}. Empty keeps each repository's own
  @JsonKey(
    
    name: r'branchTemplate',
    required: false,
    includeIfNull: false,
  )


  final String? branchTemplate;



      /// Commit message template (as a repository's); must contain {subject} or {title}. Empty keeps each repository's own
  @JsonKey(
    
    name: r'commitTemplate',
    required: false,
    includeIfNull: false,
  )


  final String? commitTemplate;



      /// Pull request title template (as a repository's); must contain {subject} or {title}. Empty keeps each repository's own
  @JsonKey(
    
    name: r'prTemplate',
    required: false,
    includeIfNull: false,
  )


  final String? prTemplate;



      /// In order; the first is the primary repository of the group's tickets
  @JsonKey(
    
    name: r'members',
    required: true,
    includeIfNull: false,
  )


  final List<RepoGroupInputMembersInner> members;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RepoGroupInput &&
      other.name == name &&
      other.description == description &&
      other.instructions == instructions &&
      other.taskPrefix == taskPrefix &&
      other.branchTemplate == branchTemplate &&
      other.commitTemplate == commitTemplate &&
      other.prTemplate == prTemplate &&
      other.members == members;

    @override
    int get hashCode =>
        name.hashCode +
        description.hashCode +
        instructions.hashCode +
        taskPrefix.hashCode +
        branchTemplate.hashCode +
        commitTemplate.hashCode +
        prTemplate.hashCode +
        members.hashCode;

  factory RepoGroupInput.fromJson(Map<String, dynamic> json) => _$RepoGroupInputFromJson(json);

  Map<String, dynamic> toJson() => _$RepoGroupInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


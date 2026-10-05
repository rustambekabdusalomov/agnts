//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'repository_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RepositoryInput {
  /// Returns a new [RepositoryInput] instance.
  RepositoryInput({

    required  this.name,

     this.kind,

    required  this.cloneUrl,

     this.defaultBranch,

     this.buildCmd,

     this.lintCmd,

     this.testCmd,

     this.branchPrefix,

     this.taskPrefix,

     this.instructions,

     this.jiraProject,

     this.deployWorkflow,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



      /// Ignored; derived from jiraProject.
  @Deprecated('kind has been deprecated')
  @JsonKey(
    
    name: r'kind',
    required: false,
    includeIfNull: false,
  )


  final RepositoryInputKindEnum? kind;



  @JsonKey(
    
    name: r'cloneUrl',
    required: true,
    includeIfNull: false,
  )


  final String cloneUrl;



  @JsonKey(
    
    name: r'defaultBranch',
    required: false,
    includeIfNull: false,
  )


  final String? defaultBranch;



  @JsonKey(
    
    name: r'buildCmd',
    required: false,
    includeIfNull: false,
  )


  final String? buildCmd;



  @JsonKey(
    
    name: r'lintCmd',
    required: false,
    includeIfNull: false,
  )


  final String? lintCmd;



  @JsonKey(
    
    name: r'testCmd',
    required: false,
    includeIfNull: false,
  )


  final String? testCmd;



  @JsonKey(
    
    name: r'branchPrefix',
    required: false,
    includeIfNull: false,
  )


  final String? branchPrefix;



  @JsonKey(
    
    name: r'taskPrefix',
    required: false,
    includeIfNull: false,
  )


  final String? taskPrefix;



  @JsonKey(
    
    name: r'instructions',
    required: false,
    includeIfNull: false,
  )


  final String? instructions;



  @JsonKey(
    
    name: r'jiraProject',
    required: false,
    includeIfNull: false,
  )


  final String? jiraProject;



      /// GitHub workflow file run by Deploy, e.g. deploy.yml
  @JsonKey(
    
    name: r'deployWorkflow',
    required: false,
    includeIfNull: false,
  )


  final String? deployWorkflow;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RepositoryInput &&
      other.name == name &&
      other.kind == kind &&
      other.cloneUrl == cloneUrl &&
      other.defaultBranch == defaultBranch &&
      other.buildCmd == buildCmd &&
      other.lintCmd == lintCmd &&
      other.testCmd == testCmd &&
      other.branchPrefix == branchPrefix &&
      other.taskPrefix == taskPrefix &&
      other.instructions == instructions &&
      other.jiraProject == jiraProject &&
      other.deployWorkflow == deployWorkflow;

    @override
    int get hashCode =>
        name.hashCode +
        kind.hashCode +
        cloneUrl.hashCode +
        defaultBranch.hashCode +
        buildCmd.hashCode +
        lintCmd.hashCode +
        testCmd.hashCode +
        branchPrefix.hashCode +
        taskPrefix.hashCode +
        instructions.hashCode +
        jiraProject.hashCode +
        deployWorkflow.hashCode;

  factory RepositoryInput.fromJson(Map<String, dynamic> json) => _$RepositoryInputFromJson(json);

  Map<String, dynamic> toJson() => _$RepositoryInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// Ignored; derived from jiraProject.
enum RepositoryInputKindEnum {
@JsonValue(r'jira')
jira(r'jira'),
@JsonValue(r'side')
side(r'side');

const RepositoryInputKindEnum(this.value);

final String value;

@override
String toString() => value;
}



//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/repo_preview.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'repository.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Repository {
  /// Returns a new [Repository] instance.
  Repository({

    required  this.id,

    required  this.name,

    required  this.kind,

    required  this.provider,

    required  this.cloneUrl,

    required  this.defaultBranch,

    required  this.buildCmd,

    required  this.lintCmd,

    required  this.testCmd,

    required  this.branchPrefix,

    required  this.taskPrefix,

    required  this.instructions,

    required  this.jiraProject,

    required  this.claudeMd,

    required  this.openTickets,

     this.deployWorkflow,

     this.archivedAt,

     this.preview,
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



      /// jira when the repository has a Jira project key, else side. Every repository takes side-project tasks.
  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final RepositoryKindEnum kind;



  @JsonKey(
    
    name: r'provider',
    required: true,
    includeIfNull: false,
  )


  final RepositoryProviderEnum provider;



  @JsonKey(
    
    name: r'cloneUrl',
    required: true,
    includeIfNull: false,
  )


  final String cloneUrl;



  @JsonKey(
    
    name: r'defaultBranch',
    required: true,
    includeIfNull: false,
  )


  final String defaultBranch;



  @JsonKey(
    
    name: r'buildCmd',
    required: true,
    includeIfNull: false,
  )


  final String buildCmd;



  @JsonKey(
    
    name: r'lintCmd',
    required: true,
    includeIfNull: false,
  )


  final String lintCmd;



  @JsonKey(
    
    name: r'testCmd',
    required: true,
    includeIfNull: false,
  )


  final String testCmd;



  @JsonKey(
    
    name: r'branchPrefix',
    required: true,
    includeIfNull: false,
  )


  final String branchPrefix;



  @JsonKey(
    
    name: r'taskPrefix',
    required: true,
    includeIfNull: false,
  )


  final String taskPrefix;



      /// Extra instructions added to every prompt
  @JsonKey(
    
    name: r'instructions',
    required: true,
    includeIfNull: false,
  )


  final String instructions;



  @JsonKey(
    
    name: r'jiraProject',
    required: true,
    includeIfNull: false,
  )


  final String jiraProject;



  @JsonKey(
    
    name: r'claudeMd',
    required: true,
    includeIfNull: false,
  )


  final RepositoryClaudeMdEnum claudeMd;



  @JsonKey(
    
    name: r'openTickets',
    required: true,
    includeIfNull: false,
  )


  final int openTickets;



  @JsonKey(
    
    name: r'deployWorkflow',
    required: false,
    includeIfNull: false,
  )


  final String? deployWorkflow;



      /// Set while the repository is archived
  @JsonKey(
    
    name: r'archivedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? archivedAt;



  @JsonKey(
    
    name: r'preview',
    required: false,
    includeIfNull: false,
  )


  final RepoPreview? preview;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Repository &&
      other.id == id &&
      other.name == name &&
      other.kind == kind &&
      other.provider == provider &&
      other.cloneUrl == cloneUrl &&
      other.defaultBranch == defaultBranch &&
      other.buildCmd == buildCmd &&
      other.lintCmd == lintCmd &&
      other.testCmd == testCmd &&
      other.branchPrefix == branchPrefix &&
      other.taskPrefix == taskPrefix &&
      other.instructions == instructions &&
      other.jiraProject == jiraProject &&
      other.claudeMd == claudeMd &&
      other.openTickets == openTickets &&
      other.deployWorkflow == deployWorkflow &&
      other.archivedAt == archivedAt &&
      other.preview == preview;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        kind.hashCode +
        provider.hashCode +
        cloneUrl.hashCode +
        defaultBranch.hashCode +
        buildCmd.hashCode +
        lintCmd.hashCode +
        testCmd.hashCode +
        branchPrefix.hashCode +
        taskPrefix.hashCode +
        instructions.hashCode +
        jiraProject.hashCode +
        claudeMd.hashCode +
        openTickets.hashCode +
        deployWorkflow.hashCode +
        archivedAt.hashCode +
        preview.hashCode;

  factory Repository.fromJson(Map<String, dynamic> json) => _$RepositoryFromJson(json);

  Map<String, dynamic> toJson() => _$RepositoryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// jira when the repository has a Jira project key, else side. Every repository takes side-project tasks.
enum RepositoryKindEnum {
@JsonValue(r'jira')
jira(r'jira'),
@JsonValue(r'side')
side(r'side');

const RepositoryKindEnum(this.value);

final String value;

@override
String toString() => value;
}


enum RepositoryProviderEnum {
@JsonValue(r'github')
github(r'github'),
@JsonValue(r'gitlab')
gitlab(r'gitlab');

const RepositoryProviderEnum(this.value);

final String value;

@override
String toString() => value;
}


enum RepositoryClaudeMdEnum {
@JsonValue(r'found')
found(r'found'),
@JsonValue(r'missing')
missing(r'missing'),
@JsonValue(r'unknown')
unknown(r'unknown');

const RepositoryClaudeMdEnum(this.value);

final String value;

@override
String toString() => value;
}



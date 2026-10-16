//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/toolchain.dart';
import 'package:agnts_api/src/model/repo_group_ref.dart';
import 'package:agnts_api/src/model/repo_preview.dart';
import 'package:agnts_api/src/model/repo_harness.dart';
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

     this.branchTemplate,

     this.commitTemplate,

    required  this.taskPrefix,

    required  this.instructions,

    required  this.jiraProject,

     this.planeProject,

    required  this.claudeMd,

    required  this.openTickets,

     this.deployWorkflow,

     this.archivedAt,

     this.preview,

     this.stack,

     this.toolchains,

     this.toolchainsOverride,

     this.toolchainsDetectedAt,

     this.toolchainNotes,

     this.runnerImage,

     this.memoryMb,

     this.buildEnvSet,

     this.buildEnvNames,

     this.harness,

     this.groups,
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



      /// jira when the repository has a Jira project key, plane when it has only a Plane project, else side. Every repository takes side-project tasks.
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



      /// How agnts names branches, with placeholders {prefix} {type} {key} {number} {slug} {user}; empty uses {prefix}{key}
  @JsonKey(
    
    name: r'branchTemplate',
    required: false,
    includeIfNull: false,
  )


  final String? branchTemplate;



      /// How agnts writes commit messages, with placeholders {number} {key} {type} {scope} {subject} {title}; empty uses KEY: Title
  @JsonKey(
    
    name: r'commitTemplate',
    required: false,
    includeIfNull: false,
  )


  final String? commitTemplate;



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



      /// Plane project identifier (WEB in WEB-123); empty when not linked
  @JsonKey(
    
    name: r'planeProject',
    required: false,
    includeIfNull: false,
  )


  final String? planeProject;



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



      /// Toolchain names, comma-separated (go,node)
  @JsonKey(
    
    name: r'stack',
    required: false,
    includeIfNull: false,
  )


  final String? stack;



      /// Installed into every run container
  @JsonKey(
    
    name: r'toolchains',
    required: false,
    includeIfNull: false,
  )


  final List<Toolchain>? toolchains;



      /// Set by a person; detection leaves them alone
  @JsonKey(
    
    name: r'toolchainsOverride',
    required: false,
    includeIfNull: false,
  )


  final bool? toolchainsOverride;



  @JsonKey(
    
    name: r'toolchainsDetectedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? toolchainsDetectedAt;



      /// What detection could not handle
  @JsonKey(
    
    name: r'toolchainNotes',
    required: false,
    includeIfNull: false,
  )


  final List<String>? toolchainNotes;



      /// Custom runner image (built FROM agnts-runner); empty uses the default
  @JsonKey(
    
    name: r'runnerImage',
    required: false,
    includeIfNull: false,
  )


  final String? runnerImage;



      /// Run container memory; 0 uses the server default
  @JsonKey(
    
    name: r'memoryMb',
    required: false,
    includeIfNull: false,
  )


  final int? memoryMb;



  @JsonKey(
    
    name: r'buildEnvSet',
    required: false,
    includeIfNull: false,
  )


  final bool? buildEnvSet;



      /// Names of the build environment variables; the values are never returned
  @JsonKey(
    
    name: r'buildEnvNames',
    required: false,
    includeIfNull: false,
  )


  final List<String>? buildEnvNames;



  @JsonKey(
    
    name: r'harness',
    required: false,
    includeIfNull: false,
  )


  final RepoHarness? harness;



      /// The groups it is a member of
  @JsonKey(
    
    name: r'groups',
    required: false,
    includeIfNull: false,
  )


  final List<RepoGroupRef>? groups;





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
      other.branchTemplate == branchTemplate &&
      other.commitTemplate == commitTemplate &&
      other.taskPrefix == taskPrefix &&
      other.instructions == instructions &&
      other.jiraProject == jiraProject &&
      other.planeProject == planeProject &&
      other.claudeMd == claudeMd &&
      other.openTickets == openTickets &&
      other.deployWorkflow == deployWorkflow &&
      other.archivedAt == archivedAt &&
      other.preview == preview &&
      other.stack == stack &&
      other.toolchains == toolchains &&
      other.toolchainsOverride == toolchainsOverride &&
      other.toolchainsDetectedAt == toolchainsDetectedAt &&
      other.toolchainNotes == toolchainNotes &&
      other.runnerImage == runnerImage &&
      other.memoryMb == memoryMb &&
      other.buildEnvSet == buildEnvSet &&
      other.buildEnvNames == buildEnvNames &&
      other.harness == harness &&
      other.groups == groups;

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
        branchTemplate.hashCode +
        commitTemplate.hashCode +
        taskPrefix.hashCode +
        instructions.hashCode +
        jiraProject.hashCode +
        planeProject.hashCode +
        claudeMd.hashCode +
        openTickets.hashCode +
        deployWorkflow.hashCode +
        archivedAt.hashCode +
        preview.hashCode +
        stack.hashCode +
        toolchains.hashCode +
        toolchainsOverride.hashCode +
        toolchainsDetectedAt.hashCode +
        toolchainNotes.hashCode +
        runnerImage.hashCode +
        memoryMb.hashCode +
        buildEnvSet.hashCode +
        buildEnvNames.hashCode +
        harness.hashCode +
        groups.hashCode;

  factory Repository.fromJson(Map<String, dynamic> json) => _$RepositoryFromJson(json);

  Map<String, dynamic> toJson() => _$RepositoryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// jira when the repository has a Jira project key, plane when it has only a Plane project, else side. Every repository takes side-project tasks.
enum RepositoryKindEnum {
@JsonValue(r'jira')
jira(r'jira'),
@JsonValue(r'plane')
plane(r'plane'),
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



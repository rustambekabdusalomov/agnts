//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/repo_preview_input.dart';
import 'package:agnts_api/src/model/toolchain.dart';
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

     this.branchTemplate,

     this.commitTemplate,

     this.prTemplate,

     this.taskPrefix,

     this.instructions,

     this.jiraProject,

     this.planeProject,

     this.deployWorkflow,

     this.preview,

     this.toolchains,

     this.toolchainsOverride,

     this.runnerImage,

     this.memoryMb,

     this.buildEnv,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



      /// Ignored; derived from jiraProject and planeProject.
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



      /// Branch name template; must contain {key} or {number}. Empty uses {prefix}{key}
  @JsonKey(
    
    name: r'branchTemplate',
    required: false,
    includeIfNull: false,
  )


  final String? branchTemplate;



      /// Commit message template; must contain {subject} or {title}. Empty uses KEY: Title
  @JsonKey(
    
    name: r'commitTemplate',
    required: false,
    includeIfNull: false,
  )


  final String? commitTemplate;



      /// Pull request title template, with the commit template's placeholders; must contain {subject} or {title}. Empty uses the workspace's PR title
  @JsonKey(
    
    name: r'prTemplate',
    required: false,
    includeIfNull: false,
  )


  final String? prTemplate;



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



  @JsonKey(
    
    name: r'planeProject',
    required: false,
    includeIfNull: false,
  )


  final String? planeProject;



      /// GitHub workflow file run by Deploy, e.g. deploy.yml
  @JsonKey(
    
    name: r'deployWorkflow',
    required: false,
    includeIfNull: false,
  )


  final String? deployWorkflow;



  @JsonKey(
    
    name: r'preview',
    required: false,
    includeIfNull: false,
  )


  final RepoPreviewInput? preview;



      /// Absent keeps the stored list
  @JsonKey(
    
    name: r'toolchains',
    required: false,
    includeIfNull: false,
  )


  final List<Toolchain>? toolchains;



      /// true: these toolchains were set by hand; detection keeps them
  @JsonKey(
    
    name: r'toolchainsOverride',
    required: false,
    includeIfNull: false,
  )


  final bool? toolchainsOverride;



  @JsonKey(
    
    name: r'runnerImage',
    required: false,
    includeIfNull: false,
  )


  final String? runnerImage;



          // minimum: 0
          // maximum: 65536
  @JsonKey(
    
    name: r'memoryMb',
    required: false,
    includeIfNull: false,
  )


  final int? memoryMb;



      /// KEY=value lines given to every run (registry tokens); replaces the stored one, \"\" clears it, absent keeps it
  @JsonKey(
    
    name: r'buildEnv',
    required: false,
    includeIfNull: false,
  )


  final String? buildEnv;





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
      other.branchTemplate == branchTemplate &&
      other.commitTemplate == commitTemplate &&
      other.prTemplate == prTemplate &&
      other.taskPrefix == taskPrefix &&
      other.instructions == instructions &&
      other.jiraProject == jiraProject &&
      other.planeProject == planeProject &&
      other.deployWorkflow == deployWorkflow &&
      other.preview == preview &&
      other.toolchains == toolchains &&
      other.toolchainsOverride == toolchainsOverride &&
      other.runnerImage == runnerImage &&
      other.memoryMb == memoryMb &&
      other.buildEnv == buildEnv;

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
        branchTemplate.hashCode +
        commitTemplate.hashCode +
        prTemplate.hashCode +
        taskPrefix.hashCode +
        instructions.hashCode +
        jiraProject.hashCode +
        planeProject.hashCode +
        deployWorkflow.hashCode +
        preview.hashCode +
        toolchains.hashCode +
        toolchainsOverride.hashCode +
        runnerImage.hashCode +
        memoryMb.hashCode +
        buildEnv.hashCode;

  factory RepositoryInput.fromJson(Map<String, dynamic> json) => _$RepositoryInputFromJson(json);

  Map<String, dynamic> toJson() => _$RepositoryInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// Ignored; derived from jiraProject and planeProject.
enum RepositoryInputKindEnum {
@JsonValue(r'jira')
jira(r'jira'),
@JsonValue(r'plane')
plane(r'plane'),
@JsonValue(r'side')
side(r'side');

const RepositoryInputKindEnum(this.value);

final String value;

@override
String toString() => value;
}



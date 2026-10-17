//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ticket_repo_state.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TicketRepoState {
  /// Returns a new [TicketRepoState] instance.
  TicketRepoState({

    required  this.repoId,

    required  this.repoName,

    required  this.role,

    required  this.folder,

    required  this.branch,

    required  this.headSha,

     this.prNumber,

    required  this.prUrl,

    required  this.ciFixes,

    required  this.state,

     this.mergedAt,

     this.closedAt,

     this.pushError,

     this.canRenameBranch,

    required  this.files,

     this.archived,
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



      /// Its role in the group, as people named it (backend, web)
  @JsonKey(
    
    name: r'role',
    required: true,
    includeIfNull: false,
  )


  final String role;



      /// Its folder in the run, /workspace/<folder>; empty when the ticket has one repository
  @JsonKey(
    
    name: r'folder',
    required: true,
    includeIfNull: false,
  )


  final String folder;



  @JsonKey(
    
    name: r'branch',
    required: true,
    includeIfNull: false,
  )


  final String branch;



  @JsonKey(
    
    name: r'headSha',
    required: true,
    includeIfNull: false,
  )


  final String headSha;



  @JsonKey(
    
    name: r'prNumber',
    required: false,
    includeIfNull: false,
  )


  final int? prNumber;



  @JsonKey(
    
    name: r'prUrl',
    required: true,
    includeIfNull: false,
  )


  final String prUrl;



      /// Rounds a red CI check on its pull request sent the ticket back to coding
  @JsonKey(
    
    name: r'ciFixes',
    required: true,
    includeIfNull: false,
  )


  final int ciFixes;



      /// pending = not pushed yet; unchanged = the work did not change it (no pull request); pushed; merged; dropped = its pull request was closed without a merge
  @JsonKey(
    
    name: r'state',
    required: true,
    includeIfNull: false,
  )


  final TicketRepoStateStateEnum state;



  @JsonKey(
    
    name: r'mergedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? mergedAt;



  @JsonKey(
    
    name: r'closedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? closedAt;



      /// Why its last push failed; a retry pushes it again
  @JsonKey(
    
    name: r'pushError',
    required: false,
    includeIfNull: false,
  )


  final String? pushError;



      /// Its branch was never pushed and can still be renamed (ticket detail only)
  @JsonKey(
    
    name: r'canRenameBranch',
    required: false,
    includeIfNull: false,
  )


  final bool? canRenameBranch;



      /// Files its change touches
  @JsonKey(
    
    name: r'files',
    required: true,
    includeIfNull: false,
  )


  final int files;



      /// The repository is archived
  @JsonKey(
    
    name: r'archived',
    required: false,
    includeIfNull: false,
  )


  final bool? archived;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TicketRepoState &&
      other.repoId == repoId &&
      other.repoName == repoName &&
      other.role == role &&
      other.folder == folder &&
      other.branch == branch &&
      other.headSha == headSha &&
      other.prNumber == prNumber &&
      other.prUrl == prUrl &&
      other.ciFixes == ciFixes &&
      other.state == state &&
      other.mergedAt == mergedAt &&
      other.closedAt == closedAt &&
      other.pushError == pushError &&
      other.canRenameBranch == canRenameBranch &&
      other.files == files &&
      other.archived == archived;

    @override
    int get hashCode =>
        repoId.hashCode +
        repoName.hashCode +
        role.hashCode +
        folder.hashCode +
        branch.hashCode +
        headSha.hashCode +
        prNumber.hashCode +
        prUrl.hashCode +
        ciFixes.hashCode +
        state.hashCode +
        mergedAt.hashCode +
        closedAt.hashCode +
        pushError.hashCode +
        canRenameBranch.hashCode +
        files.hashCode +
        archived.hashCode;

  factory TicketRepoState.fromJson(Map<String, dynamic> json) => _$TicketRepoStateFromJson(json);

  Map<String, dynamic> toJson() => _$TicketRepoStateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// pending = not pushed yet; unchanged = the work did not change it (no pull request); pushed; merged; dropped = its pull request was closed without a merge
enum TicketRepoStateStateEnum {
@JsonValue(r'pending')
pending(r'pending'),
@JsonValue(r'unchanged')
unchanged(r'unchanged'),
@JsonValue(r'pushed')
pushed(r'pushed'),
@JsonValue(r'merged')
merged(r'merged'),
@JsonValue(r'dropped')
dropped(r'dropped');

const TicketRepoStateStateEnum(this.value);

final String value;

@override
String toString() => value;
}



//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/claude_connection_state.dart';
import 'package:agnts_api/src/model/workspace_claude_members_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workspace_claude.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkspaceClaude {
  /// Returns a new [WorkspaceClaude] instance.
  WorkspaceClaude({

    required  this.mode,

    required  this.fallback,

     this.defaultMemberId,

    required  this.connection,

    required  this.members,

    required  this.creditsBalance,

    required  this.subscriptionsAllowed,
  });

  @JsonKey(
    
    name: r'mode',
    required: true,
    includeIfNull: false,
  )


  final WorkspaceClaudeModeEnum mode;



  @JsonKey(
    
    name: r'fallback',
    required: true,
    includeIfNull: false,
  )


  final bool fallback;



  @JsonKey(
    
    name: r'defaultMemberId',
    required: false,
    includeIfNull: false,
  )


  final int? defaultMemberId;



  @JsonKey(
    
    name: r'connection',
    required: true,
    includeIfNull: false,
  )


  final ClaudeConnectionState connection;



      /// Who has a personal connection (per-member mode)
  @JsonKey(
    
    name: r'members',
    required: true,
    includeIfNull: false,
  )


  final List<WorkspaceClaudeMembersInner> members;



  @JsonKey(
    
    name: r'creditsBalance',
    required: true,
    includeIfNull: false,
  )


  final int creditsBalance;



      /// This server accepts Claude subscription tokens (self-hosted); otherwise API keys only
  @JsonKey(
    
    name: r'subscriptionsAllowed',
    required: true,
    includeIfNull: false,
  )


  final bool subscriptionsAllowed;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WorkspaceClaude &&
      other.mode == mode &&
      other.fallback == fallback &&
      other.defaultMemberId == defaultMemberId &&
      other.connection == connection &&
      other.members == members &&
      other.creditsBalance == creditsBalance &&
      other.subscriptionsAllowed == subscriptionsAllowed;

    @override
    int get hashCode =>
        mode.hashCode +
        fallback.hashCode +
        defaultMemberId.hashCode +
        connection.hashCode +
        members.hashCode +
        creditsBalance.hashCode +
        subscriptionsAllowed.hashCode;

  factory WorkspaceClaude.fromJson(Map<String, dynamic> json) => _$WorkspaceClaudeFromJson(json);

  Map<String, dynamic> toJson() => _$WorkspaceClaudeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum WorkspaceClaudeModeEnum {
@JsonValue(r'shared')
shared(r'shared'),
@JsonValue(r'member')
member(r'member');

const WorkspaceClaudeModeEnum(this.value);

final String value;

@override
String toString() => value;
}



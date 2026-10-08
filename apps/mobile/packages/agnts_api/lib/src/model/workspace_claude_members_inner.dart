//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workspace_claude_members_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkspaceClaudeMembersInner {
  /// Returns a new [WorkspaceClaudeMembersInner] instance.
  WorkspaceClaudeMembersInner({

    required  this.userId,

    required  this.username,

    required  this.connected,

     this.pausedUntil,
  });

  @JsonKey(
    
    name: r'userId',
    required: true,
    includeIfNull: false,
  )


  final int userId;



  @JsonKey(
    
    name: r'username',
    required: true,
    includeIfNull: false,
  )


  final String username;



  @JsonKey(
    
    name: r'connected',
    required: true,
    includeIfNull: false,
  )


  final bool connected;



  @JsonKey(
    
    name: r'pausedUntil',
    required: false,
    includeIfNull: false,
  )


  final DateTime? pausedUntil;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WorkspaceClaudeMembersInner &&
      other.userId == userId &&
      other.username == username &&
      other.connected == connected &&
      other.pausedUntil == pausedUntil;

    @override
    int get hashCode =>
        userId.hashCode +
        username.hashCode +
        connected.hashCode +
        pausedUntil.hashCode;

  factory WorkspaceClaudeMembersInner.fromJson(Map<String, dynamic> json) => _$WorkspaceClaudeMembersInnerFromJson(json);

  Map<String, dynamic> toJson() => _$WorkspaceClaudeMembersInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


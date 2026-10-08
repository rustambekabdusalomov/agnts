//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_workspace_claude_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateWorkspaceClaudeRequest {
  /// Returns a new [UpdateWorkspaceClaudeRequest] instance.
  UpdateWorkspaceClaudeRequest({

     this.mode,

     this.fallback,

     this.defaultMemberId,
  });

  @JsonKey(
    
    name: r'mode',
    required: false,
    includeIfNull: false,
  )


  final UpdateWorkspaceClaudeRequestModeEnum? mode;



      /// Continue on workspace credits when the account is at its limit or missing
  @JsonKey(
    
    name: r'fallback',
    required: false,
    includeIfNull: false,
  )


  final bool? fallback;



      /// Whose account tickets without a person use in per-member mode; 0 for the owner
  @JsonKey(
    
    name: r'defaultMemberId',
    required: false,
    includeIfNull: false,
  )


  final int? defaultMemberId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateWorkspaceClaudeRequest &&
      other.mode == mode &&
      other.fallback == fallback &&
      other.defaultMemberId == defaultMemberId;

    @override
    int get hashCode =>
        mode.hashCode +
        fallback.hashCode +
        defaultMemberId.hashCode;

  factory UpdateWorkspaceClaudeRequest.fromJson(Map<String, dynamic> json) => _$UpdateWorkspaceClaudeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateWorkspaceClaudeRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum UpdateWorkspaceClaudeRequestModeEnum {
@JsonValue(r'shared')
shared(r'shared'),
@JsonValue(r'member')
member(r'member');

const UpdateWorkspaceClaudeRequestModeEnum(this.value);

final String value;

@override
String toString() => value;
}



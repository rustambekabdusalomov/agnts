//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'edit_commit_message_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EditCommitMessageRequest {
  /// Returns a new [EditCommitMessageRequest] instance.
  EditCommitMessageRequest({

    required  this.sha,

    required  this.message,

     this.repoId,
  });

      /// The commit, as its commits list it
  @JsonKey(
    
    name: r'sha',
    required: true,
    includeIfNull: false,
  )


  final String sha;



      /// The whole message: the subject line, then a blank line and the body
  @JsonKey(
    
    name: r'message',
    required: true,
    includeIfNull: false,
  )


  final String message;



      /// Which repository of the ticket; absent is the primary
  @JsonKey(
    
    name: r'repoId',
    required: false,
    includeIfNull: false,
  )


  final int? repoId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EditCommitMessageRequest &&
      other.sha == sha &&
      other.message == message &&
      other.repoId == repoId;

    @override
    int get hashCode =>
        sha.hashCode +
        message.hashCode +
        repoId.hashCode;

  factory EditCommitMessageRequest.fromJson(Map<String, dynamic> json) => _$EditCommitMessageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EditCommitMessageRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


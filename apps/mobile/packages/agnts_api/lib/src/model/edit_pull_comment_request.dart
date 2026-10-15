//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'edit_pull_comment_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EditPullCommentRequest {
  /// Returns a new [EditPullCommentRequest] instance.
  EditPullCommentRequest({

    required  this.commentId,

    required  this.body,
  });

  @JsonKey(
    
    name: r'commentId',
    required: true,
    includeIfNull: false,
  )


  final String commentId;



  @JsonKey(
    
    name: r'body',
    required: true,
    includeIfNull: false,
  )


  final String body;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EditPullCommentRequest &&
      other.commentId == commentId &&
      other.body == body;

    @override
    int get hashCode =>
        commentId.hashCode +
        body.hashCode;

  factory EditPullCommentRequest.fromJson(Map<String, dynamic> json) => _$EditPullCommentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EditPullCommentRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


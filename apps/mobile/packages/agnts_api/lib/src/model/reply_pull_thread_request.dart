//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reply_pull_thread_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReplyPullThreadRequest {
  /// Returns a new [ReplyPullThreadRequest] instance.
  ReplyPullThreadRequest({

    required  this.threadId,

    required  this.body,
  });

  @JsonKey(
    
    name: r'threadId',
    required: true,
    includeIfNull: false,
  )


  final String threadId;



  @JsonKey(
    
    name: r'body',
    required: true,
    includeIfNull: false,
  )


  final String body;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReplyPullThreadRequest &&
      other.threadId == threadId &&
      other.body == body;

    @override
    int get hashCode =>
        threadId.hashCode +
        body.hashCode;

  factory ReplyPullThreadRequest.fromJson(Map<String, dynamic> json) => _$ReplyPullThreadRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ReplyPullThreadRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


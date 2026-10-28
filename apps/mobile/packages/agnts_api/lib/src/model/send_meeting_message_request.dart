//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'send_meeting_message_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SendMeetingMessageRequest {
  /// Returns a new [SendMeetingMessageRequest] instance.
  SendMeetingMessageRequest({

    required  this.body,
  });

  @JsonKey(
    
    name: r'body',
    required: true,
    includeIfNull: false,
  )


  final String body;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SendMeetingMessageRequest &&
      other.body == body;

    @override
    int get hashCode =>
        body.hashCode;

  factory SendMeetingMessageRequest.fromJson(Map<String, dynamic> json) => _$SendMeetingMessageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SendMeetingMessageRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


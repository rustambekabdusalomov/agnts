//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_send_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChatSendRequest {
  /// Returns a new [ChatSendRequest] instance.
  ChatSendRequest({

    required  this.clientMsgId,

    required  this.body,

     this.replyTo,
  });

      /// Made on the device; a resend with the same id returns the stored message
  @JsonKey(
    
    name: r'clientMsgId',
    required: true,
    includeIfNull: false,
  )


  final String clientMsgId;



  @JsonKey(
    
    name: r'body',
    required: true,
    includeIfNull: false,
  )


  final String body;



  @JsonKey(
    
    name: r'replyTo',
    required: false,
    includeIfNull: false,
  )


  final int? replyTo;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ChatSendRequest &&
      other.clientMsgId == clientMsgId &&
      other.body == body &&
      other.replyTo == replyTo;

    @override
    int get hashCode =>
        clientMsgId.hashCode +
        body.hashCode +
        replyTo.hashCode;

  factory ChatSendRequest.fromJson(Map<String, dynamic> json) => _$ChatSendRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChatSendRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/chat_ref.dart';
import 'package:agnts_api/src/model/chat_audio.dart';
import 'package:agnts_api/src/model/chat_card.dart';
import 'package:agnts_api/src/model/chat_ai.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_message.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChatMessage {
  /// Returns a new [ChatMessage] instance.
  ChatMessage({

    required  this.id,

    required  this.channelId,

     this.replyTo,

     this.authorId,

    required  this.author,

    required  this.kind,

    required  this.body,

     this.card,

     this.ai,

     this.ticketKey,

     this.audio,

     this.clientMsgId,

    required  this.refs,

    required  this.createdAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'channelId',
    required: true,
    includeIfNull: false,
  )


  final int channelId;



  @JsonKey(
    
    name: r'replyTo',
    required: false,
    includeIfNull: false,
  )


  final int? replyTo;



  @JsonKey(
    
    name: r'authorId',
    required: false,
    includeIfNull: false,
  )


  final int? authorId;



      /// The person's username
  @JsonKey(
    
    name: r'author',
    required: true,
    includeIfNull: false,
  )


  final String author;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final ChatMessageKindEnum kind;



  @JsonKey(
    
    name: r'body',
    required: true,
    includeIfNull: false,
  )


  final String body;



  @JsonKey(
    
    name: r'card',
    required: false,
    includeIfNull: false,
  )


  final ChatCard? card;



  @JsonKey(
    
    name: r'ai',
    required: false,
    includeIfNull: false,
  )


  final ChatAI? ai;



  @JsonKey(
    
    name: r'ticketKey',
    required: false,
    includeIfNull: false,
  )


  final String? ticketKey;



  @JsonKey(
    
    name: r'audio',
    required: false,
    includeIfNull: false,
  )


  final ChatAudio? audio;



  @JsonKey(
    
    name: r'clientMsgId',
    required: false,
    includeIfNull: false,
  )


  final String? clientMsgId;



  @JsonKey(
    
    name: r'refs',
    required: true,
    includeIfNull: false,
  )


  final List<ChatRef> refs;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ChatMessage &&
      other.id == id &&
      other.channelId == channelId &&
      other.replyTo == replyTo &&
      other.authorId == authorId &&
      other.author == author &&
      other.kind == kind &&
      other.body == body &&
      other.card == card &&
      other.ai == ai &&
      other.ticketKey == ticketKey &&
      other.audio == audio &&
      other.clientMsgId == clientMsgId &&
      other.refs == refs &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        channelId.hashCode +
        replyTo.hashCode +
        authorId.hashCode +
        author.hashCode +
        kind.hashCode +
        body.hashCode +
        card.hashCode +
        ai.hashCode +
        ticketKey.hashCode +
        audio.hashCode +
        clientMsgId.hashCode +
        refs.hashCode +
        createdAt.hashCode;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum ChatMessageKindEnum {
@JsonValue(r'text')
text(r'text'),
@JsonValue(r'agent_card')
agentCard(r'agent_card'),
@JsonValue(r'agent_text')
agentText(r'agent_text'),
@JsonValue(r'system')
system(r'system');

const ChatMessageKindEnum(this.value);

final String value;

@override
String toString() => value;
}



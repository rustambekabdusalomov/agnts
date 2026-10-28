//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/code_ticket.dart';
import 'package:agnts_api/src/model/ticket_kind_choice.dart';
import 'package:agnts_api/src/model/assistant_message.dart';
import 'package:agnts_api/src/model/repo_choice.dart';
import 'package:agnts_api/src/model/chat_mode.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_conversation.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantConversation {
  /// Returns a new [AssistantConversation] instance.
  AssistantConversation({

    required  this.id,

    required  this.title,

    required  this.mode,

    required  this.createdAt,

    required  this.updatedAt,

    required  this.messages,

     this.repos,

     this.kind,

     this.quick,

     this.tickets,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



      /// The first question, cut
  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'mode',
    required: true,
    includeIfNull: false,
  )


  final ChatMode mode;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;



  @JsonKey(
    
    name: r'updatedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime updatedAt;



      /// Oldest first; in lists, only the last message
  @JsonKey(
    
    name: r'messages',
    required: true,
    includeIfNull: false,
  )


  final List<AssistantMessage> messages;



  @JsonKey(
    
    name: r'repos',
    required: false,
    includeIfNull: false,
  )


  final RepoChoice? repos;



  @JsonKey(
    
    name: r'kind',
    required: false,
    includeIfNull: false,
  )


  final TicketKindChoice? kind;



      /// Code mode: its tickets skip their checks
  @JsonKey(
    
    name: r'quick',
    required: false,
    includeIfNull: false,
  )


  final bool? quick;



      /// Code mode: its tickets, oldest first; in lists, only the current one
  @JsonKey(
    
    name: r'tickets',
    required: false,
    includeIfNull: false,
  )


  final List<CodeTicket>? tickets;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantConversation &&
      other.id == id &&
      other.title == title &&
      other.mode == mode &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.messages == messages &&
      other.repos == repos &&
      other.kind == kind &&
      other.quick == quick &&
      other.tickets == tickets;

    @override
    int get hashCode =>
        id.hashCode +
        title.hashCode +
        mode.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode +
        messages.hashCode +
        repos.hashCode +
        kind.hashCode +
        quick.hashCode +
        tickets.hashCode;

  factory AssistantConversation.fromJson(Map<String, dynamic> json) => _$AssistantConversationFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantConversationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


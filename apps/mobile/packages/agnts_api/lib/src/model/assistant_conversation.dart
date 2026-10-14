//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/assistant_message.dart';
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

    required  this.createdAt,

    required  this.updatedAt,

    required  this.messages,
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





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantConversation &&
      other.id == id &&
      other.title == title &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.messages == messages;

    @override
    int get hashCode =>
        id.hashCode +
        title.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode +
        messages.hashCode;

  factory AssistantConversation.fromJson(Map<String, dynamic> json) => _$AssistantConversationFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantConversationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_channel.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChatChannel {
  /// Returns a new [ChatChannel] instance.
  ChatChannel({

    required  this.id,

    required  this.name,

    required  this.topic,

    required  this.agents,

    required  this.createdAt,

     this.archivedAt,

    required  this.lastId,

    required  this.unread,

    required  this.lastReadId,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'topic',
    required: true,
    includeIfNull: false,
  )


  final String topic;



      /// agnts posts its cards here
  @JsonKey(
    
    name: r'agents',
    required: true,
    includeIfNull: false,
  )


  final bool agents;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;



  @JsonKey(
    
    name: r'archivedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? archivedAt;



      /// The newest message's id
  @JsonKey(
    
    name: r'lastId',
    required: true,
    includeIfNull: false,
  )


  final int lastId;



  @JsonKey(
    
    name: r'unread',
    required: true,
    includeIfNull: false,
  )


  final int unread;



  @JsonKey(
    
    name: r'lastReadId',
    required: true,
    includeIfNull: false,
  )


  final int lastReadId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ChatChannel &&
      other.id == id &&
      other.name == name &&
      other.topic == topic &&
      other.agents == agents &&
      other.createdAt == createdAt &&
      other.archivedAt == archivedAt &&
      other.lastId == lastId &&
      other.unread == unread &&
      other.lastReadId == lastReadId;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        topic.hashCode +
        agents.hashCode +
        createdAt.hashCode +
        archivedAt.hashCode +
        lastId.hashCode +
        unread.hashCode +
        lastReadId.hashCode;

  factory ChatChannel.fromJson(Map<String, dynamic> json) => _$ChatChannelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatChannelToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


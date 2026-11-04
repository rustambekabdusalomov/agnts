//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_channel_update.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChatChannelUpdate {
  /// Returns a new [ChatChannelUpdate] instance.
  ChatChannelUpdate({

     this.topic,

     this.agents,

     this.archive,
  });

  @JsonKey(
    
    name: r'topic',
    required: false,
    includeIfNull: false,
  )


  final String? topic;



  @JsonKey(
    
    name: r'agents',
    required: false,
    includeIfNull: false,
  )


  final bool? agents;



  @JsonKey(
    
    name: r'archive',
    required: false,
    includeIfNull: false,
  )


  final bool? archive;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ChatChannelUpdate &&
      other.topic == topic &&
      other.agents == agents &&
      other.archive == archive;

    @override
    int get hashCode =>
        topic.hashCode +
        agents.hashCode +
        archive.hashCode;

  factory ChatChannelUpdate.fromJson(Map<String, dynamic> json) => _$ChatChannelUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$ChatChannelUpdateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


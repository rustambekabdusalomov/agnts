//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_channel_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChatChannelInput {
  /// Returns a new [ChatChannelInput] instance.
  ChatChannelInput({

    required  this.name,

     this.topic,

     this.agents,
  });

      /// Lower case letters, digits, - and _ (spaces become -)
  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is ChatChannelInput &&
      other.name == name &&
      other.topic == topic &&
      other.agents == agents;

    @override
    int get hashCode =>
        name.hashCode +
        topic.hashCode +
        agents.hashCode;

  factory ChatChannelInput.fromJson(Map<String, dynamic> json) => _$ChatChannelInputFromJson(json);

  Map<String, dynamic> toJson() => _$ChatChannelInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


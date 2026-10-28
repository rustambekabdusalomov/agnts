//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_message.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingMessage {
  /// Returns a new [MeetingMessage] instance.
  MeetingMessage({

    required  this.id,

    required  this.person,

    required  this.name,

    required  this.body,

    required  this.at,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



      /// u<id> or g<id>
  @JsonKey(
    
    name: r'person',
    required: true,
    includeIfNull: false,
  )


  final String person;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'body',
    required: true,
    includeIfNull: false,
  )


  final String body;



  @JsonKey(
    
    name: r'at',
    required: true,
    includeIfNull: false,
  )


  final DateTime at;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingMessage &&
      other.id == id &&
      other.person == person &&
      other.name == name &&
      other.body == body &&
      other.at == at;

    @override
    int get hashCode =>
        id.hashCode +
        person.hashCode +
        name.hashCode +
        body.hashCode +
        at.hashCode;

  factory MeetingMessage.fromJson(Map<String, dynamic> json) => _$MeetingMessageFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingMessageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


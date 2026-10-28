//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_action_item.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingActionItem {
  /// Returns a new [MeetingActionItem] instance.
  MeetingActionItem({

    required  this.id,

    required  this.position,

    required  this.text,

    required  this.who,

    required  this.due,

     this.atMs,

    required  this.quote,

     this.ticketKey,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'position',
    required: true,
    includeIfNull: false,
  )


  final int position;



  @JsonKey(
    
    name: r'text',
    required: true,
    includeIfNull: false,
  )


  final String text;



      /// As named in the meeting
  @JsonKey(
    
    name: r'who',
    required: true,
    includeIfNull: false,
  )


  final String who;



      /// As said
  @JsonKey(
    
    name: r'due',
    required: true,
    includeIfNull: false,
  )


  final String due;



      /// When it was said, from the start of the call
  @JsonKey(
    
    name: r'atMs',
    required: false,
    includeIfNull: false,
  )


  final int? atMs;



  @JsonKey(
    
    name: r'quote',
    required: true,
    includeIfNull: false,
  )


  final String quote;



      /// The ticket made from it
  @JsonKey(
    
    name: r'ticketKey',
    required: false,
    includeIfNull: false,
  )


  final String? ticketKey;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingActionItem &&
      other.id == id &&
      other.position == position &&
      other.text == text &&
      other.who == who &&
      other.due == due &&
      other.atMs == atMs &&
      other.quote == quote &&
      other.ticketKey == ticketKey;

    @override
    int get hashCode =>
        id.hashCode +
        position.hashCode +
        text.hashCode +
        who.hashCode +
        due.hashCode +
        atMs.hashCode +
        quote.hashCode +
        ticketKey.hashCode;

  factory MeetingActionItem.fromJson(Map<String, dynamic> json) => _$MeetingActionItemFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingActionItemToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


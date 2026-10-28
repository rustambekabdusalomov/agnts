//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/event.dart';
import 'package:agnts_api/src/model/assistant_message.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'timeline_item.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TimelineItem {
  /// Returns a new [TimelineItem] instance.
  TimelineItem({

    required  this.at,

     this.message,

     this.event,
  });

  @JsonKey(
    
    name: r'at',
    required: true,
    includeIfNull: false,
  )


  final DateTime at;



  @JsonKey(
    
    name: r'message',
    required: false,
    includeIfNull: false,
  )


  final AssistantMessage? message;



  @JsonKey(
    
    name: r'event',
    required: false,
    includeIfNull: false,
  )


  final Event? event;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TimelineItem &&
      other.at == at &&
      other.message == message &&
      other.event == event;

    @override
    int get hashCode =>
        at.hashCode +
        message.hashCode +
        event.hashCode;

  factory TimelineItem.fromJson(Map<String, dynamic> json) => _$TimelineItemFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineItemToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


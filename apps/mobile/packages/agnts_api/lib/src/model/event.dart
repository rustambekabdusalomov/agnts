//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Event {
  /// Returns a new [Event] instance.
  Event({

    required  this.id,

    required  this.ticketKey,

     this.runId,

    required  this.step,

    required  this.type,

    required  this.level,

    required  this.origin,

    required  this.message,

    required  this.data,

     this.durationMs,

     this.user,

    required  this.createdAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'ticketKey',
    required: true,
    includeIfNull: false,
  )


  final String ticketKey;



  @JsonKey(
    
    name: r'runId',
    required: false,
    includeIfNull: false,
  )


  final int? runId;



  @JsonKey(
    
    name: r'step',
    required: true,
    includeIfNull: false,
  )


  final String step;



  @JsonKey(
    
    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final String type;



  @JsonKey(
    
    name: r'level',
    required: true,
    includeIfNull: false,
  )


  final EventLevelEnum level;



  @JsonKey(
    
    name: r'origin',
    required: true,
    includeIfNull: false,
  )


  final EventOriginEnum origin;



  @JsonKey(
    
    name: r'message',
    required: true,
    includeIfNull: false,
  )


  final String message;



  @JsonKey(
    
    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final Map<String, Object> data;



  @JsonKey(
    
    name: r'durationMs',
    required: false,
    includeIfNull: false,
  )


  final int? durationMs;



      /// The person behind the event; absent for agnts
  @JsonKey(
    
    name: r'user',
    required: false,
    includeIfNull: false,
  )


  final String? user;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Event &&
      other.id == id &&
      other.ticketKey == ticketKey &&
      other.runId == runId &&
      other.step == step &&
      other.type == type &&
      other.level == level &&
      other.origin == origin &&
      other.message == message &&
      other.data == data &&
      other.durationMs == durationMs &&
      other.user == user &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        ticketKey.hashCode +
        runId.hashCode +
        step.hashCode +
        type.hashCode +
        level.hashCode +
        origin.hashCode +
        message.hashCode +
        data.hashCode +
        durationMs.hashCode +
        user.hashCode +
        createdAt.hashCode;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum EventLevelEnum {
@JsonValue(r'debug')
debug(r'debug'),
@JsonValue(r'info')
info(r'info'),
@JsonValue(r'warn')
warn(r'warn'),
@JsonValue(r'error')
error(r'error');

const EventLevelEnum(this.value);

final String value;

@override
String toString() => value;
}


enum EventOriginEnum {
@JsonValue(r'system')
system(r'system'),
@JsonValue(r'web')
web(r'web'),
@JsonValue(r'mobile')
mobile(r'mobile'),
@JsonValue(r'mcp')
mcp(r'mcp'),
@JsonValue(r'telegram')
telegram(r'telegram'),
@JsonValue(r'webhook')
webhook(r'webhook'),
@JsonValue(r'assistant')
assistant(r'assistant'),
@JsonValue(r'chat')
chat(r'chat');

const EventOriginEnum(this.value);

final String value;

@override
String toString() => value;
}



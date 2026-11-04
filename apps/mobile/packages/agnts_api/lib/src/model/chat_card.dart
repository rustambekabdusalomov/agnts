//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_card.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChatCard {
  /// Returns a new [ChatCard] instance.
  ChatCard({

    required  this.type,

    required  this.state,

    required  this.title,

     this.summary,

    required  this.actions,

     this.data,

     this.by,

     this.done,

     this.result,

     this.at,
  });

  @JsonKey(
    
    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final ChatCardTypeEnum type;



  @JsonKey(
    
    name: r'state',
    required: true,
    includeIfNull: false,
  )


  final ChatCardStateEnum state;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'summary',
    required: false,
    includeIfNull: false,
  )


  final String? summary;



  @JsonKey(
    
    name: r'actions',
    required: true,
    includeIfNull: false,
  )


  final List<ChatCardActionsEnum> actions;



  @JsonKey(
    
    name: r'data',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? data;



  @JsonKey(
    
    name: r'by',
    required: false,
    includeIfNull: false,
  )


  final String? by;



  @JsonKey(
    
    name: r'done',
    required: false,
    includeIfNull: false,
  )


  final String? done;



  @JsonKey(
    
    name: r'result',
    required: false,
    includeIfNull: false,
  )


  final String? result;



  @JsonKey(
    
    name: r'at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? at;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ChatCard &&
      other.type == type &&
      other.state == state &&
      other.title == title &&
      other.summary == summary &&
      other.actions == actions &&
      other.data == data &&
      other.by == by &&
      other.done == done &&
      other.result == result &&
      other.at == at;

    @override
    int get hashCode =>
        type.hashCode +
        state.hashCode +
        title.hashCode +
        summary.hashCode +
        actions.hashCode +
        data.hashCode +
        by.hashCode +
        done.hashCode +
        result.hashCode +
        at.hashCode;

  factory ChatCard.fromJson(Map<String, dynamic> json) => _$ChatCardFromJson(json);

  Map<String, dynamic> toJson() => _$ChatCardToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum ChatCardTypeEnum {
@JsonValue(r'log_finding')
logFinding(r'log_finding'),
@JsonValue(r'review_ready')
reviewReady(r'review_ready'),
@JsonValue(r'pr_opened')
prOpened(r'pr_opened'),
@JsonValue(r'ticket_draft')
ticketDraft(r'ticket_draft');

const ChatCardTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


enum ChatCardStateEnum {
@JsonValue(r'open')
open(r'open'),
@JsonValue(r'done')
done(r'done'),
@JsonValue(r'failed')
failed(r'failed'),
@JsonValue(r'expired')
expired(r'expired');

const ChatCardStateEnum(this.value);

final String value;

@override
String toString() => value;
}


enum ChatCardActionsEnum {
@JsonValue(r'fix')
fix(r'fix'),
@JsonValue(r'mute')
mute(r'mute'),
@JsonValue(r'approve')
approve(r'approve'),
@JsonValue(r'request_changes')
requestChanges(r'request_changes'),
@JsonValue(r'merge')
merge(r'merge'),
@JsonValue(r'create')
create(r'create'),
@JsonValue(r'create_assign')
createAssign(r'create_assign');

const ChatCardActionsEnum(this.value);

final String value;

@override
String toString() => value;
}



//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_action.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantAction {
  /// Returns a new [AssistantAction] instance.
  AssistantAction({

    required  this.id,

    required  this.messageId,

    required  this.conversationId,

    required  this.tool,

     this.ticketKey,

    required  this.summary,

    required  this.destructive,

    required  this.status,

     this.result,

    required  this.expiresAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'messageId',
    required: true,
    includeIfNull: false,
  )


  final int messageId;



  @JsonKey(
    
    name: r'conversationId',
    required: true,
    includeIfNull: false,
  )


  final int conversationId;



  @JsonKey(
    
    name: r'tool',
    required: true,
    includeIfNull: false,
  )


  final AssistantActionToolEnum tool;



      /// The ticket it acts on, or the one it created
  @JsonKey(
    
    name: r'ticketKey',
    required: false,
    includeIfNull: false,
  )


  final String? ticketKey;



  @JsonKey(
    
    name: r'summary',
    required: true,
    includeIfNull: false,
  )


  final String summary;



      /// It cannot be taken back (approve, reject): ask once more before confirming
  @JsonKey(
    
    name: r'destructive',
    required: true,
    includeIfNull: false,
  )


  final bool destructive;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final AssistantActionStatusEnum status;



      /// What happened (done), or why not (failed)
  @JsonKey(
    
    name: r'result',
    required: false,
    includeIfNull: false,
  )


  final String? result;



  @JsonKey(
    
    name: r'expiresAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime expiresAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantAction &&
      other.id == id &&
      other.messageId == messageId &&
      other.conversationId == conversationId &&
      other.tool == tool &&
      other.ticketKey == ticketKey &&
      other.summary == summary &&
      other.destructive == destructive &&
      other.status == status &&
      other.result == result &&
      other.expiresAt == expiresAt;

    @override
    int get hashCode =>
        id.hashCode +
        messageId.hashCode +
        conversationId.hashCode +
        tool.hashCode +
        ticketKey.hashCode +
        summary.hashCode +
        destructive.hashCode +
        status.hashCode +
        result.hashCode +
        expiresAt.hashCode;

  factory AssistantAction.fromJson(Map<String, dynamic> json) => _$AssistantActionFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantActionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum AssistantActionToolEnum {
@JsonValue(r'answer_questions')
answerQuestions(r'answer_questions'),
@JsonValue(r'start_run')
startRun(r'start_run'),
@JsonValue(r'request_changes')
requestChanges(r'request_changes'),
@JsonValue(r'retry_run')
retryRun(r'retry_run'),
@JsonValue(r'create_task')
createTask(r'create_task'),
@JsonValue(r'implement_ticket')
implementTicket(r'implement_ticket'),
@JsonValue(r'accept_follow_ups')
acceptFollowUps(r'accept_follow_ups'),
@JsonValue(r'dismiss_follow_up')
dismissFollowUp(r'dismiss_follow_up'),
@JsonValue(r'set_ticket_kind')
setTicketKind(r'set_ticket_kind'),
@JsonValue(r'approve_ticket')
approveTicket(r'approve_ticket'),
@JsonValue(r'reject_ticket')
rejectTicket(r'reject_ticket');

const AssistantActionToolEnum(this.value);

final String value;

@override
String toString() => value;
}


enum AssistantActionStatusEnum {
@JsonValue(r'proposed')
proposed(r'proposed'),
@JsonValue(r'running')
running(r'running'),
@JsonValue(r'done')
done(r'done'),
@JsonValue(r'failed')
failed(r'failed'),
@JsonValue(r'cancelled')
cancelled(r'cancelled'),
@JsonValue(r'expired')
expired(r'expired');

const AssistantActionStatusEnum(this.value);

final String value;

@override
String toString() => value;
}



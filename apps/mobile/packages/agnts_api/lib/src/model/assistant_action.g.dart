// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_action.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantActionCWProxy {
  AssistantAction id(String id);

  AssistantAction messageId(int messageId);

  AssistantAction conversationId(int conversationId);

  AssistantAction tool(AssistantActionToolEnum tool);

  AssistantAction ticketKey(String? ticketKey);

  AssistantAction summary(String summary);

  AssistantAction destructive(bool destructive);

  AssistantAction status(AssistantActionStatusEnum status);

  AssistantAction result(String? result);

  AssistantAction expiresAt(DateTime expiresAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantAction(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantAction(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantAction call({
    String id,
    int messageId,
    int conversationId,
    AssistantActionToolEnum tool,
    String? ticketKey,
    String summary,
    bool destructive,
    AssistantActionStatusEnum status,
    String? result,
    DateTime expiresAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantAction.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantAction.copyWith.fieldName(...)`
class _$AssistantActionCWProxyImpl implements _$AssistantActionCWProxy {
  const _$AssistantActionCWProxyImpl(this._value);

  final AssistantAction _value;

  @override
  AssistantAction id(String id) => this(id: id);

  @override
  AssistantAction messageId(int messageId) => this(messageId: messageId);

  @override
  AssistantAction conversationId(int conversationId) =>
      this(conversationId: conversationId);

  @override
  AssistantAction tool(AssistantActionToolEnum tool) => this(tool: tool);

  @override
  AssistantAction ticketKey(String? ticketKey) => this(ticketKey: ticketKey);

  @override
  AssistantAction summary(String summary) => this(summary: summary);

  @override
  AssistantAction destructive(bool destructive) =>
      this(destructive: destructive);

  @override
  AssistantAction status(AssistantActionStatusEnum status) =>
      this(status: status);

  @override
  AssistantAction result(String? result) => this(result: result);

  @override
  AssistantAction expiresAt(DateTime expiresAt) => this(expiresAt: expiresAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantAction(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantAction(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantAction call({
    Object? id = const $CopyWithPlaceholder(),
    Object? messageId = const $CopyWithPlaceholder(),
    Object? conversationId = const $CopyWithPlaceholder(),
    Object? tool = const $CopyWithPlaceholder(),
    Object? ticketKey = const $CopyWithPlaceholder(),
    Object? summary = const $CopyWithPlaceholder(),
    Object? destructive = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? result = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
  }) {
    return AssistantAction(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      messageId: messageId == const $CopyWithPlaceholder()
          ? _value.messageId
          // ignore: cast_nullable_to_non_nullable
          : messageId as int,
      conversationId: conversationId == const $CopyWithPlaceholder()
          ? _value.conversationId
          // ignore: cast_nullable_to_non_nullable
          : conversationId as int,
      tool: tool == const $CopyWithPlaceholder()
          ? _value.tool
          // ignore: cast_nullable_to_non_nullable
          : tool as AssistantActionToolEnum,
      ticketKey: ticketKey == const $CopyWithPlaceholder()
          ? _value.ticketKey
          // ignore: cast_nullable_to_non_nullable
          : ticketKey as String?,
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as String,
      destructive: destructive == const $CopyWithPlaceholder()
          ? _value.destructive
          // ignore: cast_nullable_to_non_nullable
          : destructive as bool,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as AssistantActionStatusEnum,
      result: result == const $CopyWithPlaceholder()
          ? _value.result
          // ignore: cast_nullable_to_non_nullable
          : result as String?,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime,
    );
  }
}

extension $AssistantActionCopyWith on AssistantAction {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantAction.copyWith(...)` or like so:`instanceOfAssistantAction.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantActionCWProxy get copyWith => _$AssistantActionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantAction _$AssistantActionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AssistantAction', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'messageId',
          'conversationId',
          'tool',
          'summary',
          'destructive',
          'status',
          'expiresAt',
        ],
      );
      final val = AssistantAction(
        id: $checkedConvert('id', (v) => v as String),
        messageId: $checkedConvert('messageId', (v) => (v as num).toInt()),
        conversationId: $checkedConvert(
          'conversationId',
          (v) => (v as num).toInt(),
        ),
        tool: $checkedConvert(
          'tool',
          (v) => $enumDecode(_$AssistantActionToolEnumEnumMap, v),
        ),
        ticketKey: $checkedConvert('ticketKey', (v) => v as String?),
        summary: $checkedConvert('summary', (v) => v as String),
        destructive: $checkedConvert('destructive', (v) => v as bool),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$AssistantActionStatusEnumEnumMap, v),
        ),
        result: $checkedConvert('result', (v) => v as String?),
        expiresAt: $checkedConvert(
          'expiresAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AssistantActionToJson(AssistantAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'messageId': instance.messageId,
      'conversationId': instance.conversationId,
      'tool': _$AssistantActionToolEnumEnumMap[instance.tool]!,
      'ticketKey': ?instance.ticketKey,
      'summary': instance.summary,
      'destructive': instance.destructive,
      'status': _$AssistantActionStatusEnumEnumMap[instance.status]!,
      'result': ?instance.result,
      'expiresAt': instance.expiresAt.toIso8601String(),
    };

const _$AssistantActionToolEnumEnumMap = {
  AssistantActionToolEnum.answerQuestions: 'answer_questions',
  AssistantActionToolEnum.startRun: 'start_run',
  AssistantActionToolEnum.requestChanges: 'request_changes',
  AssistantActionToolEnum.retryRun: 'retry_run',
  AssistantActionToolEnum.createTask: 'create_task',
  AssistantActionToolEnum.implementTicket: 'implement_ticket',
  AssistantActionToolEnum.acceptFollowUps: 'accept_follow_ups',
  AssistantActionToolEnum.dismissFollowUp: 'dismiss_follow_up',
  AssistantActionToolEnum.setTicketKind: 'set_ticket_kind',
  AssistantActionToolEnum.approveTicket: 'approve_ticket',
  AssistantActionToolEnum.rejectTicket: 'reject_ticket',
};

const _$AssistantActionStatusEnumEnumMap = {
  AssistantActionStatusEnum.proposed: 'proposed',
  AssistantActionStatusEnum.running: 'running',
  AssistantActionStatusEnum.done: 'done',
  AssistantActionStatusEnum.failed: 'failed',
  AssistantActionStatusEnum.cancelled: 'cancelled',
  AssistantActionStatusEnum.expired: 'expired',
};

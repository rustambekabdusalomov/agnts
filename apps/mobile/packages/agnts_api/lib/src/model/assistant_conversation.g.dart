// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_conversation.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantConversationCWProxy {
  AssistantConversation id(int id);

  AssistantConversation title(String title);

  AssistantConversation mode(ChatMode mode);

  AssistantConversation createdAt(DateTime createdAt);

  AssistantConversation updatedAt(DateTime updatedAt);

  AssistantConversation messages(List<AssistantMessage> messages);

  AssistantConversation repos(RepoChoice? repos);

  AssistantConversation kind(TicketKindChoice? kind);

  AssistantConversation quick(bool? quick);

  AssistantConversation tickets(List<CodeTicket>? tickets);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantConversation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantConversation(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantConversation call({
    int id,
    String title,
    ChatMode mode,
    DateTime createdAt,
    DateTime updatedAt,
    List<AssistantMessage> messages,
    RepoChoice? repos,
    TicketKindChoice? kind,
    bool? quick,
    List<CodeTicket>? tickets,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantConversation.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantConversation.copyWith.fieldName(...)`
class _$AssistantConversationCWProxyImpl
    implements _$AssistantConversationCWProxy {
  const _$AssistantConversationCWProxyImpl(this._value);

  final AssistantConversation _value;

  @override
  AssistantConversation id(int id) => this(id: id);

  @override
  AssistantConversation title(String title) => this(title: title);

  @override
  AssistantConversation mode(ChatMode mode) => this(mode: mode);

  @override
  AssistantConversation createdAt(DateTime createdAt) =>
      this(createdAt: createdAt);

  @override
  AssistantConversation updatedAt(DateTime updatedAt) =>
      this(updatedAt: updatedAt);

  @override
  AssistantConversation messages(List<AssistantMessage> messages) =>
      this(messages: messages);

  @override
  AssistantConversation repos(RepoChoice? repos) => this(repos: repos);

  @override
  AssistantConversation kind(TicketKindChoice? kind) => this(kind: kind);

  @override
  AssistantConversation quick(bool? quick) => this(quick: quick);

  @override
  AssistantConversation tickets(List<CodeTicket>? tickets) =>
      this(tickets: tickets);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantConversation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantConversation(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantConversation call({
    Object? id = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? mode = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? messages = const $CopyWithPlaceholder(),
    Object? repos = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? quick = const $CopyWithPlaceholder(),
    Object? tickets = const $CopyWithPlaceholder(),
  }) {
    return AssistantConversation(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      mode: mode == const $CopyWithPlaceholder()
          ? _value.mode
          // ignore: cast_nullable_to_non_nullable
          : mode as ChatMode,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
      messages: messages == const $CopyWithPlaceholder()
          ? _value.messages
          // ignore: cast_nullable_to_non_nullable
          : messages as List<AssistantMessage>,
      repos: repos == const $CopyWithPlaceholder()
          ? _value.repos
          // ignore: cast_nullable_to_non_nullable
          : repos as RepoChoice?,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as TicketKindChoice?,
      quick: quick == const $CopyWithPlaceholder()
          ? _value.quick
          // ignore: cast_nullable_to_non_nullable
          : quick as bool?,
      tickets: tickets == const $CopyWithPlaceholder()
          ? _value.tickets
          // ignore: cast_nullable_to_non_nullable
          : tickets as List<CodeTicket>?,
    );
  }
}

extension $AssistantConversationCopyWith on AssistantConversation {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantConversation.copyWith(...)` or like so:`instanceOfAssistantConversation.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantConversationCWProxy get copyWith =>
      _$AssistantConversationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantConversation _$AssistantConversationFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssistantConversation', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'title',
      'mode',
      'createdAt',
      'updatedAt',
      'messages',
    ],
  );
  final val = AssistantConversation(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    title: $checkedConvert('title', (v) => v as String),
    mode: $checkedConvert('mode', (v) => $enumDecode(_$ChatModeEnumMap, v)),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
    messages: $checkedConvert(
      'messages',
      (v) => (v as List<dynamic>)
          .map((e) => AssistantMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    repos: $checkedConvert(
      'repos',
      (v) => v == null ? null : RepoChoice.fromJson(v as Map<String, dynamic>),
    ),
    kind: $checkedConvert(
      'kind',
      (v) => $enumDecodeNullable(_$TicketKindChoiceEnumMap, v),
    ),
    quick: $checkedConvert('quick', (v) => v as bool?),
    tickets: $checkedConvert(
      'tickets',
      (v) => (v as List<dynamic>?)
          ?.map((e) => CodeTicket.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$AssistantConversationToJson(
  AssistantConversation instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'mode': _$ChatModeEnumMap[instance.mode]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'messages': instance.messages.map((e) => e.toJson()).toList(),
  'repos': ?instance.repos?.toJson(),
  'kind': ?_$TicketKindChoiceEnumMap[instance.kind],
  'quick': ?instance.quick,
  'tickets': ?instance.tickets?.map((e) => e.toJson()).toList(),
};

const _$ChatModeEnumMap = {ChatMode.chat: 'chat', ChatMode.code: 'code'};

const _$TicketKindChoiceEnumMap = {
  TicketKindChoice.auto: 'auto',
  TicketKindChoice.code: 'code',
  TicketKindChoice.test: 'test',
  TicketKindChoice.plan: 'plan',
  TicketKindChoice.analysis: 'analysis',
  TicketKindChoice.bug: 'bug',
};

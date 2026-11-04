// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChatMessageCWProxy {
  ChatMessage id(int id);

  ChatMessage channelId(int channelId);

  ChatMessage replyTo(int? replyTo);

  ChatMessage authorId(int? authorId);

  ChatMessage author(String author);

  ChatMessage kind(ChatMessageKindEnum kind);

  ChatMessage body(String body);

  ChatMessage card(ChatCard? card);

  ChatMessage ai(ChatAI? ai);

  ChatMessage ticketKey(String? ticketKey);

  ChatMessage audio(ChatAudio? audio);

  ChatMessage files(List<AttachedFile>? files);

  ChatMessage clientMsgId(String? clientMsgId);

  ChatMessage refs(List<ChatRef> refs);

  ChatMessage createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatMessage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatMessage(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatMessage call({
    int id,
    int channelId,
    int? replyTo,
    int? authorId,
    String author,
    ChatMessageKindEnum kind,
    String body,
    ChatCard? card,
    ChatAI? ai,
    String? ticketKey,
    ChatAudio? audio,
    List<AttachedFile>? files,
    String? clientMsgId,
    List<ChatRef> refs,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfChatMessage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfChatMessage.copyWith.fieldName(...)`
class _$ChatMessageCWProxyImpl implements _$ChatMessageCWProxy {
  const _$ChatMessageCWProxyImpl(this._value);

  final ChatMessage _value;

  @override
  ChatMessage id(int id) => this(id: id);

  @override
  ChatMessage channelId(int channelId) => this(channelId: channelId);

  @override
  ChatMessage replyTo(int? replyTo) => this(replyTo: replyTo);

  @override
  ChatMessage authorId(int? authorId) => this(authorId: authorId);

  @override
  ChatMessage author(String author) => this(author: author);

  @override
  ChatMessage kind(ChatMessageKindEnum kind) => this(kind: kind);

  @override
  ChatMessage body(String body) => this(body: body);

  @override
  ChatMessage card(ChatCard? card) => this(card: card);

  @override
  ChatMessage ai(ChatAI? ai) => this(ai: ai);

  @override
  ChatMessage ticketKey(String? ticketKey) => this(ticketKey: ticketKey);

  @override
  ChatMessage audio(ChatAudio? audio) => this(audio: audio);

  @override
  ChatMessage files(List<AttachedFile>? files) => this(files: files);

  @override
  ChatMessage clientMsgId(String? clientMsgId) =>
      this(clientMsgId: clientMsgId);

  @override
  ChatMessage refs(List<ChatRef> refs) => this(refs: refs);

  @override
  ChatMessage createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatMessage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatMessage(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatMessage call({
    Object? id = const $CopyWithPlaceholder(),
    Object? channelId = const $CopyWithPlaceholder(),
    Object? replyTo = const $CopyWithPlaceholder(),
    Object? authorId = const $CopyWithPlaceholder(),
    Object? author = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? body = const $CopyWithPlaceholder(),
    Object? card = const $CopyWithPlaceholder(),
    Object? ai = const $CopyWithPlaceholder(),
    Object? ticketKey = const $CopyWithPlaceholder(),
    Object? audio = const $CopyWithPlaceholder(),
    Object? files = const $CopyWithPlaceholder(),
    Object? clientMsgId = const $CopyWithPlaceholder(),
    Object? refs = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return ChatMessage(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      channelId: channelId == const $CopyWithPlaceholder()
          ? _value.channelId
          // ignore: cast_nullable_to_non_nullable
          : channelId as int,
      replyTo: replyTo == const $CopyWithPlaceholder()
          ? _value.replyTo
          // ignore: cast_nullable_to_non_nullable
          : replyTo as int?,
      authorId: authorId == const $CopyWithPlaceholder()
          ? _value.authorId
          // ignore: cast_nullable_to_non_nullable
          : authorId as int?,
      author: author == const $CopyWithPlaceholder()
          ? _value.author
          // ignore: cast_nullable_to_non_nullable
          : author as String,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as ChatMessageKindEnum,
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String,
      card: card == const $CopyWithPlaceholder()
          ? _value.card
          // ignore: cast_nullable_to_non_nullable
          : card as ChatCard?,
      ai: ai == const $CopyWithPlaceholder()
          ? _value.ai
          // ignore: cast_nullable_to_non_nullable
          : ai as ChatAI?,
      ticketKey: ticketKey == const $CopyWithPlaceholder()
          ? _value.ticketKey
          // ignore: cast_nullable_to_non_nullable
          : ticketKey as String?,
      audio: audio == const $CopyWithPlaceholder()
          ? _value.audio
          // ignore: cast_nullable_to_non_nullable
          : audio as ChatAudio?,
      files: files == const $CopyWithPlaceholder()
          ? _value.files
          // ignore: cast_nullable_to_non_nullable
          : files as List<AttachedFile>?,
      clientMsgId: clientMsgId == const $CopyWithPlaceholder()
          ? _value.clientMsgId
          // ignore: cast_nullable_to_non_nullable
          : clientMsgId as String?,
      refs: refs == const $CopyWithPlaceholder()
          ? _value.refs
          // ignore: cast_nullable_to_non_nullable
          : refs as List<ChatRef>,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $ChatMessageCopyWith on ChatMessage {
  /// Returns a callable class that can be used as follows: `instanceOfChatMessage.copyWith(...)` or like so:`instanceOfChatMessage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ChatMessageCWProxy get copyWith => _$ChatMessageCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ChatMessage', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'channelId',
          'author',
          'kind',
          'body',
          'refs',
          'createdAt',
        ],
      );
      final val = ChatMessage(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        channelId: $checkedConvert('channelId', (v) => (v as num).toInt()),
        replyTo: $checkedConvert('replyTo', (v) => (v as num?)?.toInt()),
        authorId: $checkedConvert('authorId', (v) => (v as num?)?.toInt()),
        author: $checkedConvert('author', (v) => v as String),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$ChatMessageKindEnumEnumMap, v),
        ),
        body: $checkedConvert('body', (v) => v as String),
        card: $checkedConvert(
          'card',
          (v) =>
              v == null ? null : ChatCard.fromJson(v as Map<String, dynamic>),
        ),
        ai: $checkedConvert(
          'ai',
          (v) => v == null ? null : ChatAI.fromJson(v as Map<String, dynamic>),
        ),
        ticketKey: $checkedConvert('ticketKey', (v) => v as String?),
        audio: $checkedConvert(
          'audio',
          (v) =>
              v == null ? null : ChatAudio.fromJson(v as Map<String, dynamic>),
        ),
        files: $checkedConvert(
          'files',
          (v) => (v as List<dynamic>?)
              ?.map((e) => AttachedFile.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        clientMsgId: $checkedConvert('clientMsgId', (v) => v as String?),
        refs: $checkedConvert(
          'refs',
          (v) => (v as List<dynamic>)
              .map((e) => ChatRef.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channelId': instance.channelId,
      'replyTo': ?instance.replyTo,
      'authorId': ?instance.authorId,
      'author': instance.author,
      'kind': _$ChatMessageKindEnumEnumMap[instance.kind]!,
      'body': instance.body,
      'card': ?instance.card?.toJson(),
      'ai': ?instance.ai?.toJson(),
      'ticketKey': ?instance.ticketKey,
      'audio': ?instance.audio?.toJson(),
      'files': ?instance.files?.map((e) => e.toJson()).toList(),
      'clientMsgId': ?instance.clientMsgId,
      'refs': instance.refs.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$ChatMessageKindEnumEnumMap = {
  ChatMessageKindEnum.text: 'text',
  ChatMessageKindEnum.agentCard: 'agent_card',
  ChatMessageKindEnum.agentText: 'agent_text',
  ChatMessageKindEnum.system: 'system',
};

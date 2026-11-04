// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_card.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChatCardCWProxy {
  ChatCard type(ChatCardTypeEnum type);

  ChatCard state(ChatCardStateEnum state);

  ChatCard title(String title);

  ChatCard summary(String? summary);

  ChatCard actions(List<ChatCardActionsEnum> actions);

  ChatCard data(Map<String, Object>? data);

  ChatCard by(String? by);

  ChatCard done(String? done);

  ChatCard result(String? result);

  ChatCard at(DateTime? at);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatCard(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatCard(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatCard call({
    ChatCardTypeEnum type,
    ChatCardStateEnum state,
    String title,
    String? summary,
    List<ChatCardActionsEnum> actions,
    Map<String, Object>? data,
    String? by,
    String? done,
    String? result,
    DateTime? at,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfChatCard.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfChatCard.copyWith.fieldName(...)`
class _$ChatCardCWProxyImpl implements _$ChatCardCWProxy {
  const _$ChatCardCWProxyImpl(this._value);

  final ChatCard _value;

  @override
  ChatCard type(ChatCardTypeEnum type) => this(type: type);

  @override
  ChatCard state(ChatCardStateEnum state) => this(state: state);

  @override
  ChatCard title(String title) => this(title: title);

  @override
  ChatCard summary(String? summary) => this(summary: summary);

  @override
  ChatCard actions(List<ChatCardActionsEnum> actions) => this(actions: actions);

  @override
  ChatCard data(Map<String, Object>? data) => this(data: data);

  @override
  ChatCard by(String? by) => this(by: by);

  @override
  ChatCard done(String? done) => this(done: done);

  @override
  ChatCard result(String? result) => this(result: result);

  @override
  ChatCard at(DateTime? at) => this(at: at);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatCard(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatCard(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatCard call({
    Object? type = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? summary = const $CopyWithPlaceholder(),
    Object? actions = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
    Object? by = const $CopyWithPlaceholder(),
    Object? done = const $CopyWithPlaceholder(),
    Object? result = const $CopyWithPlaceholder(),
    Object? at = const $CopyWithPlaceholder(),
  }) {
    return ChatCard(
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as ChatCardTypeEnum,
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as ChatCardStateEnum,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as String?,
      actions: actions == const $CopyWithPlaceholder()
          ? _value.actions
          // ignore: cast_nullable_to_non_nullable
          : actions as List<ChatCardActionsEnum>,
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Map<String, Object>?,
      by: by == const $CopyWithPlaceholder()
          ? _value.by
          // ignore: cast_nullable_to_non_nullable
          : by as String?,
      done: done == const $CopyWithPlaceholder()
          ? _value.done
          // ignore: cast_nullable_to_non_nullable
          : done as String?,
      result: result == const $CopyWithPlaceholder()
          ? _value.result
          // ignore: cast_nullable_to_non_nullable
          : result as String?,
      at: at == const $CopyWithPlaceholder()
          ? _value.at
          // ignore: cast_nullable_to_non_nullable
          : at as DateTime?,
    );
  }
}

extension $ChatCardCopyWith on ChatCard {
  /// Returns a callable class that can be used as follows: `instanceOfChatCard.copyWith(...)` or like so:`instanceOfChatCard.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ChatCardCWProxy get copyWith => _$ChatCardCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatCard _$ChatCardFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ChatCard', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['type', 'state', 'title', 'actions']);
  final val = ChatCard(
    type: $checkedConvert(
      'type',
      (v) => $enumDecode(_$ChatCardTypeEnumEnumMap, v),
    ),
    state: $checkedConvert(
      'state',
      (v) => $enumDecode(_$ChatCardStateEnumEnumMap, v),
    ),
    title: $checkedConvert('title', (v) => v as String),
    summary: $checkedConvert('summary', (v) => v as String?),
    actions: $checkedConvert(
      'actions',
      (v) => (v as List<dynamic>)
          .map((e) => $enumDecode(_$ChatCardActionsEnumEnumMap, e))
          .toList(),
    ),
    data: $checkedConvert(
      'data',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
    by: $checkedConvert('by', (v) => v as String?),
    done: $checkedConvert('done', (v) => v as String?),
    result: $checkedConvert('result', (v) => v as String?),
    at: $checkedConvert(
      'at',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
  );
  return val;
});

Map<String, dynamic> _$ChatCardToJson(ChatCard instance) => <String, dynamic>{
  'type': _$ChatCardTypeEnumEnumMap[instance.type]!,
  'state': _$ChatCardStateEnumEnumMap[instance.state]!,
  'title': instance.title,
  'summary': ?instance.summary,
  'actions': instance.actions
      .map((e) => _$ChatCardActionsEnumEnumMap[e]!)
      .toList(),
  'data': ?instance.data,
  'by': ?instance.by,
  'done': ?instance.done,
  'result': ?instance.result,
  'at': ?instance.at?.toIso8601String(),
};

const _$ChatCardTypeEnumEnumMap = {
  ChatCardTypeEnum.logFinding: 'log_finding',
  ChatCardTypeEnum.reviewReady: 'review_ready',
  ChatCardTypeEnum.prOpened: 'pr_opened',
  ChatCardTypeEnum.ticketDraft: 'ticket_draft',
};

const _$ChatCardStateEnumEnumMap = {
  ChatCardStateEnum.open: 'open',
  ChatCardStateEnum.done: 'done',
  ChatCardStateEnum.failed: 'failed',
  ChatCardStateEnum.expired: 'expired',
};

const _$ChatCardActionsEnumEnumMap = {
  ChatCardActionsEnum.fix: 'fix',
  ChatCardActionsEnum.mute: 'mute',
  ChatCardActionsEnum.approve: 'approve',
  ChatCardActionsEnum.requestChanges: 'request_changes',
  ChatCardActionsEnum.merge: 'merge',
  ChatCardActionsEnum.create: 'create',
  ChatCardActionsEnum.createAssign: 'create_assign',
};

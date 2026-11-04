// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_action_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChatActionRequestCWProxy {
  ChatActionRequest action(ChatActionRequestActionEnum action);

  ChatActionRequest feedback(String? feedback);

  ChatActionRequest draft(ChatActionRequestDraft? draft);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatActionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatActionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatActionRequest call({
    ChatActionRequestActionEnum action,
    String? feedback,
    ChatActionRequestDraft? draft,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfChatActionRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfChatActionRequest.copyWith.fieldName(...)`
class _$ChatActionRequestCWProxyImpl implements _$ChatActionRequestCWProxy {
  const _$ChatActionRequestCWProxyImpl(this._value);

  final ChatActionRequest _value;

  @override
  ChatActionRequest action(ChatActionRequestActionEnum action) =>
      this(action: action);

  @override
  ChatActionRequest feedback(String? feedback) => this(feedback: feedback);

  @override
  ChatActionRequest draft(ChatActionRequestDraft? draft) => this(draft: draft);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatActionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatActionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatActionRequest call({
    Object? action = const $CopyWithPlaceholder(),
    Object? feedback = const $CopyWithPlaceholder(),
    Object? draft = const $CopyWithPlaceholder(),
  }) {
    return ChatActionRequest(
      action: action == const $CopyWithPlaceholder()
          ? _value.action
          // ignore: cast_nullable_to_non_nullable
          : action as ChatActionRequestActionEnum,
      feedback: feedback == const $CopyWithPlaceholder()
          ? _value.feedback
          // ignore: cast_nullable_to_non_nullable
          : feedback as String?,
      draft: draft == const $CopyWithPlaceholder()
          ? _value.draft
          // ignore: cast_nullable_to_non_nullable
          : draft as ChatActionRequestDraft?,
    );
  }
}

extension $ChatActionRequestCopyWith on ChatActionRequest {
  /// Returns a callable class that can be used as follows: `instanceOfChatActionRequest.copyWith(...)` or like so:`instanceOfChatActionRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ChatActionRequestCWProxy get copyWith =>
      _$ChatActionRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatActionRequest _$ChatActionRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ChatActionRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['action']);
      final val = ChatActionRequest(
        action: $checkedConvert(
          'action',
          (v) => $enumDecode(_$ChatActionRequestActionEnumEnumMap, v),
        ),
        feedback: $checkedConvert('feedback', (v) => v as String?),
        draft: $checkedConvert(
          'draft',
          (v) => v == null
              ? null
              : ChatActionRequestDraft.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ChatActionRequestToJson(ChatActionRequest instance) =>
    <String, dynamic>{
      'action': _$ChatActionRequestActionEnumEnumMap[instance.action]!,
      'feedback': ?instance.feedback,
      'draft': ?instance.draft?.toJson(),
    };

const _$ChatActionRequestActionEnumEnumMap = {
  ChatActionRequestActionEnum.fix: 'fix',
  ChatActionRequestActionEnum.mute: 'mute',
  ChatActionRequestActionEnum.approve: 'approve',
  ChatActionRequestActionEnum.requestChanges: 'request_changes',
  ChatActionRequestActionEnum.merge: 'merge',
  ChatActionRequestActionEnum.create: 'create',
  ChatActionRequestActionEnum.createAssign: 'create_assign',
};

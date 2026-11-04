// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_action_request_draft.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChatActionRequestDraftCWProxy {
  ChatActionRequestDraft title(String? title);

  ChatActionRequestDraft description(String? description);

  ChatActionRequestDraft repoId(int? repoId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatActionRequestDraft(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatActionRequestDraft(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatActionRequestDraft call({
    String? title,
    String? description,
    int? repoId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfChatActionRequestDraft.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfChatActionRequestDraft.copyWith.fieldName(...)`
class _$ChatActionRequestDraftCWProxyImpl
    implements _$ChatActionRequestDraftCWProxy {
  const _$ChatActionRequestDraftCWProxyImpl(this._value);

  final ChatActionRequestDraft _value;

  @override
  ChatActionRequestDraft title(String? title) => this(title: title);

  @override
  ChatActionRequestDraft description(String? description) =>
      this(description: description);

  @override
  ChatActionRequestDraft repoId(int? repoId) => this(repoId: repoId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatActionRequestDraft(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatActionRequestDraft(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatActionRequestDraft call({
    Object? title = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? repoId = const $CopyWithPlaceholder(),
  }) {
    return ChatActionRequestDraft(
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int?,
    );
  }
}

extension $ChatActionRequestDraftCopyWith on ChatActionRequestDraft {
  /// Returns a callable class that can be used as follows: `instanceOfChatActionRequestDraft.copyWith(...)` or like so:`instanceOfChatActionRequestDraft.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ChatActionRequestDraftCWProxy get copyWith =>
      _$ChatActionRequestDraftCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatActionRequestDraft _$ChatActionRequestDraftFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ChatActionRequestDraft', json, ($checkedConvert) {
  final val = ChatActionRequestDraft(
    title: $checkedConvert('title', (v) => v as String?),
    description: $checkedConvert('description', (v) => v as String?),
    repoId: $checkedConvert('repoId', (v) => (v as num?)?.toInt()),
  );
  return val;
});

Map<String, dynamic> _$ChatActionRequestDraftToJson(
  ChatActionRequestDraft instance,
) => <String, dynamic>{
  'title': ?instance.title,
  'description': ?instance.description,
  'repoId': ?instance.repoId,
};

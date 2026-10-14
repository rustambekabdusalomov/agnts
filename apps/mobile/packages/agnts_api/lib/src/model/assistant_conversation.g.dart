// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_conversation.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantConversationCWProxy {
  AssistantConversation id(int id);

  AssistantConversation title(String title);

  AssistantConversation createdAt(DateTime createdAt);

  AssistantConversation updatedAt(DateTime updatedAt);

  AssistantConversation messages(List<AssistantMessage> messages);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantConversation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantConversation(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantConversation call({
    int id,
    String title,
    DateTime createdAt,
    DateTime updatedAt,
    List<AssistantMessage> messages,
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
  AssistantConversation createdAt(DateTime createdAt) =>
      this(createdAt: createdAt);

  @override
  AssistantConversation updatedAt(DateTime updatedAt) =>
      this(updatedAt: updatedAt);

  @override
  AssistantConversation messages(List<AssistantMessage> messages) =>
      this(messages: messages);

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
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? messages = const $CopyWithPlaceholder(),
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
    requiredKeys: const ['id', 'title', 'createdAt', 'updatedAt', 'messages'],
  );
  final val = AssistantConversation(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    title: $checkedConvert('title', (v) => v as String),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
    messages: $checkedConvert(
      'messages',
      (v) => (v as List<dynamic>)
          .map((e) => AssistantMessage.fromJson(e as Map<String, dynamic>))
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
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'messages': instance.messages.map((e) => e.toJson()).toList(),
};

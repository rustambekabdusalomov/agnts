// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_channel_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChatChannelInputCWProxy {
  ChatChannelInput name(String name);

  ChatChannelInput topic(String? topic);

  ChatChannelInput agents(bool? agents);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatChannelInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatChannelInput(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatChannelInput call({String name, String? topic, bool? agents});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfChatChannelInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfChatChannelInput.copyWith.fieldName(...)`
class _$ChatChannelInputCWProxyImpl implements _$ChatChannelInputCWProxy {
  const _$ChatChannelInputCWProxyImpl(this._value);

  final ChatChannelInput _value;

  @override
  ChatChannelInput name(String name) => this(name: name);

  @override
  ChatChannelInput topic(String? topic) => this(topic: topic);

  @override
  ChatChannelInput agents(bool? agents) => this(agents: agents);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatChannelInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatChannelInput(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatChannelInput call({
    Object? name = const $CopyWithPlaceholder(),
    Object? topic = const $CopyWithPlaceholder(),
    Object? agents = const $CopyWithPlaceholder(),
  }) {
    return ChatChannelInput(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      topic: topic == const $CopyWithPlaceholder()
          ? _value.topic
          // ignore: cast_nullable_to_non_nullable
          : topic as String?,
      agents: agents == const $CopyWithPlaceholder()
          ? _value.agents
          // ignore: cast_nullable_to_non_nullable
          : agents as bool?,
    );
  }
}

extension $ChatChannelInputCopyWith on ChatChannelInput {
  /// Returns a callable class that can be used as follows: `instanceOfChatChannelInput.copyWith(...)` or like so:`instanceOfChatChannelInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ChatChannelInputCWProxy get copyWith => _$ChatChannelInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatChannelInput _$ChatChannelInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ChatChannelInput', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['name']);
      final val = ChatChannelInput(
        name: $checkedConvert('name', (v) => v as String),
        topic: $checkedConvert('topic', (v) => v as String?),
        agents: $checkedConvert('agents', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$ChatChannelInputToJson(ChatChannelInput instance) =>
    <String, dynamic>{
      'name': instance.name,
      'topic': ?instance.topic,
      'agents': ?instance.agents,
    };

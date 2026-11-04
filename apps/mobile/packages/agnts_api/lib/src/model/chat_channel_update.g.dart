// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_channel_update.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChatChannelUpdateCWProxy {
  ChatChannelUpdate topic(String? topic);

  ChatChannelUpdate agents(bool? agents);

  ChatChannelUpdate archive(bool? archive);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatChannelUpdate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatChannelUpdate(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatChannelUpdate call({String? topic, bool? agents, bool? archive});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfChatChannelUpdate.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfChatChannelUpdate.copyWith.fieldName(...)`
class _$ChatChannelUpdateCWProxyImpl implements _$ChatChannelUpdateCWProxy {
  const _$ChatChannelUpdateCWProxyImpl(this._value);

  final ChatChannelUpdate _value;

  @override
  ChatChannelUpdate topic(String? topic) => this(topic: topic);

  @override
  ChatChannelUpdate agents(bool? agents) => this(agents: agents);

  @override
  ChatChannelUpdate archive(bool? archive) => this(archive: archive);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatChannelUpdate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatChannelUpdate(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatChannelUpdate call({
    Object? topic = const $CopyWithPlaceholder(),
    Object? agents = const $CopyWithPlaceholder(),
    Object? archive = const $CopyWithPlaceholder(),
  }) {
    return ChatChannelUpdate(
      topic: topic == const $CopyWithPlaceholder()
          ? _value.topic
          // ignore: cast_nullable_to_non_nullable
          : topic as String?,
      agents: agents == const $CopyWithPlaceholder()
          ? _value.agents
          // ignore: cast_nullable_to_non_nullable
          : agents as bool?,
      archive: archive == const $CopyWithPlaceholder()
          ? _value.archive
          // ignore: cast_nullable_to_non_nullable
          : archive as bool?,
    );
  }
}

extension $ChatChannelUpdateCopyWith on ChatChannelUpdate {
  /// Returns a callable class that can be used as follows: `instanceOfChatChannelUpdate.copyWith(...)` or like so:`instanceOfChatChannelUpdate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ChatChannelUpdateCWProxy get copyWith =>
      _$ChatChannelUpdateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatChannelUpdate _$ChatChannelUpdateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ChatChannelUpdate', json, ($checkedConvert) {
      final val = ChatChannelUpdate(
        topic: $checkedConvert('topic', (v) => v as String?),
        agents: $checkedConvert('agents', (v) => v as bool?),
        archive: $checkedConvert('archive', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$ChatChannelUpdateToJson(ChatChannelUpdate instance) =>
    <String, dynamic>{
      'topic': ?instance.topic,
      'agents': ?instance.agents,
      'archive': ?instance.archive,
    };

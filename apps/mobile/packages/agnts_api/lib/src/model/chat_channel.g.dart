// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_channel.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChatChannelCWProxy {
  ChatChannel id(int id);

  ChatChannel name(String name);

  ChatChannel topic(String topic);

  ChatChannel agents(bool agents);

  ChatChannel createdAt(DateTime createdAt);

  ChatChannel archivedAt(DateTime? archivedAt);

  ChatChannel lastId(int lastId);

  ChatChannel unread(int unread);

  ChatChannel lastReadId(int lastReadId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatChannel(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatChannel(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatChannel call({
    int id,
    String name,
    String topic,
    bool agents,
    DateTime createdAt,
    DateTime? archivedAt,
    int lastId,
    int unread,
    int lastReadId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfChatChannel.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfChatChannel.copyWith.fieldName(...)`
class _$ChatChannelCWProxyImpl implements _$ChatChannelCWProxy {
  const _$ChatChannelCWProxyImpl(this._value);

  final ChatChannel _value;

  @override
  ChatChannel id(int id) => this(id: id);

  @override
  ChatChannel name(String name) => this(name: name);

  @override
  ChatChannel topic(String topic) => this(topic: topic);

  @override
  ChatChannel agents(bool agents) => this(agents: agents);

  @override
  ChatChannel createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  ChatChannel archivedAt(DateTime? archivedAt) => this(archivedAt: archivedAt);

  @override
  ChatChannel lastId(int lastId) => this(lastId: lastId);

  @override
  ChatChannel unread(int unread) => this(unread: unread);

  @override
  ChatChannel lastReadId(int lastReadId) => this(lastReadId: lastReadId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatChannel(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatChannel(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatChannel call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? topic = const $CopyWithPlaceholder(),
    Object? agents = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? archivedAt = const $CopyWithPlaceholder(),
    Object? lastId = const $CopyWithPlaceholder(),
    Object? unread = const $CopyWithPlaceholder(),
    Object? lastReadId = const $CopyWithPlaceholder(),
  }) {
    return ChatChannel(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      topic: topic == const $CopyWithPlaceholder()
          ? _value.topic
          // ignore: cast_nullable_to_non_nullable
          : topic as String,
      agents: agents == const $CopyWithPlaceholder()
          ? _value.agents
          // ignore: cast_nullable_to_non_nullable
          : agents as bool,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      archivedAt: archivedAt == const $CopyWithPlaceholder()
          ? _value.archivedAt
          // ignore: cast_nullable_to_non_nullable
          : archivedAt as DateTime?,
      lastId: lastId == const $CopyWithPlaceholder()
          ? _value.lastId
          // ignore: cast_nullable_to_non_nullable
          : lastId as int,
      unread: unread == const $CopyWithPlaceholder()
          ? _value.unread
          // ignore: cast_nullable_to_non_nullable
          : unread as int,
      lastReadId: lastReadId == const $CopyWithPlaceholder()
          ? _value.lastReadId
          // ignore: cast_nullable_to_non_nullable
          : lastReadId as int,
    );
  }
}

extension $ChatChannelCopyWith on ChatChannel {
  /// Returns a callable class that can be used as follows: `instanceOfChatChannel.copyWith(...)` or like so:`instanceOfChatChannel.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ChatChannelCWProxy get copyWith => _$ChatChannelCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatChannel _$ChatChannelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ChatChannel', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'name',
          'topic',
          'agents',
          'createdAt',
          'lastId',
          'unread',
          'lastReadId',
        ],
      );
      final val = ChatChannel(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        name: $checkedConvert('name', (v) => v as String),
        topic: $checkedConvert('topic', (v) => v as String),
        agents: $checkedConvert('agents', (v) => v as bool),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => DateTime.parse(v as String),
        ),
        archivedAt: $checkedConvert(
          'archivedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        lastId: $checkedConvert('lastId', (v) => (v as num).toInt()),
        unread: $checkedConvert('unread', (v) => (v as num).toInt()),
        lastReadId: $checkedConvert('lastReadId', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$ChatChannelToJson(ChatChannel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'topic': instance.topic,
      'agents': instance.agents,
      'createdAt': instance.createdAt.toIso8601String(),
      'archivedAt': ?instance.archivedAt?.toIso8601String(),
      'lastId': instance.lastId,
      'unread': instance.unread,
      'lastReadId': instance.lastReadId,
    };

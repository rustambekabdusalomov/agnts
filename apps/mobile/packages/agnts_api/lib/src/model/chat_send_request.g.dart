// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_send_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChatSendRequestCWProxy {
  ChatSendRequest clientMsgId(String clientMsgId);

  ChatSendRequest body(String? body);

  ChatSendRequest files(List<int>? files);

  ChatSendRequest replyTo(int? replyTo);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatSendRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatSendRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatSendRequest call({
    String clientMsgId,
    String? body,
    List<int>? files,
    int? replyTo,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfChatSendRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfChatSendRequest.copyWith.fieldName(...)`
class _$ChatSendRequestCWProxyImpl implements _$ChatSendRequestCWProxy {
  const _$ChatSendRequestCWProxyImpl(this._value);

  final ChatSendRequest _value;

  @override
  ChatSendRequest clientMsgId(String clientMsgId) =>
      this(clientMsgId: clientMsgId);

  @override
  ChatSendRequest body(String? body) => this(body: body);

  @override
  ChatSendRequest files(List<int>? files) => this(files: files);

  @override
  ChatSendRequest replyTo(int? replyTo) => this(replyTo: replyTo);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatSendRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatSendRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatSendRequest call({
    Object? clientMsgId = const $CopyWithPlaceholder(),
    Object? body = const $CopyWithPlaceholder(),
    Object? files = const $CopyWithPlaceholder(),
    Object? replyTo = const $CopyWithPlaceholder(),
  }) {
    return ChatSendRequest(
      clientMsgId: clientMsgId == const $CopyWithPlaceholder()
          ? _value.clientMsgId
          // ignore: cast_nullable_to_non_nullable
          : clientMsgId as String,
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String?,
      files: files == const $CopyWithPlaceholder()
          ? _value.files
          // ignore: cast_nullable_to_non_nullable
          : files as List<int>?,
      replyTo: replyTo == const $CopyWithPlaceholder()
          ? _value.replyTo
          // ignore: cast_nullable_to_non_nullable
          : replyTo as int?,
    );
  }
}

extension $ChatSendRequestCopyWith on ChatSendRequest {
  /// Returns a callable class that can be used as follows: `instanceOfChatSendRequest.copyWith(...)` or like so:`instanceOfChatSendRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ChatSendRequestCWProxy get copyWith => _$ChatSendRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatSendRequest _$ChatSendRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ChatSendRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['clientMsgId']);
      final val = ChatSendRequest(
        clientMsgId: $checkedConvert('clientMsgId', (v) => v as String),
        body: $checkedConvert('body', (v) => v as String?),
        files: $checkedConvert(
          'files',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
        replyTo: $checkedConvert('replyTo', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$ChatSendRequestToJson(ChatSendRequest instance) =>
    <String, dynamic>{
      'clientMsgId': instance.clientMsgId,
      'body': ?instance.body,
      'files': ?instance.files,
      'replyTo': ?instance.replyTo,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply_pull_thread_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReplyPullThreadRequestCWProxy {
  ReplyPullThreadRequest threadId(String threadId);

  ReplyPullThreadRequest body(String body);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReplyPullThreadRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReplyPullThreadRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ReplyPullThreadRequest call({String threadId, String body});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReplyPullThreadRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReplyPullThreadRequest.copyWith.fieldName(...)`
class _$ReplyPullThreadRequestCWProxyImpl
    implements _$ReplyPullThreadRequestCWProxy {
  const _$ReplyPullThreadRequestCWProxyImpl(this._value);

  final ReplyPullThreadRequest _value;

  @override
  ReplyPullThreadRequest threadId(String threadId) => this(threadId: threadId);

  @override
  ReplyPullThreadRequest body(String body) => this(body: body);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReplyPullThreadRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReplyPullThreadRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ReplyPullThreadRequest call({
    Object? threadId = const $CopyWithPlaceholder(),
    Object? body = const $CopyWithPlaceholder(),
  }) {
    return ReplyPullThreadRequest(
      threadId: threadId == const $CopyWithPlaceholder()
          ? _value.threadId
          // ignore: cast_nullable_to_non_nullable
          : threadId as String,
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String,
    );
  }
}

extension $ReplyPullThreadRequestCopyWith on ReplyPullThreadRequest {
  /// Returns a callable class that can be used as follows: `instanceOfReplyPullThreadRequest.copyWith(...)` or like so:`instanceOfReplyPullThreadRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReplyPullThreadRequestCWProxy get copyWith =>
      _$ReplyPullThreadRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReplyPullThreadRequest _$ReplyPullThreadRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ReplyPullThreadRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['threadId', 'body']);
  final val = ReplyPullThreadRequest(
    threadId: $checkedConvert('threadId', (v) => v as String),
    body: $checkedConvert('body', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$ReplyPullThreadRequestToJson(
  ReplyPullThreadRequest instance,
) => <String, dynamic>{'threadId': instance.threadId, 'body': instance.body};

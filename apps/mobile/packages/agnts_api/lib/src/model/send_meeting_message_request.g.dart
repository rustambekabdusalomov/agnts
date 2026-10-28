// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_meeting_message_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SendMeetingMessageRequestCWProxy {
  SendMeetingMessageRequest body(String body);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SendMeetingMessageRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SendMeetingMessageRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SendMeetingMessageRequest call({String body});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSendMeetingMessageRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSendMeetingMessageRequest.copyWith.fieldName(...)`
class _$SendMeetingMessageRequestCWProxyImpl
    implements _$SendMeetingMessageRequestCWProxy {
  const _$SendMeetingMessageRequestCWProxyImpl(this._value);

  final SendMeetingMessageRequest _value;

  @override
  SendMeetingMessageRequest body(String body) => this(body: body);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SendMeetingMessageRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SendMeetingMessageRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SendMeetingMessageRequest call({
    Object? body = const $CopyWithPlaceholder(),
  }) {
    return SendMeetingMessageRequest(
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String,
    );
  }
}

extension $SendMeetingMessageRequestCopyWith on SendMeetingMessageRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSendMeetingMessageRequest.copyWith(...)` or like so:`instanceOfSendMeetingMessageRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SendMeetingMessageRequestCWProxy get copyWith =>
      _$SendMeetingMessageRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendMeetingMessageRequest _$SendMeetingMessageRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SendMeetingMessageRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['body']);
  final val = SendMeetingMessageRequest(
    body: $checkedConvert('body', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$SendMeetingMessageRequestToJson(
  SendMeetingMessageRequest instance,
) => <String, dynamic>{'body': instance.body};

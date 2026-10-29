// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'retry_ticket_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RetryTicketRequestCWProxy {
  RetryTicketRequest note(String? note);

  RetryTicketRequest attachments(List<int>? attachments);

  RetryTicketRequest skipChecks(bool? skipChecks);

  RetryTicketRequest discardWork(bool? discardWork);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RetryTicketRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RetryTicketRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RetryTicketRequest call({
    String? note,
    List<int>? attachments,
    bool? skipChecks,
    bool? discardWork,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRetryTicketRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRetryTicketRequest.copyWith.fieldName(...)`
class _$RetryTicketRequestCWProxyImpl implements _$RetryTicketRequestCWProxy {
  const _$RetryTicketRequestCWProxyImpl(this._value);

  final RetryTicketRequest _value;

  @override
  RetryTicketRequest note(String? note) => this(note: note);

  @override
  RetryTicketRequest attachments(List<int>? attachments) =>
      this(attachments: attachments);

  @override
  RetryTicketRequest skipChecks(bool? skipChecks) =>
      this(skipChecks: skipChecks);

  @override
  RetryTicketRequest discardWork(bool? discardWork) =>
      this(discardWork: discardWork);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RetryTicketRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RetryTicketRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RetryTicketRequest call({
    Object? note = const $CopyWithPlaceholder(),
    Object? attachments = const $CopyWithPlaceholder(),
    Object? skipChecks = const $CopyWithPlaceholder(),
    Object? discardWork = const $CopyWithPlaceholder(),
  }) {
    return RetryTicketRequest(
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
      attachments: attachments == const $CopyWithPlaceholder()
          ? _value.attachments
          // ignore: cast_nullable_to_non_nullable
          : attachments as List<int>?,
      skipChecks: skipChecks == const $CopyWithPlaceholder()
          ? _value.skipChecks
          // ignore: cast_nullable_to_non_nullable
          : skipChecks as bool?,
      discardWork: discardWork == const $CopyWithPlaceholder()
          ? _value.discardWork
          // ignore: cast_nullable_to_non_nullable
          : discardWork as bool?,
    );
  }
}

extension $RetryTicketRequestCopyWith on RetryTicketRequest {
  /// Returns a callable class that can be used as follows: `instanceOfRetryTicketRequest.copyWith(...)` or like so:`instanceOfRetryTicketRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RetryTicketRequestCWProxy get copyWith =>
      _$RetryTicketRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RetryTicketRequest _$RetryTicketRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RetryTicketRequest', json, ($checkedConvert) {
      final val = RetryTicketRequest(
        note: $checkedConvert('note', (v) => v as String?),
        attachments: $checkedConvert(
          'attachments',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
        skipChecks: $checkedConvert('skipChecks', (v) => v as bool?),
        discardWork: $checkedConvert('discardWork', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$RetryTicketRequestToJson(RetryTicketRequest instance) =>
    <String, dynamic>{
      'note': ?instance.note,
      'attachments': ?instance.attachments,
      'skipChecks': ?instance.skipChecks,
      'discardWork': ?instance.discardWork,
    };

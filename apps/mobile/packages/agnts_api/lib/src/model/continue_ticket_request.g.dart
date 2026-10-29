// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'continue_ticket_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ContinueTicketRequestCWProxy {
  ContinueTicketRequest note(String? note);

  ContinueTicketRequest attachments(List<int>? attachments);

  ContinueTicketRequest discardWork(bool? discardWork);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ContinueTicketRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ContinueTicketRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ContinueTicketRequest call({
    String? note,
    List<int>? attachments,
    bool? discardWork,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfContinueTicketRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfContinueTicketRequest.copyWith.fieldName(...)`
class _$ContinueTicketRequestCWProxyImpl
    implements _$ContinueTicketRequestCWProxy {
  const _$ContinueTicketRequestCWProxyImpl(this._value);

  final ContinueTicketRequest _value;

  @override
  ContinueTicketRequest note(String? note) => this(note: note);

  @override
  ContinueTicketRequest attachments(List<int>? attachments) =>
      this(attachments: attachments);

  @override
  ContinueTicketRequest discardWork(bool? discardWork) =>
      this(discardWork: discardWork);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ContinueTicketRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ContinueTicketRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ContinueTicketRequest call({
    Object? note = const $CopyWithPlaceholder(),
    Object? attachments = const $CopyWithPlaceholder(),
    Object? discardWork = const $CopyWithPlaceholder(),
  }) {
    return ContinueTicketRequest(
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
      attachments: attachments == const $CopyWithPlaceholder()
          ? _value.attachments
          // ignore: cast_nullable_to_non_nullable
          : attachments as List<int>?,
      discardWork: discardWork == const $CopyWithPlaceholder()
          ? _value.discardWork
          // ignore: cast_nullable_to_non_nullable
          : discardWork as bool?,
    );
  }
}

extension $ContinueTicketRequestCopyWith on ContinueTicketRequest {
  /// Returns a callable class that can be used as follows: `instanceOfContinueTicketRequest.copyWith(...)` or like so:`instanceOfContinueTicketRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ContinueTicketRequestCWProxy get copyWith =>
      _$ContinueTicketRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContinueTicketRequest _$ContinueTicketRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ContinueTicketRequest', json, ($checkedConvert) {
  final val = ContinueTicketRequest(
    note: $checkedConvert('note', (v) => v as String?),
    attachments: $checkedConvert(
      'attachments',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
    ),
    discardWork: $checkedConvert('discardWork', (v) => v as bool?),
  );
  return val;
});

Map<String, dynamic> _$ContinueTicketRequestToJson(
  ContinueTicketRequest instance,
) => <String, dynamic>{
  'note': ?instance.note,
  'attachments': ?instance.attachments,
  'discardWork': ?instance.discardWork,
};

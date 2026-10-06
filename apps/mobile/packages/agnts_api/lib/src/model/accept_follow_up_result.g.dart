// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accept_follow_up_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AcceptFollowUpResultCWProxy {
  AcceptFollowUpResult id(int id);

  AcceptFollowUpResult ticket(Ticket? ticket);

  AcceptFollowUpResult error(String? error);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AcceptFollowUpResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AcceptFollowUpResult(...).copyWith(id: 12, name: "My name")
  /// ````
  AcceptFollowUpResult call({int id, Ticket? ticket, String? error});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAcceptFollowUpResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAcceptFollowUpResult.copyWith.fieldName(...)`
class _$AcceptFollowUpResultCWProxyImpl
    implements _$AcceptFollowUpResultCWProxy {
  const _$AcceptFollowUpResultCWProxyImpl(this._value);

  final AcceptFollowUpResult _value;

  @override
  AcceptFollowUpResult id(int id) => this(id: id);

  @override
  AcceptFollowUpResult ticket(Ticket? ticket) => this(ticket: ticket);

  @override
  AcceptFollowUpResult error(String? error) => this(error: error);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AcceptFollowUpResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AcceptFollowUpResult(...).copyWith(id: 12, name: "My name")
  /// ````
  AcceptFollowUpResult call({
    Object? id = const $CopyWithPlaceholder(),
    Object? ticket = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
  }) {
    return AcceptFollowUpResult(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      ticket: ticket == const $CopyWithPlaceholder()
          ? _value.ticket
          // ignore: cast_nullable_to_non_nullable
          : ticket as Ticket?,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String?,
    );
  }
}

extension $AcceptFollowUpResultCopyWith on AcceptFollowUpResult {
  /// Returns a callable class that can be used as follows: `instanceOfAcceptFollowUpResult.copyWith(...)` or like so:`instanceOfAcceptFollowUpResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AcceptFollowUpResultCWProxy get copyWith =>
      _$AcceptFollowUpResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcceptFollowUpResult _$AcceptFollowUpResultFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AcceptFollowUpResult', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['id']);
  final val = AcceptFollowUpResult(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    ticket: $checkedConvert(
      'ticket',
      (v) => v == null ? null : Ticket.fromJson(v as Map<String, dynamic>),
    ),
    error: $checkedConvert('error', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$AcceptFollowUpResultToJson(
  AcceptFollowUpResult instance,
) => <String, dynamic>{
  'id': instance.id,
  'ticket': ?instance.ticket?.toJson(),
  'error': ?instance.error,
};

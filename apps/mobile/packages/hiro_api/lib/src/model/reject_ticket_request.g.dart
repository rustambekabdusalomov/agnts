// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reject_ticket_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RejectTicketRequestCWProxy {
  RejectTicketRequest reason(String? reason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RejectTicketRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RejectTicketRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RejectTicketRequest call({String? reason});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRejectTicketRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRejectTicketRequest.copyWith.fieldName(...)`
class _$RejectTicketRequestCWProxyImpl implements _$RejectTicketRequestCWProxy {
  const _$RejectTicketRequestCWProxyImpl(this._value);

  final RejectTicketRequest _value;

  @override
  RejectTicketRequest reason(String? reason) => this(reason: reason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RejectTicketRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RejectTicketRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RejectTicketRequest call({Object? reason = const $CopyWithPlaceholder()}) {
    return RejectTicketRequest(
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String?,
    );
  }
}

extension $RejectTicketRequestCopyWith on RejectTicketRequest {
  /// Returns a callable class that can be used as follows: `instanceOfRejectTicketRequest.copyWith(...)` or like so:`instanceOfRejectTicketRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RejectTicketRequestCWProxy get copyWith =>
      _$RejectTicketRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RejectTicketRequest _$RejectTicketRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RejectTicketRequest', json, ($checkedConvert) {
      final val = RejectTicketRequest(
        reason: $checkedConvert('reason', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$RejectTicketRequestToJson(
  RejectTicketRequest instance,
) => <String, dynamic>{'reason': ?instance.reason};

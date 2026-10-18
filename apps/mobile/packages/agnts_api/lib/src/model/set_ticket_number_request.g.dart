// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_ticket_number_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SetTicketNumberRequestCWProxy {
  SetTicketNumberRequest number(String number);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetTicketNumberRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetTicketNumberRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetTicketNumberRequest call({String number});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSetTicketNumberRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSetTicketNumberRequest.copyWith.fieldName(...)`
class _$SetTicketNumberRequestCWProxyImpl
    implements _$SetTicketNumberRequestCWProxy {
  const _$SetTicketNumberRequestCWProxyImpl(this._value);

  final SetTicketNumberRequest _value;

  @override
  SetTicketNumberRequest number(String number) => this(number: number);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetTicketNumberRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetTicketNumberRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetTicketNumberRequest call({Object? number = const $CopyWithPlaceholder()}) {
    return SetTicketNumberRequest(
      number: number == const $CopyWithPlaceholder()
          ? _value.number
          // ignore: cast_nullable_to_non_nullable
          : number as String,
    );
  }
}

extension $SetTicketNumberRequestCopyWith on SetTicketNumberRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSetTicketNumberRequest.copyWith(...)` or like so:`instanceOfSetTicketNumberRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SetTicketNumberRequestCWProxy get copyWith =>
      _$SetTicketNumberRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetTicketNumberRequest _$SetTicketNumberRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SetTicketNumberRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['number']);
  final val = SetTicketNumberRequest(
    number: $checkedConvert('number', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$SetTicketNumberRequestToJson(
  SetTicketNumberRequest instance,
) => <String, dynamic>{'number': instance.number};

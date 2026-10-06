// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_spend_list.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TicketSpendListCWProxy {
  TicketSpendList days(int days);

  TicketSpendList total(TokenSpend total);

  TicketSpendList tickets(List<TicketSpendRow> tickets);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TicketSpendList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TicketSpendList(...).copyWith(id: 12, name: "My name")
  /// ````
  TicketSpendList call({
    int days,
    TokenSpend total,
    List<TicketSpendRow> tickets,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTicketSpendList.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTicketSpendList.copyWith.fieldName(...)`
class _$TicketSpendListCWProxyImpl implements _$TicketSpendListCWProxy {
  const _$TicketSpendListCWProxyImpl(this._value);

  final TicketSpendList _value;

  @override
  TicketSpendList days(int days) => this(days: days);

  @override
  TicketSpendList total(TokenSpend total) => this(total: total);

  @override
  TicketSpendList tickets(List<TicketSpendRow> tickets) =>
      this(tickets: tickets);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TicketSpendList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TicketSpendList(...).copyWith(id: 12, name: "My name")
  /// ````
  TicketSpendList call({
    Object? days = const $CopyWithPlaceholder(),
    Object? total = const $CopyWithPlaceholder(),
    Object? tickets = const $CopyWithPlaceholder(),
  }) {
    return TicketSpendList(
      days: days == const $CopyWithPlaceholder()
          ? _value.days
          // ignore: cast_nullable_to_non_nullable
          : days as int,
      total: total == const $CopyWithPlaceholder()
          ? _value.total
          // ignore: cast_nullable_to_non_nullable
          : total as TokenSpend,
      tickets: tickets == const $CopyWithPlaceholder()
          ? _value.tickets
          // ignore: cast_nullable_to_non_nullable
          : tickets as List<TicketSpendRow>,
    );
  }
}

extension $TicketSpendListCopyWith on TicketSpendList {
  /// Returns a callable class that can be used as follows: `instanceOfTicketSpendList.copyWith(...)` or like so:`instanceOfTicketSpendList.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TicketSpendListCWProxy get copyWith => _$TicketSpendListCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketSpendList _$TicketSpendListFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TicketSpendList', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['days', 'total', 'tickets']);
      final val = TicketSpendList(
        days: $checkedConvert('days', (v) => (v as num).toInt()),
        total: $checkedConvert(
          'total',
          (v) => TokenSpend.fromJson(v as Map<String, dynamic>),
        ),
        tickets: $checkedConvert(
          'tickets',
          (v) => (v as List<dynamic>)
              .map((e) => TicketSpendRow.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$TicketSpendListToJson(TicketSpendList instance) =>
    <String, dynamic>{
      'days': instance.days,
      'total': instance.total.toJson(),
      'tickets': instance.tickets.map((e) => e.toJson()).toList(),
    };

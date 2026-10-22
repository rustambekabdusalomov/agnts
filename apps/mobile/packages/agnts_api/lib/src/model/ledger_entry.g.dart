// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger_entry.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LedgerEntryCWProxy {
  LedgerEntry id(int id);

  LedgerEntry amount(int amount);

  LedgerEntry reason(LedgerEntryReasonEnum reason);

  LedgerEntry ticketKey(String? ticketKey);

  LedgerEntry note(String? note);

  LedgerEntry createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LedgerEntry(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LedgerEntry(...).copyWith(id: 12, name: "My name")
  /// ````
  LedgerEntry call({
    int id,
    int amount,
    LedgerEntryReasonEnum reason,
    String? ticketKey,
    String? note,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLedgerEntry.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLedgerEntry.copyWith.fieldName(...)`
class _$LedgerEntryCWProxyImpl implements _$LedgerEntryCWProxy {
  const _$LedgerEntryCWProxyImpl(this._value);

  final LedgerEntry _value;

  @override
  LedgerEntry id(int id) => this(id: id);

  @override
  LedgerEntry amount(int amount) => this(amount: amount);

  @override
  LedgerEntry reason(LedgerEntryReasonEnum reason) => this(reason: reason);

  @override
  LedgerEntry ticketKey(String? ticketKey) => this(ticketKey: ticketKey);

  @override
  LedgerEntry note(String? note) => this(note: note);

  @override
  LedgerEntry createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LedgerEntry(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LedgerEntry(...).copyWith(id: 12, name: "My name")
  /// ````
  LedgerEntry call({
    Object? id = const $CopyWithPlaceholder(),
    Object? amount = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? ticketKey = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return LedgerEntry(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      amount: amount == const $CopyWithPlaceholder()
          ? _value.amount
          // ignore: cast_nullable_to_non_nullable
          : amount as int,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as LedgerEntryReasonEnum,
      ticketKey: ticketKey == const $CopyWithPlaceholder()
          ? _value.ticketKey
          // ignore: cast_nullable_to_non_nullable
          : ticketKey as String?,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $LedgerEntryCopyWith on LedgerEntry {
  /// Returns a callable class that can be used as follows: `instanceOfLedgerEntry.copyWith(...)` or like so:`instanceOfLedgerEntry.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LedgerEntryCWProxy get copyWith => _$LedgerEntryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LedgerEntry _$LedgerEntryFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('LedgerEntry', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['id', 'amount', 'reason', 'createdAt']);
  final val = LedgerEntry(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    amount: $checkedConvert('amount', (v) => (v as num).toInt()),
    reason: $checkedConvert(
      'reason',
      (v) => $enumDecode(_$LedgerEntryReasonEnumEnumMap, v),
    ),
    ticketKey: $checkedConvert('ticketKey', (v) => v as String?),
    note: $checkedConvert('note', (v) => v as String?),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$LedgerEntryToJson(LedgerEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'reason': _$LedgerEntryReasonEnumEnumMap[instance.reason]!,
      'ticketKey': ?instance.ticketKey,
      'note': ?instance.note,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$LedgerEntryReasonEnumEnumMap = {
  LedgerEntryReasonEnum.purchase: 'purchase',
  LedgerEntryReasonEnum.run: 'run',
  LedgerEntryReasonEnum.document: 'document',
  LedgerEntryReasonEnum.refund: 'refund',
  LedgerEntryReasonEnum.grant: 'grant',
};

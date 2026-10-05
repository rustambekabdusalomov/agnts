// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_item.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HistoryItemCWProxy {
  HistoryItem at(DateTime at);

  HistoryItem state(TicketState state);

  HistoryItem message(String message);

  HistoryItem origin(String origin);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HistoryItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HistoryItem(...).copyWith(id: 12, name: "My name")
  /// ````
  HistoryItem call({
    DateTime at,
    TicketState state,
    String message,
    String origin,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHistoryItem.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHistoryItem.copyWith.fieldName(...)`
class _$HistoryItemCWProxyImpl implements _$HistoryItemCWProxy {
  const _$HistoryItemCWProxyImpl(this._value);

  final HistoryItem _value;

  @override
  HistoryItem at(DateTime at) => this(at: at);

  @override
  HistoryItem state(TicketState state) => this(state: state);

  @override
  HistoryItem message(String message) => this(message: message);

  @override
  HistoryItem origin(String origin) => this(origin: origin);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HistoryItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HistoryItem(...).copyWith(id: 12, name: "My name")
  /// ````
  HistoryItem call({
    Object? at = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? origin = const $CopyWithPlaceholder(),
  }) {
    return HistoryItem(
      at: at == const $CopyWithPlaceholder()
          ? _value.at
          // ignore: cast_nullable_to_non_nullable
          : at as DateTime,
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as TicketState,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
      origin: origin == const $CopyWithPlaceholder()
          ? _value.origin
          // ignore: cast_nullable_to_non_nullable
          : origin as String,
    );
  }
}

extension $HistoryItemCopyWith on HistoryItem {
  /// Returns a callable class that can be used as follows: `instanceOfHistoryItem.copyWith(...)` or like so:`instanceOfHistoryItem.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HistoryItemCWProxy get copyWith => _$HistoryItemCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoryItem _$HistoryItemFromJson(Map<String, dynamic> json) => $checkedCreate(
  'HistoryItem',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['at', 'state', 'message', 'origin']);
    final val = HistoryItem(
      at: $checkedConvert('at', (v) => DateTime.parse(v as String)),
      state: $checkedConvert(
        'state',
        (v) => $enumDecode(_$TicketStateEnumMap, v),
      ),
      message: $checkedConvert('message', (v) => v as String),
      origin: $checkedConvert('origin', (v) => v as String),
    );
    return val;
  },
);

Map<String, dynamic> _$HistoryItemToJson(HistoryItem instance) =>
    <String, dynamic>{
      'at': instance.at.toIso8601String(),
      'state': _$TicketStateEnumMap[instance.state]!,
      'message': instance.message,
      'origin': instance.origin,
    };

const _$TicketStateEnumMap = {
  TicketState.new_: 'new',
  TicketState.analyzing: 'analyzing',
  TicketState.waitingForAnswers: 'waiting_for_answers',
  TicketState.coding: 'coding',
  TicketState.testing: 'testing',
  TicketState.waitingForReview: 'waiting_for_review',
  TicketState.pushing: 'pushing',
  TicketState.done: 'done',
  TicketState.rejected: 'rejected',
  TicketState.failed: 'failed',
  TicketState.rateLimited: 'rate_limited',
};

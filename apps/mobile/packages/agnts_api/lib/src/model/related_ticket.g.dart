// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'related_ticket.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RelatedTicketCWProxy {
  RelatedTicket key(String key);

  RelatedTicket title(String title);

  RelatedTicket state(TicketState state);

  RelatedTicket landed(bool landed);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RelatedTicket(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RelatedTicket(...).copyWith(id: 12, name: "My name")
  /// ````
  RelatedTicket call({
    String key,
    String title,
    TicketState state,
    bool landed,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRelatedTicket.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRelatedTicket.copyWith.fieldName(...)`
class _$RelatedTicketCWProxyImpl implements _$RelatedTicketCWProxy {
  const _$RelatedTicketCWProxyImpl(this._value);

  final RelatedTicket _value;

  @override
  RelatedTicket key(String key) => this(key: key);

  @override
  RelatedTicket title(String title) => this(title: title);

  @override
  RelatedTicket state(TicketState state) => this(state: state);

  @override
  RelatedTicket landed(bool landed) => this(landed: landed);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RelatedTicket(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RelatedTicket(...).copyWith(id: 12, name: "My name")
  /// ````
  RelatedTicket call({
    Object? key = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? landed = const $CopyWithPlaceholder(),
  }) {
    return RelatedTicket(
      key: key == const $CopyWithPlaceholder()
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as TicketState,
      landed: landed == const $CopyWithPlaceholder()
          ? _value.landed
          // ignore: cast_nullable_to_non_nullable
          : landed as bool,
    );
  }
}

extension $RelatedTicketCopyWith on RelatedTicket {
  /// Returns a callable class that can be used as follows: `instanceOfRelatedTicket.copyWith(...)` or like so:`instanceOfRelatedTicket.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RelatedTicketCWProxy get copyWith => _$RelatedTicketCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RelatedTicket _$RelatedTicketFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RelatedTicket', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['key', 'title', 'state', 'landed']);
      final val = RelatedTicket(
        key: $checkedConvert('key', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        state: $checkedConvert(
          'state',
          (v) => $enumDecode(_$TicketStateEnumMap, v),
        ),
        landed: $checkedConvert('landed', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$RelatedTicketToJson(RelatedTicket instance) =>
    <String, dynamic>{
      'key': instance.key,
      'title': instance.title,
      'state': _$TicketStateEnumMap[instance.state]!,
      'landed': instance.landed,
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commit_ticket.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CommitTicketCWProxy {
  CommitTicket key(String key);

  CommitTicket number(String? number);

  CommitTicket title(String title);

  CommitTicket state(TicketState state);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CommitTicket(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CommitTicket(...).copyWith(id: 12, name: "My name")
  /// ````
  CommitTicket call({
    String key,
    String? number,
    String title,
    TicketState state,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCommitTicket.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCommitTicket.copyWith.fieldName(...)`
class _$CommitTicketCWProxyImpl implements _$CommitTicketCWProxy {
  const _$CommitTicketCWProxyImpl(this._value);

  final CommitTicket _value;

  @override
  CommitTicket key(String key) => this(key: key);

  @override
  CommitTicket number(String? number) => this(number: number);

  @override
  CommitTicket title(String title) => this(title: title);

  @override
  CommitTicket state(TicketState state) => this(state: state);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CommitTicket(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CommitTicket(...).copyWith(id: 12, name: "My name")
  /// ````
  CommitTicket call({
    Object? key = const $CopyWithPlaceholder(),
    Object? number = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
  }) {
    return CommitTicket(
      key: key == const $CopyWithPlaceholder()
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
      number: number == const $CopyWithPlaceholder()
          ? _value.number
          // ignore: cast_nullable_to_non_nullable
          : number as String?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as TicketState,
    );
  }
}

extension $CommitTicketCopyWith on CommitTicket {
  /// Returns a callable class that can be used as follows: `instanceOfCommitTicket.copyWith(...)` or like so:`instanceOfCommitTicket.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CommitTicketCWProxy get copyWith => _$CommitTicketCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommitTicket _$CommitTicketFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CommitTicket', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['key', 'title', 'state']);
      final val = CommitTicket(
        key: $checkedConvert('key', (v) => v as String),
        number: $checkedConvert('number', (v) => v as String?),
        title: $checkedConvert('title', (v) => v as String),
        state: $checkedConvert(
          'state',
          (v) => $enumDecode(_$TicketStateEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CommitTicketToJson(CommitTicket instance) =>
    <String, dynamic>{
      'key': instance.key,
      'number': ?instance.number,
      'title': instance.title,
      'state': _$TicketStateEnumMap[instance.state]!,
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

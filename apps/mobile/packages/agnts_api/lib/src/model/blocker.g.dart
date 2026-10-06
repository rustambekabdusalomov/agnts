// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocker.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BlockerCWProxy {
  Blocker key(String key);

  Blocker title(String title);

  Blocker state(TicketState state);

  Blocker type(RelationType type);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Blocker(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Blocker(...).copyWith(id: 12, name: "My name")
  /// ````
  Blocker call({
    String key,
    String title,
    TicketState state,
    RelationType type,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBlocker.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBlocker.copyWith.fieldName(...)`
class _$BlockerCWProxyImpl implements _$BlockerCWProxy {
  const _$BlockerCWProxyImpl(this._value);

  final Blocker _value;

  @override
  Blocker key(String key) => this(key: key);

  @override
  Blocker title(String title) => this(title: title);

  @override
  Blocker state(TicketState state) => this(state: state);

  @override
  Blocker type(RelationType type) => this(type: type);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Blocker(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Blocker(...).copyWith(id: 12, name: "My name")
  /// ````
  Blocker call({
    Object? key = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
  }) {
    return Blocker(
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
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as RelationType,
    );
  }
}

extension $BlockerCopyWith on Blocker {
  /// Returns a callable class that can be used as follows: `instanceOfBlocker.copyWith(...)` or like so:`instanceOfBlocker.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BlockerCWProxy get copyWith => _$BlockerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Blocker _$BlockerFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Blocker', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['key', 'title', 'state', 'type']);
      final val = Blocker(
        key: $checkedConvert('key', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        state: $checkedConvert(
          'state',
          (v) => $enumDecode(_$TicketStateEnumMap, v),
        ),
        type: $checkedConvert(
          'type',
          (v) => $enumDecode(_$RelationTypeEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$BlockerToJson(Blocker instance) => <String, dynamic>{
  'key': instance.key,
  'title': instance.title,
  'state': _$TicketStateEnumMap[instance.state]!,
  'type': _$RelationTypeEnumMap[instance.type]!,
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

const _$RelationTypeEnumMap = {
  RelationType.dependsOn: 'depends_on',
  RelationType.conflicts: 'conflicts',
};

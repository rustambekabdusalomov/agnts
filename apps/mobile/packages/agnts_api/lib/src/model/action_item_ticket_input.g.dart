// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_item_ticket_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ActionItemTicketInputCWProxy {
  ActionItemTicketInput repoId(int? repoId);

  ActionItemTicketInput start(ActionItemTicketInputStartEnum? start);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActionItemTicketInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActionItemTicketInput(...).copyWith(id: 12, name: "My name")
  /// ````
  ActionItemTicketInput call({
    int? repoId,
    ActionItemTicketInputStartEnum? start,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfActionItemTicketInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfActionItemTicketInput.copyWith.fieldName(...)`
class _$ActionItemTicketInputCWProxyImpl
    implements _$ActionItemTicketInputCWProxy {
  const _$ActionItemTicketInputCWProxyImpl(this._value);

  final ActionItemTicketInput _value;

  @override
  ActionItemTicketInput repoId(int? repoId) => this(repoId: repoId);

  @override
  ActionItemTicketInput start(ActionItemTicketInputStartEnum? start) =>
      this(start: start);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActionItemTicketInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActionItemTicketInput(...).copyWith(id: 12, name: "My name")
  /// ````
  ActionItemTicketInput call({
    Object? repoId = const $CopyWithPlaceholder(),
    Object? start = const $CopyWithPlaceholder(),
  }) {
    return ActionItemTicketInput(
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int?,
      start: start == const $CopyWithPlaceholder()
          ? _value.start
          // ignore: cast_nullable_to_non_nullable
          : start as ActionItemTicketInputStartEnum?,
    );
  }
}

extension $ActionItemTicketInputCopyWith on ActionItemTicketInput {
  /// Returns a callable class that can be used as follows: `instanceOfActionItemTicketInput.copyWith(...)` or like so:`instanceOfActionItemTicketInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ActionItemTicketInputCWProxy get copyWith =>
      _$ActionItemTicketInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionItemTicketInput _$ActionItemTicketInputFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ActionItemTicketInput', json, ($checkedConvert) {
  final val = ActionItemTicketInput(
    repoId: $checkedConvert('repoId', (v) => (v as num?)?.toInt()),
    start: $checkedConvert(
      'start',
      (v) => $enumDecodeNullable(_$ActionItemTicketInputStartEnumEnumMap, v),
    ),
  );
  return val;
});

Map<String, dynamic> _$ActionItemTicketInputToJson(
  ActionItemTicketInput instance,
) => <String, dynamic>{
  'repoId': ?instance.repoId,
  'start': ?_$ActionItemTicketInputStartEnumEnumMap[instance.start],
};

const _$ActionItemTicketInputStartEnumEnumMap = {
  ActionItemTicketInputStartEnum.ask: 'ask',
  ActionItemTicketInputStartEnum.code: 'code',
  ActionItemTicketInputStartEnum.queue: 'queue',
};

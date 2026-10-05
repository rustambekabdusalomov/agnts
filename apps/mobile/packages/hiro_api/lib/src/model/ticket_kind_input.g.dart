// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_kind_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TicketKindInputCWProxy {
  TicketKindInput kind(TicketKindChoice kind);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TicketKindInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TicketKindInput(...).copyWith(id: 12, name: "My name")
  /// ````
  TicketKindInput call({TicketKindChoice kind});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTicketKindInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTicketKindInput.copyWith.fieldName(...)`
class _$TicketKindInputCWProxyImpl implements _$TicketKindInputCWProxy {
  const _$TicketKindInputCWProxyImpl(this._value);

  final TicketKindInput _value;

  @override
  TicketKindInput kind(TicketKindChoice kind) => this(kind: kind);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TicketKindInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TicketKindInput(...).copyWith(id: 12, name: "My name")
  /// ````
  TicketKindInput call({Object? kind = const $CopyWithPlaceholder()}) {
    return TicketKindInput(
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as TicketKindChoice,
    );
  }
}

extension $TicketKindInputCopyWith on TicketKindInput {
  /// Returns a callable class that can be used as follows: `instanceOfTicketKindInput.copyWith(...)` or like so:`instanceOfTicketKindInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TicketKindInputCWProxy get copyWith => _$TicketKindInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketKindInput _$TicketKindInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TicketKindInput', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['kind']);
      final val = TicketKindInput(
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$TicketKindChoiceEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$TicketKindInputToJson(TicketKindInput instance) =>
    <String, dynamic>{'kind': _$TicketKindChoiceEnumMap[instance.kind]!};

const _$TicketKindChoiceEnumMap = {
  TicketKindChoice.auto: 'auto',
  TicketKindChoice.code: 'code',
  TicketKindChoice.test: 'test',
  TicketKindChoice.plan: 'plan',
  TicketKindChoice.analysis: 'analysis',
  TicketKindChoice.bug: 'bug',
};

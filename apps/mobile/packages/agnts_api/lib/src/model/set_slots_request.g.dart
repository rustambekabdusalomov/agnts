// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_slots_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SetSlotsRequestCWProxy {
  SetSlotsRequest slots(int slots);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetSlotsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetSlotsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetSlotsRequest call({int slots});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSetSlotsRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSetSlotsRequest.copyWith.fieldName(...)`
class _$SetSlotsRequestCWProxyImpl implements _$SetSlotsRequestCWProxy {
  const _$SetSlotsRequestCWProxyImpl(this._value);

  final SetSlotsRequest _value;

  @override
  SetSlotsRequest slots(int slots) => this(slots: slots);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetSlotsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetSlotsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetSlotsRequest call({Object? slots = const $CopyWithPlaceholder()}) {
    return SetSlotsRequest(
      slots: slots == const $CopyWithPlaceholder()
          ? _value.slots
          // ignore: cast_nullable_to_non_nullable
          : slots as int,
    );
  }
}

extension $SetSlotsRequestCopyWith on SetSlotsRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSetSlotsRequest.copyWith(...)` or like so:`instanceOfSetSlotsRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SetSlotsRequestCWProxy get copyWith => _$SetSlotsRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetSlotsRequest _$SetSlotsRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SetSlotsRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['slots']);
      final val = SetSlotsRequest(
        slots: $checkedConvert('slots', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$SetSlotsRequestToJson(SetSlotsRequest instance) =>
    <String, dynamic>{'slots': instance.slots};

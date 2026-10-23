// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presence_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PresenceInputCWProxy {
  PresenceInput leaving(bool? leaving);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PresenceInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PresenceInput(...).copyWith(id: 12, name: "My name")
  /// ````
  PresenceInput call({bool? leaving});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPresenceInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPresenceInput.copyWith.fieldName(...)`
class _$PresenceInputCWProxyImpl implements _$PresenceInputCWProxy {
  const _$PresenceInputCWProxyImpl(this._value);

  final PresenceInput _value;

  @override
  PresenceInput leaving(bool? leaving) => this(leaving: leaving);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PresenceInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PresenceInput(...).copyWith(id: 12, name: "My name")
  /// ````
  PresenceInput call({Object? leaving = const $CopyWithPlaceholder()}) {
    return PresenceInput(
      leaving: leaving == const $CopyWithPlaceholder()
          ? _value.leaving
          // ignore: cast_nullable_to_non_nullable
          : leaving as bool?,
    );
  }
}

extension $PresenceInputCopyWith on PresenceInput {
  /// Returns a callable class that can be used as follows: `instanceOfPresenceInput.copyWith(...)` or like so:`instanceOfPresenceInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PresenceInputCWProxy get copyWith => _$PresenceInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PresenceInput _$PresenceInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PresenceInput', json, ($checkedConvert) {
      final val = PresenceInput(
        leaving: $checkedConvert('leaving', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$PresenceInputToJson(PresenceInput instance) =>
    <String, dynamic>{'leaving': ?instance.leaving};

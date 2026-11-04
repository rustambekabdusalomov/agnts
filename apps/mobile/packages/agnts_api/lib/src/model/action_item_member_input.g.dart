// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_item_member_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ActionItemMemberInputCWProxy {
  ActionItemMemberInput userId(int userId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActionItemMemberInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActionItemMemberInput(...).copyWith(id: 12, name: "My name")
  /// ````
  ActionItemMemberInput call({int userId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfActionItemMemberInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfActionItemMemberInput.copyWith.fieldName(...)`
class _$ActionItemMemberInputCWProxyImpl
    implements _$ActionItemMemberInputCWProxy {
  const _$ActionItemMemberInputCWProxyImpl(this._value);

  final ActionItemMemberInput _value;

  @override
  ActionItemMemberInput userId(int userId) => this(userId: userId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActionItemMemberInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActionItemMemberInput(...).copyWith(id: 12, name: "My name")
  /// ````
  ActionItemMemberInput call({Object? userId = const $CopyWithPlaceholder()}) {
    return ActionItemMemberInput(
      userId: userId == const $CopyWithPlaceholder()
          ? _value.userId
          // ignore: cast_nullable_to_non_nullable
          : userId as int,
    );
  }
}

extension $ActionItemMemberInputCopyWith on ActionItemMemberInput {
  /// Returns a callable class that can be used as follows: `instanceOfActionItemMemberInput.copyWith(...)` or like so:`instanceOfActionItemMemberInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ActionItemMemberInputCWProxy get copyWith =>
      _$ActionItemMemberInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionItemMemberInput _$ActionItemMemberInputFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ActionItemMemberInput', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['userId']);
  final val = ActionItemMemberInput(
    userId: $checkedConvert('userId', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$ActionItemMemberInputToJson(
  ActionItemMemberInput instance,
) => <String, dynamic>{'userId': instance.userId};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'try_enforce_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TryEnforceInputCWProxy {
  TryEnforceInput enforce(RuleEnforce enforce);

  TryEnforceInput repoId(int? repoId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TryEnforceInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TryEnforceInput(...).copyWith(id: 12, name: "My name")
  /// ````
  TryEnforceInput call({RuleEnforce enforce, int? repoId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTryEnforceInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTryEnforceInput.copyWith.fieldName(...)`
class _$TryEnforceInputCWProxyImpl implements _$TryEnforceInputCWProxy {
  const _$TryEnforceInputCWProxyImpl(this._value);

  final TryEnforceInput _value;

  @override
  TryEnforceInput enforce(RuleEnforce enforce) => this(enforce: enforce);

  @override
  TryEnforceInput repoId(int? repoId) => this(repoId: repoId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TryEnforceInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TryEnforceInput(...).copyWith(id: 12, name: "My name")
  /// ````
  TryEnforceInput call({
    Object? enforce = const $CopyWithPlaceholder(),
    Object? repoId = const $CopyWithPlaceholder(),
  }) {
    return TryEnforceInput(
      enforce: enforce == const $CopyWithPlaceholder()
          ? _value.enforce
          // ignore: cast_nullable_to_non_nullable
          : enforce as RuleEnforce,
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int?,
    );
  }
}

extension $TryEnforceInputCopyWith on TryEnforceInput {
  /// Returns a callable class that can be used as follows: `instanceOfTryEnforceInput.copyWith(...)` or like so:`instanceOfTryEnforceInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TryEnforceInputCWProxy get copyWith => _$TryEnforceInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TryEnforceInput _$TryEnforceInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TryEnforceInput', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['enforce']);
      final val = TryEnforceInput(
        enforce: $checkedConvert(
          'enforce',
          (v) => RuleEnforce.fromJson(v as Map<String, dynamic>),
        ),
        repoId: $checkedConvert('repoId', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$TryEnforceInputToJson(TryEnforceInput instance) =>
    <String, dynamic>{
      'enforce': instance.enforce.toJson(),
      'repoId': ?instance.repoId,
    };

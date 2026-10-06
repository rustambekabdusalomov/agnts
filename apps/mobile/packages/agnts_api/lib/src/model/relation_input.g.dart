// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relation_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RelationInputCWProxy {
  RelationInput otherKey(String otherKey);

  RelationInput type(RelationType type);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RelationInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RelationInput(...).copyWith(id: 12, name: "My name")
  /// ````
  RelationInput call({String otherKey, RelationType type});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRelationInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRelationInput.copyWith.fieldName(...)`
class _$RelationInputCWProxyImpl implements _$RelationInputCWProxy {
  const _$RelationInputCWProxyImpl(this._value);

  final RelationInput _value;

  @override
  RelationInput otherKey(String otherKey) => this(otherKey: otherKey);

  @override
  RelationInput type(RelationType type) => this(type: type);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RelationInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RelationInput(...).copyWith(id: 12, name: "My name")
  /// ````
  RelationInput call({
    Object? otherKey = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
  }) {
    return RelationInput(
      otherKey: otherKey == const $CopyWithPlaceholder()
          ? _value.otherKey
          // ignore: cast_nullable_to_non_nullable
          : otherKey as String,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as RelationType,
    );
  }
}

extension $RelationInputCopyWith on RelationInput {
  /// Returns a callable class that can be used as follows: `instanceOfRelationInput.copyWith(...)` or like so:`instanceOfRelationInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RelationInputCWProxy get copyWith => _$RelationInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RelationInput _$RelationInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RelationInput', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['otherKey', 'type']);
      final val = RelationInput(
        otherKey: $checkedConvert('otherKey', (v) => v as String),
        type: $checkedConvert(
          'type',
          (v) => $enumDecode(_$RelationTypeEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$RelationInputToJson(RelationInput instance) =>
    <String, dynamic>{
      'otherKey': instance.otherKey,
      'type': _$RelationTypeEnumMap[instance.type]!,
    };

const _$RelationTypeEnumMap = {
  RelationType.dependsOn: 'depends_on',
  RelationType.conflicts: 'conflicts',
};

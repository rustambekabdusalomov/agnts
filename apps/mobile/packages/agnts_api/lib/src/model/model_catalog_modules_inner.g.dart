// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_catalog_modules_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ModelCatalogModulesInnerCWProxy {
  ModelCatalogModulesInner id(ModelCatalogModulesInnerIdEnum id);

  ModelCatalogModulesInner label(String label);

  ModelCatalogModulesInner light(String? light);

  ModelCatalogModulesInner strong(String? strong);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ModelCatalogModulesInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ModelCatalogModulesInner(...).copyWith(id: 12, name: "My name")
  /// ````
  ModelCatalogModulesInner call({
    ModelCatalogModulesInnerIdEnum id,
    String label,
    String? light,
    String? strong,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfModelCatalogModulesInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfModelCatalogModulesInner.copyWith.fieldName(...)`
class _$ModelCatalogModulesInnerCWProxyImpl
    implements _$ModelCatalogModulesInnerCWProxy {
  const _$ModelCatalogModulesInnerCWProxyImpl(this._value);

  final ModelCatalogModulesInner _value;

  @override
  ModelCatalogModulesInner id(ModelCatalogModulesInnerIdEnum id) =>
      this(id: id);

  @override
  ModelCatalogModulesInner label(String label) => this(label: label);

  @override
  ModelCatalogModulesInner light(String? light) => this(light: light);

  @override
  ModelCatalogModulesInner strong(String? strong) => this(strong: strong);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ModelCatalogModulesInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ModelCatalogModulesInner(...).copyWith(id: 12, name: "My name")
  /// ````
  ModelCatalogModulesInner call({
    Object? id = const $CopyWithPlaceholder(),
    Object? label = const $CopyWithPlaceholder(),
    Object? light = const $CopyWithPlaceholder(),
    Object? strong = const $CopyWithPlaceholder(),
  }) {
    return ModelCatalogModulesInner(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as ModelCatalogModulesInnerIdEnum,
      label: label == const $CopyWithPlaceholder()
          ? _value.label
          // ignore: cast_nullable_to_non_nullable
          : label as String,
      light: light == const $CopyWithPlaceholder()
          ? _value.light
          // ignore: cast_nullable_to_non_nullable
          : light as String?,
      strong: strong == const $CopyWithPlaceholder()
          ? _value.strong
          // ignore: cast_nullable_to_non_nullable
          : strong as String?,
    );
  }
}

extension $ModelCatalogModulesInnerCopyWith on ModelCatalogModulesInner {
  /// Returns a callable class that can be used as follows: `instanceOfModelCatalogModulesInner.copyWith(...)` or like so:`instanceOfModelCatalogModulesInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ModelCatalogModulesInnerCWProxy get copyWith =>
      _$ModelCatalogModulesInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModelCatalogModulesInner _$ModelCatalogModulesInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ModelCatalogModulesInner', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['id', 'label']);
  final val = ModelCatalogModulesInner(
    id: $checkedConvert(
      'id',
      (v) => $enumDecode(_$ModelCatalogModulesInnerIdEnumEnumMap, v),
    ),
    label: $checkedConvert('label', (v) => v as String),
    light: $checkedConvert('light', (v) => v as String?),
    strong: $checkedConvert('strong', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$ModelCatalogModulesInnerToJson(
  ModelCatalogModulesInner instance,
) => <String, dynamic>{
  'id': _$ModelCatalogModulesInnerIdEnumEnumMap[instance.id]!,
  'label': instance.label,
  'light': ?instance.light,
  'strong': ?instance.strong,
};

const _$ModelCatalogModulesInnerIdEnumEnumMap = {
  ModelCatalogModulesInnerIdEnum.muse: 'muse',
  ModelCatalogModulesInnerIdEnum.claude: 'claude',
  ModelCatalogModulesInnerIdEnum.codex: 'codex',
};

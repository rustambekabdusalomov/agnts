// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_catalog_tiers_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ModelCatalogTiersInnerCWProxy {
  ModelCatalogTiersInner id(String id);

  ModelCatalogTiersInner label(String label);

  ModelCatalogTiersInner strong(bool strong);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ModelCatalogTiersInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ModelCatalogTiersInner(...).copyWith(id: 12, name: "My name")
  /// ````
  ModelCatalogTiersInner call({String id, String label, bool strong});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfModelCatalogTiersInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfModelCatalogTiersInner.copyWith.fieldName(...)`
class _$ModelCatalogTiersInnerCWProxyImpl
    implements _$ModelCatalogTiersInnerCWProxy {
  const _$ModelCatalogTiersInnerCWProxyImpl(this._value);

  final ModelCatalogTiersInner _value;

  @override
  ModelCatalogTiersInner id(String id) => this(id: id);

  @override
  ModelCatalogTiersInner label(String label) => this(label: label);

  @override
  ModelCatalogTiersInner strong(bool strong) => this(strong: strong);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ModelCatalogTiersInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ModelCatalogTiersInner(...).copyWith(id: 12, name: "My name")
  /// ````
  ModelCatalogTiersInner call({
    Object? id = const $CopyWithPlaceholder(),
    Object? label = const $CopyWithPlaceholder(),
    Object? strong = const $CopyWithPlaceholder(),
  }) {
    return ModelCatalogTiersInner(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      label: label == const $CopyWithPlaceholder()
          ? _value.label
          // ignore: cast_nullable_to_non_nullable
          : label as String,
      strong: strong == const $CopyWithPlaceholder()
          ? _value.strong
          // ignore: cast_nullable_to_non_nullable
          : strong as bool,
    );
  }
}

extension $ModelCatalogTiersInnerCopyWith on ModelCatalogTiersInner {
  /// Returns a callable class that can be used as follows: `instanceOfModelCatalogTiersInner.copyWith(...)` or like so:`instanceOfModelCatalogTiersInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ModelCatalogTiersInnerCWProxy get copyWith =>
      _$ModelCatalogTiersInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModelCatalogTiersInner _$ModelCatalogTiersInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ModelCatalogTiersInner', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['id', 'label', 'strong']);
  final val = ModelCatalogTiersInner(
    id: $checkedConvert('id', (v) => v as String),
    label: $checkedConvert('label', (v) => v as String),
    strong: $checkedConvert('strong', (v) => v as bool),
  );
  return val;
});

Map<String, dynamic> _$ModelCatalogTiersInnerToJson(
  ModelCatalogTiersInner instance,
) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'strong': instance.strong,
};

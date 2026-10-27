// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_catalog_models_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ModelCatalogModelsInnerCWProxy {
  ModelCatalogModelsInner id(String id);

  ModelCatalogModelsInner label(String label);

  ModelCatalogModelsInner provider(
    ModelCatalogModelsInnerProviderEnum provider,
  );

  ModelCatalogModelsInner strong(bool strong);

  ModelCatalogModelsInner inputPerMillionUSD(num? inputPerMillionUSD);

  ModelCatalogModelsInner outputPerMillionUSD(num? outputPerMillionUSD);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ModelCatalogModelsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ModelCatalogModelsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  ModelCatalogModelsInner call({
    String id,
    String label,
    ModelCatalogModelsInnerProviderEnum provider,
    bool strong,
    num? inputPerMillionUSD,
    num? outputPerMillionUSD,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfModelCatalogModelsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfModelCatalogModelsInner.copyWith.fieldName(...)`
class _$ModelCatalogModelsInnerCWProxyImpl
    implements _$ModelCatalogModelsInnerCWProxy {
  const _$ModelCatalogModelsInnerCWProxyImpl(this._value);

  final ModelCatalogModelsInner _value;

  @override
  ModelCatalogModelsInner id(String id) => this(id: id);

  @override
  ModelCatalogModelsInner label(String label) => this(label: label);

  @override
  ModelCatalogModelsInner provider(
    ModelCatalogModelsInnerProviderEnum provider,
  ) => this(provider: provider);

  @override
  ModelCatalogModelsInner strong(bool strong) => this(strong: strong);

  @override
  ModelCatalogModelsInner inputPerMillionUSD(num? inputPerMillionUSD) =>
      this(inputPerMillionUSD: inputPerMillionUSD);

  @override
  ModelCatalogModelsInner outputPerMillionUSD(num? outputPerMillionUSD) =>
      this(outputPerMillionUSD: outputPerMillionUSD);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ModelCatalogModelsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ModelCatalogModelsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  ModelCatalogModelsInner call({
    Object? id = const $CopyWithPlaceholder(),
    Object? label = const $CopyWithPlaceholder(),
    Object? provider = const $CopyWithPlaceholder(),
    Object? strong = const $CopyWithPlaceholder(),
    Object? inputPerMillionUSD = const $CopyWithPlaceholder(),
    Object? outputPerMillionUSD = const $CopyWithPlaceholder(),
  }) {
    return ModelCatalogModelsInner(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      label: label == const $CopyWithPlaceholder()
          ? _value.label
          // ignore: cast_nullable_to_non_nullable
          : label as String,
      provider: provider == const $CopyWithPlaceholder()
          ? _value.provider
          // ignore: cast_nullable_to_non_nullable
          : provider as ModelCatalogModelsInnerProviderEnum,
      strong: strong == const $CopyWithPlaceholder()
          ? _value.strong
          // ignore: cast_nullable_to_non_nullable
          : strong as bool,
      inputPerMillionUSD: inputPerMillionUSD == const $CopyWithPlaceholder()
          ? _value.inputPerMillionUSD
          // ignore: cast_nullable_to_non_nullable
          : inputPerMillionUSD as num?,
      outputPerMillionUSD: outputPerMillionUSD == const $CopyWithPlaceholder()
          ? _value.outputPerMillionUSD
          // ignore: cast_nullable_to_non_nullable
          : outputPerMillionUSD as num?,
    );
  }
}

extension $ModelCatalogModelsInnerCopyWith on ModelCatalogModelsInner {
  /// Returns a callable class that can be used as follows: `instanceOfModelCatalogModelsInner.copyWith(...)` or like so:`instanceOfModelCatalogModelsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ModelCatalogModelsInnerCWProxy get copyWith =>
      _$ModelCatalogModelsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModelCatalogModelsInner _$ModelCatalogModelsInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ModelCatalogModelsInner', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['id', 'label', 'provider', 'strong']);
  final val = ModelCatalogModelsInner(
    id: $checkedConvert('id', (v) => v as String),
    label: $checkedConvert('label', (v) => v as String),
    provider: $checkedConvert(
      'provider',
      (v) => $enumDecode(_$ModelCatalogModelsInnerProviderEnumEnumMap, v),
    ),
    strong: $checkedConvert('strong', (v) => v as bool),
    inputPerMillionUSD: $checkedConvert('inputPerMillionUSD', (v) => v as num?),
    outputPerMillionUSD: $checkedConvert(
      'outputPerMillionUSD',
      (v) => v as num?,
    ),
  );
  return val;
});

Map<String, dynamic> _$ModelCatalogModelsInnerToJson(
  ModelCatalogModelsInner instance,
) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'provider': _$ModelCatalogModelsInnerProviderEnumEnumMap[instance.provider]!,
  'strong': instance.strong,
  'inputPerMillionUSD': ?instance.inputPerMillionUSD,
  'outputPerMillionUSD': ?instance.outputPerMillionUSD,
};

const _$ModelCatalogModelsInnerProviderEnumEnumMap = {
  ModelCatalogModelsInnerProviderEnum.muse: 'muse',
  ModelCatalogModelsInnerProviderEnum.claude: 'claude',
  ModelCatalogModelsInnerProviderEnum.codex: 'codex',
};

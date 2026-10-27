// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_catalog.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ModelCatalogCWProxy {
  ModelCatalog providers(List<ModelCatalogProvidersEnum> providers);

  ModelCatalog primary(ModelCatalogPrimaryEnum primary);

  ModelCatalog models(List<ModelCatalogModelsInner> models);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ModelCatalog(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ModelCatalog(...).copyWith(id: 12, name: "My name")
  /// ````
  ModelCatalog call({
    List<ModelCatalogProvidersEnum> providers,
    ModelCatalogPrimaryEnum primary,
    List<ModelCatalogModelsInner> models,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfModelCatalog.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfModelCatalog.copyWith.fieldName(...)`
class _$ModelCatalogCWProxyImpl implements _$ModelCatalogCWProxy {
  const _$ModelCatalogCWProxyImpl(this._value);

  final ModelCatalog _value;

  @override
  ModelCatalog providers(List<ModelCatalogProvidersEnum> providers) =>
      this(providers: providers);

  @override
  ModelCatalog primary(ModelCatalogPrimaryEnum primary) =>
      this(primary: primary);

  @override
  ModelCatalog models(List<ModelCatalogModelsInner> models) =>
      this(models: models);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ModelCatalog(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ModelCatalog(...).copyWith(id: 12, name: "My name")
  /// ````
  ModelCatalog call({
    Object? providers = const $CopyWithPlaceholder(),
    Object? primary = const $CopyWithPlaceholder(),
    Object? models = const $CopyWithPlaceholder(),
  }) {
    return ModelCatalog(
      providers: providers == const $CopyWithPlaceholder()
          ? _value.providers
          // ignore: cast_nullable_to_non_nullable
          : providers as List<ModelCatalogProvidersEnum>,
      primary: primary == const $CopyWithPlaceholder()
          ? _value.primary
          // ignore: cast_nullable_to_non_nullable
          : primary as ModelCatalogPrimaryEnum,
      models: models == const $CopyWithPlaceholder()
          ? _value.models
          // ignore: cast_nullable_to_non_nullable
          : models as List<ModelCatalogModelsInner>,
    );
  }
}

extension $ModelCatalogCopyWith on ModelCatalog {
  /// Returns a callable class that can be used as follows: `instanceOfModelCatalog.copyWith(...)` or like so:`instanceOfModelCatalog.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ModelCatalogCWProxy get copyWith => _$ModelCatalogCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModelCatalog _$ModelCatalogFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ModelCatalog', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['providers', 'primary', 'models']);
      final val = ModelCatalog(
        providers: $checkedConvert(
          'providers',
          (v) => (v as List<dynamic>)
              .map((e) => $enumDecode(_$ModelCatalogProvidersEnumEnumMap, e))
              .toList(),
        ),
        primary: $checkedConvert(
          'primary',
          (v) => $enumDecode(_$ModelCatalogPrimaryEnumEnumMap, v),
        ),
        models: $checkedConvert(
          'models',
          (v) => (v as List<dynamic>)
              .map(
                (e) =>
                    ModelCatalogModelsInner.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ModelCatalogToJson(ModelCatalog instance) =>
    <String, dynamic>{
      'providers': instance.providers
          .map((e) => _$ModelCatalogProvidersEnumEnumMap[e]!)
          .toList(),
      'primary': _$ModelCatalogPrimaryEnumEnumMap[instance.primary]!,
      'models': instance.models.map((e) => e.toJson()).toList(),
    };

const _$ModelCatalogProvidersEnumEnumMap = {
  ModelCatalogProvidersEnum.muse: 'muse',
  ModelCatalogProvidersEnum.claude: 'claude',
  ModelCatalogProvidersEnum.codex: 'codex',
};

const _$ModelCatalogPrimaryEnumEnumMap = {
  ModelCatalogPrimaryEnum.muse: 'muse',
  ModelCatalogPrimaryEnum.claude: 'claude',
  ModelCatalogPrimaryEnum.codex: 'codex',
};

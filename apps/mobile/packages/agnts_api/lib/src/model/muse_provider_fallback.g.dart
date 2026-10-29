// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muse_provider_fallback.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MuseProviderFallbackCWProxy {
  MuseProviderFallback name(String name);

  MuseProviderFallback model(String model);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MuseProviderFallback(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MuseProviderFallback(...).copyWith(id: 12, name: "My name")
  /// ````
  MuseProviderFallback call({String name, String model});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMuseProviderFallback.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMuseProviderFallback.copyWith.fieldName(...)`
class _$MuseProviderFallbackCWProxyImpl
    implements _$MuseProviderFallbackCWProxy {
  const _$MuseProviderFallbackCWProxyImpl(this._value);

  final MuseProviderFallback _value;

  @override
  MuseProviderFallback name(String name) => this(name: name);

  @override
  MuseProviderFallback model(String model) => this(model: model);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MuseProviderFallback(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MuseProviderFallback(...).copyWith(id: 12, name: "My name")
  /// ````
  MuseProviderFallback call({
    Object? name = const $CopyWithPlaceholder(),
    Object? model = const $CopyWithPlaceholder(),
  }) {
    return MuseProviderFallback(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      model: model == const $CopyWithPlaceholder()
          ? _value.model
          // ignore: cast_nullable_to_non_nullable
          : model as String,
    );
  }
}

extension $MuseProviderFallbackCopyWith on MuseProviderFallback {
  /// Returns a callable class that can be used as follows: `instanceOfMuseProviderFallback.copyWith(...)` or like so:`instanceOfMuseProviderFallback.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MuseProviderFallbackCWProxy get copyWith =>
      _$MuseProviderFallbackCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MuseProviderFallback _$MuseProviderFallbackFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MuseProviderFallback', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['name', 'model']);
  final val = MuseProviderFallback(
    name: $checkedConvert('name', (v) => v as String),
    model: $checkedConvert('model', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$MuseProviderFallbackToJson(
  MuseProviderFallback instance,
) => <String, dynamic>{'name': instance.name, 'model': instance.model};

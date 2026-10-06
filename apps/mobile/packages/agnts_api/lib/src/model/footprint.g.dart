// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'footprint.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FootprintCWProxy {
  Footprint files(List<String> files);

  Footprint modules(List<String>? modules);

  Footprint provides(List<String>? provides);

  Footprint consumes(List<String>? consumes);

  Footprint migrations(bool? migrations);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Footprint(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Footprint(...).copyWith(id: 12, name: "My name")
  /// ````
  Footprint call({
    List<String> files,
    List<String>? modules,
    List<String>? provides,
    List<String>? consumes,
    bool? migrations,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFootprint.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFootprint.copyWith.fieldName(...)`
class _$FootprintCWProxyImpl implements _$FootprintCWProxy {
  const _$FootprintCWProxyImpl(this._value);

  final Footprint _value;

  @override
  Footprint files(List<String> files) => this(files: files);

  @override
  Footprint modules(List<String>? modules) => this(modules: modules);

  @override
  Footprint provides(List<String>? provides) => this(provides: provides);

  @override
  Footprint consumes(List<String>? consumes) => this(consumes: consumes);

  @override
  Footprint migrations(bool? migrations) => this(migrations: migrations);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Footprint(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Footprint(...).copyWith(id: 12, name: "My name")
  /// ````
  Footprint call({
    Object? files = const $CopyWithPlaceholder(),
    Object? modules = const $CopyWithPlaceholder(),
    Object? provides = const $CopyWithPlaceholder(),
    Object? consumes = const $CopyWithPlaceholder(),
    Object? migrations = const $CopyWithPlaceholder(),
  }) {
    return Footprint(
      files: files == const $CopyWithPlaceholder()
          ? _value.files
          // ignore: cast_nullable_to_non_nullable
          : files as List<String>,
      modules: modules == const $CopyWithPlaceholder()
          ? _value.modules
          // ignore: cast_nullable_to_non_nullable
          : modules as List<String>?,
      provides: provides == const $CopyWithPlaceholder()
          ? _value.provides
          // ignore: cast_nullable_to_non_nullable
          : provides as List<String>?,
      consumes: consumes == const $CopyWithPlaceholder()
          ? _value.consumes
          // ignore: cast_nullable_to_non_nullable
          : consumes as List<String>?,
      migrations: migrations == const $CopyWithPlaceholder()
          ? _value.migrations
          // ignore: cast_nullable_to_non_nullable
          : migrations as bool?,
    );
  }
}

extension $FootprintCopyWith on Footprint {
  /// Returns a callable class that can be used as follows: `instanceOfFootprint.copyWith(...)` or like so:`instanceOfFootprint.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FootprintCWProxy get copyWith => _$FootprintCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Footprint _$FootprintFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Footprint', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['files']);
      final val = Footprint(
        files: $checkedConvert(
          'files',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        modules: $checkedConvert(
          'modules',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        provides: $checkedConvert(
          'provides',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        consumes: $checkedConvert(
          'consumes',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        migrations: $checkedConvert('migrations', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$FootprintToJson(Footprint instance) => <String, dynamic>{
  'files': instance.files,
  'modules': ?instance.modules,
  'provides': ?instance.provides,
  'consumes': ?instance.consumes,
  'migrations': ?instance.migrations,
};

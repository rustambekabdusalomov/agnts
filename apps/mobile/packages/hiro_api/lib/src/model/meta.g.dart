// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MetaCWProxy {
  Meta version(String version);

  Meta commit(String commit);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Meta(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Meta(...).copyWith(id: 12, name: "My name")
  /// ````
  Meta call({String version, String commit});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeta.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeta.copyWith.fieldName(...)`
class _$MetaCWProxyImpl implements _$MetaCWProxy {
  const _$MetaCWProxyImpl(this._value);

  final Meta _value;

  @override
  Meta version(String version) => this(version: version);

  @override
  Meta commit(String commit) => this(commit: commit);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Meta(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Meta(...).copyWith(id: 12, name: "My name")
  /// ````
  Meta call({
    Object? version = const $CopyWithPlaceholder(),
    Object? commit = const $CopyWithPlaceholder(),
  }) {
    return Meta(
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as String,
      commit: commit == const $CopyWithPlaceholder()
          ? _value.commit
          // ignore: cast_nullable_to_non_nullable
          : commit as String,
    );
  }
}

extension $MetaCopyWith on Meta {
  /// Returns a callable class that can be used as follows: `instanceOfMeta.copyWith(...)` or like so:`instanceOfMeta.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MetaCWProxy get copyWith => _$MetaCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Meta _$MetaFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Meta', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['version', 'commit']);
      final val = Meta(
        version: $checkedConvert('version', (v) => v as String),
        commit: $checkedConvert('commit', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$MetaToJson(Meta instance) => <String, dynamic>{
  'version': instance.version,
  'commit': instance.commit,
};

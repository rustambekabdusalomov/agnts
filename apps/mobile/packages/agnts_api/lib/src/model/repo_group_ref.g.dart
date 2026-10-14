// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_group_ref.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RepoGroupRefCWProxy {
  RepoGroupRef id(int id);

  RepoGroupRef name(String name);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoGroupRef(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoGroupRef(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoGroupRef call({int id, String name});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRepoGroupRef.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRepoGroupRef.copyWith.fieldName(...)`
class _$RepoGroupRefCWProxyImpl implements _$RepoGroupRefCWProxy {
  const _$RepoGroupRefCWProxyImpl(this._value);

  final RepoGroupRef _value;

  @override
  RepoGroupRef id(int id) => this(id: id);

  @override
  RepoGroupRef name(String name) => this(name: name);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoGroupRef(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoGroupRef(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoGroupRef call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
  }) {
    return RepoGroupRef(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
    );
  }
}

extension $RepoGroupRefCopyWith on RepoGroupRef {
  /// Returns a callable class that can be used as follows: `instanceOfRepoGroupRef.copyWith(...)` or like so:`instanceOfRepoGroupRef.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RepoGroupRefCWProxy get copyWith => _$RepoGroupRefCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepoGroupRef _$RepoGroupRefFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RepoGroupRef', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'name']);
      final val = RepoGroupRef(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        name: $checkedConvert('name', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$RepoGroupRefToJson(RepoGroupRef instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

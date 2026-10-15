// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tree_entry.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TreeEntryCWProxy {
  TreeEntry name(String name);

  TreeEntry path(String path);

  TreeEntry type(TreeEntryTypeEnum type);

  TreeEntry size(int? size);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TreeEntry(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TreeEntry(...).copyWith(id: 12, name: "My name")
  /// ````
  TreeEntry call({String name, String path, TreeEntryTypeEnum type, int? size});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTreeEntry.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTreeEntry.copyWith.fieldName(...)`
class _$TreeEntryCWProxyImpl implements _$TreeEntryCWProxy {
  const _$TreeEntryCWProxyImpl(this._value);

  final TreeEntry _value;

  @override
  TreeEntry name(String name) => this(name: name);

  @override
  TreeEntry path(String path) => this(path: path);

  @override
  TreeEntry type(TreeEntryTypeEnum type) => this(type: type);

  @override
  TreeEntry size(int? size) => this(size: size);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TreeEntry(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TreeEntry(...).copyWith(id: 12, name: "My name")
  /// ````
  TreeEntry call({
    Object? name = const $CopyWithPlaceholder(),
    Object? path = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? size = const $CopyWithPlaceholder(),
  }) {
    return TreeEntry(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      path: path == const $CopyWithPlaceholder()
          ? _value.path
          // ignore: cast_nullable_to_non_nullable
          : path as String,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as TreeEntryTypeEnum,
      size: size == const $CopyWithPlaceholder()
          ? _value.size
          // ignore: cast_nullable_to_non_nullable
          : size as int?,
    );
  }
}

extension $TreeEntryCopyWith on TreeEntry {
  /// Returns a callable class that can be used as follows: `instanceOfTreeEntry.copyWith(...)` or like so:`instanceOfTreeEntry.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TreeEntryCWProxy get copyWith => _$TreeEntryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TreeEntry _$TreeEntryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TreeEntry', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['name', 'path', 'type']);
      final val = TreeEntry(
        name: $checkedConvert('name', (v) => v as String),
        path: $checkedConvert('path', (v) => v as String),
        type: $checkedConvert(
          'type',
          (v) => $enumDecode(_$TreeEntryTypeEnumEnumMap, v),
        ),
        size: $checkedConvert('size', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$TreeEntryToJson(TreeEntry instance) => <String, dynamic>{
  'name': instance.name,
  'path': instance.path,
  'type': _$TreeEntryTypeEnumEnumMap[instance.type]!,
  'size': ?instance.size,
};

const _$TreeEntryTypeEnumEnumMap = {
  TreeEntryTypeEnum.dir: 'dir',
  TreeEntryTypeEnum.file: 'file',
  TreeEntryTypeEnum.symlink: 'symlink',
  TreeEntryTypeEnum.submodule: 'submodule',
};

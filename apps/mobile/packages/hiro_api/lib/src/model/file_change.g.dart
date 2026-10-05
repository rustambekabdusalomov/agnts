// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_change.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FileChangeCWProxy {
  FileChange path(String path);

  FileChange add(int add);

  FileChange del(int del);

  FileChange diff(String diff);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FileChange(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FileChange(...).copyWith(id: 12, name: "My name")
  /// ````
  FileChange call({String path, int add, int del, String diff});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFileChange.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFileChange.copyWith.fieldName(...)`
class _$FileChangeCWProxyImpl implements _$FileChangeCWProxy {
  const _$FileChangeCWProxyImpl(this._value);

  final FileChange _value;

  @override
  FileChange path(String path) => this(path: path);

  @override
  FileChange add(int add) => this(add: add);

  @override
  FileChange del(int del) => this(del: del);

  @override
  FileChange diff(String diff) => this(diff: diff);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FileChange(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FileChange(...).copyWith(id: 12, name: "My name")
  /// ````
  FileChange call({
    Object? path = const $CopyWithPlaceholder(),
    Object? add = const $CopyWithPlaceholder(),
    Object? del = const $CopyWithPlaceholder(),
    Object? diff = const $CopyWithPlaceholder(),
  }) {
    return FileChange(
      path: path == const $CopyWithPlaceholder()
          ? _value.path
          // ignore: cast_nullable_to_non_nullable
          : path as String,
      add: add == const $CopyWithPlaceholder()
          ? _value.add
          // ignore: cast_nullable_to_non_nullable
          : add as int,
      del: del == const $CopyWithPlaceholder()
          ? _value.del
          // ignore: cast_nullable_to_non_nullable
          : del as int,
      diff: diff == const $CopyWithPlaceholder()
          ? _value.diff
          // ignore: cast_nullable_to_non_nullable
          : diff as String,
    );
  }
}

extension $FileChangeCopyWith on FileChange {
  /// Returns a callable class that can be used as follows: `instanceOfFileChange.copyWith(...)` or like so:`instanceOfFileChange.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FileChangeCWProxy get copyWith => _$FileChangeCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileChange _$FileChangeFromJson(Map<String, dynamic> json) =>
    $checkedCreate('FileChange', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['path', 'add', 'del', 'diff']);
      final val = FileChange(
        path: $checkedConvert('path', (v) => v as String),
        add: $checkedConvert('add', (v) => (v as num).toInt()),
        del: $checkedConvert('del', (v) => (v as num).toInt()),
        diff: $checkedConvert('diff', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$FileChangeToJson(FileChange instance) =>
    <String, dynamic>{
      'path': instance.path,
      'add': instance.add,
      'del': instance.del,
      'diff': instance.diff,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_tree.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RepoTreeCWProxy {
  RepoTree ref(String ref);

  RepoTree path(String path);

  RepoTree entries(List<TreeEntry> entries);

  RepoTree capped(bool? capped);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoTree(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoTree(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoTree call({
    String ref,
    String path,
    List<TreeEntry> entries,
    bool? capped,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRepoTree.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRepoTree.copyWith.fieldName(...)`
class _$RepoTreeCWProxyImpl implements _$RepoTreeCWProxy {
  const _$RepoTreeCWProxyImpl(this._value);

  final RepoTree _value;

  @override
  RepoTree ref(String ref) => this(ref: ref);

  @override
  RepoTree path(String path) => this(path: path);

  @override
  RepoTree entries(List<TreeEntry> entries) => this(entries: entries);

  @override
  RepoTree capped(bool? capped) => this(capped: capped);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoTree(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoTree(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoTree call({
    Object? ref = const $CopyWithPlaceholder(),
    Object? path = const $CopyWithPlaceholder(),
    Object? entries = const $CopyWithPlaceholder(),
    Object? capped = const $CopyWithPlaceholder(),
  }) {
    return RepoTree(
      ref: ref == const $CopyWithPlaceholder()
          ? _value.ref
          // ignore: cast_nullable_to_non_nullable
          : ref as String,
      path: path == const $CopyWithPlaceholder()
          ? _value.path
          // ignore: cast_nullable_to_non_nullable
          : path as String,
      entries: entries == const $CopyWithPlaceholder()
          ? _value.entries
          // ignore: cast_nullable_to_non_nullable
          : entries as List<TreeEntry>,
      capped: capped == const $CopyWithPlaceholder()
          ? _value.capped
          // ignore: cast_nullable_to_non_nullable
          : capped as bool?,
    );
  }
}

extension $RepoTreeCopyWith on RepoTree {
  /// Returns a callable class that can be used as follows: `instanceOfRepoTree.copyWith(...)` or like so:`instanceOfRepoTree.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RepoTreeCWProxy get copyWith => _$RepoTreeCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepoTree _$RepoTreeFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RepoTree', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['ref', 'path', 'entries']);
      final val = RepoTree(
        ref: $checkedConvert('ref', (v) => v as String),
        path: $checkedConvert('path', (v) => v as String),
        entries: $checkedConvert(
          'entries',
          (v) => (v as List<dynamic>)
              .map((e) => TreeEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        capped: $checkedConvert('capped', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$RepoTreeToJson(RepoTree instance) => <String, dynamic>{
  'ref': instance.ref,
  'path': instance.path,
  'entries': instance.entries.map((e) => e.toJson()).toList(),
  'capped': ?instance.capped,
};

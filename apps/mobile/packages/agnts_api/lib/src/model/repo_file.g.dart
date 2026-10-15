// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_file.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RepoFileCWProxy {
  RepoFile ref(String ref);

  RepoFile path(String path);

  RepoFile size(int size);

  RepoFile content(String? content);

  RepoFile binary(bool binary);

  RepoFile tooLarge(bool tooLarge);

  RepoFile url(String url);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoFile(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoFile(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoFile call({
    String ref,
    String path,
    int size,
    String? content,
    bool binary,
    bool tooLarge,
    String url,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRepoFile.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRepoFile.copyWith.fieldName(...)`
class _$RepoFileCWProxyImpl implements _$RepoFileCWProxy {
  const _$RepoFileCWProxyImpl(this._value);

  final RepoFile _value;

  @override
  RepoFile ref(String ref) => this(ref: ref);

  @override
  RepoFile path(String path) => this(path: path);

  @override
  RepoFile size(int size) => this(size: size);

  @override
  RepoFile content(String? content) => this(content: content);

  @override
  RepoFile binary(bool binary) => this(binary: binary);

  @override
  RepoFile tooLarge(bool tooLarge) => this(tooLarge: tooLarge);

  @override
  RepoFile url(String url) => this(url: url);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoFile(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoFile(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoFile call({
    Object? ref = const $CopyWithPlaceholder(),
    Object? path = const $CopyWithPlaceholder(),
    Object? size = const $CopyWithPlaceholder(),
    Object? content = const $CopyWithPlaceholder(),
    Object? binary = const $CopyWithPlaceholder(),
    Object? tooLarge = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
  }) {
    return RepoFile(
      ref: ref == const $CopyWithPlaceholder()
          ? _value.ref
          // ignore: cast_nullable_to_non_nullable
          : ref as String,
      path: path == const $CopyWithPlaceholder()
          ? _value.path
          // ignore: cast_nullable_to_non_nullable
          : path as String,
      size: size == const $CopyWithPlaceholder()
          ? _value.size
          // ignore: cast_nullable_to_non_nullable
          : size as int,
      content: content == const $CopyWithPlaceholder()
          ? _value.content
          // ignore: cast_nullable_to_non_nullable
          : content as String?,
      binary: binary == const $CopyWithPlaceholder()
          ? _value.binary
          // ignore: cast_nullable_to_non_nullable
          : binary as bool,
      tooLarge: tooLarge == const $CopyWithPlaceholder()
          ? _value.tooLarge
          // ignore: cast_nullable_to_non_nullable
          : tooLarge as bool,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
    );
  }
}

extension $RepoFileCopyWith on RepoFile {
  /// Returns a callable class that can be used as follows: `instanceOfRepoFile.copyWith(...)` or like so:`instanceOfRepoFile.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RepoFileCWProxy get copyWith => _$RepoFileCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepoFile _$RepoFileFromJson(Map<String, dynamic> json) => $checkedCreate(
  'RepoFile',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['ref', 'path', 'size', 'binary', 'tooLarge', 'url'],
    );
    final val = RepoFile(
      ref: $checkedConvert('ref', (v) => v as String),
      path: $checkedConvert('path', (v) => v as String),
      size: $checkedConvert('size', (v) => (v as num).toInt()),
      content: $checkedConvert('content', (v) => v as String?),
      binary: $checkedConvert('binary', (v) => v as bool),
      tooLarge: $checkedConvert('tooLarge', (v) => v as bool),
      url: $checkedConvert('url', (v) => v as String),
    );
    return val;
  },
);

Map<String, dynamic> _$RepoFileToJson(RepoFile instance) => <String, dynamic>{
  'ref': instance.ref,
  'path': instance.path,
  'size': instance.size,
  'content': ?instance.content,
  'binary': instance.binary,
  'tooLarge': instance.tooLarge,
  'url': instance.url,
};

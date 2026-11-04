// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attached_file.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AttachedFileCWProxy {
  AttachedFile id(int id);

  AttachedFile name(String name);

  AttachedFile contentType(String contentType);

  AttachedFile size(int size);

  AttachedFile image(bool image);

  AttachedFile url(String url);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AttachedFile(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AttachedFile(...).copyWith(id: 12, name: "My name")
  /// ````
  AttachedFile call({
    int id,
    String name,
    String contentType,
    int size,
    bool image,
    String url,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAttachedFile.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAttachedFile.copyWith.fieldName(...)`
class _$AttachedFileCWProxyImpl implements _$AttachedFileCWProxy {
  const _$AttachedFileCWProxyImpl(this._value);

  final AttachedFile _value;

  @override
  AttachedFile id(int id) => this(id: id);

  @override
  AttachedFile name(String name) => this(name: name);

  @override
  AttachedFile contentType(String contentType) =>
      this(contentType: contentType);

  @override
  AttachedFile size(int size) => this(size: size);

  @override
  AttachedFile image(bool image) => this(image: image);

  @override
  AttachedFile url(String url) => this(url: url);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AttachedFile(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AttachedFile(...).copyWith(id: 12, name: "My name")
  /// ````
  AttachedFile call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? contentType = const $CopyWithPlaceholder(),
    Object? size = const $CopyWithPlaceholder(),
    Object? image = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
  }) {
    return AttachedFile(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      contentType: contentType == const $CopyWithPlaceholder()
          ? _value.contentType
          // ignore: cast_nullable_to_non_nullable
          : contentType as String,
      size: size == const $CopyWithPlaceholder()
          ? _value.size
          // ignore: cast_nullable_to_non_nullable
          : size as int,
      image: image == const $CopyWithPlaceholder()
          ? _value.image
          // ignore: cast_nullable_to_non_nullable
          : image as bool,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
    );
  }
}

extension $AttachedFileCopyWith on AttachedFile {
  /// Returns a callable class that can be used as follows: `instanceOfAttachedFile.copyWith(...)` or like so:`instanceOfAttachedFile.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AttachedFileCWProxy get copyWith => _$AttachedFileCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttachedFile _$AttachedFileFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AttachedFile', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'name',
          'contentType',
          'size',
          'image',
          'url',
        ],
      );
      final val = AttachedFile(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        name: $checkedConvert('name', (v) => v as String),
        contentType: $checkedConvert('contentType', (v) => v as String),
        size: $checkedConvert('size', (v) => (v as num).toInt()),
        image: $checkedConvert('image', (v) => v as bool),
        url: $checkedConvert('url', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$AttachedFileToJson(AttachedFile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'contentType': instance.contentType,
      'size': instance.size,
      'image': instance.image,
      'url': instance.url,
    };

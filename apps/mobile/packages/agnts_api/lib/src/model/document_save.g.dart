// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_save.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentSaveCWProxy {
  DocumentSave title(String title);

  DocumentSave body(String body);

  DocumentSave baseVersion(int baseVersion);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentSave(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentSave(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentSave call({String title, String body, int baseVersion});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentSave.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentSave.copyWith.fieldName(...)`
class _$DocumentSaveCWProxyImpl implements _$DocumentSaveCWProxy {
  const _$DocumentSaveCWProxyImpl(this._value);

  final DocumentSave _value;

  @override
  DocumentSave title(String title) => this(title: title);

  @override
  DocumentSave body(String body) => this(body: body);

  @override
  DocumentSave baseVersion(int baseVersion) => this(baseVersion: baseVersion);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentSave(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentSave(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentSave call({
    Object? title = const $CopyWithPlaceholder(),
    Object? body = const $CopyWithPlaceholder(),
    Object? baseVersion = const $CopyWithPlaceholder(),
  }) {
    return DocumentSave(
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String,
      baseVersion: baseVersion == const $CopyWithPlaceholder()
          ? _value.baseVersion
          // ignore: cast_nullable_to_non_nullable
          : baseVersion as int,
    );
  }
}

extension $DocumentSaveCopyWith on DocumentSave {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentSave.copyWith(...)` or like so:`instanceOfDocumentSave.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentSaveCWProxy get copyWith => _$DocumentSaveCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentSave _$DocumentSaveFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DocumentSave', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['title', 'body', 'baseVersion']);
      final val = DocumentSave(
        title: $checkedConvert('title', (v) => v as String),
        body: $checkedConvert('body', (v) => v as String),
        baseVersion: $checkedConvert('baseVersion', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$DocumentSaveToJson(DocumentSave instance) =>
    <String, dynamic>{
      'title': instance.title,
      'body': instance.body,
      'baseVersion': instance.baseVersion,
    };

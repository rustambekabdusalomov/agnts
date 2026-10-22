// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_version.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentVersionCWProxy {
  DocumentVersion version(int version);

  DocumentVersion title(String title);

  DocumentVersion body(String? body);

  DocumentVersion source_(DocumentVersionSource_Enum source_);

  DocumentVersion note(String note);

  DocumentVersion authorId(int? authorId);

  DocumentVersion authorName(String? authorName);

  DocumentVersion createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentVersion(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentVersion(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentVersion call({
    int version,
    String title,
    String? body,
    DocumentVersionSource_Enum source_,
    String note,
    int? authorId,
    String? authorName,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentVersion.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentVersion.copyWith.fieldName(...)`
class _$DocumentVersionCWProxyImpl implements _$DocumentVersionCWProxy {
  const _$DocumentVersionCWProxyImpl(this._value);

  final DocumentVersion _value;

  @override
  DocumentVersion version(int version) => this(version: version);

  @override
  DocumentVersion title(String title) => this(title: title);

  @override
  DocumentVersion body(String? body) => this(body: body);

  @override
  DocumentVersion source_(DocumentVersionSource_Enum source_) =>
      this(source_: source_);

  @override
  DocumentVersion note(String note) => this(note: note);

  @override
  DocumentVersion authorId(int? authorId) => this(authorId: authorId);

  @override
  DocumentVersion authorName(String? authorName) =>
      this(authorName: authorName);

  @override
  DocumentVersion createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentVersion(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentVersion(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentVersion call({
    Object? version = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? body = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? authorId = const $CopyWithPlaceholder(),
    Object? authorName = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return DocumentVersion(
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String?,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as DocumentVersionSource_Enum,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String,
      authorId: authorId == const $CopyWithPlaceholder()
          ? _value.authorId
          // ignore: cast_nullable_to_non_nullable
          : authorId as int?,
      authorName: authorName == const $CopyWithPlaceholder()
          ? _value.authorName
          // ignore: cast_nullable_to_non_nullable
          : authorName as String?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $DocumentVersionCopyWith on DocumentVersion {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentVersion.copyWith(...)` or like so:`instanceOfDocumentVersion.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentVersionCWProxy get copyWith => _$DocumentVersionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentVersion _$DocumentVersionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DocumentVersion', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['version', 'title', 'source', 'note', 'createdAt'],
      );
      final val = DocumentVersion(
        version: $checkedConvert('version', (v) => (v as num).toInt()),
        title: $checkedConvert('title', (v) => v as String),
        body: $checkedConvert('body', (v) => v as String?),
        source_: $checkedConvert(
          'source',
          (v) => $enumDecode(_$DocumentVersionSource_EnumEnumMap, v),
        ),
        note: $checkedConvert('note', (v) => v as String),
        authorId: $checkedConvert('authorId', (v) => (v as num?)?.toInt()),
        authorName: $checkedConvert('authorName', (v) => v as String?),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    }, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$DocumentVersionToJson(DocumentVersion instance) =>
    <String, dynamic>{
      'version': instance.version,
      'title': instance.title,
      'body': ?instance.body,
      'source': _$DocumentVersionSource_EnumEnumMap[instance.source_]!,
      'note': instance.note,
      'authorId': ?instance.authorId,
      'authorName': ?instance.authorName,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$DocumentVersionSource_EnumEnumMap = {
  DocumentVersionSource_Enum.human: 'human',
  DocumentVersionSource_Enum.ai: 'ai',
  DocumentVersionSource_Enum.restore: 'restore',
};

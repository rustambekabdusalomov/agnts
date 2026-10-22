// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentCWProxy {
  Document id(int id);

  Document title(String title);

  Document version(int version);

  Document type(DocumentTypeEnum type);

  Document workspaceAccess(DocumentWorkspaceAccessEnum workspaceAccess);

  Document ownerId(int ownerId);

  Document ownerName(String ownerName);

  Document language(DocumentLanguageEnum language);

  Document access(DocumentAccess access);

  Document ticketCount(int ticketCount);

  Document generation(DocumentGeneration? generation);

  Document createdAt(DateTime createdAt);

  Document updatedAt(DateTime updatedAt);

  Document deletedAt(DateTime? deletedAt);

  Document body(String body);

  Document publicUrl(String? publicUrl);

  Document source_(DocumentSourceInput? source_);

  Document dataAsOf(DateTime? dataAsOf);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Document(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Document(...).copyWith(id: 12, name: "My name")
  /// ````
  Document call({
    int id,
    String title,
    int version,
    DocumentTypeEnum type,
    DocumentWorkspaceAccessEnum workspaceAccess,
    int ownerId,
    String ownerName,
    DocumentLanguageEnum language,
    DocumentAccess access,
    int ticketCount,
    DocumentGeneration? generation,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
    String body,
    String? publicUrl,
    DocumentSourceInput? source_,
    DateTime? dataAsOf,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocument.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocument.copyWith.fieldName(...)`
class _$DocumentCWProxyImpl implements _$DocumentCWProxy {
  const _$DocumentCWProxyImpl(this._value);

  final Document _value;

  @override
  Document id(int id) => this(id: id);

  @override
  Document title(String title) => this(title: title);

  @override
  Document version(int version) => this(version: version);

  @override
  Document type(DocumentTypeEnum type) => this(type: type);

  @override
  Document workspaceAccess(DocumentWorkspaceAccessEnum workspaceAccess) =>
      this(workspaceAccess: workspaceAccess);

  @override
  Document ownerId(int ownerId) => this(ownerId: ownerId);

  @override
  Document ownerName(String ownerName) => this(ownerName: ownerName);

  @override
  Document language(DocumentLanguageEnum language) => this(language: language);

  @override
  Document access(DocumentAccess access) => this(access: access);

  @override
  Document ticketCount(int ticketCount) => this(ticketCount: ticketCount);

  @override
  Document generation(DocumentGeneration? generation) =>
      this(generation: generation);

  @override
  Document createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  Document updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  Document deletedAt(DateTime? deletedAt) => this(deletedAt: deletedAt);

  @override
  Document body(String body) => this(body: body);

  @override
  Document publicUrl(String? publicUrl) => this(publicUrl: publicUrl);

  @override
  Document source_(DocumentSourceInput? source_) => this(source_: source_);

  @override
  Document dataAsOf(DateTime? dataAsOf) => this(dataAsOf: dataAsOf);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Document(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Document(...).copyWith(id: 12, name: "My name")
  /// ````
  Document call({
    Object? id = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? workspaceAccess = const $CopyWithPlaceholder(),
    Object? ownerId = const $CopyWithPlaceholder(),
    Object? ownerName = const $CopyWithPlaceholder(),
    Object? language = const $CopyWithPlaceholder(),
    Object? access = const $CopyWithPlaceholder(),
    Object? ticketCount = const $CopyWithPlaceholder(),
    Object? generation = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? deletedAt = const $CopyWithPlaceholder(),
    Object? body = const $CopyWithPlaceholder(),
    Object? publicUrl = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
    Object? dataAsOf = const $CopyWithPlaceholder(),
  }) {
    return Document(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as DocumentTypeEnum,
      workspaceAccess: workspaceAccess == const $CopyWithPlaceholder()
          ? _value.workspaceAccess
          // ignore: cast_nullable_to_non_nullable
          : workspaceAccess as DocumentWorkspaceAccessEnum,
      ownerId: ownerId == const $CopyWithPlaceholder()
          ? _value.ownerId
          // ignore: cast_nullable_to_non_nullable
          : ownerId as int,
      ownerName: ownerName == const $CopyWithPlaceholder()
          ? _value.ownerName
          // ignore: cast_nullable_to_non_nullable
          : ownerName as String,
      language: language == const $CopyWithPlaceholder()
          ? _value.language
          // ignore: cast_nullable_to_non_nullable
          : language as DocumentLanguageEnum,
      access: access == const $CopyWithPlaceholder()
          ? _value.access
          // ignore: cast_nullable_to_non_nullable
          : access as DocumentAccess,
      ticketCount: ticketCount == const $CopyWithPlaceholder()
          ? _value.ticketCount
          // ignore: cast_nullable_to_non_nullable
          : ticketCount as int,
      generation: generation == const $CopyWithPlaceholder()
          ? _value.generation
          // ignore: cast_nullable_to_non_nullable
          : generation as DocumentGeneration?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
      deletedAt: deletedAt == const $CopyWithPlaceholder()
          ? _value.deletedAt
          // ignore: cast_nullable_to_non_nullable
          : deletedAt as DateTime?,
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String,
      publicUrl: publicUrl == const $CopyWithPlaceholder()
          ? _value.publicUrl
          // ignore: cast_nullable_to_non_nullable
          : publicUrl as String?,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as DocumentSourceInput?,
      dataAsOf: dataAsOf == const $CopyWithPlaceholder()
          ? _value.dataAsOf
          // ignore: cast_nullable_to_non_nullable
          : dataAsOf as DateTime?,
    );
  }
}

extension $DocumentCopyWith on Document {
  /// Returns a callable class that can be used as follows: `instanceOfDocument.copyWith(...)` or like so:`instanceOfDocument.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentCWProxy get copyWith => _$DocumentCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Document _$DocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('Document', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'title',
      'version',
      'type',
      'workspaceAccess',
      'ownerId',
      'ownerName',
      'language',
      'access',
      'ticketCount',
      'createdAt',
      'updatedAt',
      'body',
    ],
  );
  final val = Document(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    title: $checkedConvert('title', (v) => v as String),
    version: $checkedConvert('version', (v) => (v as num).toInt()),
    type: $checkedConvert(
      'type',
      (v) => $enumDecode(_$DocumentTypeEnumEnumMap, v),
    ),
    workspaceAccess: $checkedConvert(
      'workspaceAccess',
      (v) => $enumDecode(_$DocumentWorkspaceAccessEnumEnumMap, v),
    ),
    ownerId: $checkedConvert('ownerId', (v) => (v as num).toInt()),
    ownerName: $checkedConvert('ownerName', (v) => v as String),
    language: $checkedConvert(
      'language',
      (v) => $enumDecode(_$DocumentLanguageEnumEnumMap, v),
    ),
    access: $checkedConvert(
      'access',
      (v) => $enumDecode(_$DocumentAccessEnumMap, v),
    ),
    ticketCount: $checkedConvert('ticketCount', (v) => (v as num).toInt()),
    generation: $checkedConvert(
      'generation',
      (v) => v == null
          ? null
          : DocumentGeneration.fromJson(v as Map<String, dynamic>),
    ),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
    deletedAt: $checkedConvert(
      'deletedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    body: $checkedConvert('body', (v) => v as String),
    publicUrl: $checkedConvert('publicUrl', (v) => v as String?),
    source_: $checkedConvert(
      'source',
      (v) => v == null
          ? null
          : DocumentSourceInput.fromJson(v as Map<String, dynamic>),
    ),
    dataAsOf: $checkedConvert(
      'dataAsOf',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
  );
  return val;
}, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$DocumentToJson(Document instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'version': instance.version,
  'type': _$DocumentTypeEnumEnumMap[instance.type]!,
  'workspaceAccess':
      _$DocumentWorkspaceAccessEnumEnumMap[instance.workspaceAccess]!,
  'ownerId': instance.ownerId,
  'ownerName': instance.ownerName,
  'language': _$DocumentLanguageEnumEnumMap[instance.language]!,
  'access': _$DocumentAccessEnumMap[instance.access]!,
  'ticketCount': instance.ticketCount,
  'generation': ?instance.generation?.toJson(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'deletedAt': ?instance.deletedAt?.toIso8601String(),
  'body': instance.body,
  'publicUrl': ?instance.publicUrl,
  'source': ?instance.source_?.toJson(),
  'dataAsOf': ?instance.dataAsOf?.toIso8601String(),
};

const _$DocumentTypeEnumEnumMap = {
  DocumentTypeEnum.private: 'private',
  DocumentTypeEnum.public: 'public',
};

const _$DocumentWorkspaceAccessEnumEnumMap = {
  DocumentWorkspaceAccessEnum.none: 'none',
  DocumentWorkspaceAccessEnum.view: 'view',
  DocumentWorkspaceAccessEnum.edit: 'edit',
};

const _$DocumentLanguageEnumEnumMap = {
  DocumentLanguageEnum.en: 'en',
  DocumentLanguageEnum.ru: 'ru',
  DocumentLanguageEnum.uz: 'uz',
};

const _$DocumentAccessEnumMap = {
  DocumentAccess.none: 'none',
  DocumentAccess.view: 'view',
  DocumentAccess.edit: 'edit',
  DocumentAccess.owner: 'owner',
};

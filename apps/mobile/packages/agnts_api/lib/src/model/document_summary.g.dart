// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentSummaryCWProxy {
  DocumentSummary id(int id);

  DocumentSummary title(String title);

  DocumentSummary version(int version);

  DocumentSummary type(DocumentSummaryTypeEnum type);

  DocumentSummary workspaceAccess(
    DocumentSummaryWorkspaceAccessEnum workspaceAccess,
  );

  DocumentSummary ownerId(int ownerId);

  DocumentSummary ownerName(String ownerName);

  DocumentSummary language(DocumentSummaryLanguageEnum language);

  DocumentSummary access(DocumentAccess access);

  DocumentSummary ticketCount(int ticketCount);

  DocumentSummary generation(DocumentGeneration? generation);

  DocumentSummary createdAt(DateTime createdAt);

  DocumentSummary updatedAt(DateTime updatedAt);

  DocumentSummary deletedAt(DateTime? deletedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentSummary call({
    int id,
    String title,
    int version,
    DocumentSummaryTypeEnum type,
    DocumentSummaryWorkspaceAccessEnum workspaceAccess,
    int ownerId,
    String ownerName,
    DocumentSummaryLanguageEnum language,
    DocumentAccess access,
    int ticketCount,
    DocumentGeneration? generation,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentSummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentSummary.copyWith.fieldName(...)`
class _$DocumentSummaryCWProxyImpl implements _$DocumentSummaryCWProxy {
  const _$DocumentSummaryCWProxyImpl(this._value);

  final DocumentSummary _value;

  @override
  DocumentSummary id(int id) => this(id: id);

  @override
  DocumentSummary title(String title) => this(title: title);

  @override
  DocumentSummary version(int version) => this(version: version);

  @override
  DocumentSummary type(DocumentSummaryTypeEnum type) => this(type: type);

  @override
  DocumentSummary workspaceAccess(
    DocumentSummaryWorkspaceAccessEnum workspaceAccess,
  ) => this(workspaceAccess: workspaceAccess);

  @override
  DocumentSummary ownerId(int ownerId) => this(ownerId: ownerId);

  @override
  DocumentSummary ownerName(String ownerName) => this(ownerName: ownerName);

  @override
  DocumentSummary language(DocumentSummaryLanguageEnum language) =>
      this(language: language);

  @override
  DocumentSummary access(DocumentAccess access) => this(access: access);

  @override
  DocumentSummary ticketCount(int ticketCount) =>
      this(ticketCount: ticketCount);

  @override
  DocumentSummary generation(DocumentGeneration? generation) =>
      this(generation: generation);

  @override
  DocumentSummary createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  DocumentSummary updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  DocumentSummary deletedAt(DateTime? deletedAt) => this(deletedAt: deletedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentSummary call({
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
  }) {
    return DocumentSummary(
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
          : type as DocumentSummaryTypeEnum,
      workspaceAccess: workspaceAccess == const $CopyWithPlaceholder()
          ? _value.workspaceAccess
          // ignore: cast_nullable_to_non_nullable
          : workspaceAccess as DocumentSummaryWorkspaceAccessEnum,
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
          : language as DocumentSummaryLanguageEnum,
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
    );
  }
}

extension $DocumentSummaryCopyWith on DocumentSummary {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentSummary.copyWith(...)` or like so:`instanceOfDocumentSummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentSummaryCWProxy get copyWith => _$DocumentSummaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentSummary _$DocumentSummaryFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DocumentSummary', json, ($checkedConvert) {
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
    ],
  );
  final val = DocumentSummary(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    title: $checkedConvert('title', (v) => v as String),
    version: $checkedConvert('version', (v) => (v as num).toInt()),
    type: $checkedConvert(
      'type',
      (v) => $enumDecode(_$DocumentSummaryTypeEnumEnumMap, v),
    ),
    workspaceAccess: $checkedConvert(
      'workspaceAccess',
      (v) => $enumDecode(_$DocumentSummaryWorkspaceAccessEnumEnumMap, v),
    ),
    ownerId: $checkedConvert('ownerId', (v) => (v as num).toInt()),
    ownerName: $checkedConvert('ownerName', (v) => v as String),
    language: $checkedConvert(
      'language',
      (v) => $enumDecode(_$DocumentSummaryLanguageEnumEnumMap, v),
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
  );
  return val;
});

Map<String, dynamic> _$DocumentSummaryToJson(
  DocumentSummary instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'version': instance.version,
  'type': _$DocumentSummaryTypeEnumEnumMap[instance.type]!,
  'workspaceAccess':
      _$DocumentSummaryWorkspaceAccessEnumEnumMap[instance.workspaceAccess]!,
  'ownerId': instance.ownerId,
  'ownerName': instance.ownerName,
  'language': _$DocumentSummaryLanguageEnumEnumMap[instance.language]!,
  'access': _$DocumentAccessEnumMap[instance.access]!,
  'ticketCount': instance.ticketCount,
  'generation': ?instance.generation?.toJson(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'deletedAt': ?instance.deletedAt?.toIso8601String(),
};

const _$DocumentSummaryTypeEnumEnumMap = {
  DocumentSummaryTypeEnum.private: 'private',
  DocumentSummaryTypeEnum.public: 'public',
};

const _$DocumentSummaryWorkspaceAccessEnumEnumMap = {
  DocumentSummaryWorkspaceAccessEnum.none: 'none',
  DocumentSummaryWorkspaceAccessEnum.view: 'view',
  DocumentSummaryWorkspaceAccessEnum.edit: 'edit',
};

const _$DocumentSummaryLanguageEnumEnumMap = {
  DocumentSummaryLanguageEnum.en: 'en',
  DocumentSummaryLanguageEnum.ru: 'ru',
  DocumentSummaryLanguageEnum.uz: 'uz',
};

const _$DocumentAccessEnumMap = {
  DocumentAccess.none: 'none',
  DocumentAccess.view: 'view',
  DocumentAccess.edit: 'edit',
  DocumentAccess.owner: 'owner',
};

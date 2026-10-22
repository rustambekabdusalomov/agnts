// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_generation.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentGenerationCWProxy {
  DocumentGeneration id(int id);

  DocumentGeneration status(DocumentGenerationStatusEnum status);

  DocumentGeneration error(String error);

  DocumentGeneration source_(DocumentSourceInput? source_);

  DocumentGeneration requestedBy(int? requestedBy);

  DocumentGeneration startedAt(DateTime? startedAt);

  DocumentGeneration finishedAt(DateTime? finishedAt);

  DocumentGeneration createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentGeneration(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentGeneration(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentGeneration call({
    int id,
    DocumentGenerationStatusEnum status,
    String error,
    DocumentSourceInput? source_,
    int? requestedBy,
    DateTime? startedAt,
    DateTime? finishedAt,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentGeneration.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentGeneration.copyWith.fieldName(...)`
class _$DocumentGenerationCWProxyImpl implements _$DocumentGenerationCWProxy {
  const _$DocumentGenerationCWProxyImpl(this._value);

  final DocumentGeneration _value;

  @override
  DocumentGeneration id(int id) => this(id: id);

  @override
  DocumentGeneration status(DocumentGenerationStatusEnum status) =>
      this(status: status);

  @override
  DocumentGeneration error(String error) => this(error: error);

  @override
  DocumentGeneration source_(DocumentSourceInput? source_) =>
      this(source_: source_);

  @override
  DocumentGeneration requestedBy(int? requestedBy) =>
      this(requestedBy: requestedBy);

  @override
  DocumentGeneration startedAt(DateTime? startedAt) =>
      this(startedAt: startedAt);

  @override
  DocumentGeneration finishedAt(DateTime? finishedAt) =>
      this(finishedAt: finishedAt);

  @override
  DocumentGeneration createdAt(DateTime createdAt) =>
      this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentGeneration(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentGeneration(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentGeneration call({
    Object? id = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
    Object? requestedBy = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
    Object? finishedAt = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return DocumentGeneration(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as DocumentGenerationStatusEnum,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as DocumentSourceInput?,
      requestedBy: requestedBy == const $CopyWithPlaceholder()
          ? _value.requestedBy
          // ignore: cast_nullable_to_non_nullable
          : requestedBy as int?,
      startedAt: startedAt == const $CopyWithPlaceholder()
          ? _value.startedAt
          // ignore: cast_nullable_to_non_nullable
          : startedAt as DateTime?,
      finishedAt: finishedAt == const $CopyWithPlaceholder()
          ? _value.finishedAt
          // ignore: cast_nullable_to_non_nullable
          : finishedAt as DateTime?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $DocumentGenerationCopyWith on DocumentGeneration {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentGeneration.copyWith(...)` or like so:`instanceOfDocumentGeneration.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentGenerationCWProxy get copyWith =>
      _$DocumentGenerationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentGeneration _$DocumentGenerationFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DocumentGeneration', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['id', 'status', 'error', 'createdAt']);
  final val = DocumentGeneration(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$DocumentGenerationStatusEnumEnumMap, v),
    ),
    error: $checkedConvert('error', (v) => v as String),
    source_: $checkedConvert(
      'source',
      (v) => v == null
          ? null
          : DocumentSourceInput.fromJson(v as Map<String, dynamic>),
    ),
    requestedBy: $checkedConvert('requestedBy', (v) => (v as num?)?.toInt()),
    startedAt: $checkedConvert(
      'startedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    finishedAt: $checkedConvert(
      'finishedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
  );
  return val;
}, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$DocumentGenerationToJson(DocumentGeneration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$DocumentGenerationStatusEnumEnumMap[instance.status]!,
      'error': instance.error,
      'source': ?instance.source_?.toJson(),
      'requestedBy': ?instance.requestedBy,
      'startedAt': ?instance.startedAt?.toIso8601String(),
      'finishedAt': ?instance.finishedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$DocumentGenerationStatusEnumEnumMap = {
  DocumentGenerationStatusEnum.queued: 'queued',
  DocumentGenerationStatusEnum.writing: 'writing',
  DocumentGenerationStatusEnum.done: 'done',
  DocumentGenerationStatusEnum.failed: 'failed',
};

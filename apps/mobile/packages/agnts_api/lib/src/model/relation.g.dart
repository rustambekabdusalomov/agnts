// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relation.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RelationCWProxy {
  Relation id(int id);

  Relation type(RelationType type);

  Relation direction(RelationDirectionEnum direction);

  Relation source_(RelationSource_Enum source_);

  Relation status(RelationStatusEnum status);

  Relation confidence(double confidence);

  Relation reason(String reason);

  Relation basis(String basis);

  Relation files(List<String> files);

  Relation other(RelatedTicket other);

  Relation confirmedAt(DateTime? confirmedAt);

  Relation decidedAt(DateTime? decidedAt);

  Relation createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Relation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Relation(...).copyWith(id: 12, name: "My name")
  /// ````
  Relation call({
    int id,
    RelationType type,
    RelationDirectionEnum direction,
    RelationSource_Enum source_,
    RelationStatusEnum status,
    double confidence,
    String reason,
    String basis,
    List<String> files,
    RelatedTicket other,
    DateTime? confirmedAt,
    DateTime? decidedAt,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRelation.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRelation.copyWith.fieldName(...)`
class _$RelationCWProxyImpl implements _$RelationCWProxy {
  const _$RelationCWProxyImpl(this._value);

  final Relation _value;

  @override
  Relation id(int id) => this(id: id);

  @override
  Relation type(RelationType type) => this(type: type);

  @override
  Relation direction(RelationDirectionEnum direction) =>
      this(direction: direction);

  @override
  Relation source_(RelationSource_Enum source_) => this(source_: source_);

  @override
  Relation status(RelationStatusEnum status) => this(status: status);

  @override
  Relation confidence(double confidence) => this(confidence: confidence);

  @override
  Relation reason(String reason) => this(reason: reason);

  @override
  Relation basis(String basis) => this(basis: basis);

  @override
  Relation files(List<String> files) => this(files: files);

  @override
  Relation other(RelatedTicket other) => this(other: other);

  @override
  Relation confirmedAt(DateTime? confirmedAt) => this(confirmedAt: confirmedAt);

  @override
  Relation decidedAt(DateTime? decidedAt) => this(decidedAt: decidedAt);

  @override
  Relation createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Relation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Relation(...).copyWith(id: 12, name: "My name")
  /// ````
  Relation call({
    Object? id = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? direction = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? confidence = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? basis = const $CopyWithPlaceholder(),
    Object? files = const $CopyWithPlaceholder(),
    Object? other = const $CopyWithPlaceholder(),
    Object? confirmedAt = const $CopyWithPlaceholder(),
    Object? decidedAt = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return Relation(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as RelationType,
      direction: direction == const $CopyWithPlaceholder()
          ? _value.direction
          // ignore: cast_nullable_to_non_nullable
          : direction as RelationDirectionEnum,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as RelationSource_Enum,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as RelationStatusEnum,
      confidence: confidence == const $CopyWithPlaceholder()
          ? _value.confidence
          // ignore: cast_nullable_to_non_nullable
          : confidence as double,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
      basis: basis == const $CopyWithPlaceholder()
          ? _value.basis
          // ignore: cast_nullable_to_non_nullable
          : basis as String,
      files: files == const $CopyWithPlaceholder()
          ? _value.files
          // ignore: cast_nullable_to_non_nullable
          : files as List<String>,
      other: other == const $CopyWithPlaceholder()
          ? _value.other
          // ignore: cast_nullable_to_non_nullable
          : other as RelatedTicket,
      confirmedAt: confirmedAt == const $CopyWithPlaceholder()
          ? _value.confirmedAt
          // ignore: cast_nullable_to_non_nullable
          : confirmedAt as DateTime?,
      decidedAt: decidedAt == const $CopyWithPlaceholder()
          ? _value.decidedAt
          // ignore: cast_nullable_to_non_nullable
          : decidedAt as DateTime?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $RelationCopyWith on Relation {
  /// Returns a callable class that can be used as follows: `instanceOfRelation.copyWith(...)` or like so:`instanceOfRelation.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RelationCWProxy get copyWith => _$RelationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Relation _$RelationFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('Relation', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'type',
      'direction',
      'source',
      'status',
      'confidence',
      'reason',
      'basis',
      'files',
      'other',
      'createdAt',
    ],
  );
  final val = Relation(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    type: $checkedConvert('type', (v) => $enumDecode(_$RelationTypeEnumMap, v)),
    direction: $checkedConvert(
      'direction',
      (v) => $enumDecode(_$RelationDirectionEnumEnumMap, v),
    ),
    source_: $checkedConvert(
      'source',
      (v) => $enumDecode(_$RelationSource_EnumEnumMap, v),
    ),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$RelationStatusEnumEnumMap, v),
    ),
    confidence: $checkedConvert('confidence', (v) => (v as num).toDouble()),
    reason: $checkedConvert('reason', (v) => v as String),
    basis: $checkedConvert('basis', (v) => v as String),
    files: $checkedConvert(
      'files',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    other: $checkedConvert(
      'other',
      (v) => RelatedTicket.fromJson(v as Map<String, dynamic>),
    ),
    confirmedAt: $checkedConvert(
      'confirmedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    decidedAt: $checkedConvert(
      'decidedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
  );
  return val;
}, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$RelationToJson(Relation instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$RelationTypeEnumMap[instance.type]!,
  'direction': _$RelationDirectionEnumEnumMap[instance.direction]!,
  'source': _$RelationSource_EnumEnumMap[instance.source_]!,
  'status': _$RelationStatusEnumEnumMap[instance.status]!,
  'confidence': instance.confidence,
  'reason': instance.reason,
  'basis': instance.basis,
  'files': instance.files,
  'other': instance.other.toJson(),
  'confirmedAt': ?instance.confirmedAt?.toIso8601String(),
  'decidedAt': ?instance.decidedAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$RelationTypeEnumMap = {
  RelationType.dependsOn: 'depends_on',
  RelationType.conflicts: 'conflicts',
};

const _$RelationDirectionEnumEnumMap = {
  RelationDirectionEnum.waitsFor: 'waits_for',
  RelationDirectionEnum.waitedBy: 'waited_by',
  RelationDirectionEnum.conflicts: 'conflicts',
};

const _$RelationSource_EnumEnumMap = {
  RelationSource_Enum.jira: 'jira',
  RelationSource_Enum.plane: 'plane',
  RelationSource_Enum.user: 'user',
  RelationSource_Enum.agnts: 'agnts',
  RelationSource_Enum.rule: 'rule',
  RelationSource_Enum.git: 'git',
};

const _$RelationStatusEnumEnumMap = {
  RelationStatusEnum.active: 'active',
  RelationStatusEnum.proposed: 'proposed',
  RelationStatusEnum.dismissed: 'dismissed',
};

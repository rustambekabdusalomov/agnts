// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_brief.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RepoBriefCWProxy {
  RepoBrief repoId(int repoId);

  RepoBrief repoName(String repoName);

  RepoBrief body(String body);

  RepoBrief bodySha(String bodySha);

  RepoBrief draft(String draft);

  RepoBrief draftSha(String draftSha);

  RepoBrief status(RepoBriefStatusEnum status);

  RepoBrief mergesSince(int mergesSince);

  RepoBrief refreshAfter(int refreshAfter);

  RepoBrief error(String error);

  RepoBrief surveyedAt(DateTime? surveyedAt);

  RepoBrief approvedAt(DateTime? approvedAt);

  RepoBrief updatedAt(DateTime updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoBrief(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoBrief(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoBrief call({
    int repoId,
    String repoName,
    String body,
    String bodySha,
    String draft,
    String draftSha,
    RepoBriefStatusEnum status,
    int mergesSince,
    int refreshAfter,
    String error,
    DateTime? surveyedAt,
    DateTime? approvedAt,
    DateTime updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRepoBrief.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRepoBrief.copyWith.fieldName(...)`
class _$RepoBriefCWProxyImpl implements _$RepoBriefCWProxy {
  const _$RepoBriefCWProxyImpl(this._value);

  final RepoBrief _value;

  @override
  RepoBrief repoId(int repoId) => this(repoId: repoId);

  @override
  RepoBrief repoName(String repoName) => this(repoName: repoName);

  @override
  RepoBrief body(String body) => this(body: body);

  @override
  RepoBrief bodySha(String bodySha) => this(bodySha: bodySha);

  @override
  RepoBrief draft(String draft) => this(draft: draft);

  @override
  RepoBrief draftSha(String draftSha) => this(draftSha: draftSha);

  @override
  RepoBrief status(RepoBriefStatusEnum status) => this(status: status);

  @override
  RepoBrief mergesSince(int mergesSince) => this(mergesSince: mergesSince);

  @override
  RepoBrief refreshAfter(int refreshAfter) => this(refreshAfter: refreshAfter);

  @override
  RepoBrief error(String error) => this(error: error);

  @override
  RepoBrief surveyedAt(DateTime? surveyedAt) => this(surveyedAt: surveyedAt);

  @override
  RepoBrief approvedAt(DateTime? approvedAt) => this(approvedAt: approvedAt);

  @override
  RepoBrief updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoBrief(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoBrief(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoBrief call({
    Object? repoId = const $CopyWithPlaceholder(),
    Object? repoName = const $CopyWithPlaceholder(),
    Object? body = const $CopyWithPlaceholder(),
    Object? bodySha = const $CopyWithPlaceholder(),
    Object? draft = const $CopyWithPlaceholder(),
    Object? draftSha = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? mergesSince = const $CopyWithPlaceholder(),
    Object? refreshAfter = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
    Object? surveyedAt = const $CopyWithPlaceholder(),
    Object? approvedAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return RepoBrief(
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int,
      repoName: repoName == const $CopyWithPlaceholder()
          ? _value.repoName
          // ignore: cast_nullable_to_non_nullable
          : repoName as String,
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String,
      bodySha: bodySha == const $CopyWithPlaceholder()
          ? _value.bodySha
          // ignore: cast_nullable_to_non_nullable
          : bodySha as String,
      draft: draft == const $CopyWithPlaceholder()
          ? _value.draft
          // ignore: cast_nullable_to_non_nullable
          : draft as String,
      draftSha: draftSha == const $CopyWithPlaceholder()
          ? _value.draftSha
          // ignore: cast_nullable_to_non_nullable
          : draftSha as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as RepoBriefStatusEnum,
      mergesSince: mergesSince == const $CopyWithPlaceholder()
          ? _value.mergesSince
          // ignore: cast_nullable_to_non_nullable
          : mergesSince as int,
      refreshAfter: refreshAfter == const $CopyWithPlaceholder()
          ? _value.refreshAfter
          // ignore: cast_nullable_to_non_nullable
          : refreshAfter as int,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String,
      surveyedAt: surveyedAt == const $CopyWithPlaceholder()
          ? _value.surveyedAt
          // ignore: cast_nullable_to_non_nullable
          : surveyedAt as DateTime?,
      approvedAt: approvedAt == const $CopyWithPlaceholder()
          ? _value.approvedAt
          // ignore: cast_nullable_to_non_nullable
          : approvedAt as DateTime?,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
    );
  }
}

extension $RepoBriefCopyWith on RepoBrief {
  /// Returns a callable class that can be used as follows: `instanceOfRepoBrief.copyWith(...)` or like so:`instanceOfRepoBrief.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RepoBriefCWProxy get copyWith => _$RepoBriefCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepoBrief _$RepoBriefFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RepoBrief', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'repoId',
      'repoName',
      'body',
      'bodySha',
      'draft',
      'draftSha',
      'status',
      'mergesSince',
      'refreshAfter',
      'error',
      'updatedAt',
    ],
  );
  final val = RepoBrief(
    repoId: $checkedConvert('repoId', (v) => (v as num).toInt()),
    repoName: $checkedConvert('repoName', (v) => v as String),
    body: $checkedConvert('body', (v) => v as String),
    bodySha: $checkedConvert('bodySha', (v) => v as String),
    draft: $checkedConvert('draft', (v) => v as String),
    draftSha: $checkedConvert('draftSha', (v) => v as String),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$RepoBriefStatusEnumEnumMap, v),
    ),
    mergesSince: $checkedConvert('mergesSince', (v) => (v as num).toInt()),
    refreshAfter: $checkedConvert('refreshAfter', (v) => (v as num).toInt()),
    error: $checkedConvert('error', (v) => v as String),
    surveyedAt: $checkedConvert(
      'surveyedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    approvedAt: $checkedConvert(
      'approvedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$RepoBriefToJson(RepoBrief instance) => <String, dynamic>{
  'repoId': instance.repoId,
  'repoName': instance.repoName,
  'body': instance.body,
  'bodySha': instance.bodySha,
  'draft': instance.draft,
  'draftSha': instance.draftSha,
  'status': _$RepoBriefStatusEnumEnumMap[instance.status]!,
  'mergesSince': instance.mergesSince,
  'refreshAfter': instance.refreshAfter,
  'error': instance.error,
  'surveyedAt': ?instance.surveyedAt?.toIso8601String(),
  'approvedAt': ?instance.approvedAt?.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$RepoBriefStatusEnumEnumMap = {
  RepoBriefStatusEnum.idle: 'idle',
  RepoBriefStatusEnum.pending: 'pending',
  RepoBriefStatusEnum.surveying: 'surveying',
  RepoBriefStatusEnum.failed: 'failed',
};

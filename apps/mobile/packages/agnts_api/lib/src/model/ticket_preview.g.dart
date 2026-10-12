// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_preview.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TicketPreviewCWProxy {
  TicketPreview runId(int runId);

  TicketPreview revision(int revision);

  TicketPreview model(String model);

  TicketPreview compare(bool compare);

  TicketPreview status(TicketPreviewStatusEnum status);

  TicketPreview summary(String summary);

  TicketPreview shots(List<PreviewShot> shots);

  TicketPreview issues(List<PreviewIssue> issues);

  TicketPreview acceptance(Acceptance? acceptance);

  TicketPreview createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TicketPreview(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TicketPreview(...).copyWith(id: 12, name: "My name")
  /// ````
  TicketPreview call({
    int runId,
    int revision,
    String model,
    bool compare,
    TicketPreviewStatusEnum status,
    String summary,
    List<PreviewShot> shots,
    List<PreviewIssue> issues,
    Acceptance? acceptance,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTicketPreview.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTicketPreview.copyWith.fieldName(...)`
class _$TicketPreviewCWProxyImpl implements _$TicketPreviewCWProxy {
  const _$TicketPreviewCWProxyImpl(this._value);

  final TicketPreview _value;

  @override
  TicketPreview runId(int runId) => this(runId: runId);

  @override
  TicketPreview revision(int revision) => this(revision: revision);

  @override
  TicketPreview model(String model) => this(model: model);

  @override
  TicketPreview compare(bool compare) => this(compare: compare);

  @override
  TicketPreview status(TicketPreviewStatusEnum status) => this(status: status);

  @override
  TicketPreview summary(String summary) => this(summary: summary);

  @override
  TicketPreview shots(List<PreviewShot> shots) => this(shots: shots);

  @override
  TicketPreview issues(List<PreviewIssue> issues) => this(issues: issues);

  @override
  TicketPreview acceptance(Acceptance? acceptance) =>
      this(acceptance: acceptance);

  @override
  TicketPreview createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TicketPreview(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TicketPreview(...).copyWith(id: 12, name: "My name")
  /// ````
  TicketPreview call({
    Object? runId = const $CopyWithPlaceholder(),
    Object? revision = const $CopyWithPlaceholder(),
    Object? model = const $CopyWithPlaceholder(),
    Object? compare = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? summary = const $CopyWithPlaceholder(),
    Object? shots = const $CopyWithPlaceholder(),
    Object? issues = const $CopyWithPlaceholder(),
    Object? acceptance = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return TicketPreview(
      runId: runId == const $CopyWithPlaceholder()
          ? _value.runId
          // ignore: cast_nullable_to_non_nullable
          : runId as int,
      revision: revision == const $CopyWithPlaceholder()
          ? _value.revision
          // ignore: cast_nullable_to_non_nullable
          : revision as int,
      model: model == const $CopyWithPlaceholder()
          ? _value.model
          // ignore: cast_nullable_to_non_nullable
          : model as String,
      compare: compare == const $CopyWithPlaceholder()
          ? _value.compare
          // ignore: cast_nullable_to_non_nullable
          : compare as bool,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as TicketPreviewStatusEnum,
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as String,
      shots: shots == const $CopyWithPlaceholder()
          ? _value.shots
          // ignore: cast_nullable_to_non_nullable
          : shots as List<PreviewShot>,
      issues: issues == const $CopyWithPlaceholder()
          ? _value.issues
          // ignore: cast_nullable_to_non_nullable
          : issues as List<PreviewIssue>,
      acceptance: acceptance == const $CopyWithPlaceholder()
          ? _value.acceptance
          // ignore: cast_nullable_to_non_nullable
          : acceptance as Acceptance?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $TicketPreviewCopyWith on TicketPreview {
  /// Returns a callable class that can be used as follows: `instanceOfTicketPreview.copyWith(...)` or like so:`instanceOfTicketPreview.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TicketPreviewCWProxy get copyWith => _$TicketPreviewCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketPreview _$TicketPreviewFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TicketPreview', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'runId',
          'revision',
          'model',
          'compare',
          'status',
          'summary',
          'shots',
          'issues',
          'createdAt',
        ],
      );
      final val = TicketPreview(
        runId: $checkedConvert('runId', (v) => (v as num).toInt()),
        revision: $checkedConvert('revision', (v) => (v as num).toInt()),
        model: $checkedConvert('model', (v) => v as String),
        compare: $checkedConvert('compare', (v) => v as bool),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$TicketPreviewStatusEnumEnumMap, v),
        ),
        summary: $checkedConvert('summary', (v) => v as String),
        shots: $checkedConvert(
          'shots',
          (v) => (v as List<dynamic>)
              .map((e) => PreviewShot.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        issues: $checkedConvert(
          'issues',
          (v) => (v as List<dynamic>)
              .map((e) => PreviewIssue.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        acceptance: $checkedConvert(
          'acceptance',
          (v) =>
              v == null ? null : Acceptance.fromJson(v as Map<String, dynamic>),
        ),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$TicketPreviewToJson(TicketPreview instance) =>
    <String, dynamic>{
      'runId': instance.runId,
      'revision': instance.revision,
      'model': instance.model,
      'compare': instance.compare,
      'status': _$TicketPreviewStatusEnumEnumMap[instance.status]!,
      'summary': instance.summary,
      'shots': instance.shots.map((e) => e.toJson()).toList(),
      'issues': instance.issues.map((e) => e.toJson()).toList(),
      'acceptance': ?instance.acceptance?.toJson(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$TicketPreviewStatusEnumEnumMap = {
  TicketPreviewStatusEnum.ok: 'ok',
  TicketPreviewStatusEnum.partial: 'partial',
  TicketPreviewStatusEnum.failed: 'failed',
};

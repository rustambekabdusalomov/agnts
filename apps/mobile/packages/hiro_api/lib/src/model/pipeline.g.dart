// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pipeline.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PipelineCWProxy {
  Pipeline id(int id);

  Pipeline name(String name);

  Pipeline branch(String branch);

  Pipeline sha(String sha);

  Pipeline message(String message);

  Pipeline trigger(String trigger);

  Pipeline status(CI status);

  Pipeline created(DateTime? created);

  Pipeline durationMs(int durationMs);

  Pipeline url(String url);

  Pipeline stages(List<Stage> stages);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Pipeline(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Pipeline(...).copyWith(id: 12, name: "My name")
  /// ````
  Pipeline call({
    int id,
    String name,
    String branch,
    String sha,
    String message,
    String trigger,
    CI status,
    DateTime? created,
    int durationMs,
    String url,
    List<Stage> stages,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPipeline.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPipeline.copyWith.fieldName(...)`
class _$PipelineCWProxyImpl implements _$PipelineCWProxy {
  const _$PipelineCWProxyImpl(this._value);

  final Pipeline _value;

  @override
  Pipeline id(int id) => this(id: id);

  @override
  Pipeline name(String name) => this(name: name);

  @override
  Pipeline branch(String branch) => this(branch: branch);

  @override
  Pipeline sha(String sha) => this(sha: sha);

  @override
  Pipeline message(String message) => this(message: message);

  @override
  Pipeline trigger(String trigger) => this(trigger: trigger);

  @override
  Pipeline status(CI status) => this(status: status);

  @override
  Pipeline created(DateTime? created) => this(created: created);

  @override
  Pipeline durationMs(int durationMs) => this(durationMs: durationMs);

  @override
  Pipeline url(String url) => this(url: url);

  @override
  Pipeline stages(List<Stage> stages) => this(stages: stages);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Pipeline(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Pipeline(...).copyWith(id: 12, name: "My name")
  /// ````
  Pipeline call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? branch = const $CopyWithPlaceholder(),
    Object? sha = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? trigger = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? created = const $CopyWithPlaceholder(),
    Object? durationMs = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? stages = const $CopyWithPlaceholder(),
  }) {
    return Pipeline(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      branch: branch == const $CopyWithPlaceholder()
          ? _value.branch
          // ignore: cast_nullable_to_non_nullable
          : branch as String,
      sha: sha == const $CopyWithPlaceholder()
          ? _value.sha
          // ignore: cast_nullable_to_non_nullable
          : sha as String,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
      trigger: trigger == const $CopyWithPlaceholder()
          ? _value.trigger
          // ignore: cast_nullable_to_non_nullable
          : trigger as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as CI,
      created: created == const $CopyWithPlaceholder()
          ? _value.created
          // ignore: cast_nullable_to_non_nullable
          : created as DateTime?,
      durationMs: durationMs == const $CopyWithPlaceholder()
          ? _value.durationMs
          // ignore: cast_nullable_to_non_nullable
          : durationMs as int,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      stages: stages == const $CopyWithPlaceholder()
          ? _value.stages
          // ignore: cast_nullable_to_non_nullable
          : stages as List<Stage>,
    );
  }
}

extension $PipelineCopyWith on Pipeline {
  /// Returns a callable class that can be used as follows: `instanceOfPipeline.copyWith(...)` or like so:`instanceOfPipeline.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PipelineCWProxy get copyWith => _$PipelineCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pipeline _$PipelineFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Pipeline', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'name',
          'branch',
          'sha',
          'message',
          'trigger',
          'status',
          'durationMs',
          'url',
          'stages',
        ],
      );
      final val = Pipeline(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        name: $checkedConvert('name', (v) => v as String),
        branch: $checkedConvert('branch', (v) => v as String),
        sha: $checkedConvert('sha', (v) => v as String),
        message: $checkedConvert('message', (v) => v as String),
        trigger: $checkedConvert('trigger', (v) => v as String),
        status: $checkedConvert('status', (v) => $enumDecode(_$CIEnumMap, v)),
        created: $checkedConvert(
          'created',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        durationMs: $checkedConvert('durationMs', (v) => (v as num).toInt()),
        url: $checkedConvert('url', (v) => v as String),
        stages: $checkedConvert(
          'stages',
          (v) => (v as List<dynamic>)
              .map((e) => Stage.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PipelineToJson(Pipeline instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'branch': instance.branch,
  'sha': instance.sha,
  'message': instance.message,
  'trigger': instance.trigger,
  'status': _$CIEnumMap[instance.status]!,
  'created': ?instance.created?.toIso8601String(),
  'durationMs': instance.durationMs,
  'url': instance.url,
  'stages': instance.stages.map((e) => e.toJson()).toList(),
};

const _$CIEnumMap = {
  CI.ok: 'ok',
  CI.fail: 'fail',
  CI.run: 'run',
  CI.pending: 'pending',
  CI.manual: 'manual',
  CI.skip: 'skip',
  CI.canceled: 'canceled',
  CI.none: 'none',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flaky_job.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FlakyJobCWProxy {
  FlakyJob id(int id);

  FlakyJob repo(String repo);

  FlakyJob workflow(String workflow);

  FlakyJob job(String job);

  FlakyJob title(String title);

  FlakyJob flaky(int flaky);

  FlakyJob failures(int failures);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FlakyJob(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FlakyJob(...).copyWith(id: 12, name: "My name")
  /// ````
  FlakyJob call({
    int id,
    String repo,
    String workflow,
    String job,
    String title,
    int flaky,
    int failures,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFlakyJob.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFlakyJob.copyWith.fieldName(...)`
class _$FlakyJobCWProxyImpl implements _$FlakyJobCWProxy {
  const _$FlakyJobCWProxyImpl(this._value);

  final FlakyJob _value;

  @override
  FlakyJob id(int id) => this(id: id);

  @override
  FlakyJob repo(String repo) => this(repo: repo);

  @override
  FlakyJob workflow(String workflow) => this(workflow: workflow);

  @override
  FlakyJob job(String job) => this(job: job);

  @override
  FlakyJob title(String title) => this(title: title);

  @override
  FlakyJob flaky(int flaky) => this(flaky: flaky);

  @override
  FlakyJob failures(int failures) => this(failures: failures);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FlakyJob(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FlakyJob(...).copyWith(id: 12, name: "My name")
  /// ````
  FlakyJob call({
    Object? id = const $CopyWithPlaceholder(),
    Object? repo = const $CopyWithPlaceholder(),
    Object? workflow = const $CopyWithPlaceholder(),
    Object? job = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? flaky = const $CopyWithPlaceholder(),
    Object? failures = const $CopyWithPlaceholder(),
  }) {
    return FlakyJob(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      repo: repo == const $CopyWithPlaceholder()
          ? _value.repo
          // ignore: cast_nullable_to_non_nullable
          : repo as String,
      workflow: workflow == const $CopyWithPlaceholder()
          ? _value.workflow
          // ignore: cast_nullable_to_non_nullable
          : workflow as String,
      job: job == const $CopyWithPlaceholder()
          ? _value.job
          // ignore: cast_nullable_to_non_nullable
          : job as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      flaky: flaky == const $CopyWithPlaceholder()
          ? _value.flaky
          // ignore: cast_nullable_to_non_nullable
          : flaky as int,
      failures: failures == const $CopyWithPlaceholder()
          ? _value.failures
          // ignore: cast_nullable_to_non_nullable
          : failures as int,
    );
  }
}

extension $FlakyJobCopyWith on FlakyJob {
  /// Returns a callable class that can be used as follows: `instanceOfFlakyJob.copyWith(...)` or like so:`instanceOfFlakyJob.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FlakyJobCWProxy get copyWith => _$FlakyJobCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlakyJob _$FlakyJobFromJson(Map<String, dynamic> json) =>
    $checkedCreate('FlakyJob', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'repo',
          'workflow',
          'job',
          'title',
          'flaky',
          'failures',
        ],
      );
      final val = FlakyJob(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        repo: $checkedConvert('repo', (v) => v as String),
        workflow: $checkedConvert('workflow', (v) => v as String),
        job: $checkedConvert('job', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        flaky: $checkedConvert('flaky', (v) => (v as num).toInt()),
        failures: $checkedConvert('failures', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$FlakyJobToJson(FlakyJob instance) => <String, dynamic>{
  'id': instance.id,
  'repo': instance.repo,
  'workflow': instance.workflow,
  'job': instance.job,
  'title': instance.title,
  'flaky': instance.flaky,
  'failures': instance.failures,
};

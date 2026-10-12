// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ci_occurrence.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CIOccurrenceCWProxy {
  CIOccurrence runId(int runId);

  CIOccurrence url(String url);

  CIOccurrence sha(String sha);

  CIOccurrence job(String job);

  CIOccurrence at(DateTime at);

  CIOccurrence flaky(bool? flaky);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CIOccurrence(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CIOccurrence(...).copyWith(id: 12, name: "My name")
  /// ````
  CIOccurrence call({
    int runId,
    String url,
    String sha,
    String job,
    DateTime at,
    bool? flaky,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCIOccurrence.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCIOccurrence.copyWith.fieldName(...)`
class _$CIOccurrenceCWProxyImpl implements _$CIOccurrenceCWProxy {
  const _$CIOccurrenceCWProxyImpl(this._value);

  final CIOccurrence _value;

  @override
  CIOccurrence runId(int runId) => this(runId: runId);

  @override
  CIOccurrence url(String url) => this(url: url);

  @override
  CIOccurrence sha(String sha) => this(sha: sha);

  @override
  CIOccurrence job(String job) => this(job: job);

  @override
  CIOccurrence at(DateTime at) => this(at: at);

  @override
  CIOccurrence flaky(bool? flaky) => this(flaky: flaky);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CIOccurrence(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CIOccurrence(...).copyWith(id: 12, name: "My name")
  /// ````
  CIOccurrence call({
    Object? runId = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? sha = const $CopyWithPlaceholder(),
    Object? job = const $CopyWithPlaceholder(),
    Object? at = const $CopyWithPlaceholder(),
    Object? flaky = const $CopyWithPlaceholder(),
  }) {
    return CIOccurrence(
      runId: runId == const $CopyWithPlaceholder()
          ? _value.runId
          // ignore: cast_nullable_to_non_nullable
          : runId as int,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      sha: sha == const $CopyWithPlaceholder()
          ? _value.sha
          // ignore: cast_nullable_to_non_nullable
          : sha as String,
      job: job == const $CopyWithPlaceholder()
          ? _value.job
          // ignore: cast_nullable_to_non_nullable
          : job as String,
      at: at == const $CopyWithPlaceholder()
          ? _value.at
          // ignore: cast_nullable_to_non_nullable
          : at as DateTime,
      flaky: flaky == const $CopyWithPlaceholder()
          ? _value.flaky
          // ignore: cast_nullable_to_non_nullable
          : flaky as bool?,
    );
  }
}

extension $CIOccurrenceCopyWith on CIOccurrence {
  /// Returns a callable class that can be used as follows: `instanceOfCIOccurrence.copyWith(...)` or like so:`instanceOfCIOccurrence.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CIOccurrenceCWProxy get copyWith => _$CIOccurrenceCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CIOccurrence _$CIOccurrenceFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CIOccurrence', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['runId', 'url', 'sha', 'job', 'at'],
      );
      final val = CIOccurrence(
        runId: $checkedConvert('runId', (v) => (v as num).toInt()),
        url: $checkedConvert('url', (v) => v as String),
        sha: $checkedConvert('sha', (v) => v as String),
        job: $checkedConvert('job', (v) => v as String),
        at: $checkedConvert('at', (v) => DateTime.parse(v as String)),
        flaky: $checkedConvert('flaky', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$CIOccurrenceToJson(CIOccurrence instance) =>
    <String, dynamic>{
      'runId': instance.runId,
      'url': instance.url,
      'sha': instance.sha,
      'job': instance.job,
      'at': instance.at.toIso8601String(),
      'flaky': ?instance.flaky,
    };

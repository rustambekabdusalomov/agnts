// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swagger_results.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SwaggerResultsCWProxy {
  SwaggerResults test(SwaggerTestView test);

  SwaggerResults runId(int? runId);

  SwaggerResults createdAt(DateTime? createdAt);

  SwaggerResults status(String? status);

  SwaggerResults summary(String? summary);

  SwaggerResults counts(ApiCounts? counts);

  SwaggerResults cases(List<ApiCase> cases);

  SwaggerResults requests(List<ApiRequestRow> requests);

  SwaggerResults notes(List<String> notes);

  SwaggerResults previous(ApiCounts? previous);

  SwaggerResults newFailures(List<String> newFailures);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerResults(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerResults(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerResults call({
    SwaggerTestView test,
    int? runId,
    DateTime? createdAt,
    String? status,
    String? summary,
    ApiCounts? counts,
    List<ApiCase> cases,
    List<ApiRequestRow> requests,
    List<String> notes,
    ApiCounts? previous,
    List<String> newFailures,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSwaggerResults.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSwaggerResults.copyWith.fieldName(...)`
class _$SwaggerResultsCWProxyImpl implements _$SwaggerResultsCWProxy {
  const _$SwaggerResultsCWProxyImpl(this._value);

  final SwaggerResults _value;

  @override
  SwaggerResults test(SwaggerTestView test) => this(test: test);

  @override
  SwaggerResults runId(int? runId) => this(runId: runId);

  @override
  SwaggerResults createdAt(DateTime? createdAt) => this(createdAt: createdAt);

  @override
  SwaggerResults status(String? status) => this(status: status);

  @override
  SwaggerResults summary(String? summary) => this(summary: summary);

  @override
  SwaggerResults counts(ApiCounts? counts) => this(counts: counts);

  @override
  SwaggerResults cases(List<ApiCase> cases) => this(cases: cases);

  @override
  SwaggerResults requests(List<ApiRequestRow> requests) =>
      this(requests: requests);

  @override
  SwaggerResults notes(List<String> notes) => this(notes: notes);

  @override
  SwaggerResults previous(ApiCounts? previous) => this(previous: previous);

  @override
  SwaggerResults newFailures(List<String> newFailures) =>
      this(newFailures: newFailures);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerResults(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerResults(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerResults call({
    Object? test = const $CopyWithPlaceholder(),
    Object? runId = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? summary = const $CopyWithPlaceholder(),
    Object? counts = const $CopyWithPlaceholder(),
    Object? cases = const $CopyWithPlaceholder(),
    Object? requests = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? previous = const $CopyWithPlaceholder(),
    Object? newFailures = const $CopyWithPlaceholder(),
  }) {
    return SwaggerResults(
      test: test == const $CopyWithPlaceholder()
          ? _value.test
          // ignore: cast_nullable_to_non_nullable
          : test as SwaggerTestView,
      runId: runId == const $CopyWithPlaceholder()
          ? _value.runId
          // ignore: cast_nullable_to_non_nullable
          : runId as int?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String?,
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as String?,
      counts: counts == const $CopyWithPlaceholder()
          ? _value.counts
          // ignore: cast_nullable_to_non_nullable
          : counts as ApiCounts?,
      cases: cases == const $CopyWithPlaceholder()
          ? _value.cases
          // ignore: cast_nullable_to_non_nullable
          : cases as List<ApiCase>,
      requests: requests == const $CopyWithPlaceholder()
          ? _value.requests
          // ignore: cast_nullable_to_non_nullable
          : requests as List<ApiRequestRow>,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as List<String>,
      previous: previous == const $CopyWithPlaceholder()
          ? _value.previous
          // ignore: cast_nullable_to_non_nullable
          : previous as ApiCounts?,
      newFailures: newFailures == const $CopyWithPlaceholder()
          ? _value.newFailures
          // ignore: cast_nullable_to_non_nullable
          : newFailures as List<String>,
    );
  }
}

extension $SwaggerResultsCopyWith on SwaggerResults {
  /// Returns a callable class that can be used as follows: `instanceOfSwaggerResults.copyWith(...)` or like so:`instanceOfSwaggerResults.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SwaggerResultsCWProxy get copyWith => _$SwaggerResultsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwaggerResults _$SwaggerResultsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SwaggerResults', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'test',
          'cases',
          'requests',
          'notes',
          'newFailures',
        ],
      );
      final val = SwaggerResults(
        test: $checkedConvert(
          'test',
          (v) => SwaggerTestView.fromJson(v as Map<String, dynamic>),
        ),
        runId: $checkedConvert('runId', (v) => (v as num?)?.toInt()),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        status: $checkedConvert('status', (v) => v as String?),
        summary: $checkedConvert('summary', (v) => v as String?),
        counts: $checkedConvert(
          'counts',
          (v) =>
              v == null ? null : ApiCounts.fromJson(v as Map<String, dynamic>),
        ),
        cases: $checkedConvert(
          'cases',
          (v) => (v as List<dynamic>)
              .map((e) => ApiCase.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        requests: $checkedConvert(
          'requests',
          (v) => (v as List<dynamic>)
              .map((e) => ApiRequestRow.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        notes: $checkedConvert(
          'notes',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        previous: $checkedConvert(
          'previous',
          (v) =>
              v == null ? null : ApiCounts.fromJson(v as Map<String, dynamic>),
        ),
        newFailures: $checkedConvert(
          'newFailures',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SwaggerResultsToJson(SwaggerResults instance) =>
    <String, dynamic>{
      'test': instance.test.toJson(),
      'runId': ?instance.runId,
      'createdAt': ?instance.createdAt?.toIso8601String(),
      'status': ?instance.status,
      'summary': ?instance.summary,
      'counts': ?instance.counts?.toJson(),
      'cases': instance.cases.map((e) => e.toJson()).toList(),
      'requests': instance.requests.map((e) => e.toJson()).toList(),
      'notes': instance.notes,
      'previous': ?instance.previous?.toJson(),
      'newFailures': instance.newFailures,
    };

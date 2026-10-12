// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coverage.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CoverageCWProxy {
  Coverage covered(int covered);

  Coverage total(int total);

  Coverage percent(num percent);

  Coverage threshold(int? threshold);

  Coverage error(String? error);

  Coverage files(List<CoverageFilesInner> files);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Coverage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Coverage(...).copyWith(id: 12, name: "My name")
  /// ````
  Coverage call({
    int covered,
    int total,
    num percent,
    int? threshold,
    String? error,
    List<CoverageFilesInner> files,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCoverage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCoverage.copyWith.fieldName(...)`
class _$CoverageCWProxyImpl implements _$CoverageCWProxy {
  const _$CoverageCWProxyImpl(this._value);

  final Coverage _value;

  @override
  Coverage covered(int covered) => this(covered: covered);

  @override
  Coverage total(int total) => this(total: total);

  @override
  Coverage percent(num percent) => this(percent: percent);

  @override
  Coverage threshold(int? threshold) => this(threshold: threshold);

  @override
  Coverage error(String? error) => this(error: error);

  @override
  Coverage files(List<CoverageFilesInner> files) => this(files: files);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Coverage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Coverage(...).copyWith(id: 12, name: "My name")
  /// ````
  Coverage call({
    Object? covered = const $CopyWithPlaceholder(),
    Object? total = const $CopyWithPlaceholder(),
    Object? percent = const $CopyWithPlaceholder(),
    Object? threshold = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
    Object? files = const $CopyWithPlaceholder(),
  }) {
    return Coverage(
      covered: covered == const $CopyWithPlaceholder()
          ? _value.covered
          // ignore: cast_nullable_to_non_nullable
          : covered as int,
      total: total == const $CopyWithPlaceholder()
          ? _value.total
          // ignore: cast_nullable_to_non_nullable
          : total as int,
      percent: percent == const $CopyWithPlaceholder()
          ? _value.percent
          // ignore: cast_nullable_to_non_nullable
          : percent as num,
      threshold: threshold == const $CopyWithPlaceholder()
          ? _value.threshold
          // ignore: cast_nullable_to_non_nullable
          : threshold as int?,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String?,
      files: files == const $CopyWithPlaceholder()
          ? _value.files
          // ignore: cast_nullable_to_non_nullable
          : files as List<CoverageFilesInner>,
    );
  }
}

extension $CoverageCopyWith on Coverage {
  /// Returns a callable class that can be used as follows: `instanceOfCoverage.copyWith(...)` or like so:`instanceOfCoverage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CoverageCWProxy get copyWith => _$CoverageCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Coverage _$CoverageFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Coverage',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['covered', 'total', 'percent', 'files'],
    );
    final val = Coverage(
      covered: $checkedConvert('covered', (v) => (v as num).toInt()),
      total: $checkedConvert('total', (v) => (v as num).toInt()),
      percent: $checkedConvert('percent', (v) => v as num),
      threshold: $checkedConvert('threshold', (v) => (v as num?)?.toInt()),
      error: $checkedConvert('error', (v) => v as String?),
      files: $checkedConvert(
        'files',
        (v) => (v as List<dynamic>)
            .map((e) => CoverageFilesInner.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
);

Map<String, dynamic> _$CoverageToJson(Coverage instance) => <String, dynamic>{
  'covered': instance.covered,
  'total': instance.total,
  'percent': instance.percent,
  'threshold': ?instance.threshold,
  'error': ?instance.error,
  'files': instance.files.map((e) => e.toJson()).toList(),
};

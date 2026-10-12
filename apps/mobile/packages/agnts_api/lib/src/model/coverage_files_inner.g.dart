// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coverage_files_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CoverageFilesInnerCWProxy {
  CoverageFilesInner path(String path);

  CoverageFilesInner covered(int covered);

  CoverageFilesInner total(int total);

  CoverageFilesInner uncovered(
    List<CoverageFilesInnerUncoveredInner> uncovered,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoverageFilesInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoverageFilesInner(...).copyWith(id: 12, name: "My name")
  /// ````
  CoverageFilesInner call({
    String path,
    int covered,
    int total,
    List<CoverageFilesInnerUncoveredInner> uncovered,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCoverageFilesInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCoverageFilesInner.copyWith.fieldName(...)`
class _$CoverageFilesInnerCWProxyImpl implements _$CoverageFilesInnerCWProxy {
  const _$CoverageFilesInnerCWProxyImpl(this._value);

  final CoverageFilesInner _value;

  @override
  CoverageFilesInner path(String path) => this(path: path);

  @override
  CoverageFilesInner covered(int covered) => this(covered: covered);

  @override
  CoverageFilesInner total(int total) => this(total: total);

  @override
  CoverageFilesInner uncovered(
    List<CoverageFilesInnerUncoveredInner> uncovered,
  ) => this(uncovered: uncovered);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoverageFilesInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoverageFilesInner(...).copyWith(id: 12, name: "My name")
  /// ````
  CoverageFilesInner call({
    Object? path = const $CopyWithPlaceholder(),
    Object? covered = const $CopyWithPlaceholder(),
    Object? total = const $CopyWithPlaceholder(),
    Object? uncovered = const $CopyWithPlaceholder(),
  }) {
    return CoverageFilesInner(
      path: path == const $CopyWithPlaceholder()
          ? _value.path
          // ignore: cast_nullable_to_non_nullable
          : path as String,
      covered: covered == const $CopyWithPlaceholder()
          ? _value.covered
          // ignore: cast_nullable_to_non_nullable
          : covered as int,
      total: total == const $CopyWithPlaceholder()
          ? _value.total
          // ignore: cast_nullable_to_non_nullable
          : total as int,
      uncovered: uncovered == const $CopyWithPlaceholder()
          ? _value.uncovered
          // ignore: cast_nullable_to_non_nullable
          : uncovered as List<CoverageFilesInnerUncoveredInner>,
    );
  }
}

extension $CoverageFilesInnerCopyWith on CoverageFilesInner {
  /// Returns a callable class that can be used as follows: `instanceOfCoverageFilesInner.copyWith(...)` or like so:`instanceOfCoverageFilesInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CoverageFilesInnerCWProxy get copyWith =>
      _$CoverageFilesInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoverageFilesInner _$CoverageFilesInnerFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CoverageFilesInner', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['path', 'covered', 'total', 'uncovered'],
      );
      final val = CoverageFilesInner(
        path: $checkedConvert('path', (v) => v as String),
        covered: $checkedConvert('covered', (v) => (v as num).toInt()),
        total: $checkedConvert('total', (v) => (v as num).toInt()),
        uncovered: $checkedConvert(
          'uncovered',
          (v) => (v as List<dynamic>)
              .map(
                (e) => CoverageFilesInnerUncoveredInner.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CoverageFilesInnerToJson(CoverageFilesInner instance) =>
    <String, dynamic>{
      'path': instance.path,
      'covered': instance.covered,
      'total': instance.total,
      'uncovered': instance.uncovered.map((e) => e.toJson()).toList(),
    };

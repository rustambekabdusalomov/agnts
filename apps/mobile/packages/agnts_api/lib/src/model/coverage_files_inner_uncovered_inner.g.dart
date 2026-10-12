// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coverage_files_inner_uncovered_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CoverageFilesInnerUncoveredInnerCWProxy {
  CoverageFilesInnerUncoveredInner from(int from);

  CoverageFilesInnerUncoveredInner to(int to);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoverageFilesInnerUncoveredInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoverageFilesInnerUncoveredInner(...).copyWith(id: 12, name: "My name")
  /// ````
  CoverageFilesInnerUncoveredInner call({int from, int to});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCoverageFilesInnerUncoveredInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCoverageFilesInnerUncoveredInner.copyWith.fieldName(...)`
class _$CoverageFilesInnerUncoveredInnerCWProxyImpl
    implements _$CoverageFilesInnerUncoveredInnerCWProxy {
  const _$CoverageFilesInnerUncoveredInnerCWProxyImpl(this._value);

  final CoverageFilesInnerUncoveredInner _value;

  @override
  CoverageFilesInnerUncoveredInner from(int from) => this(from: from);

  @override
  CoverageFilesInnerUncoveredInner to(int to) => this(to: to);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoverageFilesInnerUncoveredInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoverageFilesInnerUncoveredInner(...).copyWith(id: 12, name: "My name")
  /// ````
  CoverageFilesInnerUncoveredInner call({
    Object? from = const $CopyWithPlaceholder(),
    Object? to = const $CopyWithPlaceholder(),
  }) {
    return CoverageFilesInnerUncoveredInner(
      from: from == const $CopyWithPlaceholder()
          ? _value.from
          // ignore: cast_nullable_to_non_nullable
          : from as int,
      to: to == const $CopyWithPlaceholder()
          ? _value.to
          // ignore: cast_nullable_to_non_nullable
          : to as int,
    );
  }
}

extension $CoverageFilesInnerUncoveredInnerCopyWith
    on CoverageFilesInnerUncoveredInner {
  /// Returns a callable class that can be used as follows: `instanceOfCoverageFilesInnerUncoveredInner.copyWith(...)` or like so:`instanceOfCoverageFilesInnerUncoveredInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CoverageFilesInnerUncoveredInnerCWProxy get copyWith =>
      _$CoverageFilesInnerUncoveredInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoverageFilesInnerUncoveredInner _$CoverageFilesInnerUncoveredInnerFromJson(
  Map<String, dynamic> json,
) =>
    $checkedCreate('CoverageFilesInnerUncoveredInner', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['from', 'to']);
      final val = CoverageFilesInnerUncoveredInner(
        from: $checkedConvert('from', (v) => (v as num).toInt()),
        to: $checkedConvert('to', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$CoverageFilesInnerUncoveredInnerToJson(
  CoverageFilesInnerUncoveredInner instance,
) => <String, dynamic>{'from': instance.from, 'to': instance.to};

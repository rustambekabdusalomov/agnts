// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ci_watch.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CIWatchCWProxy {
  CIWatch enabled(bool enabled);

  CIWatch branches(List<String> branches);

  CIWatch ignore(List<String> ignore);

  CIWatch prs(String prs);

  CIWatch autoFix(bool? autoFix);

  CIWatch problem(String? problem);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CIWatch(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CIWatch(...).copyWith(id: 12, name: "My name")
  /// ````
  CIWatch call({
    bool enabled,
    List<String> branches,
    List<String> ignore,
    String prs,
    bool? autoFix,
    String? problem,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCIWatch.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCIWatch.copyWith.fieldName(...)`
class _$CIWatchCWProxyImpl implements _$CIWatchCWProxy {
  const _$CIWatchCWProxyImpl(this._value);

  final CIWatch _value;

  @override
  CIWatch enabled(bool enabled) => this(enabled: enabled);

  @override
  CIWatch branches(List<String> branches) => this(branches: branches);

  @override
  CIWatch ignore(List<String> ignore) => this(ignore: ignore);

  @override
  CIWatch prs(String prs) => this(prs: prs);

  @override
  CIWatch autoFix(bool? autoFix) => this(autoFix: autoFix);

  @override
  CIWatch problem(String? problem) => this(problem: problem);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CIWatch(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CIWatch(...).copyWith(id: 12, name: "My name")
  /// ````
  CIWatch call({
    Object? enabled = const $CopyWithPlaceholder(),
    Object? branches = const $CopyWithPlaceholder(),
    Object? ignore = const $CopyWithPlaceholder(),
    Object? prs = const $CopyWithPlaceholder(),
    Object? autoFix = const $CopyWithPlaceholder(),
    Object? problem = const $CopyWithPlaceholder(),
  }) {
    return CIWatch(
      enabled: enabled == const $CopyWithPlaceholder()
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool,
      branches: branches == const $CopyWithPlaceholder()
          ? _value.branches
          // ignore: cast_nullable_to_non_nullable
          : branches as List<String>,
      ignore: ignore == const $CopyWithPlaceholder()
          ? _value.ignore
          // ignore: cast_nullable_to_non_nullable
          : ignore as List<String>,
      prs: prs == const $CopyWithPlaceholder()
          ? _value.prs
          // ignore: cast_nullable_to_non_nullable
          : prs as String,
      autoFix: autoFix == const $CopyWithPlaceholder()
          ? _value.autoFix
          // ignore: cast_nullable_to_non_nullable
          : autoFix as bool?,
      problem: problem == const $CopyWithPlaceholder()
          ? _value.problem
          // ignore: cast_nullable_to_non_nullable
          : problem as String?,
    );
  }
}

extension $CIWatchCopyWith on CIWatch {
  /// Returns a callable class that can be used as follows: `instanceOfCIWatch.copyWith(...)` or like so:`instanceOfCIWatch.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CIWatchCWProxy get copyWith => _$CIWatchCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CIWatch _$CIWatchFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CIWatch', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['enabled', 'branches', 'ignore', 'prs'],
      );
      final val = CIWatch(
        enabled: $checkedConvert('enabled', (v) => v as bool),
        branches: $checkedConvert(
          'branches',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        ignore: $checkedConvert(
          'ignore',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        prs: $checkedConvert('prs', (v) => v as String),
        autoFix: $checkedConvert('autoFix', (v) => v as bool?),
        problem: $checkedConvert('problem', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$CIWatchToJson(CIWatch instance) => <String, dynamic>{
  'enabled': instance.enabled,
  'branches': instance.branches,
  'ignore': instance.ignore,
  'prs': instance.prs,
  'autoFix': ?instance.autoFix,
  'problem': ?instance.problem,
};

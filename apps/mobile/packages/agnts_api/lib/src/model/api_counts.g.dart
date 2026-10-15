// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_counts.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiCountsCWProxy {
  ApiCounts passed(int passed);

  ApiCounts failed(int failed);

  ApiCounts skipped(int skipped);

  ApiCounts blocked(int blocked);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiCounts(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiCounts(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiCounts call({int passed, int failed, int skipped, int blocked});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiCounts.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiCounts.copyWith.fieldName(...)`
class _$ApiCountsCWProxyImpl implements _$ApiCountsCWProxy {
  const _$ApiCountsCWProxyImpl(this._value);

  final ApiCounts _value;

  @override
  ApiCounts passed(int passed) => this(passed: passed);

  @override
  ApiCounts failed(int failed) => this(failed: failed);

  @override
  ApiCounts skipped(int skipped) => this(skipped: skipped);

  @override
  ApiCounts blocked(int blocked) => this(blocked: blocked);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiCounts(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiCounts(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiCounts call({
    Object? passed = const $CopyWithPlaceholder(),
    Object? failed = const $CopyWithPlaceholder(),
    Object? skipped = const $CopyWithPlaceholder(),
    Object? blocked = const $CopyWithPlaceholder(),
  }) {
    return ApiCounts(
      passed: passed == const $CopyWithPlaceholder()
          ? _value.passed
          // ignore: cast_nullable_to_non_nullable
          : passed as int,
      failed: failed == const $CopyWithPlaceholder()
          ? _value.failed
          // ignore: cast_nullable_to_non_nullable
          : failed as int,
      skipped: skipped == const $CopyWithPlaceholder()
          ? _value.skipped
          // ignore: cast_nullable_to_non_nullable
          : skipped as int,
      blocked: blocked == const $CopyWithPlaceholder()
          ? _value.blocked
          // ignore: cast_nullable_to_non_nullable
          : blocked as int,
    );
  }
}

extension $ApiCountsCopyWith on ApiCounts {
  /// Returns a callable class that can be used as follows: `instanceOfApiCounts.copyWith(...)` or like so:`instanceOfApiCounts.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiCountsCWProxy get copyWith => _$ApiCountsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiCounts _$ApiCountsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ApiCounts', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['passed', 'failed', 'skipped', 'blocked'],
      );
      final val = ApiCounts(
        passed: $checkedConvert('passed', (v) => (v as num).toInt()),
        failed: $checkedConvert('failed', (v) => (v as num).toInt()),
        skipped: $checkedConvert('skipped', (v) => (v as num).toInt()),
        blocked: $checkedConvert('blocked', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$ApiCountsToJson(ApiCounts instance) => <String, dynamic>{
  'passed': instance.passed,
  'failed': instance.failed,
  'skipped': instance.skipped,
  'blocked': instance.blocked,
};

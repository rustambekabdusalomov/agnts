// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'benchmark_run.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BenchmarkRunCWProxy {
  BenchmarkRun original(String original);

  BenchmarkRun replay(String? replay);

  BenchmarkRun error(String? error);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BenchmarkRun(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BenchmarkRun(...).copyWith(id: 12, name: "My name")
  /// ````
  BenchmarkRun call({String original, String? replay, String? error});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBenchmarkRun.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBenchmarkRun.copyWith.fieldName(...)`
class _$BenchmarkRunCWProxyImpl implements _$BenchmarkRunCWProxy {
  const _$BenchmarkRunCWProxyImpl(this._value);

  final BenchmarkRun _value;

  @override
  BenchmarkRun original(String original) => this(original: original);

  @override
  BenchmarkRun replay(String? replay) => this(replay: replay);

  @override
  BenchmarkRun error(String? error) => this(error: error);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BenchmarkRun(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BenchmarkRun(...).copyWith(id: 12, name: "My name")
  /// ````
  BenchmarkRun call({
    Object? original = const $CopyWithPlaceholder(),
    Object? replay = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
  }) {
    return BenchmarkRun(
      original: original == const $CopyWithPlaceholder()
          ? _value.original
          // ignore: cast_nullable_to_non_nullable
          : original as String,
      replay: replay == const $CopyWithPlaceholder()
          ? _value.replay
          // ignore: cast_nullable_to_non_nullable
          : replay as String?,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String?,
    );
  }
}

extension $BenchmarkRunCopyWith on BenchmarkRun {
  /// Returns a callable class that can be used as follows: `instanceOfBenchmarkRun.copyWith(...)` or like so:`instanceOfBenchmarkRun.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BenchmarkRunCWProxy get copyWith => _$BenchmarkRunCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BenchmarkRun _$BenchmarkRunFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BenchmarkRun', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['original']);
      final val = BenchmarkRun(
        original: $checkedConvert('original', (v) => v as String),
        replay: $checkedConvert('replay', (v) => v as String?),
        error: $checkedConvert('error', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$BenchmarkRunToJson(BenchmarkRun instance) =>
    <String, dynamic>{
      'original': instance.original,
      'replay': ?instance.replay,
      'error': ?instance.error,
    };

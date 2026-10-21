// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_benchmark_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RunBenchmarkRequestCWProxy {
  RunBenchmarkRequest models(Map<String, String>? models);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RunBenchmarkRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RunBenchmarkRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RunBenchmarkRequest call({Map<String, String>? models});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRunBenchmarkRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRunBenchmarkRequest.copyWith.fieldName(...)`
class _$RunBenchmarkRequestCWProxyImpl implements _$RunBenchmarkRequestCWProxy {
  const _$RunBenchmarkRequestCWProxyImpl(this._value);

  final RunBenchmarkRequest _value;

  @override
  RunBenchmarkRequest models(Map<String, String>? models) =>
      this(models: models);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RunBenchmarkRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RunBenchmarkRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RunBenchmarkRequest call({Object? models = const $CopyWithPlaceholder()}) {
    return RunBenchmarkRequest(
      models: models == const $CopyWithPlaceholder()
          ? _value.models
          // ignore: cast_nullable_to_non_nullable
          : models as Map<String, String>?,
    );
  }
}

extension $RunBenchmarkRequestCopyWith on RunBenchmarkRequest {
  /// Returns a callable class that can be used as follows: `instanceOfRunBenchmarkRequest.copyWith(...)` or like so:`instanceOfRunBenchmarkRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RunBenchmarkRequestCWProxy get copyWith =>
      _$RunBenchmarkRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RunBenchmarkRequest _$RunBenchmarkRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RunBenchmarkRequest', json, ($checkedConvert) {
      final val = RunBenchmarkRequest(
        models: $checkedConvert(
          'models',
          (v) => (v as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ),
        ),
      );
      return val;
    });

Map<String, dynamic> _$RunBenchmarkRequestToJson(
  RunBenchmarkRequest instance,
) => <String, dynamic>{'models': ?instance.models};

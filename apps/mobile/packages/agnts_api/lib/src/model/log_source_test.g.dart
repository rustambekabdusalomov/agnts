// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_source_test.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LogSourceTestCWProxy {
  LogSourceTest version(String version);

  LogSourceTest fields(LogFields fields);

  LogSourceTest labels(List<String> labels);

  LogSourceTest sample(String sample);

  LogSourceTest newest(DateTime? newest);

  LogSourceTest network(String network);

  LogSourceTest latencyMs(int latencyMs);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogSourceTest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogSourceTest(...).copyWith(id: 12, name: "My name")
  /// ````
  LogSourceTest call({
    String version,
    LogFields fields,
    List<String> labels,
    String sample,
    DateTime? newest,
    String network,
    int latencyMs,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLogSourceTest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLogSourceTest.copyWith.fieldName(...)`
class _$LogSourceTestCWProxyImpl implements _$LogSourceTestCWProxy {
  const _$LogSourceTestCWProxyImpl(this._value);

  final LogSourceTest _value;

  @override
  LogSourceTest version(String version) => this(version: version);

  @override
  LogSourceTest fields(LogFields fields) => this(fields: fields);

  @override
  LogSourceTest labels(List<String> labels) => this(labels: labels);

  @override
  LogSourceTest sample(String sample) => this(sample: sample);

  @override
  LogSourceTest newest(DateTime? newest) => this(newest: newest);

  @override
  LogSourceTest network(String network) => this(network: network);

  @override
  LogSourceTest latencyMs(int latencyMs) => this(latencyMs: latencyMs);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogSourceTest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogSourceTest(...).copyWith(id: 12, name: "My name")
  /// ````
  LogSourceTest call({
    Object? version = const $CopyWithPlaceholder(),
    Object? fields = const $CopyWithPlaceholder(),
    Object? labels = const $CopyWithPlaceholder(),
    Object? sample = const $CopyWithPlaceholder(),
    Object? newest = const $CopyWithPlaceholder(),
    Object? network = const $CopyWithPlaceholder(),
    Object? latencyMs = const $CopyWithPlaceholder(),
  }) {
    return LogSourceTest(
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as String,
      fields: fields == const $CopyWithPlaceholder()
          ? _value.fields
          // ignore: cast_nullable_to_non_nullable
          : fields as LogFields,
      labels: labels == const $CopyWithPlaceholder()
          ? _value.labels
          // ignore: cast_nullable_to_non_nullable
          : labels as List<String>,
      sample: sample == const $CopyWithPlaceholder()
          ? _value.sample
          // ignore: cast_nullable_to_non_nullable
          : sample as String,
      newest: newest == const $CopyWithPlaceholder()
          ? _value.newest
          // ignore: cast_nullable_to_non_nullable
          : newest as DateTime?,
      network: network == const $CopyWithPlaceholder()
          ? _value.network
          // ignore: cast_nullable_to_non_nullable
          : network as String,
      latencyMs: latencyMs == const $CopyWithPlaceholder()
          ? _value.latencyMs
          // ignore: cast_nullable_to_non_nullable
          : latencyMs as int,
    );
  }
}

extension $LogSourceTestCopyWith on LogSourceTest {
  /// Returns a callable class that can be used as follows: `instanceOfLogSourceTest.copyWith(...)` or like so:`instanceOfLogSourceTest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LogSourceTestCWProxy get copyWith => _$LogSourceTestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogSourceTest _$LogSourceTestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LogSourceTest', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'version',
          'fields',
          'labels',
          'sample',
          'network',
          'latencyMs',
        ],
      );
      final val = LogSourceTest(
        version: $checkedConvert('version', (v) => v as String),
        fields: $checkedConvert(
          'fields',
          (v) => LogFields.fromJson(v as Map<String, dynamic>),
        ),
        labels: $checkedConvert(
          'labels',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        sample: $checkedConvert('sample', (v) => v as String),
        newest: $checkedConvert(
          'newest',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        network: $checkedConvert('network', (v) => v as String),
        latencyMs: $checkedConvert('latencyMs', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$LogSourceTestToJson(LogSourceTest instance) =>
    <String, dynamic>{
      'version': instance.version,
      'fields': instance.fields.toJson(),
      'labels': instance.labels,
      'sample': instance.sample,
      'newest': ?instance.newest?.toIso8601String(),
      'network': instance.network,
      'latencyMs': instance.latencyMs,
    };

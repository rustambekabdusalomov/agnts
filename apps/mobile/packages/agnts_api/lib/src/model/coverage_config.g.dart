// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coverage_config.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CoverageConfigCWProxy {
  CoverageConfig enabled(bool? enabled);

  CoverageConfig command(String? command);

  CoverageConfig report(String? report);

  CoverageConfig threshold(int? threshold);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoverageConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoverageConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  CoverageConfig call({
    bool? enabled,
    String? command,
    String? report,
    int? threshold,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCoverageConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCoverageConfig.copyWith.fieldName(...)`
class _$CoverageConfigCWProxyImpl implements _$CoverageConfigCWProxy {
  const _$CoverageConfigCWProxyImpl(this._value);

  final CoverageConfig _value;

  @override
  CoverageConfig enabled(bool? enabled) => this(enabled: enabled);

  @override
  CoverageConfig command(String? command) => this(command: command);

  @override
  CoverageConfig report(String? report) => this(report: report);

  @override
  CoverageConfig threshold(int? threshold) => this(threshold: threshold);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoverageConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoverageConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  CoverageConfig call({
    Object? enabled = const $CopyWithPlaceholder(),
    Object? command = const $CopyWithPlaceholder(),
    Object? report = const $CopyWithPlaceholder(),
    Object? threshold = const $CopyWithPlaceholder(),
  }) {
    return CoverageConfig(
      enabled: enabled == const $CopyWithPlaceholder()
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool?,
      command: command == const $CopyWithPlaceholder()
          ? _value.command
          // ignore: cast_nullable_to_non_nullable
          : command as String?,
      report: report == const $CopyWithPlaceholder()
          ? _value.report
          // ignore: cast_nullable_to_non_nullable
          : report as String?,
      threshold: threshold == const $CopyWithPlaceholder()
          ? _value.threshold
          // ignore: cast_nullable_to_non_nullable
          : threshold as int?,
    );
  }
}

extension $CoverageConfigCopyWith on CoverageConfig {
  /// Returns a callable class that can be used as follows: `instanceOfCoverageConfig.copyWith(...)` or like so:`instanceOfCoverageConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CoverageConfigCWProxy get copyWith => _$CoverageConfigCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoverageConfig _$CoverageConfigFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CoverageConfig', json, ($checkedConvert) {
      final val = CoverageConfig(
        enabled: $checkedConvert('enabled', (v) => v as bool?),
        command: $checkedConvert('command', (v) => v as String?),
        report: $checkedConvert('report', (v) => v as String?),
        threshold: $checkedConvert('threshold', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$CoverageConfigToJson(CoverageConfig instance) =>
    <String, dynamic>{
      'enabled': ?instance.enabled,
      'command': ?instance.command,
      'report': ?instance.report,
      'threshold': ?instance.threshold,
    };

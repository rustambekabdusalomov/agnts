// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_override.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LogOverrideCWProxy {
  LogOverride repoId(int? repoId);

  LogOverride service(String? service);

  LogOverride errors(LogMode? errors);

  LogOverride security(LogMode? security);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogOverride(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogOverride(...).copyWith(id: 12, name: "My name")
  /// ````
  LogOverride call({
    int? repoId,
    String? service,
    LogMode? errors,
    LogMode? security,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLogOverride.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLogOverride.copyWith.fieldName(...)`
class _$LogOverrideCWProxyImpl implements _$LogOverrideCWProxy {
  const _$LogOverrideCWProxyImpl(this._value);

  final LogOverride _value;

  @override
  LogOverride repoId(int? repoId) => this(repoId: repoId);

  @override
  LogOverride service(String? service) => this(service: service);

  @override
  LogOverride errors(LogMode? errors) => this(errors: errors);

  @override
  LogOverride security(LogMode? security) => this(security: security);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogOverride(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogOverride(...).copyWith(id: 12, name: "My name")
  /// ````
  LogOverride call({
    Object? repoId = const $CopyWithPlaceholder(),
    Object? service = const $CopyWithPlaceholder(),
    Object? errors = const $CopyWithPlaceholder(),
    Object? security = const $CopyWithPlaceholder(),
  }) {
    return LogOverride(
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int?,
      service: service == const $CopyWithPlaceholder()
          ? _value.service
          // ignore: cast_nullable_to_non_nullable
          : service as String?,
      errors: errors == const $CopyWithPlaceholder()
          ? _value.errors
          // ignore: cast_nullable_to_non_nullable
          : errors as LogMode?,
      security: security == const $CopyWithPlaceholder()
          ? _value.security
          // ignore: cast_nullable_to_non_nullable
          : security as LogMode?,
    );
  }
}

extension $LogOverrideCopyWith on LogOverride {
  /// Returns a callable class that can be used as follows: `instanceOfLogOverride.copyWith(...)` or like so:`instanceOfLogOverride.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LogOverrideCWProxy get copyWith => _$LogOverrideCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogOverride _$LogOverrideFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LogOverride', json, ($checkedConvert) {
      final val = LogOverride(
        repoId: $checkedConvert('repoId', (v) => (v as num?)?.toInt()),
        service: $checkedConvert('service', (v) => v as String?),
        errors: $checkedConvert(
          'errors',
          (v) => $enumDecodeNullable(_$LogModeEnumMap, v),
        ),
        security: $checkedConvert(
          'security',
          (v) => $enumDecodeNullable(_$LogModeEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$LogOverrideToJson(LogOverride instance) =>
    <String, dynamic>{
      'repoId': ?instance.repoId,
      'service': ?instance.service,
      'errors': ?_$LogModeEnumMap[instance.errors],
      'security': ?_$LogModeEnumMap[instance.security],
    };

const _$LogModeEnumMap = {
  LogMode.false_: 'false',
  LogMode.report: 'report',
  LogMode.ticket: 'ticket',
};

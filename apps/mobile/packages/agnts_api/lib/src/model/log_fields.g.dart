// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_fields.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LogFieldsCWProxy {
  LogFields message(String? message);

  LogFields timestamp(String? timestamp);

  LogFields level(String? level);

  LogFields service(String? service);

  LogFields revision(String? revision);

  LogFields traceUrl(String? traceUrl);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogFields(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogFields(...).copyWith(id: 12, name: "My name")
  /// ````
  LogFields call({
    String? message,
    String? timestamp,
    String? level,
    String? service,
    String? revision,
    String? traceUrl,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLogFields.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLogFields.copyWith.fieldName(...)`
class _$LogFieldsCWProxyImpl implements _$LogFieldsCWProxy {
  const _$LogFieldsCWProxyImpl(this._value);

  final LogFields _value;

  @override
  LogFields message(String? message) => this(message: message);

  @override
  LogFields timestamp(String? timestamp) => this(timestamp: timestamp);

  @override
  LogFields level(String? level) => this(level: level);

  @override
  LogFields service(String? service) => this(service: service);

  @override
  LogFields revision(String? revision) => this(revision: revision);

  @override
  LogFields traceUrl(String? traceUrl) => this(traceUrl: traceUrl);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogFields(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogFields(...).copyWith(id: 12, name: "My name")
  /// ````
  LogFields call({
    Object? message = const $CopyWithPlaceholder(),
    Object? timestamp = const $CopyWithPlaceholder(),
    Object? level = const $CopyWithPlaceholder(),
    Object? service = const $CopyWithPlaceholder(),
    Object? revision = const $CopyWithPlaceholder(),
    Object? traceUrl = const $CopyWithPlaceholder(),
  }) {
    return LogFields(
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String?,
      timestamp: timestamp == const $CopyWithPlaceholder()
          ? _value.timestamp
          // ignore: cast_nullable_to_non_nullable
          : timestamp as String?,
      level: level == const $CopyWithPlaceholder()
          ? _value.level
          // ignore: cast_nullable_to_non_nullable
          : level as String?,
      service: service == const $CopyWithPlaceholder()
          ? _value.service
          // ignore: cast_nullable_to_non_nullable
          : service as String?,
      revision: revision == const $CopyWithPlaceholder()
          ? _value.revision
          // ignore: cast_nullable_to_non_nullable
          : revision as String?,
      traceUrl: traceUrl == const $CopyWithPlaceholder()
          ? _value.traceUrl
          // ignore: cast_nullable_to_non_nullable
          : traceUrl as String?,
    );
  }
}

extension $LogFieldsCopyWith on LogFields {
  /// Returns a callable class that can be used as follows: `instanceOfLogFields.copyWith(...)` or like so:`instanceOfLogFields.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LogFieldsCWProxy get copyWith => _$LogFieldsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogFields _$LogFieldsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LogFields', json, ($checkedConvert) {
      final val = LogFields(
        message: $checkedConvert('message', (v) => v as String?),
        timestamp: $checkedConvert('timestamp', (v) => v as String?),
        level: $checkedConvert('level', (v) => v as String?),
        service: $checkedConvert('service', (v) => v as String?),
        revision: $checkedConvert('revision', (v) => v as String?),
        traceUrl: $checkedConvert('traceUrl', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$LogFieldsToJson(LogFields instance) => <String, dynamic>{
  'message': ?instance.message,
  'timestamp': ?instance.timestamp,
  'level': ?instance.level,
  'service': ?instance.service,
  'revision': ?instance.revision,
  'traceUrl': ?instance.traceUrl,
};

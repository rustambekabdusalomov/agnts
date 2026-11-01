// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_occurrence.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LogOccurrenceCWProxy {
  LogOccurrence at(DateTime at);

  LogOccurrence sourceId(int sourceId);

  LogOccurrence service(String service);

  LogOccurrence revision(String? revision);

  LogOccurrence count(int count);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogOccurrence(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogOccurrence(...).copyWith(id: 12, name: "My name")
  /// ````
  LogOccurrence call({
    DateTime at,
    int sourceId,
    String service,
    String? revision,
    int count,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLogOccurrence.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLogOccurrence.copyWith.fieldName(...)`
class _$LogOccurrenceCWProxyImpl implements _$LogOccurrenceCWProxy {
  const _$LogOccurrenceCWProxyImpl(this._value);

  final LogOccurrence _value;

  @override
  LogOccurrence at(DateTime at) => this(at: at);

  @override
  LogOccurrence sourceId(int sourceId) => this(sourceId: sourceId);

  @override
  LogOccurrence service(String service) => this(service: service);

  @override
  LogOccurrence revision(String? revision) => this(revision: revision);

  @override
  LogOccurrence count(int count) => this(count: count);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogOccurrence(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogOccurrence(...).copyWith(id: 12, name: "My name")
  /// ````
  LogOccurrence call({
    Object? at = const $CopyWithPlaceholder(),
    Object? sourceId = const $CopyWithPlaceholder(),
    Object? service = const $CopyWithPlaceholder(),
    Object? revision = const $CopyWithPlaceholder(),
    Object? count = const $CopyWithPlaceholder(),
  }) {
    return LogOccurrence(
      at: at == const $CopyWithPlaceholder()
          ? _value.at
          // ignore: cast_nullable_to_non_nullable
          : at as DateTime,
      sourceId: sourceId == const $CopyWithPlaceholder()
          ? _value.sourceId
          // ignore: cast_nullable_to_non_nullable
          : sourceId as int,
      service: service == const $CopyWithPlaceholder()
          ? _value.service
          // ignore: cast_nullable_to_non_nullable
          : service as String,
      revision: revision == const $CopyWithPlaceholder()
          ? _value.revision
          // ignore: cast_nullable_to_non_nullable
          : revision as String?,
      count: count == const $CopyWithPlaceholder()
          ? _value.count
          // ignore: cast_nullable_to_non_nullable
          : count as int,
    );
  }
}

extension $LogOccurrenceCopyWith on LogOccurrence {
  /// Returns a callable class that can be used as follows: `instanceOfLogOccurrence.copyWith(...)` or like so:`instanceOfLogOccurrence.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LogOccurrenceCWProxy get copyWith => _$LogOccurrenceCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogOccurrence _$LogOccurrenceFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LogOccurrence', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['at', 'sourceId', 'service', 'count'],
      );
      final val = LogOccurrence(
        at: $checkedConvert('at', (v) => DateTime.parse(v as String)),
        sourceId: $checkedConvert('sourceId', (v) => (v as num).toInt()),
        service: $checkedConvert('service', (v) => v as String),
        revision: $checkedConvert('revision', (v) => v as String?),
        count: $checkedConvert('count', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$LogOccurrenceToJson(LogOccurrence instance) =>
    <String, dynamic>{
      'at': instance.at.toIso8601String(),
      'sourceId': instance.sourceId,
      'service': instance.service,
      'revision': ?instance.revision,
      'count': instance.count,
    };

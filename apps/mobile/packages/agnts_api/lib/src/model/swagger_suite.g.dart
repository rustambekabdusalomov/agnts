// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swagger_suite.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SwaggerSuiteCWProxy {
  SwaggerSuite id(int id);

  SwaggerSuite name(String name);

  SwaggerSuite specUrl(String? specUrl);

  SwaggerSuite baseUrl(String baseUrl);

  SwaggerSuite operations(int operations);

  SwaggerSuite writeEnabled(bool writeEnabled);

  SwaggerSuite authKind(ApiAuthKind authKind);

  SwaggerSuite hasToken(bool hasToken);

  SwaggerSuite repoId(int? repoId);

  SwaggerSuite schedule(SwaggerSuiteScheduleEnum schedule);

  SwaggerSuite hour(int hour);

  SwaggerSuite enabled(bool enabled);

  SwaggerSuite hookSet(bool hookSet);

  SwaggerSuite lastRunAt(DateTime? lastRunAt);

  SwaggerSuite nextRunAt(DateTime? nextRunAt);

  SwaggerSuite lastTicketKey(String? lastTicketKey);

  SwaggerSuite createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerSuite(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerSuite(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerSuite call({
    int id,
    String name,
    String? specUrl,
    String baseUrl,
    int operations,
    bool writeEnabled,
    ApiAuthKind authKind,
    bool hasToken,
    int? repoId,
    SwaggerSuiteScheduleEnum schedule,
    int hour,
    bool enabled,
    bool hookSet,
    DateTime? lastRunAt,
    DateTime? nextRunAt,
    String? lastTicketKey,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSwaggerSuite.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSwaggerSuite.copyWith.fieldName(...)`
class _$SwaggerSuiteCWProxyImpl implements _$SwaggerSuiteCWProxy {
  const _$SwaggerSuiteCWProxyImpl(this._value);

  final SwaggerSuite _value;

  @override
  SwaggerSuite id(int id) => this(id: id);

  @override
  SwaggerSuite name(String name) => this(name: name);

  @override
  SwaggerSuite specUrl(String? specUrl) => this(specUrl: specUrl);

  @override
  SwaggerSuite baseUrl(String baseUrl) => this(baseUrl: baseUrl);

  @override
  SwaggerSuite operations(int operations) => this(operations: operations);

  @override
  SwaggerSuite writeEnabled(bool writeEnabled) =>
      this(writeEnabled: writeEnabled);

  @override
  SwaggerSuite authKind(ApiAuthKind authKind) => this(authKind: authKind);

  @override
  SwaggerSuite hasToken(bool hasToken) => this(hasToken: hasToken);

  @override
  SwaggerSuite repoId(int? repoId) => this(repoId: repoId);

  @override
  SwaggerSuite schedule(SwaggerSuiteScheduleEnum schedule) =>
      this(schedule: schedule);

  @override
  SwaggerSuite hour(int hour) => this(hour: hour);

  @override
  SwaggerSuite enabled(bool enabled) => this(enabled: enabled);

  @override
  SwaggerSuite hookSet(bool hookSet) => this(hookSet: hookSet);

  @override
  SwaggerSuite lastRunAt(DateTime? lastRunAt) => this(lastRunAt: lastRunAt);

  @override
  SwaggerSuite nextRunAt(DateTime? nextRunAt) => this(nextRunAt: nextRunAt);

  @override
  SwaggerSuite lastTicketKey(String? lastTicketKey) =>
      this(lastTicketKey: lastTicketKey);

  @override
  SwaggerSuite createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerSuite(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerSuite(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerSuite call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? specUrl = const $CopyWithPlaceholder(),
    Object? baseUrl = const $CopyWithPlaceholder(),
    Object? operations = const $CopyWithPlaceholder(),
    Object? writeEnabled = const $CopyWithPlaceholder(),
    Object? authKind = const $CopyWithPlaceholder(),
    Object? hasToken = const $CopyWithPlaceholder(),
    Object? repoId = const $CopyWithPlaceholder(),
    Object? schedule = const $CopyWithPlaceholder(),
    Object? hour = const $CopyWithPlaceholder(),
    Object? enabled = const $CopyWithPlaceholder(),
    Object? hookSet = const $CopyWithPlaceholder(),
    Object? lastRunAt = const $CopyWithPlaceholder(),
    Object? nextRunAt = const $CopyWithPlaceholder(),
    Object? lastTicketKey = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return SwaggerSuite(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      specUrl: specUrl == const $CopyWithPlaceholder()
          ? _value.specUrl
          // ignore: cast_nullable_to_non_nullable
          : specUrl as String?,
      baseUrl: baseUrl == const $CopyWithPlaceholder()
          ? _value.baseUrl
          // ignore: cast_nullable_to_non_nullable
          : baseUrl as String,
      operations: operations == const $CopyWithPlaceholder()
          ? _value.operations
          // ignore: cast_nullable_to_non_nullable
          : operations as int,
      writeEnabled: writeEnabled == const $CopyWithPlaceholder()
          ? _value.writeEnabled
          // ignore: cast_nullable_to_non_nullable
          : writeEnabled as bool,
      authKind: authKind == const $CopyWithPlaceholder()
          ? _value.authKind
          // ignore: cast_nullable_to_non_nullable
          : authKind as ApiAuthKind,
      hasToken: hasToken == const $CopyWithPlaceholder()
          ? _value.hasToken
          // ignore: cast_nullable_to_non_nullable
          : hasToken as bool,
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int?,
      schedule: schedule == const $CopyWithPlaceholder()
          ? _value.schedule
          // ignore: cast_nullable_to_non_nullable
          : schedule as SwaggerSuiteScheduleEnum,
      hour: hour == const $CopyWithPlaceholder()
          ? _value.hour
          // ignore: cast_nullable_to_non_nullable
          : hour as int,
      enabled: enabled == const $CopyWithPlaceholder()
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool,
      hookSet: hookSet == const $CopyWithPlaceholder()
          ? _value.hookSet
          // ignore: cast_nullable_to_non_nullable
          : hookSet as bool,
      lastRunAt: lastRunAt == const $CopyWithPlaceholder()
          ? _value.lastRunAt
          // ignore: cast_nullable_to_non_nullable
          : lastRunAt as DateTime?,
      nextRunAt: nextRunAt == const $CopyWithPlaceholder()
          ? _value.nextRunAt
          // ignore: cast_nullable_to_non_nullable
          : nextRunAt as DateTime?,
      lastTicketKey: lastTicketKey == const $CopyWithPlaceholder()
          ? _value.lastTicketKey
          // ignore: cast_nullable_to_non_nullable
          : lastTicketKey as String?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $SwaggerSuiteCopyWith on SwaggerSuite {
  /// Returns a callable class that can be used as follows: `instanceOfSwaggerSuite.copyWith(...)` or like so:`instanceOfSwaggerSuite.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SwaggerSuiteCWProxy get copyWith => _$SwaggerSuiteCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwaggerSuite _$SwaggerSuiteFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SwaggerSuite', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'name',
          'baseUrl',
          'operations',
          'writeEnabled',
          'authKind',
          'hasToken',
          'schedule',
          'hour',
          'enabled',
          'hookSet',
          'createdAt',
        ],
      );
      final val = SwaggerSuite(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        name: $checkedConvert('name', (v) => v as String),
        specUrl: $checkedConvert('specUrl', (v) => v as String?),
        baseUrl: $checkedConvert('baseUrl', (v) => v as String),
        operations: $checkedConvert('operations', (v) => (v as num).toInt()),
        writeEnabled: $checkedConvert('writeEnabled', (v) => v as bool),
        authKind: $checkedConvert(
          'authKind',
          (v) => $enumDecode(_$ApiAuthKindEnumMap, v),
        ),
        hasToken: $checkedConvert('hasToken', (v) => v as bool),
        repoId: $checkedConvert('repoId', (v) => (v as num?)?.toInt()),
        schedule: $checkedConvert(
          'schedule',
          (v) => $enumDecode(_$SwaggerSuiteScheduleEnumEnumMap, v),
        ),
        hour: $checkedConvert('hour', (v) => (v as num).toInt()),
        enabled: $checkedConvert('enabled', (v) => v as bool),
        hookSet: $checkedConvert('hookSet', (v) => v as bool),
        lastRunAt: $checkedConvert(
          'lastRunAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        nextRunAt: $checkedConvert(
          'nextRunAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        lastTicketKey: $checkedConvert('lastTicketKey', (v) => v as String?),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SwaggerSuiteToJson(SwaggerSuite instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'specUrl': ?instance.specUrl,
      'baseUrl': instance.baseUrl,
      'operations': instance.operations,
      'writeEnabled': instance.writeEnabled,
      'authKind': _$ApiAuthKindEnumMap[instance.authKind]!,
      'hasToken': instance.hasToken,
      'repoId': ?instance.repoId,
      'schedule': _$SwaggerSuiteScheduleEnumEnumMap[instance.schedule]!,
      'hour': instance.hour,
      'enabled': instance.enabled,
      'hookSet': instance.hookSet,
      'lastRunAt': ?instance.lastRunAt?.toIso8601String(),
      'nextRunAt': ?instance.nextRunAt?.toIso8601String(),
      'lastTicketKey': ?instance.lastTicketKey,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$ApiAuthKindEnumMap = {
  ApiAuthKind.none: 'none',
  ApiAuthKind.bearer: 'bearer',
  ApiAuthKind.header: 'header',
  ApiAuthKind.query: 'query',
  ApiAuthKind.basic: 'basic',
};

const _$SwaggerSuiteScheduleEnumEnumMap = {
  SwaggerSuiteScheduleEnum.off: 'off',
  SwaggerSuiteScheduleEnum.hourly: 'hourly',
  SwaggerSuiteScheduleEnum.daily: 'daily',
  SwaggerSuiteScheduleEnum.weekly: 'weekly',
};

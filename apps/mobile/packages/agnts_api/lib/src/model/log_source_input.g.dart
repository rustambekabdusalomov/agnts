// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_source_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LogSourceInputCWProxy {
  LogSourceInput id(int? id);

  LogSourceInput name(String name);

  LogSourceInput kind(LogSourceInputKindEnum kind);

  LogSourceInput environment(LogSourceInputEnvironmentEnum environment);

  LogSourceInput address(String? address);

  LogSourceInput auth(LogAuthInput? auth);

  LogSourceInput caPem(String? caPem);

  LogSourceInput scope(LogScope? scope);

  LogSourceInput fields(LogFields? fields);

  LogSourceInput pollSeconds(int? pollSeconds);

  LogSourceInput enabled(bool enabled);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogSourceInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogSourceInput(...).copyWith(id: 12, name: "My name")
  /// ````
  LogSourceInput call({
    int? id,
    String name,
    LogSourceInputKindEnum kind,
    LogSourceInputEnvironmentEnum environment,
    String? address,
    LogAuthInput? auth,
    String? caPem,
    LogScope? scope,
    LogFields? fields,
    int? pollSeconds,
    bool enabled,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLogSourceInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLogSourceInput.copyWith.fieldName(...)`
class _$LogSourceInputCWProxyImpl implements _$LogSourceInputCWProxy {
  const _$LogSourceInputCWProxyImpl(this._value);

  final LogSourceInput _value;

  @override
  LogSourceInput id(int? id) => this(id: id);

  @override
  LogSourceInput name(String name) => this(name: name);

  @override
  LogSourceInput kind(LogSourceInputKindEnum kind) => this(kind: kind);

  @override
  LogSourceInput environment(LogSourceInputEnvironmentEnum environment) =>
      this(environment: environment);

  @override
  LogSourceInput address(String? address) => this(address: address);

  @override
  LogSourceInput auth(LogAuthInput? auth) => this(auth: auth);

  @override
  LogSourceInput caPem(String? caPem) => this(caPem: caPem);

  @override
  LogSourceInput scope(LogScope? scope) => this(scope: scope);

  @override
  LogSourceInput fields(LogFields? fields) => this(fields: fields);

  @override
  LogSourceInput pollSeconds(int? pollSeconds) =>
      this(pollSeconds: pollSeconds);

  @override
  LogSourceInput enabled(bool enabled) => this(enabled: enabled);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogSourceInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogSourceInput(...).copyWith(id: 12, name: "My name")
  /// ````
  LogSourceInput call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? environment = const $CopyWithPlaceholder(),
    Object? address = const $CopyWithPlaceholder(),
    Object? auth = const $CopyWithPlaceholder(),
    Object? caPem = const $CopyWithPlaceholder(),
    Object? scope = const $CopyWithPlaceholder(),
    Object? fields = const $CopyWithPlaceholder(),
    Object? pollSeconds = const $CopyWithPlaceholder(),
    Object? enabled = const $CopyWithPlaceholder(),
  }) {
    return LogSourceInput(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as LogSourceInputKindEnum,
      environment: environment == const $CopyWithPlaceholder()
          ? _value.environment
          // ignore: cast_nullable_to_non_nullable
          : environment as LogSourceInputEnvironmentEnum,
      address: address == const $CopyWithPlaceholder()
          ? _value.address
          // ignore: cast_nullable_to_non_nullable
          : address as String?,
      auth: auth == const $CopyWithPlaceholder()
          ? _value.auth
          // ignore: cast_nullable_to_non_nullable
          : auth as LogAuthInput?,
      caPem: caPem == const $CopyWithPlaceholder()
          ? _value.caPem
          // ignore: cast_nullable_to_non_nullable
          : caPem as String?,
      scope: scope == const $CopyWithPlaceholder()
          ? _value.scope
          // ignore: cast_nullable_to_non_nullable
          : scope as LogScope?,
      fields: fields == const $CopyWithPlaceholder()
          ? _value.fields
          // ignore: cast_nullable_to_non_nullable
          : fields as LogFields?,
      pollSeconds: pollSeconds == const $CopyWithPlaceholder()
          ? _value.pollSeconds
          // ignore: cast_nullable_to_non_nullable
          : pollSeconds as int?,
      enabled: enabled == const $CopyWithPlaceholder()
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool,
    );
  }
}

extension $LogSourceInputCopyWith on LogSourceInput {
  /// Returns a callable class that can be used as follows: `instanceOfLogSourceInput.copyWith(...)` or like so:`instanceOfLogSourceInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LogSourceInputCWProxy get copyWith => _$LogSourceInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogSourceInput _$LogSourceInputFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('LogSourceInput', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['name', 'kind', 'environment', 'enabled'],
  );
  final val = LogSourceInput(
    id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
    name: $checkedConvert('name', (v) => v as String),
    kind: $checkedConvert(
      'kind',
      (v) => $enumDecode(_$LogSourceInputKindEnumEnumMap, v),
    ),
    environment: $checkedConvert(
      'environment',
      (v) => $enumDecode(_$LogSourceInputEnvironmentEnumEnumMap, v),
    ),
    address: $checkedConvert('address', (v) => v as String?),
    auth: $checkedConvert(
      'auth',
      (v) =>
          v == null ? null : LogAuthInput.fromJson(v as Map<String, dynamic>),
    ),
    caPem: $checkedConvert('caPem', (v) => v as String?),
    scope: $checkedConvert(
      'scope',
      (v) => v == null ? null : LogScope.fromJson(v as Map<String, dynamic>),
    ),
    fields: $checkedConvert(
      'fields',
      (v) => v == null ? null : LogFields.fromJson(v as Map<String, dynamic>),
    ),
    pollSeconds: $checkedConvert('pollSeconds', (v) => (v as num?)?.toInt()),
    enabled: $checkedConvert('enabled', (v) => v as bool),
  );
  return val;
});

Map<String, dynamic> _$LogSourceInputToJson(
  LogSourceInput instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'name': instance.name,
  'kind': _$LogSourceInputKindEnumEnumMap[instance.kind]!,
  'environment': _$LogSourceInputEnvironmentEnumEnumMap[instance.environment]!,
  'address': ?instance.address,
  'auth': ?instance.auth?.toJson(),
  'caPem': ?instance.caPem,
  'scope': ?instance.scope?.toJson(),
  'fields': ?instance.fields?.toJson(),
  'pollSeconds': ?instance.pollSeconds,
  'enabled': instance.enabled,
};

const _$LogSourceInputKindEnumEnumMap = {
  LogSourceInputKindEnum.loki: 'loki',
  LogSourceInputKindEnum.elasticsearch: 'elasticsearch',
  LogSourceInputKindEnum.opensearch: 'opensearch',
  LogSourceInputKindEnum.graylog: 'graylog',
  LogSourceInputKindEnum.datadog: 'datadog',
  LogSourceInputKindEnum.cloudwatch: 'cloudwatch',
  LogSourceInputKindEnum.splunk: 'splunk',
  LogSourceInputKindEnum.push: 'push',
};

const _$LogSourceInputEnvironmentEnumEnumMap = {
  LogSourceInputEnvironmentEnum.production: 'production',
  LogSourceInputEnvironmentEnum.staging: 'staging',
  LogSourceInputEnvironmentEnum.development: 'development',
};

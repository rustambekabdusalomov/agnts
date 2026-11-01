// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_source.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LogSourceCWProxy {
  LogSource id(int id);

  LogSource name(String name);

  LogSource kind(LogSourceKindEnum kind);

  LogSource environment(String environment);

  LogSource address(String address);

  LogSource authKind(String authKind);

  LogSource authUser(String? authUser);

  LogSource authTenant(String? authTenant);

  LogSource hasAuth(bool hasAuth);

  LogSource caPem(String caPem);

  LogSource scope(LogScope scope);

  LogSource fields(LogFields fields);

  LogSource pollSeconds(int pollSeconds);

  LogSource enabled(bool enabled);

  LogSource status(LogSourceStatusEnum status);

  LogSource lastError(String lastError);

  LogSource lastReadAt(DateTime? lastReadAt);

  LogSource gapFrom(DateTime? gapFrom);

  LogSource gapTo(DateTime? gapTo);

  LogSource dropped(int dropped);

  LogSource networkId(int? networkId);

  LogSource hasPushToken(bool hasPushToken);

  LogSource pushUrl(String? pushUrl);

  LogSource services(List<LogService> services);

  LogSource createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogSource(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogSource(...).copyWith(id: 12, name: "My name")
  /// ````
  LogSource call({
    int id,
    String name,
    LogSourceKindEnum kind,
    String environment,
    String address,
    String authKind,
    String? authUser,
    String? authTenant,
    bool hasAuth,
    String caPem,
    LogScope scope,
    LogFields fields,
    int pollSeconds,
    bool enabled,
    LogSourceStatusEnum status,
    String lastError,
    DateTime? lastReadAt,
    DateTime? gapFrom,
    DateTime? gapTo,
    int dropped,
    int? networkId,
    bool hasPushToken,
    String? pushUrl,
    List<LogService> services,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLogSource.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLogSource.copyWith.fieldName(...)`
class _$LogSourceCWProxyImpl implements _$LogSourceCWProxy {
  const _$LogSourceCWProxyImpl(this._value);

  final LogSource _value;

  @override
  LogSource id(int id) => this(id: id);

  @override
  LogSource name(String name) => this(name: name);

  @override
  LogSource kind(LogSourceKindEnum kind) => this(kind: kind);

  @override
  LogSource environment(String environment) => this(environment: environment);

  @override
  LogSource address(String address) => this(address: address);

  @override
  LogSource authKind(String authKind) => this(authKind: authKind);

  @override
  LogSource authUser(String? authUser) => this(authUser: authUser);

  @override
  LogSource authTenant(String? authTenant) => this(authTenant: authTenant);

  @override
  LogSource hasAuth(bool hasAuth) => this(hasAuth: hasAuth);

  @override
  LogSource caPem(String caPem) => this(caPem: caPem);

  @override
  LogSource scope(LogScope scope) => this(scope: scope);

  @override
  LogSource fields(LogFields fields) => this(fields: fields);

  @override
  LogSource pollSeconds(int pollSeconds) => this(pollSeconds: pollSeconds);

  @override
  LogSource enabled(bool enabled) => this(enabled: enabled);

  @override
  LogSource status(LogSourceStatusEnum status) => this(status: status);

  @override
  LogSource lastError(String lastError) => this(lastError: lastError);

  @override
  LogSource lastReadAt(DateTime? lastReadAt) => this(lastReadAt: lastReadAt);

  @override
  LogSource gapFrom(DateTime? gapFrom) => this(gapFrom: gapFrom);

  @override
  LogSource gapTo(DateTime? gapTo) => this(gapTo: gapTo);

  @override
  LogSource dropped(int dropped) => this(dropped: dropped);

  @override
  LogSource networkId(int? networkId) => this(networkId: networkId);

  @override
  LogSource hasPushToken(bool hasPushToken) => this(hasPushToken: hasPushToken);

  @override
  LogSource pushUrl(String? pushUrl) => this(pushUrl: pushUrl);

  @override
  LogSource services(List<LogService> services) => this(services: services);

  @override
  LogSource createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogSource(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogSource(...).copyWith(id: 12, name: "My name")
  /// ````
  LogSource call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? environment = const $CopyWithPlaceholder(),
    Object? address = const $CopyWithPlaceholder(),
    Object? authKind = const $CopyWithPlaceholder(),
    Object? authUser = const $CopyWithPlaceholder(),
    Object? authTenant = const $CopyWithPlaceholder(),
    Object? hasAuth = const $CopyWithPlaceholder(),
    Object? caPem = const $CopyWithPlaceholder(),
    Object? scope = const $CopyWithPlaceholder(),
    Object? fields = const $CopyWithPlaceholder(),
    Object? pollSeconds = const $CopyWithPlaceholder(),
    Object? enabled = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? lastError = const $CopyWithPlaceholder(),
    Object? lastReadAt = const $CopyWithPlaceholder(),
    Object? gapFrom = const $CopyWithPlaceholder(),
    Object? gapTo = const $CopyWithPlaceholder(),
    Object? dropped = const $CopyWithPlaceholder(),
    Object? networkId = const $CopyWithPlaceholder(),
    Object? hasPushToken = const $CopyWithPlaceholder(),
    Object? pushUrl = const $CopyWithPlaceholder(),
    Object? services = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return LogSource(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as LogSourceKindEnum,
      environment: environment == const $CopyWithPlaceholder()
          ? _value.environment
          // ignore: cast_nullable_to_non_nullable
          : environment as String,
      address: address == const $CopyWithPlaceholder()
          ? _value.address
          // ignore: cast_nullable_to_non_nullable
          : address as String,
      authKind: authKind == const $CopyWithPlaceholder()
          ? _value.authKind
          // ignore: cast_nullable_to_non_nullable
          : authKind as String,
      authUser: authUser == const $CopyWithPlaceholder()
          ? _value.authUser
          // ignore: cast_nullable_to_non_nullable
          : authUser as String?,
      authTenant: authTenant == const $CopyWithPlaceholder()
          ? _value.authTenant
          // ignore: cast_nullable_to_non_nullable
          : authTenant as String?,
      hasAuth: hasAuth == const $CopyWithPlaceholder()
          ? _value.hasAuth
          // ignore: cast_nullable_to_non_nullable
          : hasAuth as bool,
      caPem: caPem == const $CopyWithPlaceholder()
          ? _value.caPem
          // ignore: cast_nullable_to_non_nullable
          : caPem as String,
      scope: scope == const $CopyWithPlaceholder()
          ? _value.scope
          // ignore: cast_nullable_to_non_nullable
          : scope as LogScope,
      fields: fields == const $CopyWithPlaceholder()
          ? _value.fields
          // ignore: cast_nullable_to_non_nullable
          : fields as LogFields,
      pollSeconds: pollSeconds == const $CopyWithPlaceholder()
          ? _value.pollSeconds
          // ignore: cast_nullable_to_non_nullable
          : pollSeconds as int,
      enabled: enabled == const $CopyWithPlaceholder()
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as LogSourceStatusEnum,
      lastError: lastError == const $CopyWithPlaceholder()
          ? _value.lastError
          // ignore: cast_nullable_to_non_nullable
          : lastError as String,
      lastReadAt: lastReadAt == const $CopyWithPlaceholder()
          ? _value.lastReadAt
          // ignore: cast_nullable_to_non_nullable
          : lastReadAt as DateTime?,
      gapFrom: gapFrom == const $CopyWithPlaceholder()
          ? _value.gapFrom
          // ignore: cast_nullable_to_non_nullable
          : gapFrom as DateTime?,
      gapTo: gapTo == const $CopyWithPlaceholder()
          ? _value.gapTo
          // ignore: cast_nullable_to_non_nullable
          : gapTo as DateTime?,
      dropped: dropped == const $CopyWithPlaceholder()
          ? _value.dropped
          // ignore: cast_nullable_to_non_nullable
          : dropped as int,
      networkId: networkId == const $CopyWithPlaceholder()
          ? _value.networkId
          // ignore: cast_nullable_to_non_nullable
          : networkId as int?,
      hasPushToken: hasPushToken == const $CopyWithPlaceholder()
          ? _value.hasPushToken
          // ignore: cast_nullable_to_non_nullable
          : hasPushToken as bool,
      pushUrl: pushUrl == const $CopyWithPlaceholder()
          ? _value.pushUrl
          // ignore: cast_nullable_to_non_nullable
          : pushUrl as String?,
      services: services == const $CopyWithPlaceholder()
          ? _value.services
          // ignore: cast_nullable_to_non_nullable
          : services as List<LogService>,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $LogSourceCopyWith on LogSource {
  /// Returns a callable class that can be used as follows: `instanceOfLogSource.copyWith(...)` or like so:`instanceOfLogSource.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LogSourceCWProxy get copyWith => _$LogSourceCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogSource _$LogSourceFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LogSource', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'name',
          'kind',
          'environment',
          'address',
          'authKind',
          'hasAuth',
          'caPem',
          'scope',
          'fields',
          'pollSeconds',
          'enabled',
          'status',
          'lastError',
          'dropped',
          'hasPushToken',
          'services',
          'createdAt',
        ],
      );
      final val = LogSource(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        name: $checkedConvert('name', (v) => v as String),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$LogSourceKindEnumEnumMap, v),
        ),
        environment: $checkedConvert('environment', (v) => v as String),
        address: $checkedConvert('address', (v) => v as String),
        authKind: $checkedConvert('authKind', (v) => v as String),
        authUser: $checkedConvert('authUser', (v) => v as String?),
        authTenant: $checkedConvert('authTenant', (v) => v as String?),
        hasAuth: $checkedConvert('hasAuth', (v) => v as bool),
        caPem: $checkedConvert('caPem', (v) => v as String),
        scope: $checkedConvert(
          'scope',
          (v) => LogScope.fromJson(v as Map<String, dynamic>),
        ),
        fields: $checkedConvert(
          'fields',
          (v) => LogFields.fromJson(v as Map<String, dynamic>),
        ),
        pollSeconds: $checkedConvert('pollSeconds', (v) => (v as num).toInt()),
        enabled: $checkedConvert('enabled', (v) => v as bool),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$LogSourceStatusEnumEnumMap, v),
        ),
        lastError: $checkedConvert('lastError', (v) => v as String),
        lastReadAt: $checkedConvert(
          'lastReadAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        gapFrom: $checkedConvert(
          'gapFrom',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        gapTo: $checkedConvert(
          'gapTo',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        dropped: $checkedConvert('dropped', (v) => (v as num).toInt()),
        networkId: $checkedConvert('networkId', (v) => (v as num?)?.toInt()),
        hasPushToken: $checkedConvert('hasPushToken', (v) => v as bool),
        pushUrl: $checkedConvert('pushUrl', (v) => v as String?),
        services: $checkedConvert(
          'services',
          (v) => (v as List<dynamic>)
              .map((e) => LogService.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$LogSourceToJson(LogSource instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'kind': _$LogSourceKindEnumEnumMap[instance.kind]!,
  'environment': instance.environment,
  'address': instance.address,
  'authKind': instance.authKind,
  'authUser': ?instance.authUser,
  'authTenant': ?instance.authTenant,
  'hasAuth': instance.hasAuth,
  'caPem': instance.caPem,
  'scope': instance.scope.toJson(),
  'fields': instance.fields.toJson(),
  'pollSeconds': instance.pollSeconds,
  'enabled': instance.enabled,
  'status': _$LogSourceStatusEnumEnumMap[instance.status]!,
  'lastError': instance.lastError,
  'lastReadAt': ?instance.lastReadAt?.toIso8601String(),
  'gapFrom': ?instance.gapFrom?.toIso8601String(),
  'gapTo': ?instance.gapTo?.toIso8601String(),
  'dropped': instance.dropped,
  'networkId': ?instance.networkId,
  'hasPushToken': instance.hasPushToken,
  'pushUrl': ?instance.pushUrl,
  'services': instance.services.map((e) => e.toJson()).toList(),
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$LogSourceKindEnumEnumMap = {
  LogSourceKindEnum.loki: 'loki',
  LogSourceKindEnum.elasticsearch: 'elasticsearch',
  LogSourceKindEnum.opensearch: 'opensearch',
  LogSourceKindEnum.graylog: 'graylog',
  LogSourceKindEnum.datadog: 'datadog',
  LogSourceKindEnum.cloudwatch: 'cloudwatch',
  LogSourceKindEnum.splunk: 'splunk',
  LogSourceKindEnum.push: 'push',
};

const _$LogSourceStatusEnumEnumMap = {
  LogSourceStatusEnum.new_: 'new',
  LogSourceStatusEnum.ok: 'ok',
  LogSourceStatusEnum.behind: 'behind',
  LogSourceStatusEnum.failing: 'failing',
  LogSourceStatusEnum.authFailed: 'auth_failed',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'egress_upstream.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EgressUpstreamCWProxy {
  EgressUpstream configured(bool configured);

  EgressUpstream via(String? via);

  EgressUpstream hosts(List<String>? hosts);

  EgressUpstream target(String? target);

  EgressUpstream ok(bool ok);

  EgressUpstream checkedAt(DateTime? checkedAt);

  EgressUpstream lastOkAt(DateTime? lastOkAt);

  EgressUpstream downSince(DateTime? downSince);

  EgressUpstream latencyMs(int latencyMs);

  EgressUpstream error(String? error);

  EgressUpstream exit(EgressUpstreamExit? exit);

  EgressUpstream history(List<EgressUpstreamHistoryInner> history);

  EgressUpstream calls(int calls);

  EgressUpstream failed(int failed);

  EgressUpstream lastCallError(String? lastCallError);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EgressUpstream(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EgressUpstream(...).copyWith(id: 12, name: "My name")
  /// ````
  EgressUpstream call({
    bool configured,
    String? via,
    List<String>? hosts,
    String? target,
    bool ok,
    DateTime? checkedAt,
    DateTime? lastOkAt,
    DateTime? downSince,
    int latencyMs,
    String? error,
    EgressUpstreamExit? exit,
    List<EgressUpstreamHistoryInner> history,
    int calls,
    int failed,
    String? lastCallError,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEgressUpstream.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEgressUpstream.copyWith.fieldName(...)`
class _$EgressUpstreamCWProxyImpl implements _$EgressUpstreamCWProxy {
  const _$EgressUpstreamCWProxyImpl(this._value);

  final EgressUpstream _value;

  @override
  EgressUpstream configured(bool configured) => this(configured: configured);

  @override
  EgressUpstream via(String? via) => this(via: via);

  @override
  EgressUpstream hosts(List<String>? hosts) => this(hosts: hosts);

  @override
  EgressUpstream target(String? target) => this(target: target);

  @override
  EgressUpstream ok(bool ok) => this(ok: ok);

  @override
  EgressUpstream checkedAt(DateTime? checkedAt) => this(checkedAt: checkedAt);

  @override
  EgressUpstream lastOkAt(DateTime? lastOkAt) => this(lastOkAt: lastOkAt);

  @override
  EgressUpstream downSince(DateTime? downSince) => this(downSince: downSince);

  @override
  EgressUpstream latencyMs(int latencyMs) => this(latencyMs: latencyMs);

  @override
  EgressUpstream error(String? error) => this(error: error);

  @override
  EgressUpstream exit(EgressUpstreamExit? exit) => this(exit: exit);

  @override
  EgressUpstream history(List<EgressUpstreamHistoryInner> history) =>
      this(history: history);

  @override
  EgressUpstream calls(int calls) => this(calls: calls);

  @override
  EgressUpstream failed(int failed) => this(failed: failed);

  @override
  EgressUpstream lastCallError(String? lastCallError) =>
      this(lastCallError: lastCallError);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EgressUpstream(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EgressUpstream(...).copyWith(id: 12, name: "My name")
  /// ````
  EgressUpstream call({
    Object? configured = const $CopyWithPlaceholder(),
    Object? via = const $CopyWithPlaceholder(),
    Object? hosts = const $CopyWithPlaceholder(),
    Object? target = const $CopyWithPlaceholder(),
    Object? ok = const $CopyWithPlaceholder(),
    Object? checkedAt = const $CopyWithPlaceholder(),
    Object? lastOkAt = const $CopyWithPlaceholder(),
    Object? downSince = const $CopyWithPlaceholder(),
    Object? latencyMs = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
    Object? exit = const $CopyWithPlaceholder(),
    Object? history = const $CopyWithPlaceholder(),
    Object? calls = const $CopyWithPlaceholder(),
    Object? failed = const $CopyWithPlaceholder(),
    Object? lastCallError = const $CopyWithPlaceholder(),
  }) {
    return EgressUpstream(
      configured: configured == const $CopyWithPlaceholder()
          ? _value.configured
          // ignore: cast_nullable_to_non_nullable
          : configured as bool,
      via: via == const $CopyWithPlaceholder()
          ? _value.via
          // ignore: cast_nullable_to_non_nullable
          : via as String?,
      hosts: hosts == const $CopyWithPlaceholder()
          ? _value.hosts
          // ignore: cast_nullable_to_non_nullable
          : hosts as List<String>?,
      target: target == const $CopyWithPlaceholder()
          ? _value.target
          // ignore: cast_nullable_to_non_nullable
          : target as String?,
      ok: ok == const $CopyWithPlaceholder()
          ? _value.ok
          // ignore: cast_nullable_to_non_nullable
          : ok as bool,
      checkedAt: checkedAt == const $CopyWithPlaceholder()
          ? _value.checkedAt
          // ignore: cast_nullable_to_non_nullable
          : checkedAt as DateTime?,
      lastOkAt: lastOkAt == const $CopyWithPlaceholder()
          ? _value.lastOkAt
          // ignore: cast_nullable_to_non_nullable
          : lastOkAt as DateTime?,
      downSince: downSince == const $CopyWithPlaceholder()
          ? _value.downSince
          // ignore: cast_nullable_to_non_nullable
          : downSince as DateTime?,
      latencyMs: latencyMs == const $CopyWithPlaceholder()
          ? _value.latencyMs
          // ignore: cast_nullable_to_non_nullable
          : latencyMs as int,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String?,
      exit: exit == const $CopyWithPlaceholder()
          ? _value.exit
          // ignore: cast_nullable_to_non_nullable
          : exit as EgressUpstreamExit?,
      history: history == const $CopyWithPlaceholder()
          ? _value.history
          // ignore: cast_nullable_to_non_nullable
          : history as List<EgressUpstreamHistoryInner>,
      calls: calls == const $CopyWithPlaceholder()
          ? _value.calls
          // ignore: cast_nullable_to_non_nullable
          : calls as int,
      failed: failed == const $CopyWithPlaceholder()
          ? _value.failed
          // ignore: cast_nullable_to_non_nullable
          : failed as int,
      lastCallError: lastCallError == const $CopyWithPlaceholder()
          ? _value.lastCallError
          // ignore: cast_nullable_to_non_nullable
          : lastCallError as String?,
    );
  }
}

extension $EgressUpstreamCopyWith on EgressUpstream {
  /// Returns a callable class that can be used as follows: `instanceOfEgressUpstream.copyWith(...)` or like so:`instanceOfEgressUpstream.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EgressUpstreamCWProxy get copyWith => _$EgressUpstreamCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EgressUpstream _$EgressUpstreamFromJson(Map<String, dynamic> json) =>
    $checkedCreate('EgressUpstream', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'configured',
          'ok',
          'latencyMs',
          'history',
          'calls',
          'failed',
        ],
      );
      final val = EgressUpstream(
        configured: $checkedConvert('configured', (v) => v as bool),
        via: $checkedConvert('via', (v) => v as String?),
        hosts: $checkedConvert(
          'hosts',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        target: $checkedConvert('target', (v) => v as String?),
        ok: $checkedConvert('ok', (v) => v as bool),
        checkedAt: $checkedConvert(
          'checkedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        lastOkAt: $checkedConvert(
          'lastOkAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        downSince: $checkedConvert(
          'downSince',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        latencyMs: $checkedConvert('latencyMs', (v) => (v as num).toInt()),
        error: $checkedConvert('error', (v) => v as String?),
        exit: $checkedConvert(
          'exit',
          (v) => v == null
              ? null
              : EgressUpstreamExit.fromJson(v as Map<String, dynamic>),
        ),
        history: $checkedConvert(
          'history',
          (v) => (v as List<dynamic>)
              .map(
                (e) => EgressUpstreamHistoryInner.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
        ),
        calls: $checkedConvert('calls', (v) => (v as num).toInt()),
        failed: $checkedConvert('failed', (v) => (v as num).toInt()),
        lastCallError: $checkedConvert('lastCallError', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$EgressUpstreamToJson(EgressUpstream instance) =>
    <String, dynamic>{
      'configured': instance.configured,
      'via': ?instance.via,
      'hosts': ?instance.hosts,
      'target': ?instance.target,
      'ok': instance.ok,
      'checkedAt': ?instance.checkedAt?.toIso8601String(),
      'lastOkAt': ?instance.lastOkAt?.toIso8601String(),
      'downSince': ?instance.downSince?.toIso8601String(),
      'latencyMs': instance.latencyMs,
      'error': ?instance.error,
      'exit': ?instance.exit?.toJson(),
      'history': instance.history.map((e) => e.toJson()).toList(),
      'calls': instance.calls,
      'failed': instance.failed,
      'lastCallError': ?instance.lastCallError,
    };

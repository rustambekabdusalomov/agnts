// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_activity_dials_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NetworkActivityDialsInnerCWProxy {
  NetworkActivityDialsInner at(DateTime at);

  NetworkActivityDialsInner target(String target);

  NetworkActivityDialsInner network(int? network);

  NetworkActivityDialsInner ticket(String? ticket);

  NetworkActivityDialsInner source_(String source_);

  NetworkActivityDialsInner ok(bool ok);

  NetworkActivityDialsInner error(String? error);

  NetworkActivityDialsInner bytesIn(int bytesIn);

  NetworkActivityDialsInner bytesOut(int bytesOut);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NetworkActivityDialsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NetworkActivityDialsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  NetworkActivityDialsInner call({
    DateTime at,
    String target,
    int? network,
    String? ticket,
    String source_,
    bool ok,
    String? error,
    int bytesIn,
    int bytesOut,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNetworkActivityDialsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNetworkActivityDialsInner.copyWith.fieldName(...)`
class _$NetworkActivityDialsInnerCWProxyImpl
    implements _$NetworkActivityDialsInnerCWProxy {
  const _$NetworkActivityDialsInnerCWProxyImpl(this._value);

  final NetworkActivityDialsInner _value;

  @override
  NetworkActivityDialsInner at(DateTime at) => this(at: at);

  @override
  NetworkActivityDialsInner target(String target) => this(target: target);

  @override
  NetworkActivityDialsInner network(int? network) => this(network: network);

  @override
  NetworkActivityDialsInner ticket(String? ticket) => this(ticket: ticket);

  @override
  NetworkActivityDialsInner source_(String source_) => this(source_: source_);

  @override
  NetworkActivityDialsInner ok(bool ok) => this(ok: ok);

  @override
  NetworkActivityDialsInner error(String? error) => this(error: error);

  @override
  NetworkActivityDialsInner bytesIn(int bytesIn) => this(bytesIn: bytesIn);

  @override
  NetworkActivityDialsInner bytesOut(int bytesOut) => this(bytesOut: bytesOut);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NetworkActivityDialsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NetworkActivityDialsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  NetworkActivityDialsInner call({
    Object? at = const $CopyWithPlaceholder(),
    Object? target = const $CopyWithPlaceholder(),
    Object? network = const $CopyWithPlaceholder(),
    Object? ticket = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
    Object? ok = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
    Object? bytesIn = const $CopyWithPlaceholder(),
    Object? bytesOut = const $CopyWithPlaceholder(),
  }) {
    return NetworkActivityDialsInner(
      at: at == const $CopyWithPlaceholder()
          ? _value.at
          // ignore: cast_nullable_to_non_nullable
          : at as DateTime,
      target: target == const $CopyWithPlaceholder()
          ? _value.target
          // ignore: cast_nullable_to_non_nullable
          : target as String,
      network: network == const $CopyWithPlaceholder()
          ? _value.network
          // ignore: cast_nullable_to_non_nullable
          : network as int?,
      ticket: ticket == const $CopyWithPlaceholder()
          ? _value.ticket
          // ignore: cast_nullable_to_non_nullable
          : ticket as String?,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as String,
      ok: ok == const $CopyWithPlaceholder()
          ? _value.ok
          // ignore: cast_nullable_to_non_nullable
          : ok as bool,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String?,
      bytesIn: bytesIn == const $CopyWithPlaceholder()
          ? _value.bytesIn
          // ignore: cast_nullable_to_non_nullable
          : bytesIn as int,
      bytesOut: bytesOut == const $CopyWithPlaceholder()
          ? _value.bytesOut
          // ignore: cast_nullable_to_non_nullable
          : bytesOut as int,
    );
  }
}

extension $NetworkActivityDialsInnerCopyWith on NetworkActivityDialsInner {
  /// Returns a callable class that can be used as follows: `instanceOfNetworkActivityDialsInner.copyWith(...)` or like so:`instanceOfNetworkActivityDialsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NetworkActivityDialsInnerCWProxy get copyWith =>
      _$NetworkActivityDialsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkActivityDialsInner _$NetworkActivityDialsInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('NetworkActivityDialsInner', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['at', 'target', 'source', 'ok', 'bytesIn', 'bytesOut'],
  );
  final val = NetworkActivityDialsInner(
    at: $checkedConvert('at', (v) => DateTime.parse(v as String)),
    target: $checkedConvert('target', (v) => v as String),
    network: $checkedConvert('network', (v) => (v as num?)?.toInt()),
    ticket: $checkedConvert('ticket', (v) => v as String?),
    source_: $checkedConvert('source', (v) => v as String),
    ok: $checkedConvert('ok', (v) => v as bool),
    error: $checkedConvert('error', (v) => v as String?),
    bytesIn: $checkedConvert('bytesIn', (v) => (v as num).toInt()),
    bytesOut: $checkedConvert('bytesOut', (v) => (v as num).toInt()),
  );
  return val;
}, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$NetworkActivityDialsInnerToJson(
  NetworkActivityDialsInner instance,
) => <String, dynamic>{
  'at': instance.at.toIso8601String(),
  'target': instance.target,
  'network': ?instance.network,
  'ticket': ?instance.ticket,
  'source': instance.source_,
  'ok': instance.ok,
  'error': ?instance.error,
  'bytesIn': instance.bytesIn,
  'bytesOut': instance.bytesOut,
};

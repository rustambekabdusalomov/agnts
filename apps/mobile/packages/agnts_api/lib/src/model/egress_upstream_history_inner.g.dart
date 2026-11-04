// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'egress_upstream_history_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EgressUpstreamHistoryInnerCWProxy {
  EgressUpstreamHistoryInner at(DateTime at);

  EgressUpstreamHistoryInner ok(bool ok);

  EgressUpstreamHistoryInner ms(int ms);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EgressUpstreamHistoryInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EgressUpstreamHistoryInner(...).copyWith(id: 12, name: "My name")
  /// ````
  EgressUpstreamHistoryInner call({DateTime at, bool ok, int ms});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEgressUpstreamHistoryInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEgressUpstreamHistoryInner.copyWith.fieldName(...)`
class _$EgressUpstreamHistoryInnerCWProxyImpl
    implements _$EgressUpstreamHistoryInnerCWProxy {
  const _$EgressUpstreamHistoryInnerCWProxyImpl(this._value);

  final EgressUpstreamHistoryInner _value;

  @override
  EgressUpstreamHistoryInner at(DateTime at) => this(at: at);

  @override
  EgressUpstreamHistoryInner ok(bool ok) => this(ok: ok);

  @override
  EgressUpstreamHistoryInner ms(int ms) => this(ms: ms);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EgressUpstreamHistoryInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EgressUpstreamHistoryInner(...).copyWith(id: 12, name: "My name")
  /// ````
  EgressUpstreamHistoryInner call({
    Object? at = const $CopyWithPlaceholder(),
    Object? ok = const $CopyWithPlaceholder(),
    Object? ms = const $CopyWithPlaceholder(),
  }) {
    return EgressUpstreamHistoryInner(
      at: at == const $CopyWithPlaceholder()
          ? _value.at
          // ignore: cast_nullable_to_non_nullable
          : at as DateTime,
      ok: ok == const $CopyWithPlaceholder()
          ? _value.ok
          // ignore: cast_nullable_to_non_nullable
          : ok as bool,
      ms: ms == const $CopyWithPlaceholder()
          ? _value.ms
          // ignore: cast_nullable_to_non_nullable
          : ms as int,
    );
  }
}

extension $EgressUpstreamHistoryInnerCopyWith on EgressUpstreamHistoryInner {
  /// Returns a callable class that can be used as follows: `instanceOfEgressUpstreamHistoryInner.copyWith(...)` or like so:`instanceOfEgressUpstreamHistoryInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EgressUpstreamHistoryInnerCWProxy get copyWith =>
      _$EgressUpstreamHistoryInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EgressUpstreamHistoryInner _$EgressUpstreamHistoryInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('EgressUpstreamHistoryInner', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['at', 'ok', 'ms']);
  final val = EgressUpstreamHistoryInner(
    at: $checkedConvert('at', (v) => DateTime.parse(v as String)),
    ok: $checkedConvert('ok', (v) => v as bool),
    ms: $checkedConvert('ms', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$EgressUpstreamHistoryInnerToJson(
  EgressUpstreamHistoryInner instance,
) => <String, dynamic>{
  'at': instance.at.toIso8601String(),
  'ok': instance.ok,
  'ms': instance.ms,
};

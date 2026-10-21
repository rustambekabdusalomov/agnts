// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_ticket_benchmark_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SetTicketBenchmarkRequestCWProxy {
  SetTicketBenchmarkRequest benchmark(bool benchmark);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetTicketBenchmarkRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetTicketBenchmarkRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetTicketBenchmarkRequest call({bool benchmark});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSetTicketBenchmarkRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSetTicketBenchmarkRequest.copyWith.fieldName(...)`
class _$SetTicketBenchmarkRequestCWProxyImpl
    implements _$SetTicketBenchmarkRequestCWProxy {
  const _$SetTicketBenchmarkRequestCWProxyImpl(this._value);

  final SetTicketBenchmarkRequest _value;

  @override
  SetTicketBenchmarkRequest benchmark(bool benchmark) =>
      this(benchmark: benchmark);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetTicketBenchmarkRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetTicketBenchmarkRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetTicketBenchmarkRequest call({
    Object? benchmark = const $CopyWithPlaceholder(),
  }) {
    return SetTicketBenchmarkRequest(
      benchmark: benchmark == const $CopyWithPlaceholder()
          ? _value.benchmark
          // ignore: cast_nullable_to_non_nullable
          : benchmark as bool,
    );
  }
}

extension $SetTicketBenchmarkRequestCopyWith on SetTicketBenchmarkRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSetTicketBenchmarkRequest.copyWith(...)` or like so:`instanceOfSetTicketBenchmarkRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SetTicketBenchmarkRequestCWProxy get copyWith =>
      _$SetTicketBenchmarkRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetTicketBenchmarkRequest _$SetTicketBenchmarkRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SetTicketBenchmarkRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['benchmark']);
  final val = SetTicketBenchmarkRequest(
    benchmark: $checkedConvert('benchmark', (v) => v as bool),
  );
  return val;
});

Map<String, dynamic> _$SetTicketBenchmarkRequestToJson(
  SetTicketBenchmarkRequest instance,
) => <String, dynamic>{'benchmark': instance.benchmark};

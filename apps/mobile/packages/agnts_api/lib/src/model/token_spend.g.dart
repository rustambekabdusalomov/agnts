// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_spend.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TokenSpendCWProxy {
  TokenSpend input(int input);

  TokenSpend output(int output);

  TokenSpend cacheRead(int cacheRead);

  TokenSpend cacheWrite(int cacheWrite);

  TokenSpend total(int total);

  TokenSpend costUsd(double costUsd);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TokenSpend(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TokenSpend(...).copyWith(id: 12, name: "My name")
  /// ````
  TokenSpend call({
    int input,
    int output,
    int cacheRead,
    int cacheWrite,
    int total,
    double costUsd,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTokenSpend.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTokenSpend.copyWith.fieldName(...)`
class _$TokenSpendCWProxyImpl implements _$TokenSpendCWProxy {
  const _$TokenSpendCWProxyImpl(this._value);

  final TokenSpend _value;

  @override
  TokenSpend input(int input) => this(input: input);

  @override
  TokenSpend output(int output) => this(output: output);

  @override
  TokenSpend cacheRead(int cacheRead) => this(cacheRead: cacheRead);

  @override
  TokenSpend cacheWrite(int cacheWrite) => this(cacheWrite: cacheWrite);

  @override
  TokenSpend total(int total) => this(total: total);

  @override
  TokenSpend costUsd(double costUsd) => this(costUsd: costUsd);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TokenSpend(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TokenSpend(...).copyWith(id: 12, name: "My name")
  /// ````
  TokenSpend call({
    Object? input = const $CopyWithPlaceholder(),
    Object? output = const $CopyWithPlaceholder(),
    Object? cacheRead = const $CopyWithPlaceholder(),
    Object? cacheWrite = const $CopyWithPlaceholder(),
    Object? total = const $CopyWithPlaceholder(),
    Object? costUsd = const $CopyWithPlaceholder(),
  }) {
    return TokenSpend(
      input: input == const $CopyWithPlaceholder()
          ? _value.input
          // ignore: cast_nullable_to_non_nullable
          : input as int,
      output: output == const $CopyWithPlaceholder()
          ? _value.output
          // ignore: cast_nullable_to_non_nullable
          : output as int,
      cacheRead: cacheRead == const $CopyWithPlaceholder()
          ? _value.cacheRead
          // ignore: cast_nullable_to_non_nullable
          : cacheRead as int,
      cacheWrite: cacheWrite == const $CopyWithPlaceholder()
          ? _value.cacheWrite
          // ignore: cast_nullable_to_non_nullable
          : cacheWrite as int,
      total: total == const $CopyWithPlaceholder()
          ? _value.total
          // ignore: cast_nullable_to_non_nullable
          : total as int,
      costUsd: costUsd == const $CopyWithPlaceholder()
          ? _value.costUsd
          // ignore: cast_nullable_to_non_nullable
          : costUsd as double,
    );
  }
}

extension $TokenSpendCopyWith on TokenSpend {
  /// Returns a callable class that can be used as follows: `instanceOfTokenSpend.copyWith(...)` or like so:`instanceOfTokenSpend.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TokenSpendCWProxy get copyWith => _$TokenSpendCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenSpend _$TokenSpendFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TokenSpend', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'input',
          'output',
          'cacheRead',
          'cacheWrite',
          'total',
          'costUsd',
        ],
      );
      final val = TokenSpend(
        input: $checkedConvert('input', (v) => (v as num).toInt()),
        output: $checkedConvert('output', (v) => (v as num).toInt()),
        cacheRead: $checkedConvert('cacheRead', (v) => (v as num).toInt()),
        cacheWrite: $checkedConvert('cacheWrite', (v) => (v as num).toInt()),
        total: $checkedConvert('total', (v) => (v as num).toInt()),
        costUsd: $checkedConvert('costUsd', (v) => (v as num).toDouble()),
      );
      return val;
    });

Map<String, dynamic> _$TokenSpendToJson(TokenSpend instance) =>
    <String, dynamic>{
      'input': instance.input,
      'output': instance.output,
      'cacheRead': instance.cacheRead,
      'cacheWrite': instance.cacheWrite,
      'total': instance.total,
      'costUsd': instance.costUsd,
    };

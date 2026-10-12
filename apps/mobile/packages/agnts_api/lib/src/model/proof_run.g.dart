// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proof_run.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProofRunCWProxy {
  ProofRun exit(int exit);

  ProofRun output(String output);

  ProofRun ms(int ms);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ProofRun(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ProofRun(...).copyWith(id: 12, name: "My name")
  /// ````
  ProofRun call({int exit, String output, int ms});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfProofRun.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfProofRun.copyWith.fieldName(...)`
class _$ProofRunCWProxyImpl implements _$ProofRunCWProxy {
  const _$ProofRunCWProxyImpl(this._value);

  final ProofRun _value;

  @override
  ProofRun exit(int exit) => this(exit: exit);

  @override
  ProofRun output(String output) => this(output: output);

  @override
  ProofRun ms(int ms) => this(ms: ms);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ProofRun(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ProofRun(...).copyWith(id: 12, name: "My name")
  /// ````
  ProofRun call({
    Object? exit = const $CopyWithPlaceholder(),
    Object? output = const $CopyWithPlaceholder(),
    Object? ms = const $CopyWithPlaceholder(),
  }) {
    return ProofRun(
      exit: exit == const $CopyWithPlaceholder()
          ? _value.exit
          // ignore: cast_nullable_to_non_nullable
          : exit as int,
      output: output == const $CopyWithPlaceholder()
          ? _value.output
          // ignore: cast_nullable_to_non_nullable
          : output as String,
      ms: ms == const $CopyWithPlaceholder()
          ? _value.ms
          // ignore: cast_nullable_to_non_nullable
          : ms as int,
    );
  }
}

extension $ProofRunCopyWith on ProofRun {
  /// Returns a callable class that can be used as follows: `instanceOfProofRun.copyWith(...)` or like so:`instanceOfProofRun.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProofRunCWProxy get copyWith => _$ProofRunCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProofRun _$ProofRunFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ProofRun', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['exit', 'output', 'ms']);
      final val = ProofRun(
        exit: $checkedConvert('exit', (v) => (v as num).toInt()),
        output: $checkedConvert('output', (v) => v as String),
        ms: $checkedConvert('ms', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$ProofRunToJson(ProofRun instance) => <String, dynamic>{
  'exit': instance.exit,
  'output': instance.output,
  'ms': instance.ms,
};

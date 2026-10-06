// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_step.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CheckStepCWProxy {
  CheckStep name(String name);

  CheckStep command(String command);

  CheckStep exitCode(int exitCode);

  CheckStep durationMs(int durationMs);

  CheckStep timedOut(bool? timedOut);

  CheckStep output(String? output);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CheckStep(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CheckStep(...).copyWith(id: 12, name: "My name")
  /// ````
  CheckStep call({
    String name,
    String command,
    int exitCode,
    int durationMs,
    bool? timedOut,
    String? output,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCheckStep.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCheckStep.copyWith.fieldName(...)`
class _$CheckStepCWProxyImpl implements _$CheckStepCWProxy {
  const _$CheckStepCWProxyImpl(this._value);

  final CheckStep _value;

  @override
  CheckStep name(String name) => this(name: name);

  @override
  CheckStep command(String command) => this(command: command);

  @override
  CheckStep exitCode(int exitCode) => this(exitCode: exitCode);

  @override
  CheckStep durationMs(int durationMs) => this(durationMs: durationMs);

  @override
  CheckStep timedOut(bool? timedOut) => this(timedOut: timedOut);

  @override
  CheckStep output(String? output) => this(output: output);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CheckStep(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CheckStep(...).copyWith(id: 12, name: "My name")
  /// ````
  CheckStep call({
    Object? name = const $CopyWithPlaceholder(),
    Object? command = const $CopyWithPlaceholder(),
    Object? exitCode = const $CopyWithPlaceholder(),
    Object? durationMs = const $CopyWithPlaceholder(),
    Object? timedOut = const $CopyWithPlaceholder(),
    Object? output = const $CopyWithPlaceholder(),
  }) {
    return CheckStep(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      command: command == const $CopyWithPlaceholder()
          ? _value.command
          // ignore: cast_nullable_to_non_nullable
          : command as String,
      exitCode: exitCode == const $CopyWithPlaceholder()
          ? _value.exitCode
          // ignore: cast_nullable_to_non_nullable
          : exitCode as int,
      durationMs: durationMs == const $CopyWithPlaceholder()
          ? _value.durationMs
          // ignore: cast_nullable_to_non_nullable
          : durationMs as int,
      timedOut: timedOut == const $CopyWithPlaceholder()
          ? _value.timedOut
          // ignore: cast_nullable_to_non_nullable
          : timedOut as bool?,
      output: output == const $CopyWithPlaceholder()
          ? _value.output
          // ignore: cast_nullable_to_non_nullable
          : output as String?,
    );
  }
}

extension $CheckStepCopyWith on CheckStep {
  /// Returns a callable class that can be used as follows: `instanceOfCheckStep.copyWith(...)` or like so:`instanceOfCheckStep.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CheckStepCWProxy get copyWith => _$CheckStepCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckStep _$CheckStepFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CheckStep', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['name', 'command', 'exitCode', 'durationMs'],
      );
      final val = CheckStep(
        name: $checkedConvert('name', (v) => v as String),
        command: $checkedConvert('command', (v) => v as String),
        exitCode: $checkedConvert('exitCode', (v) => (v as num).toInt()),
        durationMs: $checkedConvert('durationMs', (v) => (v as num).toInt()),
        timedOut: $checkedConvert('timedOut', (v) => v as bool?),
        output: $checkedConvert('output', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$CheckStepToJson(CheckStep instance) => <String, dynamic>{
  'name': instance.name,
  'command': instance.command,
  'exitCode': instance.exitCode,
  'durationMs': instance.durationMs,
  'timedOut': ?instance.timedOut,
  'output': ?instance.output,
};

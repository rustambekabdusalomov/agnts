// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_repro.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AnalysisReproCWProxy {
  AnalysisRepro reproduced(bool reproduced);

  AnalysisRepro command(String? command);

  AnalysisRepro output(String? output);

  AnalysisRepro why(String? why);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnalysisRepro(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnalysisRepro(...).copyWith(id: 12, name: "My name")
  /// ````
  AnalysisRepro call({
    bool reproduced,
    String? command,
    String? output,
    String? why,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAnalysisRepro.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAnalysisRepro.copyWith.fieldName(...)`
class _$AnalysisReproCWProxyImpl implements _$AnalysisReproCWProxy {
  const _$AnalysisReproCWProxyImpl(this._value);

  final AnalysisRepro _value;

  @override
  AnalysisRepro reproduced(bool reproduced) => this(reproduced: reproduced);

  @override
  AnalysisRepro command(String? command) => this(command: command);

  @override
  AnalysisRepro output(String? output) => this(output: output);

  @override
  AnalysisRepro why(String? why) => this(why: why);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnalysisRepro(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnalysisRepro(...).copyWith(id: 12, name: "My name")
  /// ````
  AnalysisRepro call({
    Object? reproduced = const $CopyWithPlaceholder(),
    Object? command = const $CopyWithPlaceholder(),
    Object? output = const $CopyWithPlaceholder(),
    Object? why = const $CopyWithPlaceholder(),
  }) {
    return AnalysisRepro(
      reproduced: reproduced == const $CopyWithPlaceholder()
          ? _value.reproduced
          // ignore: cast_nullable_to_non_nullable
          : reproduced as bool,
      command: command == const $CopyWithPlaceholder()
          ? _value.command
          // ignore: cast_nullable_to_non_nullable
          : command as String?,
      output: output == const $CopyWithPlaceholder()
          ? _value.output
          // ignore: cast_nullable_to_non_nullable
          : output as String?,
      why: why == const $CopyWithPlaceholder()
          ? _value.why
          // ignore: cast_nullable_to_non_nullable
          : why as String?,
    );
  }
}

extension $AnalysisReproCopyWith on AnalysisRepro {
  /// Returns a callable class that can be used as follows: `instanceOfAnalysisRepro.copyWith(...)` or like so:`instanceOfAnalysisRepro.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AnalysisReproCWProxy get copyWith => _$AnalysisReproCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalysisRepro _$AnalysisReproFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AnalysisRepro', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['reproduced']);
      final val = AnalysisRepro(
        reproduced: $checkedConvert('reproduced', (v) => v as bool),
        command: $checkedConvert('command', (v) => v as String?),
        output: $checkedConvert('output', (v) => v as String?),
        why: $checkedConvert('why', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$AnalysisReproToJson(AnalysisRepro instance) =>
    <String, dynamic>{
      'reproduced': instance.reproduced,
      'command': ?instance.command,
      'output': ?instance.output,
      'why': ?instance.why,
    };

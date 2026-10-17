// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_history_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RunHistorySettingsCWProxy {
  RunHistorySettings retentionDays(int retentionDays);

  RunHistorySettings toolOutputKB(int toolOutputKB);

  RunHistorySettings textKB(int textKB);

  RunHistorySettings transcriptMB(int transcriptMB);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RunHistorySettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RunHistorySettings(...).copyWith(id: 12, name: "My name")
  /// ````
  RunHistorySettings call({
    int retentionDays,
    int toolOutputKB,
    int textKB,
    int transcriptMB,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRunHistorySettings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRunHistorySettings.copyWith.fieldName(...)`
class _$RunHistorySettingsCWProxyImpl implements _$RunHistorySettingsCWProxy {
  const _$RunHistorySettingsCWProxyImpl(this._value);

  final RunHistorySettings _value;

  @override
  RunHistorySettings retentionDays(int retentionDays) =>
      this(retentionDays: retentionDays);

  @override
  RunHistorySettings toolOutputKB(int toolOutputKB) =>
      this(toolOutputKB: toolOutputKB);

  @override
  RunHistorySettings textKB(int textKB) => this(textKB: textKB);

  @override
  RunHistorySettings transcriptMB(int transcriptMB) =>
      this(transcriptMB: transcriptMB);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RunHistorySettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RunHistorySettings(...).copyWith(id: 12, name: "My name")
  /// ````
  RunHistorySettings call({
    Object? retentionDays = const $CopyWithPlaceholder(),
    Object? toolOutputKB = const $CopyWithPlaceholder(),
    Object? textKB = const $CopyWithPlaceholder(),
    Object? transcriptMB = const $CopyWithPlaceholder(),
  }) {
    return RunHistorySettings(
      retentionDays: retentionDays == const $CopyWithPlaceholder()
          ? _value.retentionDays
          // ignore: cast_nullable_to_non_nullable
          : retentionDays as int,
      toolOutputKB: toolOutputKB == const $CopyWithPlaceholder()
          ? _value.toolOutputKB
          // ignore: cast_nullable_to_non_nullable
          : toolOutputKB as int,
      textKB: textKB == const $CopyWithPlaceholder()
          ? _value.textKB
          // ignore: cast_nullable_to_non_nullable
          : textKB as int,
      transcriptMB: transcriptMB == const $CopyWithPlaceholder()
          ? _value.transcriptMB
          // ignore: cast_nullable_to_non_nullable
          : transcriptMB as int,
    );
  }
}

extension $RunHistorySettingsCopyWith on RunHistorySettings {
  /// Returns a callable class that can be used as follows: `instanceOfRunHistorySettings.copyWith(...)` or like so:`instanceOfRunHistorySettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RunHistorySettingsCWProxy get copyWith =>
      _$RunHistorySettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RunHistorySettings _$RunHistorySettingsFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RunHistorySettings', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'retentionDays',
      'toolOutputKB',
      'textKB',
      'transcriptMB',
    ],
  );
  final val = RunHistorySettings(
    retentionDays: $checkedConvert('retentionDays', (v) => (v as num).toInt()),
    toolOutputKB: $checkedConvert('toolOutputKB', (v) => (v as num).toInt()),
    textKB: $checkedConvert('textKB', (v) => (v as num).toInt()),
    transcriptMB: $checkedConvert('transcriptMB', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$RunHistorySettingsToJson(RunHistorySettings instance) =>
    <String, dynamic>{
      'retentionDays': instance.retentionDays,
      'toolOutputKB': instance.toolOutputKB,
      'textKB': instance.textKB,
      'transcriptMB': instance.transcriptMB,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ci_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CISettingsCWProxy {
  CISettings autoFix(bool autoFix);

  CISettings maxAutoPerDay(int maxAutoPerDay);

  CISettings retryFlaky(bool retryFlaky);

  CISettings feedbackRounds(int feedbackRounds);

  CISettings infraPatterns(List<String> infraPatterns);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CISettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CISettings(...).copyWith(id: 12, name: "My name")
  /// ````
  CISettings call({
    bool autoFix,
    int maxAutoPerDay,
    bool retryFlaky,
    int feedbackRounds,
    List<String> infraPatterns,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCISettings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCISettings.copyWith.fieldName(...)`
class _$CISettingsCWProxyImpl implements _$CISettingsCWProxy {
  const _$CISettingsCWProxyImpl(this._value);

  final CISettings _value;

  @override
  CISettings autoFix(bool autoFix) => this(autoFix: autoFix);

  @override
  CISettings maxAutoPerDay(int maxAutoPerDay) =>
      this(maxAutoPerDay: maxAutoPerDay);

  @override
  CISettings retryFlaky(bool retryFlaky) => this(retryFlaky: retryFlaky);

  @override
  CISettings feedbackRounds(int feedbackRounds) =>
      this(feedbackRounds: feedbackRounds);

  @override
  CISettings infraPatterns(List<String> infraPatterns) =>
      this(infraPatterns: infraPatterns);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CISettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CISettings(...).copyWith(id: 12, name: "My name")
  /// ````
  CISettings call({
    Object? autoFix = const $CopyWithPlaceholder(),
    Object? maxAutoPerDay = const $CopyWithPlaceholder(),
    Object? retryFlaky = const $CopyWithPlaceholder(),
    Object? feedbackRounds = const $CopyWithPlaceholder(),
    Object? infraPatterns = const $CopyWithPlaceholder(),
  }) {
    return CISettings(
      autoFix: autoFix == const $CopyWithPlaceholder()
          ? _value.autoFix
          // ignore: cast_nullable_to_non_nullable
          : autoFix as bool,
      maxAutoPerDay: maxAutoPerDay == const $CopyWithPlaceholder()
          ? _value.maxAutoPerDay
          // ignore: cast_nullable_to_non_nullable
          : maxAutoPerDay as int,
      retryFlaky: retryFlaky == const $CopyWithPlaceholder()
          ? _value.retryFlaky
          // ignore: cast_nullable_to_non_nullable
          : retryFlaky as bool,
      feedbackRounds: feedbackRounds == const $CopyWithPlaceholder()
          ? _value.feedbackRounds
          // ignore: cast_nullable_to_non_nullable
          : feedbackRounds as int,
      infraPatterns: infraPatterns == const $CopyWithPlaceholder()
          ? _value.infraPatterns
          // ignore: cast_nullable_to_non_nullable
          : infraPatterns as List<String>,
    );
  }
}

extension $CISettingsCopyWith on CISettings {
  /// Returns a callable class that can be used as follows: `instanceOfCISettings.copyWith(...)` or like so:`instanceOfCISettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CISettingsCWProxy get copyWith => _$CISettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CISettings _$CISettingsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CISettings', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'autoFix',
          'maxAutoPerDay',
          'retryFlaky',
          'feedbackRounds',
          'infraPatterns',
        ],
      );
      final val = CISettings(
        autoFix: $checkedConvert('autoFix', (v) => v as bool),
        maxAutoPerDay: $checkedConvert(
          'maxAutoPerDay',
          (v) => (v as num).toInt(),
        ),
        retryFlaky: $checkedConvert('retryFlaky', (v) => v as bool),
        feedbackRounds: $checkedConvert(
          'feedbackRounds',
          (v) => (v as num).toInt(),
        ),
        infraPatterns: $checkedConvert(
          'infraPatterns',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CISettingsToJson(CISettings instance) =>
    <String, dynamic>{
      'autoFix': instance.autoFix,
      'maxAutoPerDay': instance.maxAutoPerDay,
      'retryFlaky': instance.retryFlaky,
      'feedbackRounds': instance.feedbackRounds,
      'infraPatterns': instance.infraPatterns,
    };

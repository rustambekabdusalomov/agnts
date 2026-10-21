// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'effort_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EffortSettingsCWProxy {
  EffortSettings analyze(EffortSettingsAnalyzeEnum analyze);

  EffortSettings coding(EffortSettingsCodingEnum coding);

  EffortSettings review(EffortSettingsReviewEnum review);

  EffortSettings complex(EffortSettingsComplexEnum complex);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EffortSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EffortSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  EffortSettings call({
    EffortSettingsAnalyzeEnum analyze,
    EffortSettingsCodingEnum coding,
    EffortSettingsReviewEnum review,
    EffortSettingsComplexEnum complex,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEffortSettings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEffortSettings.copyWith.fieldName(...)`
class _$EffortSettingsCWProxyImpl implements _$EffortSettingsCWProxy {
  const _$EffortSettingsCWProxyImpl(this._value);

  final EffortSettings _value;

  @override
  EffortSettings analyze(EffortSettingsAnalyzeEnum analyze) =>
      this(analyze: analyze);

  @override
  EffortSettings coding(EffortSettingsCodingEnum coding) =>
      this(coding: coding);

  @override
  EffortSettings review(EffortSettingsReviewEnum review) =>
      this(review: review);

  @override
  EffortSettings complex(EffortSettingsComplexEnum complex) =>
      this(complex: complex);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EffortSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EffortSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  EffortSettings call({
    Object? analyze = const $CopyWithPlaceholder(),
    Object? coding = const $CopyWithPlaceholder(),
    Object? review = const $CopyWithPlaceholder(),
    Object? complex = const $CopyWithPlaceholder(),
  }) {
    return EffortSettings(
      analyze: analyze == const $CopyWithPlaceholder()
          ? _value.analyze
          // ignore: cast_nullable_to_non_nullable
          : analyze as EffortSettingsAnalyzeEnum,
      coding: coding == const $CopyWithPlaceholder()
          ? _value.coding
          // ignore: cast_nullable_to_non_nullable
          : coding as EffortSettingsCodingEnum,
      review: review == const $CopyWithPlaceholder()
          ? _value.review
          // ignore: cast_nullable_to_non_nullable
          : review as EffortSettingsReviewEnum,
      complex: complex == const $CopyWithPlaceholder()
          ? _value.complex
          // ignore: cast_nullable_to_non_nullable
          : complex as EffortSettingsComplexEnum,
    );
  }
}

extension $EffortSettingsCopyWith on EffortSettings {
  /// Returns a callable class that can be used as follows: `instanceOfEffortSettings.copyWith(...)` or like so:`instanceOfEffortSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EffortSettingsCWProxy get copyWith => _$EffortSettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EffortSettings _$EffortSettingsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('EffortSettings', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['analyze', 'coding', 'review', 'complex'],
      );
      final val = EffortSettings(
        analyze: $checkedConvert(
          'analyze',
          (v) => $enumDecode(_$EffortSettingsAnalyzeEnumEnumMap, v),
        ),
        coding: $checkedConvert(
          'coding',
          (v) => $enumDecode(_$EffortSettingsCodingEnumEnumMap, v),
        ),
        review: $checkedConvert(
          'review',
          (v) => $enumDecode(_$EffortSettingsReviewEnumEnumMap, v),
        ),
        complex: $checkedConvert(
          'complex',
          (v) => $enumDecode(_$EffortSettingsComplexEnumEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$EffortSettingsToJson(EffortSettings instance) =>
    <String, dynamic>{
      'analyze': _$EffortSettingsAnalyzeEnumEnumMap[instance.analyze]!,
      'coding': _$EffortSettingsCodingEnumEnumMap[instance.coding]!,
      'review': _$EffortSettingsReviewEnumEnumMap[instance.review]!,
      'complex': _$EffortSettingsComplexEnumEnumMap[instance.complex]!,
    };

const _$EffortSettingsAnalyzeEnumEnumMap = {
  EffortSettingsAnalyzeEnum.empty: '',
  EffortSettingsAnalyzeEnum.low: 'low',
  EffortSettingsAnalyzeEnum.medium: 'medium',
  EffortSettingsAnalyzeEnum.high: 'high',
};

const _$EffortSettingsCodingEnumEnumMap = {
  EffortSettingsCodingEnum.empty: '',
  EffortSettingsCodingEnum.low: 'low',
  EffortSettingsCodingEnum.medium: 'medium',
  EffortSettingsCodingEnum.high: 'high',
};

const _$EffortSettingsReviewEnumEnumMap = {
  EffortSettingsReviewEnum.empty: '',
  EffortSettingsReviewEnum.low: 'low',
  EffortSettingsReviewEnum.medium: 'medium',
  EffortSettingsReviewEnum.high: 'high',
};

const _$EffortSettingsComplexEnumEnumMap = {
  EffortSettingsComplexEnum.empty: '',
  EffortSettingsComplexEnum.low: 'low',
  EffortSettingsComplexEnum.medium: 'medium',
  EffortSettingsComplexEnum.high: 'high',
};

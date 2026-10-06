// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stage_models.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StageModelsCWProxy {
  StageModels analyze(Model analyze);

  StageModels coding(Model coding);

  StageModels retry(Model retry);

  StageModels helper(Model helper);

  StageModels learn(Model? learn);

  StageModels review(ReviewModel? review);

  StageModels preview(Model? preview);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StageModels(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StageModels(...).copyWith(id: 12, name: "My name")
  /// ````
  StageModels call({
    Model analyze,
    Model coding,
    Model retry,
    Model helper,
    Model? learn,
    ReviewModel? review,
    Model? preview,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStageModels.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStageModels.copyWith.fieldName(...)`
class _$StageModelsCWProxyImpl implements _$StageModelsCWProxy {
  const _$StageModelsCWProxyImpl(this._value);

  final StageModels _value;

  @override
  StageModels analyze(Model analyze) => this(analyze: analyze);

  @override
  StageModels coding(Model coding) => this(coding: coding);

  @override
  StageModels retry(Model retry) => this(retry: retry);

  @override
  StageModels helper(Model helper) => this(helper: helper);

  @override
  StageModels learn(Model? learn) => this(learn: learn);

  @override
  StageModels review(ReviewModel? review) => this(review: review);

  @override
  StageModels preview(Model? preview) => this(preview: preview);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StageModels(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StageModels(...).copyWith(id: 12, name: "My name")
  /// ````
  StageModels call({
    Object? analyze = const $CopyWithPlaceholder(),
    Object? coding = const $CopyWithPlaceholder(),
    Object? retry = const $CopyWithPlaceholder(),
    Object? helper = const $CopyWithPlaceholder(),
    Object? learn = const $CopyWithPlaceholder(),
    Object? review = const $CopyWithPlaceholder(),
    Object? preview = const $CopyWithPlaceholder(),
  }) {
    return StageModels(
      analyze: analyze == const $CopyWithPlaceholder()
          ? _value.analyze
          // ignore: cast_nullable_to_non_nullable
          : analyze as Model,
      coding: coding == const $CopyWithPlaceholder()
          ? _value.coding
          // ignore: cast_nullable_to_non_nullable
          : coding as Model,
      retry: retry == const $CopyWithPlaceholder()
          ? _value.retry
          // ignore: cast_nullable_to_non_nullable
          : retry as Model,
      helper: helper == const $CopyWithPlaceholder()
          ? _value.helper
          // ignore: cast_nullable_to_non_nullable
          : helper as Model,
      learn: learn == const $CopyWithPlaceholder()
          ? _value.learn
          // ignore: cast_nullable_to_non_nullable
          : learn as Model?,
      review: review == const $CopyWithPlaceholder()
          ? _value.review
          // ignore: cast_nullable_to_non_nullable
          : review as ReviewModel?,
      preview: preview == const $CopyWithPlaceholder()
          ? _value.preview
          // ignore: cast_nullable_to_non_nullable
          : preview as Model?,
    );
  }
}

extension $StageModelsCopyWith on StageModels {
  /// Returns a callable class that can be used as follows: `instanceOfStageModels.copyWith(...)` or like so:`instanceOfStageModels.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StageModelsCWProxy get copyWith => _$StageModelsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StageModels _$StageModelsFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('StageModels', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['analyze', 'coding', 'retry', 'helper'],
  );
  final val = StageModels(
    analyze: $checkedConvert('analyze', (v) => $enumDecode(_$ModelEnumMap, v)),
    coding: $checkedConvert('coding', (v) => $enumDecode(_$ModelEnumMap, v)),
    retry: $checkedConvert('retry', (v) => $enumDecode(_$ModelEnumMap, v)),
    helper: $checkedConvert('helper', (v) => $enumDecode(_$ModelEnumMap, v)),
    learn: $checkedConvert(
      'learn',
      (v) => $enumDecodeNullable(_$ModelEnumMap, v),
    ),
    review: $checkedConvert(
      'review',
      (v) => $enumDecodeNullable(_$ReviewModelEnumMap, v),
    ),
    preview: $checkedConvert(
      'preview',
      (v) => $enumDecodeNullable(_$ModelEnumMap, v),
    ),
  );
  return val;
});

Map<String, dynamic> _$StageModelsToJson(StageModels instance) =>
    <String, dynamic>{
      'analyze': _$ModelEnumMap[instance.analyze]!,
      'coding': _$ModelEnumMap[instance.coding]!,
      'retry': _$ModelEnumMap[instance.retry]!,
      'helper': _$ModelEnumMap[instance.helper]!,
      'learn': ?_$ModelEnumMap[instance.learn],
      'review': ?_$ReviewModelEnumMap[instance.review],
      'preview': ?_$ModelEnumMap[instance.preview],
    };

const _$ModelEnumMap = {
  Model.haiku: 'haiku',
  Model.sonnet: 'sonnet',
  Model.opus: 'opus',
};

const _$ReviewModelEnumMap = {
  ReviewModel.auto: 'auto',
  ReviewModel.haiku: 'haiku',
  ReviewModel.sonnet: 'sonnet',
  ReviewModel.opus: 'opus',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stage_models.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StageModelsCWProxy {
  StageModels analyze(String analyze);

  StageModels coding(String coding);

  StageModels retry(String retry);

  StageModels helper(String helper);

  StageModels learn(String? learn);

  StageModels review(String? review);

  StageModels preview(String? preview);

  StageModels chat(String? chat);

  StageModels documents(String? documents);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StageModels(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StageModels(...).copyWith(id: 12, name: "My name")
  /// ````
  StageModels call({
    String analyze,
    String coding,
    String retry,
    String helper,
    String? learn,
    String? review,
    String? preview,
    String? chat,
    String? documents,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStageModels.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStageModels.copyWith.fieldName(...)`
class _$StageModelsCWProxyImpl implements _$StageModelsCWProxy {
  const _$StageModelsCWProxyImpl(this._value);

  final StageModels _value;

  @override
  StageModels analyze(String analyze) => this(analyze: analyze);

  @override
  StageModels coding(String coding) => this(coding: coding);

  @override
  StageModels retry(String retry) => this(retry: retry);

  @override
  StageModels helper(String helper) => this(helper: helper);

  @override
  StageModels learn(String? learn) => this(learn: learn);

  @override
  StageModels review(String? review) => this(review: review);

  @override
  StageModels preview(String? preview) => this(preview: preview);

  @override
  StageModels chat(String? chat) => this(chat: chat);

  @override
  StageModels documents(String? documents) => this(documents: documents);

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
    Object? chat = const $CopyWithPlaceholder(),
    Object? documents = const $CopyWithPlaceholder(),
  }) {
    return StageModels(
      analyze: analyze == const $CopyWithPlaceholder()
          ? _value.analyze
          // ignore: cast_nullable_to_non_nullable
          : analyze as String,
      coding: coding == const $CopyWithPlaceholder()
          ? _value.coding
          // ignore: cast_nullable_to_non_nullable
          : coding as String,
      retry: retry == const $CopyWithPlaceholder()
          ? _value.retry
          // ignore: cast_nullable_to_non_nullable
          : retry as String,
      helper: helper == const $CopyWithPlaceholder()
          ? _value.helper
          // ignore: cast_nullable_to_non_nullable
          : helper as String,
      learn: learn == const $CopyWithPlaceholder()
          ? _value.learn
          // ignore: cast_nullable_to_non_nullable
          : learn as String?,
      review: review == const $CopyWithPlaceholder()
          ? _value.review
          // ignore: cast_nullable_to_non_nullable
          : review as String?,
      preview: preview == const $CopyWithPlaceholder()
          ? _value.preview
          // ignore: cast_nullable_to_non_nullable
          : preview as String?,
      chat: chat == const $CopyWithPlaceholder()
          ? _value.chat
          // ignore: cast_nullable_to_non_nullable
          : chat as String?,
      documents: documents == const $CopyWithPlaceholder()
          ? _value.documents
          // ignore: cast_nullable_to_non_nullable
          : documents as String?,
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

StageModels _$StageModelsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('StageModels', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['analyze', 'coding', 'retry', 'helper'],
      );
      final val = StageModels(
        analyze: $checkedConvert('analyze', (v) => v as String),
        coding: $checkedConvert('coding', (v) => v as String),
        retry: $checkedConvert('retry', (v) => v as String),
        helper: $checkedConvert('helper', (v) => v as String),
        learn: $checkedConvert('learn', (v) => v as String?),
        review: $checkedConvert('review', (v) => v as String?),
        preview: $checkedConvert('preview', (v) => v as String?),
        chat: $checkedConvert('chat', (v) => v as String?),
        documents: $checkedConvert('documents', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$StageModelsToJson(StageModels instance) =>
    <String, dynamic>{
      'analyze': instance.analyze,
      'coding': instance.coding,
      'retry': instance.retry,
      'helper': instance.helper,
      'learn': ?instance.learn,
      'review': ?instance.review,
      'preview': ?instance.preview,
      'chat': ?instance.chat,
      'documents': ?instance.documents,
    };

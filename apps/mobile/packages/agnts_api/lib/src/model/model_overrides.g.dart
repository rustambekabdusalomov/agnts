// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_overrides.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ModelOverridesCWProxy {
  ModelOverrides analyze(String? analyze);

  ModelOverrides coding(String? coding);

  ModelOverrides retry(String? retry);

  ModelOverrides review(String? review);

  ModelOverrides preview(String? preview);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ModelOverrides(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ModelOverrides(...).copyWith(id: 12, name: "My name")
  /// ````
  ModelOverrides call({
    String? analyze,
    String? coding,
    String? retry,
    String? review,
    String? preview,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfModelOverrides.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfModelOverrides.copyWith.fieldName(...)`
class _$ModelOverridesCWProxyImpl implements _$ModelOverridesCWProxy {
  const _$ModelOverridesCWProxyImpl(this._value);

  final ModelOverrides _value;

  @override
  ModelOverrides analyze(String? analyze) => this(analyze: analyze);

  @override
  ModelOverrides coding(String? coding) => this(coding: coding);

  @override
  ModelOverrides retry(String? retry) => this(retry: retry);

  @override
  ModelOverrides review(String? review) => this(review: review);

  @override
  ModelOverrides preview(String? preview) => this(preview: preview);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ModelOverrides(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ModelOverrides(...).copyWith(id: 12, name: "My name")
  /// ````
  ModelOverrides call({
    Object? analyze = const $CopyWithPlaceholder(),
    Object? coding = const $CopyWithPlaceholder(),
    Object? retry = const $CopyWithPlaceholder(),
    Object? review = const $CopyWithPlaceholder(),
    Object? preview = const $CopyWithPlaceholder(),
  }) {
    return ModelOverrides(
      analyze: analyze == const $CopyWithPlaceholder()
          ? _value.analyze
          // ignore: cast_nullable_to_non_nullable
          : analyze as String?,
      coding: coding == const $CopyWithPlaceholder()
          ? _value.coding
          // ignore: cast_nullable_to_non_nullable
          : coding as String?,
      retry: retry == const $CopyWithPlaceholder()
          ? _value.retry
          // ignore: cast_nullable_to_non_nullable
          : retry as String?,
      review: review == const $CopyWithPlaceholder()
          ? _value.review
          // ignore: cast_nullable_to_non_nullable
          : review as String?,
      preview: preview == const $CopyWithPlaceholder()
          ? _value.preview
          // ignore: cast_nullable_to_non_nullable
          : preview as String?,
    );
  }
}

extension $ModelOverridesCopyWith on ModelOverrides {
  /// Returns a callable class that can be used as follows: `instanceOfModelOverrides.copyWith(...)` or like so:`instanceOfModelOverrides.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ModelOverridesCWProxy get copyWith => _$ModelOverridesCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModelOverrides _$ModelOverridesFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ModelOverrides', json, ($checkedConvert) {
      final val = ModelOverrides(
        analyze: $checkedConvert('analyze', (v) => v as String?),
        coding: $checkedConvert('coding', (v) => v as String?),
        retry: $checkedConvert('retry', (v) => v as String?),
        review: $checkedConvert('review', (v) => v as String?),
        preview: $checkedConvert('preview', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$ModelOverridesToJson(ModelOverrides instance) =>
    <String, dynamic>{
      'analyze': ?instance.analyze,
      'coding': ?instance.coding,
      'retry': ?instance.retry,
      'review': ?instance.review,
      'preview': ?instance.preview,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_overrides.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ModelOverridesCWProxy {
  ModelOverrides analyze(Model? analyze);

  ModelOverrides coding(Model? coding);

  ModelOverrides retry(Model? retry);

  ModelOverrides review(Model? review);

  ModelOverrides preview(Model? preview);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ModelOverrides(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ModelOverrides(...).copyWith(id: 12, name: "My name")
  /// ````
  ModelOverrides call({
    Model? analyze,
    Model? coding,
    Model? retry,
    Model? review,
    Model? preview,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfModelOverrides.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfModelOverrides.copyWith.fieldName(...)`
class _$ModelOverridesCWProxyImpl implements _$ModelOverridesCWProxy {
  const _$ModelOverridesCWProxyImpl(this._value);

  final ModelOverrides _value;

  @override
  ModelOverrides analyze(Model? analyze) => this(analyze: analyze);

  @override
  ModelOverrides coding(Model? coding) => this(coding: coding);

  @override
  ModelOverrides retry(Model? retry) => this(retry: retry);

  @override
  ModelOverrides review(Model? review) => this(review: review);

  @override
  ModelOverrides preview(Model? preview) => this(preview: preview);

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
          : analyze as Model?,
      coding: coding == const $CopyWithPlaceholder()
          ? _value.coding
          // ignore: cast_nullable_to_non_nullable
          : coding as Model?,
      retry: retry == const $CopyWithPlaceholder()
          ? _value.retry
          // ignore: cast_nullable_to_non_nullable
          : retry as Model?,
      review: review == const $CopyWithPlaceholder()
          ? _value.review
          // ignore: cast_nullable_to_non_nullable
          : review as Model?,
      preview: preview == const $CopyWithPlaceholder()
          ? _value.preview
          // ignore: cast_nullable_to_non_nullable
          : preview as Model?,
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
        analyze: $checkedConvert(
          'analyze',
          (v) => $enumDecodeNullable(_$ModelEnumMap, v),
        ),
        coding: $checkedConvert(
          'coding',
          (v) => $enumDecodeNullable(_$ModelEnumMap, v),
        ),
        retry: $checkedConvert(
          'retry',
          (v) => $enumDecodeNullable(_$ModelEnumMap, v),
        ),
        review: $checkedConvert(
          'review',
          (v) => $enumDecodeNullable(_$ModelEnumMap, v),
        ),
        preview: $checkedConvert(
          'preview',
          (v) => $enumDecodeNullable(_$ModelEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ModelOverridesToJson(ModelOverrides instance) =>
    <String, dynamic>{
      'analyze': ?_$ModelEnumMap[instance.analyze],
      'coding': ?_$ModelEnumMap[instance.coding],
      'retry': ?_$ModelEnumMap[instance.retry],
      'review': ?_$ModelEnumMap[instance.review],
      'preview': ?_$ModelEnumMap[instance.preview],
    };

const _$ModelEnumMap = {
  Model.haiku: 'haiku',
  Model.sonnet: 'sonnet',
  Model.opus: 'opus',
};

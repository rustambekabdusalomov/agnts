// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'second_opinion.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SecondOpinionCWProxy {
  SecondOpinion model(String model);

  SecondOpinion agrees(bool agrees);

  SecondOpinion summary(String summary);

  SecondOpinion concerns(List<String>? concerns);

  SecondOpinion alternative(String? alternative);

  SecondOpinion error(String? error);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SecondOpinion(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SecondOpinion(...).copyWith(id: 12, name: "My name")
  /// ````
  SecondOpinion call({
    String model,
    bool agrees,
    String summary,
    List<String>? concerns,
    String? alternative,
    String? error,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSecondOpinion.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSecondOpinion.copyWith.fieldName(...)`
class _$SecondOpinionCWProxyImpl implements _$SecondOpinionCWProxy {
  const _$SecondOpinionCWProxyImpl(this._value);

  final SecondOpinion _value;

  @override
  SecondOpinion model(String model) => this(model: model);

  @override
  SecondOpinion agrees(bool agrees) => this(agrees: agrees);

  @override
  SecondOpinion summary(String summary) => this(summary: summary);

  @override
  SecondOpinion concerns(List<String>? concerns) => this(concerns: concerns);

  @override
  SecondOpinion alternative(String? alternative) =>
      this(alternative: alternative);

  @override
  SecondOpinion error(String? error) => this(error: error);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SecondOpinion(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SecondOpinion(...).copyWith(id: 12, name: "My name")
  /// ````
  SecondOpinion call({
    Object? model = const $CopyWithPlaceholder(),
    Object? agrees = const $CopyWithPlaceholder(),
    Object? summary = const $CopyWithPlaceholder(),
    Object? concerns = const $CopyWithPlaceholder(),
    Object? alternative = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
  }) {
    return SecondOpinion(
      model: model == const $CopyWithPlaceholder()
          ? _value.model
          // ignore: cast_nullable_to_non_nullable
          : model as String,
      agrees: agrees == const $CopyWithPlaceholder()
          ? _value.agrees
          // ignore: cast_nullable_to_non_nullable
          : agrees as bool,
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as String,
      concerns: concerns == const $CopyWithPlaceholder()
          ? _value.concerns
          // ignore: cast_nullable_to_non_nullable
          : concerns as List<String>?,
      alternative: alternative == const $CopyWithPlaceholder()
          ? _value.alternative
          // ignore: cast_nullable_to_non_nullable
          : alternative as String?,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String?,
    );
  }
}

extension $SecondOpinionCopyWith on SecondOpinion {
  /// Returns a callable class that can be used as follows: `instanceOfSecondOpinion.copyWith(...)` or like so:`instanceOfSecondOpinion.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SecondOpinionCWProxy get copyWith => _$SecondOpinionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SecondOpinion _$SecondOpinionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SecondOpinion', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['model', 'agrees', 'summary']);
      final val = SecondOpinion(
        model: $checkedConvert('model', (v) => v as String),
        agrees: $checkedConvert('agrees', (v) => v as bool),
        summary: $checkedConvert('summary', (v) => v as String),
        concerns: $checkedConvert(
          'concerns',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        alternative: $checkedConvert('alternative', (v) => v as String?),
        error: $checkedConvert('error', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$SecondOpinionToJson(SecondOpinion instance) =>
    <String, dynamic>{
      'model': instance.model,
      'agrees': instance.agrees,
      'summary': instance.summary,
      'concerns': ?instance.concerns,
      'alternative': ?instance.alternative,
      'error': ?instance.error,
    };

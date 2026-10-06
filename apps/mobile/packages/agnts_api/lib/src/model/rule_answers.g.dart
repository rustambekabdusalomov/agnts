// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule_answers.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RuleAnswersCWProxy {
  RuleAnswers answers(List<RuleAnswersAnswersInner> answers);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RuleAnswers(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RuleAnswers(...).copyWith(id: 12, name: "My name")
  /// ````
  RuleAnswers call({List<RuleAnswersAnswersInner> answers});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRuleAnswers.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRuleAnswers.copyWith.fieldName(...)`
class _$RuleAnswersCWProxyImpl implements _$RuleAnswersCWProxy {
  const _$RuleAnswersCWProxyImpl(this._value);

  final RuleAnswers _value;

  @override
  RuleAnswers answers(List<RuleAnswersAnswersInner> answers) =>
      this(answers: answers);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RuleAnswers(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RuleAnswers(...).copyWith(id: 12, name: "My name")
  /// ````
  RuleAnswers call({Object? answers = const $CopyWithPlaceholder()}) {
    return RuleAnswers(
      answers: answers == const $CopyWithPlaceholder()
          ? _value.answers
          // ignore: cast_nullable_to_non_nullable
          : answers as List<RuleAnswersAnswersInner>,
    );
  }
}

extension $RuleAnswersCopyWith on RuleAnswers {
  /// Returns a callable class that can be used as follows: `instanceOfRuleAnswers.copyWith(...)` or like so:`instanceOfRuleAnswers.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RuleAnswersCWProxy get copyWith => _$RuleAnswersCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RuleAnswers _$RuleAnswersFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RuleAnswers', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['answers']);
      final val = RuleAnswers(
        answers: $checkedConvert(
          'answers',
          (v) => (v as List<dynamic>)
              .map(
                (e) =>
                    RuleAnswersAnswersInner.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$RuleAnswersToJson(RuleAnswers instance) =>
    <String, dynamic>{
      'answers': instance.answers.map((e) => e.toJson()).toList(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_question.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$QuizQuestionCWProxy {
  QuizQuestion question(String question);

  QuizQuestion options(List<String> options);

  QuizQuestion answer(int answer);

  QuizQuestion explanation(String? explanation);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `QuizQuestion(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// QuizQuestion(...).copyWith(id: 12, name: "My name")
  /// ````
  QuizQuestion call({
    String question,
    List<String> options,
    int answer,
    String? explanation,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfQuizQuestion.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfQuizQuestion.copyWith.fieldName(...)`
class _$QuizQuestionCWProxyImpl implements _$QuizQuestionCWProxy {
  const _$QuizQuestionCWProxyImpl(this._value);

  final QuizQuestion _value;

  @override
  QuizQuestion question(String question) => this(question: question);

  @override
  QuizQuestion options(List<String> options) => this(options: options);

  @override
  QuizQuestion answer(int answer) => this(answer: answer);

  @override
  QuizQuestion explanation(String? explanation) =>
      this(explanation: explanation);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `QuizQuestion(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// QuizQuestion(...).copyWith(id: 12, name: "My name")
  /// ````
  QuizQuestion call({
    Object? question = const $CopyWithPlaceholder(),
    Object? options = const $CopyWithPlaceholder(),
    Object? answer = const $CopyWithPlaceholder(),
    Object? explanation = const $CopyWithPlaceholder(),
  }) {
    return QuizQuestion(
      question: question == const $CopyWithPlaceholder()
          ? _value.question
          // ignore: cast_nullable_to_non_nullable
          : question as String,
      options: options == const $CopyWithPlaceholder()
          ? _value.options
          // ignore: cast_nullable_to_non_nullable
          : options as List<String>,
      answer: answer == const $CopyWithPlaceholder()
          ? _value.answer
          // ignore: cast_nullable_to_non_nullable
          : answer as int,
      explanation: explanation == const $CopyWithPlaceholder()
          ? _value.explanation
          // ignore: cast_nullable_to_non_nullable
          : explanation as String?,
    );
  }
}

extension $QuizQuestionCopyWith on QuizQuestion {
  /// Returns a callable class that can be used as follows: `instanceOfQuizQuestion.copyWith(...)` or like so:`instanceOfQuizQuestion.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$QuizQuestionCWProxy get copyWith => _$QuizQuestionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizQuestion _$QuizQuestionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('QuizQuestion', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['question', 'options', 'answer']);
      final val = QuizQuestion(
        question: $checkedConvert('question', (v) => v as String),
        options: $checkedConvert(
          'options',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        answer: $checkedConvert('answer', (v) => (v as num).toInt()),
        explanation: $checkedConvert('explanation', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$QuizQuestionToJson(QuizQuestion instance) =>
    <String, dynamic>{
      'question': instance.question,
      'options': instance.options,
      'answer': instance.answer,
      'explanation': ?instance.explanation,
    };

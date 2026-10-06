// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule_question.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RuleQuestionCWProxy {
  RuleQuestion index(int index);

  RuleQuestion text(String text);

  RuleQuestion options(List<String> options);

  RuleQuestion answer(String? answer);

  RuleQuestion note(String? note);

  RuleQuestion round(int round);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RuleQuestion(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RuleQuestion(...).copyWith(id: 12, name: "My name")
  /// ````
  RuleQuestion call({
    int index,
    String text,
    List<String> options,
    String? answer,
    String? note,
    int round,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRuleQuestion.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRuleQuestion.copyWith.fieldName(...)`
class _$RuleQuestionCWProxyImpl implements _$RuleQuestionCWProxy {
  const _$RuleQuestionCWProxyImpl(this._value);

  final RuleQuestion _value;

  @override
  RuleQuestion index(int index) => this(index: index);

  @override
  RuleQuestion text(String text) => this(text: text);

  @override
  RuleQuestion options(List<String> options) => this(options: options);

  @override
  RuleQuestion answer(String? answer) => this(answer: answer);

  @override
  RuleQuestion note(String? note) => this(note: note);

  @override
  RuleQuestion round(int round) => this(round: round);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RuleQuestion(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RuleQuestion(...).copyWith(id: 12, name: "My name")
  /// ````
  RuleQuestion call({
    Object? index = const $CopyWithPlaceholder(),
    Object? text = const $CopyWithPlaceholder(),
    Object? options = const $CopyWithPlaceholder(),
    Object? answer = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? round = const $CopyWithPlaceholder(),
  }) {
    return RuleQuestion(
      index: index == const $CopyWithPlaceholder()
          ? _value.index
          // ignore: cast_nullable_to_non_nullable
          : index as int,
      text: text == const $CopyWithPlaceholder()
          ? _value.text
          // ignore: cast_nullable_to_non_nullable
          : text as String,
      options: options == const $CopyWithPlaceholder()
          ? _value.options
          // ignore: cast_nullable_to_non_nullable
          : options as List<String>,
      answer: answer == const $CopyWithPlaceholder()
          ? _value.answer
          // ignore: cast_nullable_to_non_nullable
          : answer as String?,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
      round: round == const $CopyWithPlaceholder()
          ? _value.round
          // ignore: cast_nullable_to_non_nullable
          : round as int,
    );
  }
}

extension $RuleQuestionCopyWith on RuleQuestion {
  /// Returns a callable class that can be used as follows: `instanceOfRuleQuestion.copyWith(...)` or like so:`instanceOfRuleQuestion.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RuleQuestionCWProxy get copyWith => _$RuleQuestionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RuleQuestion _$RuleQuestionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RuleQuestion', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['index', 'text', 'options', 'round'],
      );
      final val = RuleQuestion(
        index: $checkedConvert('index', (v) => (v as num).toInt()),
        text: $checkedConvert('text', (v) => v as String),
        options: $checkedConvert(
          'options',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        answer: $checkedConvert('answer', (v) => v as String?),
        note: $checkedConvert('note', (v) => v as String?),
        round: $checkedConvert('round', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$RuleQuestionToJson(RuleQuestion instance) =>
    <String, dynamic>{
      'index': instance.index,
      'text': instance.text,
      'options': instance.options,
      'answer': ?instance.answer,
      'note': ?instance.note,
      'round': instance.round,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer_draft_request_answers_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AnswerDraftRequestAnswersInnerCWProxy {
  AnswerDraftRequestAnswersInner questionId(int questionId);

  AnswerDraftRequestAnswersInner answer(String answer);

  AnswerDraftRequestAnswersInner note(String? note);

  AnswerDraftRequestAnswersInner attachments(List<int>? attachments);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnswerDraftRequestAnswersInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnswerDraftRequestAnswersInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AnswerDraftRequestAnswersInner call({
    int questionId,
    String answer,
    String? note,
    List<int>? attachments,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAnswerDraftRequestAnswersInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAnswerDraftRequestAnswersInner.copyWith.fieldName(...)`
class _$AnswerDraftRequestAnswersInnerCWProxyImpl
    implements _$AnswerDraftRequestAnswersInnerCWProxy {
  const _$AnswerDraftRequestAnswersInnerCWProxyImpl(this._value);

  final AnswerDraftRequestAnswersInner _value;

  @override
  AnswerDraftRequestAnswersInner questionId(int questionId) =>
      this(questionId: questionId);

  @override
  AnswerDraftRequestAnswersInner answer(String answer) => this(answer: answer);

  @override
  AnswerDraftRequestAnswersInner note(String? note) => this(note: note);

  @override
  AnswerDraftRequestAnswersInner attachments(List<int>? attachments) =>
      this(attachments: attachments);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnswerDraftRequestAnswersInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnswerDraftRequestAnswersInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AnswerDraftRequestAnswersInner call({
    Object? questionId = const $CopyWithPlaceholder(),
    Object? answer = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? attachments = const $CopyWithPlaceholder(),
  }) {
    return AnswerDraftRequestAnswersInner(
      questionId: questionId == const $CopyWithPlaceholder()
          ? _value.questionId
          // ignore: cast_nullable_to_non_nullable
          : questionId as int,
      answer: answer == const $CopyWithPlaceholder()
          ? _value.answer
          // ignore: cast_nullable_to_non_nullable
          : answer as String,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
      attachments: attachments == const $CopyWithPlaceholder()
          ? _value.attachments
          // ignore: cast_nullable_to_non_nullable
          : attachments as List<int>?,
    );
  }
}

extension $AnswerDraftRequestAnswersInnerCopyWith
    on AnswerDraftRequestAnswersInner {
  /// Returns a callable class that can be used as follows: `instanceOfAnswerDraftRequestAnswersInner.copyWith(...)` or like so:`instanceOfAnswerDraftRequestAnswersInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AnswerDraftRequestAnswersInnerCWProxy get copyWith =>
      _$AnswerDraftRequestAnswersInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnswerDraftRequestAnswersInner _$AnswerDraftRequestAnswersInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AnswerDraftRequestAnswersInner', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['questionId', 'answer']);
  final val = AnswerDraftRequestAnswersInner(
    questionId: $checkedConvert('questionId', (v) => (v as num).toInt()),
    answer: $checkedConvert('answer', (v) => v as String),
    note: $checkedConvert('note', (v) => v as String?),
    attachments: $checkedConvert(
      'attachments',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$AnswerDraftRequestAnswersInnerToJson(
  AnswerDraftRequestAnswersInner instance,
) => <String, dynamic>{
  'questionId': instance.questionId,
  'answer': instance.answer,
  'note': ?instance.note,
  'attachments': ?instance.attachments,
};

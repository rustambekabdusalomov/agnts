// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answers_request_answers_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AnswersRequestAnswersInnerCWProxy {
  AnswersRequestAnswersInner questionId(int questionId);

  AnswersRequestAnswersInner answer(String answer);

  AnswersRequestAnswersInner note(String? note);

  AnswersRequestAnswersInner attachments(List<int>? attachments);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnswersRequestAnswersInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnswersRequestAnswersInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AnswersRequestAnswersInner call({
    int questionId,
    String answer,
    String? note,
    List<int>? attachments,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAnswersRequestAnswersInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAnswersRequestAnswersInner.copyWith.fieldName(...)`
class _$AnswersRequestAnswersInnerCWProxyImpl
    implements _$AnswersRequestAnswersInnerCWProxy {
  const _$AnswersRequestAnswersInnerCWProxyImpl(this._value);

  final AnswersRequestAnswersInner _value;

  @override
  AnswersRequestAnswersInner questionId(int questionId) =>
      this(questionId: questionId);

  @override
  AnswersRequestAnswersInner answer(String answer) => this(answer: answer);

  @override
  AnswersRequestAnswersInner note(String? note) => this(note: note);

  @override
  AnswersRequestAnswersInner attachments(List<int>? attachments) =>
      this(attachments: attachments);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnswersRequestAnswersInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnswersRequestAnswersInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AnswersRequestAnswersInner call({
    Object? questionId = const $CopyWithPlaceholder(),
    Object? answer = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? attachments = const $CopyWithPlaceholder(),
  }) {
    return AnswersRequestAnswersInner(
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

extension $AnswersRequestAnswersInnerCopyWith on AnswersRequestAnswersInner {
  /// Returns a callable class that can be used as follows: `instanceOfAnswersRequestAnswersInner.copyWith(...)` or like so:`instanceOfAnswersRequestAnswersInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AnswersRequestAnswersInnerCWProxy get copyWith =>
      _$AnswersRequestAnswersInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnswersRequestAnswersInner _$AnswersRequestAnswersInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AnswersRequestAnswersInner', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['questionId', 'answer']);
  final val = AnswersRequestAnswersInner(
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

Map<String, dynamic> _$AnswersRequestAnswersInnerToJson(
  AnswersRequestAnswersInner instance,
) => <String, dynamic>{
  'questionId': instance.questionId,
  'answer': instance.answer,
  'note': ?instance.note,
  'attachments': ?instance.attachments,
};

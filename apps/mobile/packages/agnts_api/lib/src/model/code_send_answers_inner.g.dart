// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code_send_answers_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CodeSendAnswersInnerCWProxy {
  CodeSendAnswersInner questionId(int questionId);

  CodeSendAnswersInner answer(String answer);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CodeSendAnswersInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CodeSendAnswersInner(...).copyWith(id: 12, name: "My name")
  /// ````
  CodeSendAnswersInner call({int questionId, String answer});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCodeSendAnswersInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCodeSendAnswersInner.copyWith.fieldName(...)`
class _$CodeSendAnswersInnerCWProxyImpl
    implements _$CodeSendAnswersInnerCWProxy {
  const _$CodeSendAnswersInnerCWProxyImpl(this._value);

  final CodeSendAnswersInner _value;

  @override
  CodeSendAnswersInner questionId(int questionId) =>
      this(questionId: questionId);

  @override
  CodeSendAnswersInner answer(String answer) => this(answer: answer);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CodeSendAnswersInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CodeSendAnswersInner(...).copyWith(id: 12, name: "My name")
  /// ````
  CodeSendAnswersInner call({
    Object? questionId = const $CopyWithPlaceholder(),
    Object? answer = const $CopyWithPlaceholder(),
  }) {
    return CodeSendAnswersInner(
      questionId: questionId == const $CopyWithPlaceholder()
          ? _value.questionId
          // ignore: cast_nullable_to_non_nullable
          : questionId as int,
      answer: answer == const $CopyWithPlaceholder()
          ? _value.answer
          // ignore: cast_nullable_to_non_nullable
          : answer as String,
    );
  }
}

extension $CodeSendAnswersInnerCopyWith on CodeSendAnswersInner {
  /// Returns a callable class that can be used as follows: `instanceOfCodeSendAnswersInner.copyWith(...)` or like so:`instanceOfCodeSendAnswersInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CodeSendAnswersInnerCWProxy get copyWith =>
      _$CodeSendAnswersInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CodeSendAnswersInner _$CodeSendAnswersInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CodeSendAnswersInner', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['questionId', 'answer']);
  final val = CodeSendAnswersInner(
    questionId: $checkedConvert('questionId', (v) => (v as num).toInt()),
    answer: $checkedConvert('answer', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$CodeSendAnswersInnerToJson(
  CodeSendAnswersInner instance,
) => <String, dynamic>{
  'questionId': instance.questionId,
  'answer': instance.answer,
};

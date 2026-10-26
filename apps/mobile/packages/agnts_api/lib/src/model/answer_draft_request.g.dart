// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer_draft_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AnswerDraftRequestCWProxy {
  AnswerDraftRequest answers(List<AnswerDraftRequestAnswersInner> answers);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnswerDraftRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnswerDraftRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AnswerDraftRequest call({List<AnswerDraftRequestAnswersInner> answers});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAnswerDraftRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAnswerDraftRequest.copyWith.fieldName(...)`
class _$AnswerDraftRequestCWProxyImpl implements _$AnswerDraftRequestCWProxy {
  const _$AnswerDraftRequestCWProxyImpl(this._value);

  final AnswerDraftRequest _value;

  @override
  AnswerDraftRequest answers(List<AnswerDraftRequestAnswersInner> answers) =>
      this(answers: answers);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnswerDraftRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnswerDraftRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AnswerDraftRequest call({Object? answers = const $CopyWithPlaceholder()}) {
    return AnswerDraftRequest(
      answers: answers == const $CopyWithPlaceholder()
          ? _value.answers
          // ignore: cast_nullable_to_non_nullable
          : answers as List<AnswerDraftRequestAnswersInner>,
    );
  }
}

extension $AnswerDraftRequestCopyWith on AnswerDraftRequest {
  /// Returns a callable class that can be used as follows: `instanceOfAnswerDraftRequest.copyWith(...)` or like so:`instanceOfAnswerDraftRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AnswerDraftRequestCWProxy get copyWith =>
      _$AnswerDraftRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnswerDraftRequest _$AnswerDraftRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AnswerDraftRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['answers']);
      final val = AnswerDraftRequest(
        answers: $checkedConvert(
          'answers',
          (v) => (v as List<dynamic>)
              .map(
                (e) => AnswerDraftRequestAnswersInner.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AnswerDraftRequestToJson(AnswerDraftRequest instance) =>
    <String, dynamic>{
      'answers': instance.answers.map((e) => e.toJson()).toList(),
    };

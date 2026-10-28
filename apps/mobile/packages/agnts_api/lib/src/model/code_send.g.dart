// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code_send.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CodeSendCWProxy {
  CodeSend text(String? text);

  CodeSend attachments(List<int>? attachments);

  CodeSend answers(List<CodeSendAnswersInner>? answers);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CodeSend(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CodeSend(...).copyWith(id: 12, name: "My name")
  /// ````
  CodeSend call({
    String? text,
    List<int>? attachments,
    List<CodeSendAnswersInner>? answers,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCodeSend.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCodeSend.copyWith.fieldName(...)`
class _$CodeSendCWProxyImpl implements _$CodeSendCWProxy {
  const _$CodeSendCWProxyImpl(this._value);

  final CodeSend _value;

  @override
  CodeSend text(String? text) => this(text: text);

  @override
  CodeSend attachments(List<int>? attachments) =>
      this(attachments: attachments);

  @override
  CodeSend answers(List<CodeSendAnswersInner>? answers) =>
      this(answers: answers);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CodeSend(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CodeSend(...).copyWith(id: 12, name: "My name")
  /// ````
  CodeSend call({
    Object? text = const $CopyWithPlaceholder(),
    Object? attachments = const $CopyWithPlaceholder(),
    Object? answers = const $CopyWithPlaceholder(),
  }) {
    return CodeSend(
      text: text == const $CopyWithPlaceholder()
          ? _value.text
          // ignore: cast_nullable_to_non_nullable
          : text as String?,
      attachments: attachments == const $CopyWithPlaceholder()
          ? _value.attachments
          // ignore: cast_nullable_to_non_nullable
          : attachments as List<int>?,
      answers: answers == const $CopyWithPlaceholder()
          ? _value.answers
          // ignore: cast_nullable_to_non_nullable
          : answers as List<CodeSendAnswersInner>?,
    );
  }
}

extension $CodeSendCopyWith on CodeSend {
  /// Returns a callable class that can be used as follows: `instanceOfCodeSend.copyWith(...)` or like so:`instanceOfCodeSend.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CodeSendCWProxy get copyWith => _$CodeSendCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CodeSend _$CodeSendFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CodeSend', json, ($checkedConvert) {
      final val = CodeSend(
        text: $checkedConvert('text', (v) => v as String?),
        attachments: $checkedConvert(
          'attachments',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
        answers: $checkedConvert(
          'answers',
          (v) => (v as List<dynamic>?)
              ?.map(
                (e) => CodeSendAnswersInner.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CodeSendToJson(CodeSend instance) => <String, dynamic>{
  'text': ?instance.text,
  'attachments': ?instance.attachments,
  'answers': ?instance.answers?.map((e) => e.toJson()).toList(),
};

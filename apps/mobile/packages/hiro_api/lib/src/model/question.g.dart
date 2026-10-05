// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$QuestionCWProxy {
  Question id(int id);

  Question position(int position);

  Question text(String text);

  Question options(List<String> options);

  Question answer(String? answer);

  Question note(String note);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Question(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Question(...).copyWith(id: 12, name: "My name")
  /// ````
  Question call({
    int id,
    int position,
    String text,
    List<String> options,
    String? answer,
    String note,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfQuestion.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfQuestion.copyWith.fieldName(...)`
class _$QuestionCWProxyImpl implements _$QuestionCWProxy {
  const _$QuestionCWProxyImpl(this._value);

  final Question _value;

  @override
  Question id(int id) => this(id: id);

  @override
  Question position(int position) => this(position: position);

  @override
  Question text(String text) => this(text: text);

  @override
  Question options(List<String> options) => this(options: options);

  @override
  Question answer(String? answer) => this(answer: answer);

  @override
  Question note(String note) => this(note: note);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Question(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Question(...).copyWith(id: 12, name: "My name")
  /// ````
  Question call({
    Object? id = const $CopyWithPlaceholder(),
    Object? position = const $CopyWithPlaceholder(),
    Object? text = const $CopyWithPlaceholder(),
    Object? options = const $CopyWithPlaceholder(),
    Object? answer = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
  }) {
    return Question(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      position: position == const $CopyWithPlaceholder()
          ? _value.position
          // ignore: cast_nullable_to_non_nullable
          : position as int,
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
          : note as String,
    );
  }
}

extension $QuestionCopyWith on Question {
  /// Returns a callable class that can be used as follows: `instanceOfQuestion.copyWith(...)` or like so:`instanceOfQuestion.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$QuestionCWProxy get copyWith => _$QuestionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Question', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['id', 'position', 'text', 'options', 'note'],
      );
      final val = Question(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        position: $checkedConvert('position', (v) => (v as num).toInt()),
        text: $checkedConvert('text', (v) => v as String),
        options: $checkedConvert(
          'options',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        answer: $checkedConvert('answer', (v) => v as String?),
        note: $checkedConvert('note', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
  'id': instance.id,
  'position': instance.position,
  'text': instance.text,
  'options': instance.options,
  'answer': ?instance.answer,
  'note': instance.note,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer_draft.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AnswerDraftCWProxy {
  AnswerDraft answer(String answer);

  AnswerDraft note(String note);

  AnswerDraft attachments(List<Attachment> attachments);

  AnswerDraft updatedAt(DateTime updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnswerDraft(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnswerDraft(...).copyWith(id: 12, name: "My name")
  /// ````
  AnswerDraft call({
    String answer,
    String note,
    List<Attachment> attachments,
    DateTime updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAnswerDraft.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAnswerDraft.copyWith.fieldName(...)`
class _$AnswerDraftCWProxyImpl implements _$AnswerDraftCWProxy {
  const _$AnswerDraftCWProxyImpl(this._value);

  final AnswerDraft _value;

  @override
  AnswerDraft answer(String answer) => this(answer: answer);

  @override
  AnswerDraft note(String note) => this(note: note);

  @override
  AnswerDraft attachments(List<Attachment> attachments) =>
      this(attachments: attachments);

  @override
  AnswerDraft updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnswerDraft(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnswerDraft(...).copyWith(id: 12, name: "My name")
  /// ````
  AnswerDraft call({
    Object? answer = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? attachments = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return AnswerDraft(
      answer: answer == const $CopyWithPlaceholder()
          ? _value.answer
          // ignore: cast_nullable_to_non_nullable
          : answer as String,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String,
      attachments: attachments == const $CopyWithPlaceholder()
          ? _value.attachments
          // ignore: cast_nullable_to_non_nullable
          : attachments as List<Attachment>,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
    );
  }
}

extension $AnswerDraftCopyWith on AnswerDraft {
  /// Returns a callable class that can be used as follows: `instanceOfAnswerDraft.copyWith(...)` or like so:`instanceOfAnswerDraft.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AnswerDraftCWProxy get copyWith => _$AnswerDraftCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnswerDraft _$AnswerDraftFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AnswerDraft', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['answer', 'note', 'attachments', 'updatedAt'],
      );
      final val = AnswerDraft(
        answer: $checkedConvert('answer', (v) => v as String),
        note: $checkedConvert('note', (v) => v as String),
        attachments: $checkedConvert(
          'attachments',
          (v) => (v as List<dynamic>)
              .map((e) => Attachment.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        updatedAt: $checkedConvert(
          'updatedAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AnswerDraftToJson(AnswerDraft instance) =>
    <String, dynamic>{
      'answer': instance.answer,
      'note': instance.note,
      'attachments': instance.attachments.map((e) => e.toJson()).toList(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reviewer_note_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReviewerNoteInputCWProxy {
  ReviewerNoteInput login(String login);

  ReviewerNoteInput note(String note);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReviewerNoteInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReviewerNoteInput(...).copyWith(id: 12, name: "My name")
  /// ````
  ReviewerNoteInput call({String login, String note});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReviewerNoteInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReviewerNoteInput.copyWith.fieldName(...)`
class _$ReviewerNoteInputCWProxyImpl implements _$ReviewerNoteInputCWProxy {
  const _$ReviewerNoteInputCWProxyImpl(this._value);

  final ReviewerNoteInput _value;

  @override
  ReviewerNoteInput login(String login) => this(login: login);

  @override
  ReviewerNoteInput note(String note) => this(note: note);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReviewerNoteInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReviewerNoteInput(...).copyWith(id: 12, name: "My name")
  /// ````
  ReviewerNoteInput call({
    Object? login = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
  }) {
    return ReviewerNoteInput(
      login: login == const $CopyWithPlaceholder()
          ? _value.login
          // ignore: cast_nullable_to_non_nullable
          : login as String,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String,
    );
  }
}

extension $ReviewerNoteInputCopyWith on ReviewerNoteInput {
  /// Returns a callable class that can be used as follows: `instanceOfReviewerNoteInput.copyWith(...)` or like so:`instanceOfReviewerNoteInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReviewerNoteInputCWProxy get copyWith =>
      _$ReviewerNoteInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewerNoteInput _$ReviewerNoteInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ReviewerNoteInput', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['login', 'note']);
      final val = ReviewerNoteInput(
        login: $checkedConvert('login', (v) => v as String),
        note: $checkedConvert('note', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ReviewerNoteInputToJson(ReviewerNoteInput instance) =>
    <String, dynamic>{'login': instance.login, 'note': instance.note};

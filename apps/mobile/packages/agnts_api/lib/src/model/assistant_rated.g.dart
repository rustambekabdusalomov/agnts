// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_rated.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantRatedCWProxy {
  AssistantRated messageId(int messageId);

  AssistantRated user(String user);

  AssistantRated question(String question);

  AssistantRated answer(String answer);

  AssistantRated rating(AssistantRatedRatingEnum rating);

  AssistantRated comment(String comment);

  AssistantRated promptVersion(String promptVersion);

  AssistantRated shared(bool shared);

  AssistantRated actions(List<AssistantAction>? actions);

  AssistantRated ratedAt(DateTime ratedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantRated(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantRated(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantRated call({
    int messageId,
    String user,
    String question,
    String answer,
    AssistantRatedRatingEnum rating,
    String comment,
    String promptVersion,
    bool shared,
    List<AssistantAction>? actions,
    DateTime ratedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantRated.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantRated.copyWith.fieldName(...)`
class _$AssistantRatedCWProxyImpl implements _$AssistantRatedCWProxy {
  const _$AssistantRatedCWProxyImpl(this._value);

  final AssistantRated _value;

  @override
  AssistantRated messageId(int messageId) => this(messageId: messageId);

  @override
  AssistantRated user(String user) => this(user: user);

  @override
  AssistantRated question(String question) => this(question: question);

  @override
  AssistantRated answer(String answer) => this(answer: answer);

  @override
  AssistantRated rating(AssistantRatedRatingEnum rating) =>
      this(rating: rating);

  @override
  AssistantRated comment(String comment) => this(comment: comment);

  @override
  AssistantRated promptVersion(String promptVersion) =>
      this(promptVersion: promptVersion);

  @override
  AssistantRated shared(bool shared) => this(shared: shared);

  @override
  AssistantRated actions(List<AssistantAction>? actions) =>
      this(actions: actions);

  @override
  AssistantRated ratedAt(DateTime ratedAt) => this(ratedAt: ratedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantRated(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantRated(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantRated call({
    Object? messageId = const $CopyWithPlaceholder(),
    Object? user = const $CopyWithPlaceholder(),
    Object? question = const $CopyWithPlaceholder(),
    Object? answer = const $CopyWithPlaceholder(),
    Object? rating = const $CopyWithPlaceholder(),
    Object? comment = const $CopyWithPlaceholder(),
    Object? promptVersion = const $CopyWithPlaceholder(),
    Object? shared = const $CopyWithPlaceholder(),
    Object? actions = const $CopyWithPlaceholder(),
    Object? ratedAt = const $CopyWithPlaceholder(),
  }) {
    return AssistantRated(
      messageId: messageId == const $CopyWithPlaceholder()
          ? _value.messageId
          // ignore: cast_nullable_to_non_nullable
          : messageId as int,
      user: user == const $CopyWithPlaceholder()
          ? _value.user
          // ignore: cast_nullable_to_non_nullable
          : user as String,
      question: question == const $CopyWithPlaceholder()
          ? _value.question
          // ignore: cast_nullable_to_non_nullable
          : question as String,
      answer: answer == const $CopyWithPlaceholder()
          ? _value.answer
          // ignore: cast_nullable_to_non_nullable
          : answer as String,
      rating: rating == const $CopyWithPlaceholder()
          ? _value.rating
          // ignore: cast_nullable_to_non_nullable
          : rating as AssistantRatedRatingEnum,
      comment: comment == const $CopyWithPlaceholder()
          ? _value.comment
          // ignore: cast_nullable_to_non_nullable
          : comment as String,
      promptVersion: promptVersion == const $CopyWithPlaceholder()
          ? _value.promptVersion
          // ignore: cast_nullable_to_non_nullable
          : promptVersion as String,
      shared: shared == const $CopyWithPlaceholder()
          ? _value.shared
          // ignore: cast_nullable_to_non_nullable
          : shared as bool,
      actions: actions == const $CopyWithPlaceholder()
          ? _value.actions
          // ignore: cast_nullable_to_non_nullable
          : actions as List<AssistantAction>?,
      ratedAt: ratedAt == const $CopyWithPlaceholder()
          ? _value.ratedAt
          // ignore: cast_nullable_to_non_nullable
          : ratedAt as DateTime,
    );
  }
}

extension $AssistantRatedCopyWith on AssistantRated {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantRated.copyWith(...)` or like so:`instanceOfAssistantRated.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantRatedCWProxy get copyWith => _$AssistantRatedCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantRated _$AssistantRatedFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AssistantRated', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'messageId',
          'user',
          'question',
          'answer',
          'rating',
          'comment',
          'promptVersion',
          'shared',
          'ratedAt',
        ],
      );
      final val = AssistantRated(
        messageId: $checkedConvert('messageId', (v) => (v as num).toInt()),
        user: $checkedConvert('user', (v) => v as String),
        question: $checkedConvert('question', (v) => v as String),
        answer: $checkedConvert('answer', (v) => v as String),
        rating: $checkedConvert(
          'rating',
          (v) => $enumDecode(_$AssistantRatedRatingEnumEnumMap, v),
        ),
        comment: $checkedConvert('comment', (v) => v as String),
        promptVersion: $checkedConvert('promptVersion', (v) => v as String),
        shared: $checkedConvert('shared', (v) => v as bool),
        actions: $checkedConvert(
          'actions',
          (v) => (v as List<dynamic>?)
              ?.map((e) => AssistantAction.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        ratedAt: $checkedConvert('ratedAt', (v) => DateTime.parse(v as String)),
      );
      return val;
    });

Map<String, dynamic> _$AssistantRatedToJson(AssistantRated instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'user': instance.user,
      'question': instance.question,
      'answer': instance.answer,
      'rating': _$AssistantRatedRatingEnumEnumMap[instance.rating]!,
      'comment': instance.comment,
      'promptVersion': instance.promptVersion,
      'shared': instance.shared,
      'actions': ?instance.actions?.map((e) => e.toJson()).toList(),
      'ratedAt': instance.ratedAt.toIso8601String(),
    };

const _$AssistantRatedRatingEnumEnumMap = {
  AssistantRatedRatingEnum.numberNegative1: -1,
  AssistantRatedRatingEnum.number1: 1,
};

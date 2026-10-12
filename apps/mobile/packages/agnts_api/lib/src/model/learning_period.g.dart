// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_period.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LearningPeriodCWProxy {
  LearningPeriod lessons(int lessons);

  LearningPeriod lessonsLearned(int lessonsLearned);

  LearningPeriod rulesSuggested(int rulesSuggested);

  LearningPeriod rulesAdopted(int rulesAdopted);

  LearningPeriod rulesManual(int rulesManual);

  LearningPeriod reflections(int reflections);

  LearningPeriod reflectionRules(int reflectionRules);

  LearningPeriod followUps(int followUps);

  LearningPeriod accepted(int accepted);

  LearningPeriod dismissed(int dismissed);

  LearningPeriod reviewerNotes(int reviewerNotes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LearningPeriod(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LearningPeriod(...).copyWith(id: 12, name: "My name")
  /// ````
  LearningPeriod call({
    int lessons,
    int lessonsLearned,
    int rulesSuggested,
    int rulesAdopted,
    int rulesManual,
    int reflections,
    int reflectionRules,
    int followUps,
    int accepted,
    int dismissed,
    int reviewerNotes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLearningPeriod.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLearningPeriod.copyWith.fieldName(...)`
class _$LearningPeriodCWProxyImpl implements _$LearningPeriodCWProxy {
  const _$LearningPeriodCWProxyImpl(this._value);

  final LearningPeriod _value;

  @override
  LearningPeriod lessons(int lessons) => this(lessons: lessons);

  @override
  LearningPeriod lessonsLearned(int lessonsLearned) =>
      this(lessonsLearned: lessonsLearned);

  @override
  LearningPeriod rulesSuggested(int rulesSuggested) =>
      this(rulesSuggested: rulesSuggested);

  @override
  LearningPeriod rulesAdopted(int rulesAdopted) =>
      this(rulesAdopted: rulesAdopted);

  @override
  LearningPeriod rulesManual(int rulesManual) => this(rulesManual: rulesManual);

  @override
  LearningPeriod reflections(int reflections) => this(reflections: reflections);

  @override
  LearningPeriod reflectionRules(int reflectionRules) =>
      this(reflectionRules: reflectionRules);

  @override
  LearningPeriod followUps(int followUps) => this(followUps: followUps);

  @override
  LearningPeriod accepted(int accepted) => this(accepted: accepted);

  @override
  LearningPeriod dismissed(int dismissed) => this(dismissed: dismissed);

  @override
  LearningPeriod reviewerNotes(int reviewerNotes) =>
      this(reviewerNotes: reviewerNotes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LearningPeriod(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LearningPeriod(...).copyWith(id: 12, name: "My name")
  /// ````
  LearningPeriod call({
    Object? lessons = const $CopyWithPlaceholder(),
    Object? lessonsLearned = const $CopyWithPlaceholder(),
    Object? rulesSuggested = const $CopyWithPlaceholder(),
    Object? rulesAdopted = const $CopyWithPlaceholder(),
    Object? rulesManual = const $CopyWithPlaceholder(),
    Object? reflections = const $CopyWithPlaceholder(),
    Object? reflectionRules = const $CopyWithPlaceholder(),
    Object? followUps = const $CopyWithPlaceholder(),
    Object? accepted = const $CopyWithPlaceholder(),
    Object? dismissed = const $CopyWithPlaceholder(),
    Object? reviewerNotes = const $CopyWithPlaceholder(),
  }) {
    return LearningPeriod(
      lessons: lessons == const $CopyWithPlaceholder()
          ? _value.lessons
          // ignore: cast_nullable_to_non_nullable
          : lessons as int,
      lessonsLearned: lessonsLearned == const $CopyWithPlaceholder()
          ? _value.lessonsLearned
          // ignore: cast_nullable_to_non_nullable
          : lessonsLearned as int,
      rulesSuggested: rulesSuggested == const $CopyWithPlaceholder()
          ? _value.rulesSuggested
          // ignore: cast_nullable_to_non_nullable
          : rulesSuggested as int,
      rulesAdopted: rulesAdopted == const $CopyWithPlaceholder()
          ? _value.rulesAdopted
          // ignore: cast_nullable_to_non_nullable
          : rulesAdopted as int,
      rulesManual: rulesManual == const $CopyWithPlaceholder()
          ? _value.rulesManual
          // ignore: cast_nullable_to_non_nullable
          : rulesManual as int,
      reflections: reflections == const $CopyWithPlaceholder()
          ? _value.reflections
          // ignore: cast_nullable_to_non_nullable
          : reflections as int,
      reflectionRules: reflectionRules == const $CopyWithPlaceholder()
          ? _value.reflectionRules
          // ignore: cast_nullable_to_non_nullable
          : reflectionRules as int,
      followUps: followUps == const $CopyWithPlaceholder()
          ? _value.followUps
          // ignore: cast_nullable_to_non_nullable
          : followUps as int,
      accepted: accepted == const $CopyWithPlaceholder()
          ? _value.accepted
          // ignore: cast_nullable_to_non_nullable
          : accepted as int,
      dismissed: dismissed == const $CopyWithPlaceholder()
          ? _value.dismissed
          // ignore: cast_nullable_to_non_nullable
          : dismissed as int,
      reviewerNotes: reviewerNotes == const $CopyWithPlaceholder()
          ? _value.reviewerNotes
          // ignore: cast_nullable_to_non_nullable
          : reviewerNotes as int,
    );
  }
}

extension $LearningPeriodCopyWith on LearningPeriod {
  /// Returns a callable class that can be used as follows: `instanceOfLearningPeriod.copyWith(...)` or like so:`instanceOfLearningPeriod.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LearningPeriodCWProxy get copyWith => _$LearningPeriodCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LearningPeriod _$LearningPeriodFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('LearningPeriod', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'lessons',
      'lessonsLearned',
      'rulesSuggested',
      'rulesAdopted',
      'rulesManual',
      'reflections',
      'reflectionRules',
      'followUps',
      'accepted',
      'dismissed',
      'reviewerNotes',
    ],
  );
  final val = LearningPeriod(
    lessons: $checkedConvert('lessons', (v) => (v as num).toInt()),
    lessonsLearned: $checkedConvert(
      'lessonsLearned',
      (v) => (v as num).toInt(),
    ),
    rulesSuggested: $checkedConvert(
      'rulesSuggested',
      (v) => (v as num).toInt(),
    ),
    rulesAdopted: $checkedConvert('rulesAdopted', (v) => (v as num).toInt()),
    rulesManual: $checkedConvert('rulesManual', (v) => (v as num).toInt()),
    reflections: $checkedConvert('reflections', (v) => (v as num).toInt()),
    reflectionRules: $checkedConvert(
      'reflectionRules',
      (v) => (v as num).toInt(),
    ),
    followUps: $checkedConvert('followUps', (v) => (v as num).toInt()),
    accepted: $checkedConvert('accepted', (v) => (v as num).toInt()),
    dismissed: $checkedConvert('dismissed', (v) => (v as num).toInt()),
    reviewerNotes: $checkedConvert('reviewerNotes', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$LearningPeriodToJson(LearningPeriod instance) =>
    <String, dynamic>{
      'lessons': instance.lessons,
      'lessonsLearned': instance.lessonsLearned,
      'rulesSuggested': instance.rulesSuggested,
      'rulesAdopted': instance.rulesAdopted,
      'rulesManual': instance.rulesManual,
      'reflections': instance.reflections,
      'reflectionRules': instance.reflectionRules,
      'followUps': instance.followUps,
      'accepted': instance.accepted,
      'dismissed': instance.dismissed,
      'reviewerNotes': instance.reviewerNotes,
    };

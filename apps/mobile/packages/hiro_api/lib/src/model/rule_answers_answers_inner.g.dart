// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule_answers_answers_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RuleAnswersAnswersInnerCWProxy {
  RuleAnswersAnswersInner index(int index);

  RuleAnswersAnswersInner answer(String answer);

  RuleAnswersAnswersInner note(String? note);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RuleAnswersAnswersInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RuleAnswersAnswersInner(...).copyWith(id: 12, name: "My name")
  /// ````
  RuleAnswersAnswersInner call({int index, String answer, String? note});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRuleAnswersAnswersInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRuleAnswersAnswersInner.copyWith.fieldName(...)`
class _$RuleAnswersAnswersInnerCWProxyImpl
    implements _$RuleAnswersAnswersInnerCWProxy {
  const _$RuleAnswersAnswersInnerCWProxyImpl(this._value);

  final RuleAnswersAnswersInner _value;

  @override
  RuleAnswersAnswersInner index(int index) => this(index: index);

  @override
  RuleAnswersAnswersInner answer(String answer) => this(answer: answer);

  @override
  RuleAnswersAnswersInner note(String? note) => this(note: note);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RuleAnswersAnswersInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RuleAnswersAnswersInner(...).copyWith(id: 12, name: "My name")
  /// ````
  RuleAnswersAnswersInner call({
    Object? index = const $CopyWithPlaceholder(),
    Object? answer = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
  }) {
    return RuleAnswersAnswersInner(
      index: index == const $CopyWithPlaceholder()
          ? _value.index
          // ignore: cast_nullable_to_non_nullable
          : index as int,
      answer: answer == const $CopyWithPlaceholder()
          ? _value.answer
          // ignore: cast_nullable_to_non_nullable
          : answer as String,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
    );
  }
}

extension $RuleAnswersAnswersInnerCopyWith on RuleAnswersAnswersInner {
  /// Returns a callable class that can be used as follows: `instanceOfRuleAnswersAnswersInner.copyWith(...)` or like so:`instanceOfRuleAnswersAnswersInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RuleAnswersAnswersInnerCWProxy get copyWith =>
      _$RuleAnswersAnswersInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RuleAnswersAnswersInner _$RuleAnswersAnswersInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RuleAnswersAnswersInner', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['index', 'answer']);
  final val = RuleAnswersAnswersInner(
    index: $checkedConvert('index', (v) => (v as num).toInt()),
    answer: $checkedConvert('answer', (v) => v as String),
    note: $checkedConvert('note', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$RuleAnswersAnswersInnerToJson(
  RuleAnswersAnswersInner instance,
) => <String, dynamic>{
  'index': instance.index,
  'answer': instance.answer,
  'note': ?instance.note,
};

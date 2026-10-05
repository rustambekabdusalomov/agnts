// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answers_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AnswersRequestCWProxy {
  AnswersRequest answers(List<AnswersRequestAnswersInner> answers);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnswersRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnswersRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AnswersRequest call({List<AnswersRequestAnswersInner> answers});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAnswersRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAnswersRequest.copyWith.fieldName(...)`
class _$AnswersRequestCWProxyImpl implements _$AnswersRequestCWProxy {
  const _$AnswersRequestCWProxyImpl(this._value);

  final AnswersRequest _value;

  @override
  AnswersRequest answers(List<AnswersRequestAnswersInner> answers) =>
      this(answers: answers);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnswersRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnswersRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AnswersRequest call({Object? answers = const $CopyWithPlaceholder()}) {
    return AnswersRequest(
      answers: answers == const $CopyWithPlaceholder()
          ? _value.answers
          // ignore: cast_nullable_to_non_nullable
          : answers as List<AnswersRequestAnswersInner>,
    );
  }
}

extension $AnswersRequestCopyWith on AnswersRequest {
  /// Returns a callable class that can be used as follows: `instanceOfAnswersRequest.copyWith(...)` or like so:`instanceOfAnswersRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AnswersRequestCWProxy get copyWith => _$AnswersRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnswersRequest _$AnswersRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AnswersRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['answers']);
      final val = AnswersRequest(
        answers: $checkedConvert(
          'answers',
          (v) => (v as List<dynamic>)
              .map(
                (e) => AnswersRequestAnswersInner.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AnswersRequestToJson(AnswersRequest instance) =>
    <String, dynamic>{
      'answers': instance.answers.map((e) => e.toJson()).toList(),
    };

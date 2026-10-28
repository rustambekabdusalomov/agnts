// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer_meeting_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AnswerMeetingRequestCWProxy {
  AnswerMeetingRequest answer(AnswerMeetingRequestAnswerEnum answer);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnswerMeetingRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnswerMeetingRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AnswerMeetingRequest call({AnswerMeetingRequestAnswerEnum answer});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAnswerMeetingRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAnswerMeetingRequest.copyWith.fieldName(...)`
class _$AnswerMeetingRequestCWProxyImpl
    implements _$AnswerMeetingRequestCWProxy {
  const _$AnswerMeetingRequestCWProxyImpl(this._value);

  final AnswerMeetingRequest _value;

  @override
  AnswerMeetingRequest answer(AnswerMeetingRequestAnswerEnum answer) =>
      this(answer: answer);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnswerMeetingRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnswerMeetingRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AnswerMeetingRequest call({Object? answer = const $CopyWithPlaceholder()}) {
    return AnswerMeetingRequest(
      answer: answer == const $CopyWithPlaceholder()
          ? _value.answer
          // ignore: cast_nullable_to_non_nullable
          : answer as AnswerMeetingRequestAnswerEnum,
    );
  }
}

extension $AnswerMeetingRequestCopyWith on AnswerMeetingRequest {
  /// Returns a callable class that can be used as follows: `instanceOfAnswerMeetingRequest.copyWith(...)` or like so:`instanceOfAnswerMeetingRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AnswerMeetingRequestCWProxy get copyWith =>
      _$AnswerMeetingRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnswerMeetingRequest _$AnswerMeetingRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AnswerMeetingRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['answer']);
  final val = AnswerMeetingRequest(
    answer: $checkedConvert(
      'answer',
      (v) => $enumDecode(_$AnswerMeetingRequestAnswerEnumEnumMap, v),
    ),
  );
  return val;
});

Map<String, dynamic> _$AnswerMeetingRequestToJson(
  AnswerMeetingRequest instance,
) => <String, dynamic>{
  'answer': _$AnswerMeetingRequestAnswerEnumEnumMap[instance.answer]!,
};

const _$AnswerMeetingRequestAnswerEnumEnumMap = {
  AnswerMeetingRequestAnswerEnum.true_: 'true',
  AnswerMeetingRequestAnswerEnum.false_: 'false',
  AnswerMeetingRequestAnswerEnum.maybe: 'maybe',
};

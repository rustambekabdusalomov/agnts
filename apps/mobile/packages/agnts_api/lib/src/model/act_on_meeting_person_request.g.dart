// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'act_on_meeting_person_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ActOnMeetingPersonRequestCWProxy {
  ActOnMeetingPersonRequest source_(
    ActOnMeetingPersonRequestSource_Enum? source_,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActOnMeetingPersonRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActOnMeetingPersonRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ActOnMeetingPersonRequest call({
    ActOnMeetingPersonRequestSource_Enum? source_,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfActOnMeetingPersonRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfActOnMeetingPersonRequest.copyWith.fieldName(...)`
class _$ActOnMeetingPersonRequestCWProxyImpl
    implements _$ActOnMeetingPersonRequestCWProxy {
  const _$ActOnMeetingPersonRequestCWProxyImpl(this._value);

  final ActOnMeetingPersonRequest _value;

  @override
  ActOnMeetingPersonRequest source_(
    ActOnMeetingPersonRequestSource_Enum? source_,
  ) => this(source_: source_);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActOnMeetingPersonRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActOnMeetingPersonRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ActOnMeetingPersonRequest call({
    Object? source_ = const $CopyWithPlaceholder(),
  }) {
    return ActOnMeetingPersonRequest(
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as ActOnMeetingPersonRequestSource_Enum?,
    );
  }
}

extension $ActOnMeetingPersonRequestCopyWith on ActOnMeetingPersonRequest {
  /// Returns a callable class that can be used as follows: `instanceOfActOnMeetingPersonRequest.copyWith(...)` or like so:`instanceOfActOnMeetingPersonRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ActOnMeetingPersonRequestCWProxy get copyWith =>
      _$ActOnMeetingPersonRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActOnMeetingPersonRequest _$ActOnMeetingPersonRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ActOnMeetingPersonRequest', json, ($checkedConvert) {
  final val = ActOnMeetingPersonRequest(
    source_: $checkedConvert(
      'source',
      (v) =>
          $enumDecodeNullable(_$ActOnMeetingPersonRequestSource_EnumEnumMap, v),
    ),
  );
  return val;
}, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$ActOnMeetingPersonRequestToJson(
  ActOnMeetingPersonRequest instance,
) => <String, dynamic>{
  'source': ?_$ActOnMeetingPersonRequestSource_EnumEnumMap[instance.source_],
};

const _$ActOnMeetingPersonRequestSource_EnumEnumMap = {
  ActOnMeetingPersonRequestSource_Enum.microphone: 'microphone',
  ActOnMeetingPersonRequestSource_Enum.camera: 'camera',
  ActOnMeetingPersonRequestSource_Enum.screenShare: 'screen_share',
};

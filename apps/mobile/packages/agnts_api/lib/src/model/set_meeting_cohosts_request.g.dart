// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_meeting_cohosts_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SetMeetingCohostsRequestCWProxy {
  SetMeetingCohostsRequest userIds(List<int> userIds);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetMeetingCohostsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetMeetingCohostsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetMeetingCohostsRequest call({List<int> userIds});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSetMeetingCohostsRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSetMeetingCohostsRequest.copyWith.fieldName(...)`
class _$SetMeetingCohostsRequestCWProxyImpl
    implements _$SetMeetingCohostsRequestCWProxy {
  const _$SetMeetingCohostsRequestCWProxyImpl(this._value);

  final SetMeetingCohostsRequest _value;

  @override
  SetMeetingCohostsRequest userIds(List<int> userIds) => this(userIds: userIds);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetMeetingCohostsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetMeetingCohostsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetMeetingCohostsRequest call({
    Object? userIds = const $CopyWithPlaceholder(),
  }) {
    return SetMeetingCohostsRequest(
      userIds: userIds == const $CopyWithPlaceholder()
          ? _value.userIds
          // ignore: cast_nullable_to_non_nullable
          : userIds as List<int>,
    );
  }
}

extension $SetMeetingCohostsRequestCopyWith on SetMeetingCohostsRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSetMeetingCohostsRequest.copyWith(...)` or like so:`instanceOfSetMeetingCohostsRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SetMeetingCohostsRequestCWProxy get copyWith =>
      _$SetMeetingCohostsRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetMeetingCohostsRequest _$SetMeetingCohostsRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SetMeetingCohostsRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['userIds']);
  final val = SetMeetingCohostsRequest(
    userIds: $checkedConvert(
      'userIds',
      (v) => (v as List<dynamic>).map((e) => (e as num).toInt()).toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$SetMeetingCohostsRequestToJson(
  SetMeetingCohostsRequest instance,
) => <String, dynamic>{'userIds': instance.userIds};

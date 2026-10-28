// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ring_meeting_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RingMeetingRequestCWProxy {
  RingMeetingRequest userIds(List<int> userIds);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RingMeetingRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RingMeetingRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RingMeetingRequest call({List<int> userIds});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRingMeetingRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRingMeetingRequest.copyWith.fieldName(...)`
class _$RingMeetingRequestCWProxyImpl implements _$RingMeetingRequestCWProxy {
  const _$RingMeetingRequestCWProxyImpl(this._value);

  final RingMeetingRequest _value;

  @override
  RingMeetingRequest userIds(List<int> userIds) => this(userIds: userIds);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RingMeetingRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RingMeetingRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RingMeetingRequest call({Object? userIds = const $CopyWithPlaceholder()}) {
    return RingMeetingRequest(
      userIds: userIds == const $CopyWithPlaceholder()
          ? _value.userIds
          // ignore: cast_nullable_to_non_nullable
          : userIds as List<int>,
    );
  }
}

extension $RingMeetingRequestCopyWith on RingMeetingRequest {
  /// Returns a callable class that can be used as follows: `instanceOfRingMeetingRequest.copyWith(...)` or like so:`instanceOfRingMeetingRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RingMeetingRequestCWProxy get copyWith =>
      _$RingMeetingRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RingMeetingRequest _$RingMeetingRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RingMeetingRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['userIds']);
      final val = RingMeetingRequest(
        userIds: $checkedConvert(
          'userIds',
          (v) => (v as List<dynamic>).map((e) => (e as num).toInt()).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$RingMeetingRequestToJson(RingMeetingRequest instance) =>
    <String, dynamic>{'userIds': instance.userIds};

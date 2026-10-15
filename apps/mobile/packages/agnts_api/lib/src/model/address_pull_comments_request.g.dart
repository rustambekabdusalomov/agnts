// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_pull_comments_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AddressPullCommentsRequestCWProxy {
  AddressPullCommentsRequest threadIds(List<String>? threadIds);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AddressPullCommentsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AddressPullCommentsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AddressPullCommentsRequest call({List<String>? threadIds});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAddressPullCommentsRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAddressPullCommentsRequest.copyWith.fieldName(...)`
class _$AddressPullCommentsRequestCWProxyImpl
    implements _$AddressPullCommentsRequestCWProxy {
  const _$AddressPullCommentsRequestCWProxyImpl(this._value);

  final AddressPullCommentsRequest _value;

  @override
  AddressPullCommentsRequest threadIds(List<String>? threadIds) =>
      this(threadIds: threadIds);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AddressPullCommentsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AddressPullCommentsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AddressPullCommentsRequest call({
    Object? threadIds = const $CopyWithPlaceholder(),
  }) {
    return AddressPullCommentsRequest(
      threadIds: threadIds == const $CopyWithPlaceholder()
          ? _value.threadIds
          // ignore: cast_nullable_to_non_nullable
          : threadIds as List<String>?,
    );
  }
}

extension $AddressPullCommentsRequestCopyWith on AddressPullCommentsRequest {
  /// Returns a callable class that can be used as follows: `instanceOfAddressPullCommentsRequest.copyWith(...)` or like so:`instanceOfAddressPullCommentsRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AddressPullCommentsRequestCWProxy get copyWith =>
      _$AddressPullCommentsRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressPullCommentsRequest _$AddressPullCommentsRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AddressPullCommentsRequest', json, ($checkedConvert) {
  final val = AddressPullCommentsRequest(
    threadIds: $checkedConvert(
      'threadIds',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$AddressPullCommentsRequestToJson(
  AddressPullCommentsRequest instance,
) => <String, dynamic>{'threadIds': ?instance.threadIds};

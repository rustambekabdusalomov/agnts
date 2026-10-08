// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_platform_workspace_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpdatePlatformWorkspaceRequestCWProxy {
  UpdatePlatformWorkspaceRequest plan(String? plan);

  UpdatePlatformWorkspaceRequest slots(int? slots);

  UpdatePlatformWorkspaceRequest memberLimit(int? memberLimit);

  UpdatePlatformWorkspaceRequest suspended(bool? suspended);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdatePlatformWorkspaceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdatePlatformWorkspaceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdatePlatformWorkspaceRequest call({
    String? plan,
    int? slots,
    int? memberLimit,
    bool? suspended,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpdatePlatformWorkspaceRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpdatePlatformWorkspaceRequest.copyWith.fieldName(...)`
class _$UpdatePlatformWorkspaceRequestCWProxyImpl
    implements _$UpdatePlatformWorkspaceRequestCWProxy {
  const _$UpdatePlatformWorkspaceRequestCWProxyImpl(this._value);

  final UpdatePlatformWorkspaceRequest _value;

  @override
  UpdatePlatformWorkspaceRequest plan(String? plan) => this(plan: plan);

  @override
  UpdatePlatformWorkspaceRequest slots(int? slots) => this(slots: slots);

  @override
  UpdatePlatformWorkspaceRequest memberLimit(int? memberLimit) =>
      this(memberLimit: memberLimit);

  @override
  UpdatePlatformWorkspaceRequest suspended(bool? suspended) =>
      this(suspended: suspended);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdatePlatformWorkspaceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdatePlatformWorkspaceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdatePlatformWorkspaceRequest call({
    Object? plan = const $CopyWithPlaceholder(),
    Object? slots = const $CopyWithPlaceholder(),
    Object? memberLimit = const $CopyWithPlaceholder(),
    Object? suspended = const $CopyWithPlaceholder(),
  }) {
    return UpdatePlatformWorkspaceRequest(
      plan: plan == const $CopyWithPlaceholder()
          ? _value.plan
          // ignore: cast_nullable_to_non_nullable
          : plan as String?,
      slots: slots == const $CopyWithPlaceholder()
          ? _value.slots
          // ignore: cast_nullable_to_non_nullable
          : slots as int?,
      memberLimit: memberLimit == const $CopyWithPlaceholder()
          ? _value.memberLimit
          // ignore: cast_nullable_to_non_nullable
          : memberLimit as int?,
      suspended: suspended == const $CopyWithPlaceholder()
          ? _value.suspended
          // ignore: cast_nullable_to_non_nullable
          : suspended as bool?,
    );
  }
}

extension $UpdatePlatformWorkspaceRequestCopyWith
    on UpdatePlatformWorkspaceRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUpdatePlatformWorkspaceRequest.copyWith(...)` or like so:`instanceOfUpdatePlatformWorkspaceRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpdatePlatformWorkspaceRequestCWProxy get copyWith =>
      _$UpdatePlatformWorkspaceRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePlatformWorkspaceRequest _$UpdatePlatformWorkspaceRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UpdatePlatformWorkspaceRequest', json, ($checkedConvert) {
  final val = UpdatePlatformWorkspaceRequest(
    plan: $checkedConvert('plan', (v) => v as String?),
    slots: $checkedConvert('slots', (v) => (v as num?)?.toInt()),
    memberLimit: $checkedConvert('memberLimit', (v) => (v as num?)?.toInt()),
    suspended: $checkedConvert('suspended', (v) => v as bool?),
  );
  return val;
});

Map<String, dynamic> _$UpdatePlatformWorkspaceRequestToJson(
  UpdatePlatformWorkspaceRequest instance,
) => <String, dynamic>{
  'plan': ?instance.plan,
  'slots': ?instance.slots,
  'memberLimit': ?instance.memberLimit,
  'suspended': ?instance.suspended,
};

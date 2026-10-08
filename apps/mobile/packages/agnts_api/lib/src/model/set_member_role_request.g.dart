// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_member_role_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SetMemberRoleRequestCWProxy {
  SetMemberRoleRequest role(SetMemberRoleRequestRoleEnum role);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetMemberRoleRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetMemberRoleRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetMemberRoleRequest call({SetMemberRoleRequestRoleEnum role});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSetMemberRoleRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSetMemberRoleRequest.copyWith.fieldName(...)`
class _$SetMemberRoleRequestCWProxyImpl
    implements _$SetMemberRoleRequestCWProxy {
  const _$SetMemberRoleRequestCWProxyImpl(this._value);

  final SetMemberRoleRequest _value;

  @override
  SetMemberRoleRequest role(SetMemberRoleRequestRoleEnum role) =>
      this(role: role);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetMemberRoleRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetMemberRoleRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetMemberRoleRequest call({Object? role = const $CopyWithPlaceholder()}) {
    return SetMemberRoleRequest(
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as SetMemberRoleRequestRoleEnum,
    );
  }
}

extension $SetMemberRoleRequestCopyWith on SetMemberRoleRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSetMemberRoleRequest.copyWith(...)` or like so:`instanceOfSetMemberRoleRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SetMemberRoleRequestCWProxy get copyWith =>
      _$SetMemberRoleRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetMemberRoleRequest _$SetMemberRoleRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SetMemberRoleRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['role']);
  final val = SetMemberRoleRequest(
    role: $checkedConvert(
      'role',
      (v) => $enumDecode(_$SetMemberRoleRequestRoleEnumEnumMap, v),
    ),
  );
  return val;
});

Map<String, dynamic> _$SetMemberRoleRequestToJson(
  SetMemberRoleRequest instance,
) => <String, dynamic>{
  'role': _$SetMemberRoleRequestRoleEnumEnumMap[instance.role]!,
};

const _$SetMemberRoleRequestRoleEnumEnumMap = {
  SetMemberRoleRequestRoleEnum.user: 'user',
  SetMemberRoleRequestRoleEnum.viewer: 'viewer',
};

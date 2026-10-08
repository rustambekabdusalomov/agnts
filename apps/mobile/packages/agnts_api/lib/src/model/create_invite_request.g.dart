// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_invite_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateInviteRequestCWProxy {
  CreateInviteRequest email(String? email);

  CreateInviteRequest role(CreateInviteRequestRoleEnum? role);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateInviteRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateInviteRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateInviteRequest call({String? email, CreateInviteRequestRoleEnum? role});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateInviteRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateInviteRequest.copyWith.fieldName(...)`
class _$CreateInviteRequestCWProxyImpl implements _$CreateInviteRequestCWProxy {
  const _$CreateInviteRequestCWProxyImpl(this._value);

  final CreateInviteRequest _value;

  @override
  CreateInviteRequest email(String? email) => this(email: email);

  @override
  CreateInviteRequest role(CreateInviteRequestRoleEnum? role) =>
      this(role: role);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateInviteRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateInviteRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateInviteRequest call({
    Object? email = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
  }) {
    return CreateInviteRequest(
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String?,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as CreateInviteRequestRoleEnum?,
    );
  }
}

extension $CreateInviteRequestCopyWith on CreateInviteRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateInviteRequest.copyWith(...)` or like so:`instanceOfCreateInviteRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateInviteRequestCWProxy get copyWith =>
      _$CreateInviteRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateInviteRequest _$CreateInviteRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CreateInviteRequest', json, ($checkedConvert) {
      final val = CreateInviteRequest(
        email: $checkedConvert('email', (v) => v as String?),
        role: $checkedConvert(
          'role',
          (v) => $enumDecodeNullable(_$CreateInviteRequestRoleEnumEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CreateInviteRequestToJson(
  CreateInviteRequest instance,
) => <String, dynamic>{
  'email': ?instance.email,
  'role': ?_$CreateInviteRequestRoleEnumEnumMap[instance.role],
};

const _$CreateInviteRequestRoleEnumEnumMap = {
  CreateInviteRequestRoleEnum.user: 'user',
  CreateInviteRequestRoleEnum.viewer: 'viewer',
};

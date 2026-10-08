// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_ticket_member_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SetTicketMemberRequestCWProxy {
  SetTicketMemberRequest userId(int userId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetTicketMemberRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetTicketMemberRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetTicketMemberRequest call({int userId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSetTicketMemberRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSetTicketMemberRequest.copyWith.fieldName(...)`
class _$SetTicketMemberRequestCWProxyImpl
    implements _$SetTicketMemberRequestCWProxy {
  const _$SetTicketMemberRequestCWProxyImpl(this._value);

  final SetTicketMemberRequest _value;

  @override
  SetTicketMemberRequest userId(int userId) => this(userId: userId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetTicketMemberRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetTicketMemberRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetTicketMemberRequest call({Object? userId = const $CopyWithPlaceholder()}) {
    return SetTicketMemberRequest(
      userId: userId == const $CopyWithPlaceholder()
          ? _value.userId
          // ignore: cast_nullable_to_non_nullable
          : userId as int,
    );
  }
}

extension $SetTicketMemberRequestCopyWith on SetTicketMemberRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSetTicketMemberRequest.copyWith(...)` or like so:`instanceOfSetTicketMemberRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SetTicketMemberRequestCWProxy get copyWith =>
      _$SetTicketMemberRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetTicketMemberRequest _$SetTicketMemberRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SetTicketMemberRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['userId']);
  final val = SetTicketMemberRequest(
    userId: $checkedConvert('userId', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$SetTicketMemberRequestToJson(
  SetTicketMemberRequest instance,
) => <String, dynamic>{'userId': instance.userId};

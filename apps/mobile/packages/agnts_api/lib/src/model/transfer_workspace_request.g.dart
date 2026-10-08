// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_workspace_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TransferWorkspaceRequestCWProxy {
  TransferWorkspaceRequest userId(int userId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TransferWorkspaceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TransferWorkspaceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  TransferWorkspaceRequest call({int userId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTransferWorkspaceRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTransferWorkspaceRequest.copyWith.fieldName(...)`
class _$TransferWorkspaceRequestCWProxyImpl
    implements _$TransferWorkspaceRequestCWProxy {
  const _$TransferWorkspaceRequestCWProxyImpl(this._value);

  final TransferWorkspaceRequest _value;

  @override
  TransferWorkspaceRequest userId(int userId) => this(userId: userId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TransferWorkspaceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TransferWorkspaceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  TransferWorkspaceRequest call({
    Object? userId = const $CopyWithPlaceholder(),
  }) {
    return TransferWorkspaceRequest(
      userId: userId == const $CopyWithPlaceholder()
          ? _value.userId
          // ignore: cast_nullable_to_non_nullable
          : userId as int,
    );
  }
}

extension $TransferWorkspaceRequestCopyWith on TransferWorkspaceRequest {
  /// Returns a callable class that can be used as follows: `instanceOfTransferWorkspaceRequest.copyWith(...)` or like so:`instanceOfTransferWorkspaceRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TransferWorkspaceRequestCWProxy get copyWith =>
      _$TransferWorkspaceRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferWorkspaceRequest _$TransferWorkspaceRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('TransferWorkspaceRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['userId']);
  final val = TransferWorkspaceRequest(
    userId: $checkedConvert('userId', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$TransferWorkspaceRequestToJson(
  TransferWorkspaceRequest instance,
) => <String, dynamic>{'userId': instance.userId};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_workspace_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DeleteWorkspaceRequestCWProxy {
  DeleteWorkspaceRequest confirm(String confirm);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeleteWorkspaceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeleteWorkspaceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  DeleteWorkspaceRequest call({String confirm});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDeleteWorkspaceRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDeleteWorkspaceRequest.copyWith.fieldName(...)`
class _$DeleteWorkspaceRequestCWProxyImpl
    implements _$DeleteWorkspaceRequestCWProxy {
  const _$DeleteWorkspaceRequestCWProxyImpl(this._value);

  final DeleteWorkspaceRequest _value;

  @override
  DeleteWorkspaceRequest confirm(String confirm) => this(confirm: confirm);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeleteWorkspaceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeleteWorkspaceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  DeleteWorkspaceRequest call({
    Object? confirm = const $CopyWithPlaceholder(),
  }) {
    return DeleteWorkspaceRequest(
      confirm: confirm == const $CopyWithPlaceholder()
          ? _value.confirm
          // ignore: cast_nullable_to_non_nullable
          : confirm as String,
    );
  }
}

extension $DeleteWorkspaceRequestCopyWith on DeleteWorkspaceRequest {
  /// Returns a callable class that can be used as follows: `instanceOfDeleteWorkspaceRequest.copyWith(...)` or like so:`instanceOfDeleteWorkspaceRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DeleteWorkspaceRequestCWProxy get copyWith =>
      _$DeleteWorkspaceRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteWorkspaceRequest _$DeleteWorkspaceRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DeleteWorkspaceRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['confirm']);
  final val = DeleteWorkspaceRequest(
    confirm: $checkedConvert('confirm', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$DeleteWorkspaceRequestToJson(
  DeleteWorkspaceRequest instance,
) => <String, dynamic>{'confirm': instance.confirm};

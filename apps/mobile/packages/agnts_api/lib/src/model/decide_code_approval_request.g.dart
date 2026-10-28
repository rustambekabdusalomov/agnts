// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decide_code_approval_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DecideCodeApprovalRequestCWProxy {
  DecideCodeApprovalRequest allow(bool allow);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DecideCodeApprovalRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DecideCodeApprovalRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  DecideCodeApprovalRequest call({bool allow});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDecideCodeApprovalRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDecideCodeApprovalRequest.copyWith.fieldName(...)`
class _$DecideCodeApprovalRequestCWProxyImpl
    implements _$DecideCodeApprovalRequestCWProxy {
  const _$DecideCodeApprovalRequestCWProxyImpl(this._value);

  final DecideCodeApprovalRequest _value;

  @override
  DecideCodeApprovalRequest allow(bool allow) => this(allow: allow);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DecideCodeApprovalRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DecideCodeApprovalRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  DecideCodeApprovalRequest call({
    Object? allow = const $CopyWithPlaceholder(),
  }) {
    return DecideCodeApprovalRequest(
      allow: allow == const $CopyWithPlaceholder()
          ? _value.allow
          // ignore: cast_nullable_to_non_nullable
          : allow as bool,
    );
  }
}

extension $DecideCodeApprovalRequestCopyWith on DecideCodeApprovalRequest {
  /// Returns a callable class that can be used as follows: `instanceOfDecideCodeApprovalRequest.copyWith(...)` or like so:`instanceOfDecideCodeApprovalRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DecideCodeApprovalRequestCWProxy get copyWith =>
      _$DecideCodeApprovalRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DecideCodeApprovalRequest _$DecideCodeApprovalRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DecideCodeApprovalRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['allow']);
  final val = DecideCodeApprovalRequest(
    allow: $checkedConvert('allow', (v) => v as bool),
  );
  return val;
});

Map<String, dynamic> _$DecideCodeApprovalRequestToJson(
  DecideCodeApprovalRequest instance,
) => <String, dynamic>{'allow': instance.allow};

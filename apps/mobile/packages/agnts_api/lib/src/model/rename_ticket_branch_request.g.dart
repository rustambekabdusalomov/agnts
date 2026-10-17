// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rename_ticket_branch_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RenameTicketBranchRequestCWProxy {
  RenameTicketBranchRequest branch(String branch);

  RenameTicketBranchRequest repoId(int? repoId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RenameTicketBranchRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RenameTicketBranchRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RenameTicketBranchRequest call({String branch, int? repoId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRenameTicketBranchRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRenameTicketBranchRequest.copyWith.fieldName(...)`
class _$RenameTicketBranchRequestCWProxyImpl
    implements _$RenameTicketBranchRequestCWProxy {
  const _$RenameTicketBranchRequestCWProxyImpl(this._value);

  final RenameTicketBranchRequest _value;

  @override
  RenameTicketBranchRequest branch(String branch) => this(branch: branch);

  @override
  RenameTicketBranchRequest repoId(int? repoId) => this(repoId: repoId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RenameTicketBranchRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RenameTicketBranchRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RenameTicketBranchRequest call({
    Object? branch = const $CopyWithPlaceholder(),
    Object? repoId = const $CopyWithPlaceholder(),
  }) {
    return RenameTicketBranchRequest(
      branch: branch == const $CopyWithPlaceholder()
          ? _value.branch
          // ignore: cast_nullable_to_non_nullable
          : branch as String,
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int?,
    );
  }
}

extension $RenameTicketBranchRequestCopyWith on RenameTicketBranchRequest {
  /// Returns a callable class that can be used as follows: `instanceOfRenameTicketBranchRequest.copyWith(...)` or like so:`instanceOfRenameTicketBranchRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RenameTicketBranchRequestCWProxy get copyWith =>
      _$RenameTicketBranchRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RenameTicketBranchRequest _$RenameTicketBranchRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RenameTicketBranchRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['branch']);
  final val = RenameTicketBranchRequest(
    branch: $checkedConvert('branch', (v) => v as String),
    repoId: $checkedConvert('repoId', (v) => (v as num?)?.toInt()),
  );
  return val;
});

Map<String, dynamic> _$RenameTicketBranchRequestToJson(
  RenameTicketBranchRequest instance,
) => <String, dynamic>{'branch': instance.branch, 'repoId': ?instance.repoId};

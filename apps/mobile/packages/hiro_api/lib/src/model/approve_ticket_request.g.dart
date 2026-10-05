// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approve_ticket_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApproveTicketRequestCWProxy {
  ApproveTicketRequest assignees(List<String>? assignees);

  ApproveTicketRequest postReport(bool? postReport);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApproveTicketRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApproveTicketRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ApproveTicketRequest call({List<String>? assignees, bool? postReport});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApproveTicketRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApproveTicketRequest.copyWith.fieldName(...)`
class _$ApproveTicketRequestCWProxyImpl
    implements _$ApproveTicketRequestCWProxy {
  const _$ApproveTicketRequestCWProxyImpl(this._value);

  final ApproveTicketRequest _value;

  @override
  ApproveTicketRequest assignees(List<String>? assignees) =>
      this(assignees: assignees);

  @override
  ApproveTicketRequest postReport(bool? postReport) =>
      this(postReport: postReport);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApproveTicketRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApproveTicketRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ApproveTicketRequest call({
    Object? assignees = const $CopyWithPlaceholder(),
    Object? postReport = const $CopyWithPlaceholder(),
  }) {
    return ApproveTicketRequest(
      assignees: assignees == const $CopyWithPlaceholder()
          ? _value.assignees
          // ignore: cast_nullable_to_non_nullable
          : assignees as List<String>?,
      postReport: postReport == const $CopyWithPlaceholder()
          ? _value.postReport
          // ignore: cast_nullable_to_non_nullable
          : postReport as bool?,
    );
  }
}

extension $ApproveTicketRequestCopyWith on ApproveTicketRequest {
  /// Returns a callable class that can be used as follows: `instanceOfApproveTicketRequest.copyWith(...)` or like so:`instanceOfApproveTicketRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApproveTicketRequestCWProxy get copyWith =>
      _$ApproveTicketRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApproveTicketRequest _$ApproveTicketRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApproveTicketRequest', json, ($checkedConvert) {
  final val = ApproveTicketRequest(
    assignees: $checkedConvert(
      'assignees',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    postReport: $checkedConvert('postReport', (v) => v as bool?),
  );
  return val;
});

Map<String, dynamic> _$ApproveTicketRequestToJson(
  ApproveTicketRequest instance,
) => <String, dynamic>{
  'assignees': ?instance.assignees,
  'postReport': ?instance.postReport,
};

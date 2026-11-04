// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dismiss_security_findings_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DismissSecurityFindingsRequestCWProxy {
  DismissSecurityFindingsRequest findingIds(List<int> findingIds);

  DismissSecurityFindingsRequest reason(
    DismissSecurityFindingsRequestReasonEnum reason,
  );

  DismissSecurityFindingsRequest note(String? note);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DismissSecurityFindingsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DismissSecurityFindingsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  DismissSecurityFindingsRequest call({
    List<int> findingIds,
    DismissSecurityFindingsRequestReasonEnum reason,
    String? note,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDismissSecurityFindingsRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDismissSecurityFindingsRequest.copyWith.fieldName(...)`
class _$DismissSecurityFindingsRequestCWProxyImpl
    implements _$DismissSecurityFindingsRequestCWProxy {
  const _$DismissSecurityFindingsRequestCWProxyImpl(this._value);

  final DismissSecurityFindingsRequest _value;

  @override
  DismissSecurityFindingsRequest findingIds(List<int> findingIds) =>
      this(findingIds: findingIds);

  @override
  DismissSecurityFindingsRequest reason(
    DismissSecurityFindingsRequestReasonEnum reason,
  ) => this(reason: reason);

  @override
  DismissSecurityFindingsRequest note(String? note) => this(note: note);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DismissSecurityFindingsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DismissSecurityFindingsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  DismissSecurityFindingsRequest call({
    Object? findingIds = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
  }) {
    return DismissSecurityFindingsRequest(
      findingIds: findingIds == const $CopyWithPlaceholder()
          ? _value.findingIds
          // ignore: cast_nullable_to_non_nullable
          : findingIds as List<int>,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as DismissSecurityFindingsRequestReasonEnum,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
    );
  }
}

extension $DismissSecurityFindingsRequestCopyWith
    on DismissSecurityFindingsRequest {
  /// Returns a callable class that can be used as follows: `instanceOfDismissSecurityFindingsRequest.copyWith(...)` or like so:`instanceOfDismissSecurityFindingsRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DismissSecurityFindingsRequestCWProxy get copyWith =>
      _$DismissSecurityFindingsRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DismissSecurityFindingsRequest _$DismissSecurityFindingsRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DismissSecurityFindingsRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['findingIds', 'reason']);
  final val = DismissSecurityFindingsRequest(
    findingIds: $checkedConvert(
      'findingIds',
      (v) => (v as List<dynamic>).map((e) => (e as num).toInt()).toList(),
    ),
    reason: $checkedConvert(
      'reason',
      (v) => $enumDecode(_$DismissSecurityFindingsRequestReasonEnumEnumMap, v),
    ),
    note: $checkedConvert('note', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$DismissSecurityFindingsRequestToJson(
  DismissSecurityFindingsRequest instance,
) => <String, dynamic>{
  'findingIds': instance.findingIds,
  'reason': _$DismissSecurityFindingsRequestReasonEnumEnumMap[instance.reason]!,
  'note': ?instance.note,
};

const _$DismissSecurityFindingsRequestReasonEnumEnumMap = {
  DismissSecurityFindingsRequestReasonEnum.falsePositive: 'false_positive',
  DismissSecurityFindingsRequestReasonEnum.acceptedRisk: 'accepted_risk',
  DismissSecurityFindingsRequestReasonEnum.wontFix: 'wont_fix',
};

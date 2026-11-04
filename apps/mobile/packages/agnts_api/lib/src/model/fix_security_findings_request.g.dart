// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fix_security_findings_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FixSecurityFindingsRequestCWProxy {
  FixSecurityFindingsRequest findingIds(List<int> findingIds);

  FixSecurityFindingsRequest hold(bool? hold);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FixSecurityFindingsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FixSecurityFindingsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  FixSecurityFindingsRequest call({List<int> findingIds, bool? hold});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFixSecurityFindingsRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFixSecurityFindingsRequest.copyWith.fieldName(...)`
class _$FixSecurityFindingsRequestCWProxyImpl
    implements _$FixSecurityFindingsRequestCWProxy {
  const _$FixSecurityFindingsRequestCWProxyImpl(this._value);

  final FixSecurityFindingsRequest _value;

  @override
  FixSecurityFindingsRequest findingIds(List<int> findingIds) =>
      this(findingIds: findingIds);

  @override
  FixSecurityFindingsRequest hold(bool? hold) => this(hold: hold);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FixSecurityFindingsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FixSecurityFindingsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  FixSecurityFindingsRequest call({
    Object? findingIds = const $CopyWithPlaceholder(),
    Object? hold = const $CopyWithPlaceholder(),
  }) {
    return FixSecurityFindingsRequest(
      findingIds: findingIds == const $CopyWithPlaceholder()
          ? _value.findingIds
          // ignore: cast_nullable_to_non_nullable
          : findingIds as List<int>,
      hold: hold == const $CopyWithPlaceholder()
          ? _value.hold
          // ignore: cast_nullable_to_non_nullable
          : hold as bool?,
    );
  }
}

extension $FixSecurityFindingsRequestCopyWith on FixSecurityFindingsRequest {
  /// Returns a callable class that can be used as follows: `instanceOfFixSecurityFindingsRequest.copyWith(...)` or like so:`instanceOfFixSecurityFindingsRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FixSecurityFindingsRequestCWProxy get copyWith =>
      _$FixSecurityFindingsRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FixSecurityFindingsRequest _$FixSecurityFindingsRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('FixSecurityFindingsRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['findingIds']);
  final val = FixSecurityFindingsRequest(
    findingIds: $checkedConvert(
      'findingIds',
      (v) => (v as List<dynamic>).map((e) => (e as num).toInt()).toList(),
    ),
    hold: $checkedConvert('hold', (v) => v as bool?),
  );
  return val;
});

Map<String, dynamic> _$FixSecurityFindingsRequestToJson(
  FixSecurityFindingsRequest instance,
) => <String, dynamic>{
  'findingIds': instance.findingIds,
  'hold': ?instance.hold,
};

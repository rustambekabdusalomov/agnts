// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_free_credits_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SetFreeCreditsRequestCWProxy {
  SetFreeCreditsRequest limit(int limit);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetFreeCreditsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetFreeCreditsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetFreeCreditsRequest call({int limit});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSetFreeCreditsRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSetFreeCreditsRequest.copyWith.fieldName(...)`
class _$SetFreeCreditsRequestCWProxyImpl
    implements _$SetFreeCreditsRequestCWProxy {
  const _$SetFreeCreditsRequestCWProxyImpl(this._value);

  final SetFreeCreditsRequest _value;

  @override
  SetFreeCreditsRequest limit(int limit) => this(limit: limit);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetFreeCreditsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetFreeCreditsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetFreeCreditsRequest call({Object? limit = const $CopyWithPlaceholder()}) {
    return SetFreeCreditsRequest(
      limit: limit == const $CopyWithPlaceholder()
          ? _value.limit
          // ignore: cast_nullable_to_non_nullable
          : limit as int,
    );
  }
}

extension $SetFreeCreditsRequestCopyWith on SetFreeCreditsRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSetFreeCreditsRequest.copyWith(...)` or like so:`instanceOfSetFreeCreditsRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SetFreeCreditsRequestCWProxy get copyWith =>
      _$SetFreeCreditsRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetFreeCreditsRequest _$SetFreeCreditsRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SetFreeCreditsRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['limit']);
  final val = SetFreeCreditsRequest(
    limit: $checkedConvert('limit', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$SetFreeCreditsRequestToJson(
  SetFreeCreditsRequest instance,
) => <String, dynamic>{'limit': instance.limit};

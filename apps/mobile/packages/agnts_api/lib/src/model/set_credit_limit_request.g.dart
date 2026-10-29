// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_credit_limit_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SetCreditLimitRequestCWProxy {
  SetCreditLimitRequest limit(int limit);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetCreditLimitRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetCreditLimitRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetCreditLimitRequest call({int limit});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSetCreditLimitRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSetCreditLimitRequest.copyWith.fieldName(...)`
class _$SetCreditLimitRequestCWProxyImpl
    implements _$SetCreditLimitRequestCWProxy {
  const _$SetCreditLimitRequestCWProxyImpl(this._value);

  final SetCreditLimitRequest _value;

  @override
  SetCreditLimitRequest limit(int limit) => this(limit: limit);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetCreditLimitRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetCreditLimitRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetCreditLimitRequest call({Object? limit = const $CopyWithPlaceholder()}) {
    return SetCreditLimitRequest(
      limit: limit == const $CopyWithPlaceholder()
          ? _value.limit
          // ignore: cast_nullable_to_non_nullable
          : limit as int,
    );
  }
}

extension $SetCreditLimitRequestCopyWith on SetCreditLimitRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSetCreditLimitRequest.copyWith(...)` or like so:`instanceOfSetCreditLimitRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SetCreditLimitRequestCWProxy get copyWith =>
      _$SetCreditLimitRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetCreditLimitRequest _$SetCreditLimitRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SetCreditLimitRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['limit']);
  final val = SetCreditLimitRequest(
    limit: $checkedConvert('limit', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$SetCreditLimitRequestToJson(
  SetCreditLimitRequest instance,
) => <String, dynamic>{'limit': instance.limit};

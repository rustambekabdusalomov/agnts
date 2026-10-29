// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_fallback_limit_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SetFallbackLimitRequestCWProxy {
  SetFallbackLimitRequest limit(int? limit);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetFallbackLimitRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetFallbackLimitRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetFallbackLimitRequest call({int? limit});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSetFallbackLimitRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSetFallbackLimitRequest.copyWith.fieldName(...)`
class _$SetFallbackLimitRequestCWProxyImpl
    implements _$SetFallbackLimitRequestCWProxy {
  const _$SetFallbackLimitRequestCWProxyImpl(this._value);

  final SetFallbackLimitRequest _value;

  @override
  SetFallbackLimitRequest limit(int? limit) => this(limit: limit);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetFallbackLimitRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetFallbackLimitRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetFallbackLimitRequest call({Object? limit = const $CopyWithPlaceholder()}) {
    return SetFallbackLimitRequest(
      limit: limit == const $CopyWithPlaceholder()
          ? _value.limit
          // ignore: cast_nullable_to_non_nullable
          : limit as int?,
    );
  }
}

extension $SetFallbackLimitRequestCopyWith on SetFallbackLimitRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSetFallbackLimitRequest.copyWith(...)` or like so:`instanceOfSetFallbackLimitRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SetFallbackLimitRequestCWProxy get copyWith =>
      _$SetFallbackLimitRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetFallbackLimitRequest _$SetFallbackLimitRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SetFallbackLimitRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['limit']);
  final val = SetFallbackLimitRequest(
    limit: $checkedConvert('limit', (v) => (v as num?)?.toInt()),
  );
  return val;
});

Map<String, dynamic> _$SetFallbackLimitRequestToJson(
  SetFallbackLimitRequest instance,
) => <String, dynamic>{'limit': instance.limit};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_security_scan200_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StartSecurityScan200ResponseCWProxy {
  StartSecurityScan200Response scan(SecurityScan scan);

  StartSecurityScan200Response queued(bool queued);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StartSecurityScan200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StartSecurityScan200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  StartSecurityScan200Response call({SecurityScan scan, bool queued});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStartSecurityScan200Response.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStartSecurityScan200Response.copyWith.fieldName(...)`
class _$StartSecurityScan200ResponseCWProxyImpl
    implements _$StartSecurityScan200ResponseCWProxy {
  const _$StartSecurityScan200ResponseCWProxyImpl(this._value);

  final StartSecurityScan200Response _value;

  @override
  StartSecurityScan200Response scan(SecurityScan scan) => this(scan: scan);

  @override
  StartSecurityScan200Response queued(bool queued) => this(queued: queued);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StartSecurityScan200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StartSecurityScan200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  StartSecurityScan200Response call({
    Object? scan = const $CopyWithPlaceholder(),
    Object? queued = const $CopyWithPlaceholder(),
  }) {
    return StartSecurityScan200Response(
      scan: scan == const $CopyWithPlaceholder()
          ? _value.scan
          // ignore: cast_nullable_to_non_nullable
          : scan as SecurityScan,
      queued: queued == const $CopyWithPlaceholder()
          ? _value.queued
          // ignore: cast_nullable_to_non_nullable
          : queued as bool,
    );
  }
}

extension $StartSecurityScan200ResponseCopyWith
    on StartSecurityScan200Response {
  /// Returns a callable class that can be used as follows: `instanceOfStartSecurityScan200Response.copyWith(...)` or like so:`instanceOfStartSecurityScan200Response.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StartSecurityScan200ResponseCWProxy get copyWith =>
      _$StartSecurityScan200ResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartSecurityScan200Response _$StartSecurityScan200ResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('StartSecurityScan200Response', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['scan', 'queued']);
  final val = StartSecurityScan200Response(
    scan: $checkedConvert(
      'scan',
      (v) => SecurityScan.fromJson(v as Map<String, dynamic>),
    ),
    queued: $checkedConvert('queued', (v) => v as bool),
  );
  return val;
});

Map<String, dynamic> _$StartSecurityScan200ResponseToJson(
  StartSecurityScan200Response instance,
) => <String, dynamic>{
  'scan': instance.scan.toJson(),
  'queued': instance.queued,
};

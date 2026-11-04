// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'egress_upstream_exit.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EgressUpstreamExitCWProxy {
  EgressUpstreamExit ip(String ip);

  EgressUpstreamExit org(String? org);

  EgressUpstreamExit city(String? city);

  EgressUpstreamExit country(String? country);

  EgressUpstreamExit at(DateTime at);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EgressUpstreamExit(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EgressUpstreamExit(...).copyWith(id: 12, name: "My name")
  /// ````
  EgressUpstreamExit call({
    String ip,
    String? org,
    String? city,
    String? country,
    DateTime at,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEgressUpstreamExit.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEgressUpstreamExit.copyWith.fieldName(...)`
class _$EgressUpstreamExitCWProxyImpl implements _$EgressUpstreamExitCWProxy {
  const _$EgressUpstreamExitCWProxyImpl(this._value);

  final EgressUpstreamExit _value;

  @override
  EgressUpstreamExit ip(String ip) => this(ip: ip);

  @override
  EgressUpstreamExit org(String? org) => this(org: org);

  @override
  EgressUpstreamExit city(String? city) => this(city: city);

  @override
  EgressUpstreamExit country(String? country) => this(country: country);

  @override
  EgressUpstreamExit at(DateTime at) => this(at: at);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EgressUpstreamExit(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EgressUpstreamExit(...).copyWith(id: 12, name: "My name")
  /// ````
  EgressUpstreamExit call({
    Object? ip = const $CopyWithPlaceholder(),
    Object? org = const $CopyWithPlaceholder(),
    Object? city = const $CopyWithPlaceholder(),
    Object? country = const $CopyWithPlaceholder(),
    Object? at = const $CopyWithPlaceholder(),
  }) {
    return EgressUpstreamExit(
      ip: ip == const $CopyWithPlaceholder()
          ? _value.ip
          // ignore: cast_nullable_to_non_nullable
          : ip as String,
      org: org == const $CopyWithPlaceholder()
          ? _value.org
          // ignore: cast_nullable_to_non_nullable
          : org as String?,
      city: city == const $CopyWithPlaceholder()
          ? _value.city
          // ignore: cast_nullable_to_non_nullable
          : city as String?,
      country: country == const $CopyWithPlaceholder()
          ? _value.country
          // ignore: cast_nullable_to_non_nullable
          : country as String?,
      at: at == const $CopyWithPlaceholder()
          ? _value.at
          // ignore: cast_nullable_to_non_nullable
          : at as DateTime,
    );
  }
}

extension $EgressUpstreamExitCopyWith on EgressUpstreamExit {
  /// Returns a callable class that can be used as follows: `instanceOfEgressUpstreamExit.copyWith(...)` or like so:`instanceOfEgressUpstreamExit.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EgressUpstreamExitCWProxy get copyWith =>
      _$EgressUpstreamExitCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EgressUpstreamExit _$EgressUpstreamExitFromJson(Map<String, dynamic> json) =>
    $checkedCreate('EgressUpstreamExit', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['ip', 'at']);
      final val = EgressUpstreamExit(
        ip: $checkedConvert('ip', (v) => v as String),
        org: $checkedConvert('org', (v) => v as String?),
        city: $checkedConvert('city', (v) => v as String?),
        country: $checkedConvert('country', (v) => v as String?),
        at: $checkedConvert('at', (v) => DateTime.parse(v as String)),
      );
      return val;
    });

Map<String, dynamic> _$EgressUpstreamExitToJson(EgressUpstreamExit instance) =>
    <String, dynamic>{
      'ip': instance.ip,
      'org': ?instance.org,
      'city': ?instance.city,
      'country': ?instance.country,
      'at': instance.at.toIso8601String(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_test_tls.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NetworkTestTlsCWProxy {
  NetworkTestTls verified(bool verified);

  NetworkTestTls subject(String? subject);

  NetworkTestTls issuer(String? issuer);

  NetworkTestTls notAfter(DateTime? notAfter);

  NetworkTestTls error(String? error);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NetworkTestTls(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NetworkTestTls(...).copyWith(id: 12, name: "My name")
  /// ````
  NetworkTestTls call({
    bool verified,
    String? subject,
    String? issuer,
    DateTime? notAfter,
    String? error,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNetworkTestTls.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNetworkTestTls.copyWith.fieldName(...)`
class _$NetworkTestTlsCWProxyImpl implements _$NetworkTestTlsCWProxy {
  const _$NetworkTestTlsCWProxyImpl(this._value);

  final NetworkTestTls _value;

  @override
  NetworkTestTls verified(bool verified) => this(verified: verified);

  @override
  NetworkTestTls subject(String? subject) => this(subject: subject);

  @override
  NetworkTestTls issuer(String? issuer) => this(issuer: issuer);

  @override
  NetworkTestTls notAfter(DateTime? notAfter) => this(notAfter: notAfter);

  @override
  NetworkTestTls error(String? error) => this(error: error);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NetworkTestTls(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NetworkTestTls(...).copyWith(id: 12, name: "My name")
  /// ````
  NetworkTestTls call({
    Object? verified = const $CopyWithPlaceholder(),
    Object? subject = const $CopyWithPlaceholder(),
    Object? issuer = const $CopyWithPlaceholder(),
    Object? notAfter = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
  }) {
    return NetworkTestTls(
      verified: verified == const $CopyWithPlaceholder()
          ? _value.verified
          // ignore: cast_nullable_to_non_nullable
          : verified as bool,
      subject: subject == const $CopyWithPlaceholder()
          ? _value.subject
          // ignore: cast_nullable_to_non_nullable
          : subject as String?,
      issuer: issuer == const $CopyWithPlaceholder()
          ? _value.issuer
          // ignore: cast_nullable_to_non_nullable
          : issuer as String?,
      notAfter: notAfter == const $CopyWithPlaceholder()
          ? _value.notAfter
          // ignore: cast_nullable_to_non_nullable
          : notAfter as DateTime?,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String?,
    );
  }
}

extension $NetworkTestTlsCopyWith on NetworkTestTls {
  /// Returns a callable class that can be used as follows: `instanceOfNetworkTestTls.copyWith(...)` or like so:`instanceOfNetworkTestTls.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NetworkTestTlsCWProxy get copyWith => _$NetworkTestTlsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkTestTls _$NetworkTestTlsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('NetworkTestTls', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['verified']);
      final val = NetworkTestTls(
        verified: $checkedConvert('verified', (v) => v as bool),
        subject: $checkedConvert('subject', (v) => v as String?),
        issuer: $checkedConvert('issuer', (v) => v as String?),
        notAfter: $checkedConvert(
          'notAfter',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        error: $checkedConvert('error', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$NetworkTestTlsToJson(NetworkTestTls instance) =>
    <String, dynamic>{
      'verified': instance.verified,
      'subject': ?instance.subject,
      'issuer': ?instance.issuer,
      'notAfter': ?instance.notAfter?.toIso8601String(),
      'error': ?instance.error,
    };

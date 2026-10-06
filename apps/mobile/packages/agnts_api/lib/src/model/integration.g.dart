// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'integration.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$IntegrationCWProxy {
  Integration provider(String provider);

  Integration connected(bool connected);

  Integration checkedAt(DateTime? checkedAt);

  Integration account(String? account);

  Integration tokenHint(String? tokenHint);

  Integration lastError(String? lastError);

  Integration settings(Map<String, String> settings);

  Integration webhookUrl(String? webhookUrl);

  Integration webhookSecret(String? webhookSecret);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Integration(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Integration(...).copyWith(id: 12, name: "My name")
  /// ````
  Integration call({
    String provider,
    bool connected,
    DateTime? checkedAt,
    String? account,
    String? tokenHint,
    String? lastError,
    Map<String, String> settings,
    String? webhookUrl,
    String? webhookSecret,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfIntegration.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfIntegration.copyWith.fieldName(...)`
class _$IntegrationCWProxyImpl implements _$IntegrationCWProxy {
  const _$IntegrationCWProxyImpl(this._value);

  final Integration _value;

  @override
  Integration provider(String provider) => this(provider: provider);

  @override
  Integration connected(bool connected) => this(connected: connected);

  @override
  Integration checkedAt(DateTime? checkedAt) => this(checkedAt: checkedAt);

  @override
  Integration account(String? account) => this(account: account);

  @override
  Integration tokenHint(String? tokenHint) => this(tokenHint: tokenHint);

  @override
  Integration lastError(String? lastError) => this(lastError: lastError);

  @override
  Integration settings(Map<String, String> settings) =>
      this(settings: settings);

  @override
  Integration webhookUrl(String? webhookUrl) => this(webhookUrl: webhookUrl);

  @override
  Integration webhookSecret(String? webhookSecret) =>
      this(webhookSecret: webhookSecret);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Integration(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Integration(...).copyWith(id: 12, name: "My name")
  /// ````
  Integration call({
    Object? provider = const $CopyWithPlaceholder(),
    Object? connected = const $CopyWithPlaceholder(),
    Object? checkedAt = const $CopyWithPlaceholder(),
    Object? account = const $CopyWithPlaceholder(),
    Object? tokenHint = const $CopyWithPlaceholder(),
    Object? lastError = const $CopyWithPlaceholder(),
    Object? settings = const $CopyWithPlaceholder(),
    Object? webhookUrl = const $CopyWithPlaceholder(),
    Object? webhookSecret = const $CopyWithPlaceholder(),
  }) {
    return Integration(
      provider: provider == const $CopyWithPlaceholder()
          ? _value.provider
          // ignore: cast_nullable_to_non_nullable
          : provider as String,
      connected: connected == const $CopyWithPlaceholder()
          ? _value.connected
          // ignore: cast_nullable_to_non_nullable
          : connected as bool,
      checkedAt: checkedAt == const $CopyWithPlaceholder()
          ? _value.checkedAt
          // ignore: cast_nullable_to_non_nullable
          : checkedAt as DateTime?,
      account: account == const $CopyWithPlaceholder()
          ? _value.account
          // ignore: cast_nullable_to_non_nullable
          : account as String?,
      tokenHint: tokenHint == const $CopyWithPlaceholder()
          ? _value.tokenHint
          // ignore: cast_nullable_to_non_nullable
          : tokenHint as String?,
      lastError: lastError == const $CopyWithPlaceholder()
          ? _value.lastError
          // ignore: cast_nullable_to_non_nullable
          : lastError as String?,
      settings: settings == const $CopyWithPlaceholder()
          ? _value.settings
          // ignore: cast_nullable_to_non_nullable
          : settings as Map<String, String>,
      webhookUrl: webhookUrl == const $CopyWithPlaceholder()
          ? _value.webhookUrl
          // ignore: cast_nullable_to_non_nullable
          : webhookUrl as String?,
      webhookSecret: webhookSecret == const $CopyWithPlaceholder()
          ? _value.webhookSecret
          // ignore: cast_nullable_to_non_nullable
          : webhookSecret as String?,
    );
  }
}

extension $IntegrationCopyWith on Integration {
  /// Returns a callable class that can be used as follows: `instanceOfIntegration.copyWith(...)` or like so:`instanceOfIntegration.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$IntegrationCWProxy get copyWith => _$IntegrationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Integration _$IntegrationFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Integration',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['provider', 'connected', 'settings']);
    final val = Integration(
      provider: $checkedConvert('provider', (v) => v as String),
      connected: $checkedConvert('connected', (v) => v as bool),
      checkedAt: $checkedConvert(
        'checkedAt',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      account: $checkedConvert('account', (v) => v as String?),
      tokenHint: $checkedConvert('tokenHint', (v) => v as String?),
      lastError: $checkedConvert('lastError', (v) => v as String?),
      settings: $checkedConvert(
        'settings',
        (v) => Map<String, String>.from(v as Map),
      ),
      webhookUrl: $checkedConvert('webhookUrl', (v) => v as String?),
      webhookSecret: $checkedConvert('webhookSecret', (v) => v as String?),
    );
    return val;
  },
);

Map<String, dynamic> _$IntegrationToJson(Integration instance) =>
    <String, dynamic>{
      'provider': instance.provider,
      'connected': instance.connected,
      'checkedAt': ?instance.checkedAt?.toIso8601String(),
      'account': ?instance.account,
      'tokenHint': ?instance.tokenHint,
      'lastError': ?instance.lastError,
      'settings': instance.settings,
      'webhookUrl': ?instance.webhookUrl,
      'webhookSecret': ?instance.webhookSecret,
    };

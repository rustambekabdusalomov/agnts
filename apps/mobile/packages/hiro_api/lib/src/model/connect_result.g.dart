// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connect_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ConnectResultCWProxy {
  ConnectResult integration(Integration integration);

  ConnectResult webhookSecret(String? webhookSecret);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConnectResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConnectResult(...).copyWith(id: 12, name: "My name")
  /// ````
  ConnectResult call({Integration integration, String? webhookSecret});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfConnectResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfConnectResult.copyWith.fieldName(...)`
class _$ConnectResultCWProxyImpl implements _$ConnectResultCWProxy {
  const _$ConnectResultCWProxyImpl(this._value);

  final ConnectResult _value;

  @override
  ConnectResult integration(Integration integration) =>
      this(integration: integration);

  @override
  ConnectResult webhookSecret(String? webhookSecret) =>
      this(webhookSecret: webhookSecret);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConnectResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConnectResult(...).copyWith(id: 12, name: "My name")
  /// ````
  ConnectResult call({
    Object? integration = const $CopyWithPlaceholder(),
    Object? webhookSecret = const $CopyWithPlaceholder(),
  }) {
    return ConnectResult(
      integration: integration == const $CopyWithPlaceholder()
          ? _value.integration
          // ignore: cast_nullable_to_non_nullable
          : integration as Integration,
      webhookSecret: webhookSecret == const $CopyWithPlaceholder()
          ? _value.webhookSecret
          // ignore: cast_nullable_to_non_nullable
          : webhookSecret as String?,
    );
  }
}

extension $ConnectResultCopyWith on ConnectResult {
  /// Returns a callable class that can be used as follows: `instanceOfConnectResult.copyWith(...)` or like so:`instanceOfConnectResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ConnectResultCWProxy get copyWith => _$ConnectResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConnectResult _$ConnectResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ConnectResult', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['integration']);
      final val = ConnectResult(
        integration: $checkedConvert(
          'integration',
          (v) => Integration.fromJson(v as Map<String, dynamic>),
        ),
        webhookSecret: $checkedConvert('webhookSecret', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$ConnectResultToJson(ConnectResult instance) =>
    <String, dynamic>{
      'integration': instance.integration.toJson(),
      'webhookSecret': ?instance.webhookSecret,
    };

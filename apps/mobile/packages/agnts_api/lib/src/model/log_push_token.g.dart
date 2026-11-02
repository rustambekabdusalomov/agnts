// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_push_token.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LogPushTokenCWProxy {
  LogPushToken token(String token);

  LogPushToken url(String url);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogPushToken(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogPushToken(...).copyWith(id: 12, name: "My name")
  /// ````
  LogPushToken call({String token, String url});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLogPushToken.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLogPushToken.copyWith.fieldName(...)`
class _$LogPushTokenCWProxyImpl implements _$LogPushTokenCWProxy {
  const _$LogPushTokenCWProxyImpl(this._value);

  final LogPushToken _value;

  @override
  LogPushToken token(String token) => this(token: token);

  @override
  LogPushToken url(String url) => this(url: url);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogPushToken(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogPushToken(...).copyWith(id: 12, name: "My name")
  /// ````
  LogPushToken call({
    Object? token = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
  }) {
    return LogPushToken(
      token: token == const $CopyWithPlaceholder()
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
    );
  }
}

extension $LogPushTokenCopyWith on LogPushToken {
  /// Returns a callable class that can be used as follows: `instanceOfLogPushToken.copyWith(...)` or like so:`instanceOfLogPushToken.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LogPushTokenCWProxy get copyWith => _$LogPushTokenCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogPushToken _$LogPushTokenFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LogPushToken', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['token', 'url']);
      final val = LogPushToken(
        token: $checkedConvert('token', (v) => v as String),
        url: $checkedConvert('url', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$LogPushTokenToJson(LogPushToken instance) =>
    <String, dynamic>{'token': instance.token, 'url': instance.url};

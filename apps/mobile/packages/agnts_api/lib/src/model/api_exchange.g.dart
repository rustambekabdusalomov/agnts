// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_exchange.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiExchangeCWProxy {
  ApiExchange id(String id);

  ApiExchange case_(String? case_);

  ApiExchange auth(String? auth);

  ApiExchange method(String method);

  ApiExchange url(String url);

  ApiExchange status(int status);

  ApiExchange ms(int ms);

  ApiExchange error(String? error);

  ApiExchange truncated(bool? truncated);

  ApiExchange requestHeaders(Map<String, String>? requestHeaders);

  ApiExchange requestBody(String? requestBody);

  ApiExchange responseHeaders(Map<String, String>? responseHeaders);

  ApiExchange responseBody(String? responseBody);

  ApiExchange at(DateTime? at);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiExchange(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiExchange(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiExchange call({
    String id,
    String? case_,
    String? auth,
    String method,
    String url,
    int status,
    int ms,
    String? error,
    bool? truncated,
    Map<String, String>? requestHeaders,
    String? requestBody,
    Map<String, String>? responseHeaders,
    String? responseBody,
    DateTime? at,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiExchange.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiExchange.copyWith.fieldName(...)`
class _$ApiExchangeCWProxyImpl implements _$ApiExchangeCWProxy {
  const _$ApiExchangeCWProxyImpl(this._value);

  final ApiExchange _value;

  @override
  ApiExchange id(String id) => this(id: id);

  @override
  ApiExchange case_(String? case_) => this(case_: case_);

  @override
  ApiExchange auth(String? auth) => this(auth: auth);

  @override
  ApiExchange method(String method) => this(method: method);

  @override
  ApiExchange url(String url) => this(url: url);

  @override
  ApiExchange status(int status) => this(status: status);

  @override
  ApiExchange ms(int ms) => this(ms: ms);

  @override
  ApiExchange error(String? error) => this(error: error);

  @override
  ApiExchange truncated(bool? truncated) => this(truncated: truncated);

  @override
  ApiExchange requestHeaders(Map<String, String>? requestHeaders) =>
      this(requestHeaders: requestHeaders);

  @override
  ApiExchange requestBody(String? requestBody) =>
      this(requestBody: requestBody);

  @override
  ApiExchange responseHeaders(Map<String, String>? responseHeaders) =>
      this(responseHeaders: responseHeaders);

  @override
  ApiExchange responseBody(String? responseBody) =>
      this(responseBody: responseBody);

  @override
  ApiExchange at(DateTime? at) => this(at: at);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiExchange(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiExchange(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiExchange call({
    Object? id = const $CopyWithPlaceholder(),
    Object? case_ = const $CopyWithPlaceholder(),
    Object? auth = const $CopyWithPlaceholder(),
    Object? method = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? ms = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
    Object? truncated = const $CopyWithPlaceholder(),
    Object? requestHeaders = const $CopyWithPlaceholder(),
    Object? requestBody = const $CopyWithPlaceholder(),
    Object? responseHeaders = const $CopyWithPlaceholder(),
    Object? responseBody = const $CopyWithPlaceholder(),
    Object? at = const $CopyWithPlaceholder(),
  }) {
    return ApiExchange(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      case_: case_ == const $CopyWithPlaceholder()
          ? _value.case_
          // ignore: cast_nullable_to_non_nullable
          : case_ as String?,
      auth: auth == const $CopyWithPlaceholder()
          ? _value.auth
          // ignore: cast_nullable_to_non_nullable
          : auth as String?,
      method: method == const $CopyWithPlaceholder()
          ? _value.method
          // ignore: cast_nullable_to_non_nullable
          : method as String,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as int,
      ms: ms == const $CopyWithPlaceholder()
          ? _value.ms
          // ignore: cast_nullable_to_non_nullable
          : ms as int,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String?,
      truncated: truncated == const $CopyWithPlaceholder()
          ? _value.truncated
          // ignore: cast_nullable_to_non_nullable
          : truncated as bool?,
      requestHeaders: requestHeaders == const $CopyWithPlaceholder()
          ? _value.requestHeaders
          // ignore: cast_nullable_to_non_nullable
          : requestHeaders as Map<String, String>?,
      requestBody: requestBody == const $CopyWithPlaceholder()
          ? _value.requestBody
          // ignore: cast_nullable_to_non_nullable
          : requestBody as String?,
      responseHeaders: responseHeaders == const $CopyWithPlaceholder()
          ? _value.responseHeaders
          // ignore: cast_nullable_to_non_nullable
          : responseHeaders as Map<String, String>?,
      responseBody: responseBody == const $CopyWithPlaceholder()
          ? _value.responseBody
          // ignore: cast_nullable_to_non_nullable
          : responseBody as String?,
      at: at == const $CopyWithPlaceholder()
          ? _value.at
          // ignore: cast_nullable_to_non_nullable
          : at as DateTime?,
    );
  }
}

extension $ApiExchangeCopyWith on ApiExchange {
  /// Returns a callable class that can be used as follows: `instanceOfApiExchange.copyWith(...)` or like so:`instanceOfApiExchange.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiExchangeCWProxy get copyWith => _$ApiExchangeCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiExchange _$ApiExchangeFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiExchange', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['id', 'method', 'url', 'status', 'ms']);
  final val = ApiExchange(
    id: $checkedConvert('id', (v) => v as String),
    case_: $checkedConvert('case', (v) => v as String?),
    auth: $checkedConvert('auth', (v) => v as String?),
    method: $checkedConvert('method', (v) => v as String),
    url: $checkedConvert('url', (v) => v as String),
    status: $checkedConvert('status', (v) => (v as num).toInt()),
    ms: $checkedConvert('ms', (v) => (v as num).toInt()),
    error: $checkedConvert('error', (v) => v as String?),
    truncated: $checkedConvert('truncated', (v) => v as bool?),
    requestHeaders: $checkedConvert(
      'requestHeaders',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as String)),
    ),
    requestBody: $checkedConvert('requestBody', (v) => v as String?),
    responseHeaders: $checkedConvert(
      'responseHeaders',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as String)),
    ),
    responseBody: $checkedConvert('responseBody', (v) => v as String?),
    at: $checkedConvert(
      'at',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
  );
  return val;
}, fieldKeyMap: const {'case_': 'case'});

Map<String, dynamic> _$ApiExchangeToJson(ApiExchange instance) =>
    <String, dynamic>{
      'id': instance.id,
      'case': ?instance.case_,
      'auth': ?instance.auth,
      'method': instance.method,
      'url': instance.url,
      'status': instance.status,
      'ms': instance.ms,
      'error': ?instance.error,
      'truncated': ?instance.truncated,
      'requestHeaders': ?instance.requestHeaders,
      'requestBody': ?instance.requestBody,
      'responseHeaders': ?instance.responseHeaders,
      'responseBody': ?instance.responseBody,
      'at': ?instance.at?.toIso8601String(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_request_row.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiRequestRowCWProxy {
  ApiRequestRow id(String id);

  ApiRequestRow case_(String? case_);

  ApiRequestRow auth(String? auth);

  ApiRequestRow method(String method);

  ApiRequestRow url(String url);

  ApiRequestRow status(int status);

  ApiRequestRow ms(int ms);

  ApiRequestRow error(String? error);

  ApiRequestRow truncated(bool? truncated);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiRequestRow(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiRequestRow(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiRequestRow call({
    String id,
    String? case_,
    String? auth,
    String method,
    String url,
    int status,
    int ms,
    String? error,
    bool? truncated,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiRequestRow.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiRequestRow.copyWith.fieldName(...)`
class _$ApiRequestRowCWProxyImpl implements _$ApiRequestRowCWProxy {
  const _$ApiRequestRowCWProxyImpl(this._value);

  final ApiRequestRow _value;

  @override
  ApiRequestRow id(String id) => this(id: id);

  @override
  ApiRequestRow case_(String? case_) => this(case_: case_);

  @override
  ApiRequestRow auth(String? auth) => this(auth: auth);

  @override
  ApiRequestRow method(String method) => this(method: method);

  @override
  ApiRequestRow url(String url) => this(url: url);

  @override
  ApiRequestRow status(int status) => this(status: status);

  @override
  ApiRequestRow ms(int ms) => this(ms: ms);

  @override
  ApiRequestRow error(String? error) => this(error: error);

  @override
  ApiRequestRow truncated(bool? truncated) => this(truncated: truncated);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiRequestRow(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiRequestRow(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiRequestRow call({
    Object? id = const $CopyWithPlaceholder(),
    Object? case_ = const $CopyWithPlaceholder(),
    Object? auth = const $CopyWithPlaceholder(),
    Object? method = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? ms = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
    Object? truncated = const $CopyWithPlaceholder(),
  }) {
    return ApiRequestRow(
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
    );
  }
}

extension $ApiRequestRowCopyWith on ApiRequestRow {
  /// Returns a callable class that can be used as follows: `instanceOfApiRequestRow.copyWith(...)` or like so:`instanceOfApiRequestRow.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiRequestRowCWProxy get copyWith => _$ApiRequestRowCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiRequestRow _$ApiRequestRowFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ApiRequestRow', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['id', 'method', 'url', 'status', 'ms'],
      );
      final val = ApiRequestRow(
        id: $checkedConvert('id', (v) => v as String),
        case_: $checkedConvert('case', (v) => v as String?),
        auth: $checkedConvert('auth', (v) => v as String?),
        method: $checkedConvert('method', (v) => v as String),
        url: $checkedConvert('url', (v) => v as String),
        status: $checkedConvert('status', (v) => (v as num).toInt()),
        ms: $checkedConvert('ms', (v) => (v as num).toInt()),
        error: $checkedConvert('error', (v) => v as String?),
        truncated: $checkedConvert('truncated', (v) => v as bool?),
      );
      return val;
    }, fieldKeyMap: const {'case_': 'case'});

Map<String, dynamic> _$ApiRequestRowToJson(ApiRequestRow instance) =>
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
    };

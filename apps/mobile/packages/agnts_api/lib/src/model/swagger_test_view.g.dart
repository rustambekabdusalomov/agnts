// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swagger_test_view.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SwaggerTestViewCWProxy {
  SwaggerTestView specUrl(String? specUrl);

  SwaggerTestView baseUrl(String baseUrl);

  SwaggerTestView operations(List<String> operations);

  SwaggerTestView writeEnabled(bool writeEnabled);

  SwaggerTestView authKind(ApiAuthKind authKind);

  SwaggerTestView authName(String? authName);

  SwaggerTestView hasToken(bool hasToken);

  SwaggerTestView rateLimit(int rateLimit);

  SwaggerTestView maxRequests(int maxRequests);

  SwaggerTestView suiteId(int? suiteId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerTestView(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerTestView(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerTestView call({
    String? specUrl,
    String baseUrl,
    List<String> operations,
    bool writeEnabled,
    ApiAuthKind authKind,
    String? authName,
    bool hasToken,
    int rateLimit,
    int maxRequests,
    int? suiteId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSwaggerTestView.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSwaggerTestView.copyWith.fieldName(...)`
class _$SwaggerTestViewCWProxyImpl implements _$SwaggerTestViewCWProxy {
  const _$SwaggerTestViewCWProxyImpl(this._value);

  final SwaggerTestView _value;

  @override
  SwaggerTestView specUrl(String? specUrl) => this(specUrl: specUrl);

  @override
  SwaggerTestView baseUrl(String baseUrl) => this(baseUrl: baseUrl);

  @override
  SwaggerTestView operations(List<String> operations) =>
      this(operations: operations);

  @override
  SwaggerTestView writeEnabled(bool writeEnabled) =>
      this(writeEnabled: writeEnabled);

  @override
  SwaggerTestView authKind(ApiAuthKind authKind) => this(authKind: authKind);

  @override
  SwaggerTestView authName(String? authName) => this(authName: authName);

  @override
  SwaggerTestView hasToken(bool hasToken) => this(hasToken: hasToken);

  @override
  SwaggerTestView rateLimit(int rateLimit) => this(rateLimit: rateLimit);

  @override
  SwaggerTestView maxRequests(int maxRequests) =>
      this(maxRequests: maxRequests);

  @override
  SwaggerTestView suiteId(int? suiteId) => this(suiteId: suiteId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerTestView(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerTestView(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerTestView call({
    Object? specUrl = const $CopyWithPlaceholder(),
    Object? baseUrl = const $CopyWithPlaceholder(),
    Object? operations = const $CopyWithPlaceholder(),
    Object? writeEnabled = const $CopyWithPlaceholder(),
    Object? authKind = const $CopyWithPlaceholder(),
    Object? authName = const $CopyWithPlaceholder(),
    Object? hasToken = const $CopyWithPlaceholder(),
    Object? rateLimit = const $CopyWithPlaceholder(),
    Object? maxRequests = const $CopyWithPlaceholder(),
    Object? suiteId = const $CopyWithPlaceholder(),
  }) {
    return SwaggerTestView(
      specUrl: specUrl == const $CopyWithPlaceholder()
          ? _value.specUrl
          // ignore: cast_nullable_to_non_nullable
          : specUrl as String?,
      baseUrl: baseUrl == const $CopyWithPlaceholder()
          ? _value.baseUrl
          // ignore: cast_nullable_to_non_nullable
          : baseUrl as String,
      operations: operations == const $CopyWithPlaceholder()
          ? _value.operations
          // ignore: cast_nullable_to_non_nullable
          : operations as List<String>,
      writeEnabled: writeEnabled == const $CopyWithPlaceholder()
          ? _value.writeEnabled
          // ignore: cast_nullable_to_non_nullable
          : writeEnabled as bool,
      authKind: authKind == const $CopyWithPlaceholder()
          ? _value.authKind
          // ignore: cast_nullable_to_non_nullable
          : authKind as ApiAuthKind,
      authName: authName == const $CopyWithPlaceholder()
          ? _value.authName
          // ignore: cast_nullable_to_non_nullable
          : authName as String?,
      hasToken: hasToken == const $CopyWithPlaceholder()
          ? _value.hasToken
          // ignore: cast_nullable_to_non_nullable
          : hasToken as bool,
      rateLimit: rateLimit == const $CopyWithPlaceholder()
          ? _value.rateLimit
          // ignore: cast_nullable_to_non_nullable
          : rateLimit as int,
      maxRequests: maxRequests == const $CopyWithPlaceholder()
          ? _value.maxRequests
          // ignore: cast_nullable_to_non_nullable
          : maxRequests as int,
      suiteId: suiteId == const $CopyWithPlaceholder()
          ? _value.suiteId
          // ignore: cast_nullable_to_non_nullable
          : suiteId as int?,
    );
  }
}

extension $SwaggerTestViewCopyWith on SwaggerTestView {
  /// Returns a callable class that can be used as follows: `instanceOfSwaggerTestView.copyWith(...)` or like so:`instanceOfSwaggerTestView.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SwaggerTestViewCWProxy get copyWith => _$SwaggerTestViewCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwaggerTestView _$SwaggerTestViewFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SwaggerTestView', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'baseUrl',
          'operations',
          'writeEnabled',
          'authKind',
          'hasToken',
          'rateLimit',
          'maxRequests',
        ],
      );
      final val = SwaggerTestView(
        specUrl: $checkedConvert('specUrl', (v) => v as String?),
        baseUrl: $checkedConvert('baseUrl', (v) => v as String),
        operations: $checkedConvert(
          'operations',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        writeEnabled: $checkedConvert('writeEnabled', (v) => v as bool),
        authKind: $checkedConvert(
          'authKind',
          (v) => $enumDecode(_$ApiAuthKindEnumMap, v),
        ),
        authName: $checkedConvert('authName', (v) => v as String?),
        hasToken: $checkedConvert('hasToken', (v) => v as bool),
        rateLimit: $checkedConvert('rateLimit', (v) => (v as num).toInt()),
        maxRequests: $checkedConvert('maxRequests', (v) => (v as num).toInt()),
        suiteId: $checkedConvert('suiteId', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$SwaggerTestViewToJson(SwaggerTestView instance) =>
    <String, dynamic>{
      'specUrl': ?instance.specUrl,
      'baseUrl': instance.baseUrl,
      'operations': instance.operations,
      'writeEnabled': instance.writeEnabled,
      'authKind': _$ApiAuthKindEnumMap[instance.authKind]!,
      'authName': ?instance.authName,
      'hasToken': instance.hasToken,
      'rateLimit': instance.rateLimit,
      'maxRequests': instance.maxRequests,
      'suiteId': ?instance.suiteId,
    };

const _$ApiAuthKindEnumMap = {
  ApiAuthKind.none: 'none',
  ApiAuthKind.bearer: 'bearer',
  ApiAuthKind.header: 'header',
  ApiAuthKind.query: 'query',
  ApiAuthKind.basic: 'basic',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swagger_security_scheme.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SwaggerSecuritySchemeCWProxy {
  SwaggerSecurityScheme name(String name);

  SwaggerSecurityScheme type(String type);

  SwaggerSecurityScheme scheme(String? scheme);

  SwaggerSecurityScheme in_(String? in_);

  SwaggerSecurityScheme param(String? param);

  SwaggerSecurityScheme authKind(ApiAuthKind? authKind);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerSecurityScheme(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerSecurityScheme(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerSecurityScheme call({
    String name,
    String type,
    String? scheme,
    String? in_,
    String? param,
    ApiAuthKind? authKind,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSwaggerSecurityScheme.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSwaggerSecurityScheme.copyWith.fieldName(...)`
class _$SwaggerSecuritySchemeCWProxyImpl
    implements _$SwaggerSecuritySchemeCWProxy {
  const _$SwaggerSecuritySchemeCWProxyImpl(this._value);

  final SwaggerSecurityScheme _value;

  @override
  SwaggerSecurityScheme name(String name) => this(name: name);

  @override
  SwaggerSecurityScheme type(String type) => this(type: type);

  @override
  SwaggerSecurityScheme scheme(String? scheme) => this(scheme: scheme);

  @override
  SwaggerSecurityScheme in_(String? in_) => this(in_: in_);

  @override
  SwaggerSecurityScheme param(String? param) => this(param: param);

  @override
  SwaggerSecurityScheme authKind(ApiAuthKind? authKind) =>
      this(authKind: authKind);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerSecurityScheme(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerSecurityScheme(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerSecurityScheme call({
    Object? name = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? scheme = const $CopyWithPlaceholder(),
    Object? in_ = const $CopyWithPlaceholder(),
    Object? param = const $CopyWithPlaceholder(),
    Object? authKind = const $CopyWithPlaceholder(),
  }) {
    return SwaggerSecurityScheme(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as String,
      scheme: scheme == const $CopyWithPlaceholder()
          ? _value.scheme
          // ignore: cast_nullable_to_non_nullable
          : scheme as String?,
      in_: in_ == const $CopyWithPlaceholder()
          ? _value.in_
          // ignore: cast_nullable_to_non_nullable
          : in_ as String?,
      param: param == const $CopyWithPlaceholder()
          ? _value.param
          // ignore: cast_nullable_to_non_nullable
          : param as String?,
      authKind: authKind == const $CopyWithPlaceholder()
          ? _value.authKind
          // ignore: cast_nullable_to_non_nullable
          : authKind as ApiAuthKind?,
    );
  }
}

extension $SwaggerSecuritySchemeCopyWith on SwaggerSecurityScheme {
  /// Returns a callable class that can be used as follows: `instanceOfSwaggerSecurityScheme.copyWith(...)` or like so:`instanceOfSwaggerSecurityScheme.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SwaggerSecuritySchemeCWProxy get copyWith =>
      _$SwaggerSecuritySchemeCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwaggerSecurityScheme _$SwaggerSecuritySchemeFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SwaggerSecurityScheme', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['name', 'type']);
  final val = SwaggerSecurityScheme(
    name: $checkedConvert('name', (v) => v as String),
    type: $checkedConvert('type', (v) => v as String),
    scheme: $checkedConvert('scheme', (v) => v as String?),
    in_: $checkedConvert('in', (v) => v as String?),
    param: $checkedConvert('param', (v) => v as String?),
    authKind: $checkedConvert(
      'authKind',
      (v) => $enumDecodeNullable(_$ApiAuthKindEnumMap, v),
    ),
  );
  return val;
}, fieldKeyMap: const {'in_': 'in'});

Map<String, dynamic> _$SwaggerSecuritySchemeToJson(
  SwaggerSecurityScheme instance,
) => <String, dynamic>{
  'name': instance.name,
  'type': instance.type,
  'scheme': ?instance.scheme,
  'in': ?instance.in_,
  'param': ?instance.param,
  'authKind': ?_$ApiAuthKindEnumMap[instance.authKind],
};

const _$ApiAuthKindEnumMap = {
  ApiAuthKind.none: 'none',
  ApiAuthKind.bearer: 'bearer',
  ApiAuthKind.header: 'header',
  ApiAuthKind.query: 'query',
  ApiAuthKind.basic: 'basic',
};

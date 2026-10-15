// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swagger_auth_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SwaggerAuthInputCWProxy {
  SwaggerAuthInput kind(ApiAuthKind kind);

  SwaggerAuthInput name(String? name);

  SwaggerAuthInput value(String? value);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerAuthInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerAuthInput(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerAuthInput call({ApiAuthKind kind, String? name, String? value});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSwaggerAuthInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSwaggerAuthInput.copyWith.fieldName(...)`
class _$SwaggerAuthInputCWProxyImpl implements _$SwaggerAuthInputCWProxy {
  const _$SwaggerAuthInputCWProxyImpl(this._value);

  final SwaggerAuthInput _value;

  @override
  SwaggerAuthInput kind(ApiAuthKind kind) => this(kind: kind);

  @override
  SwaggerAuthInput name(String? name) => this(name: name);

  @override
  SwaggerAuthInput value(String? value) => this(value: value);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerAuthInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerAuthInput(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerAuthInput call({
    Object? kind = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? value = const $CopyWithPlaceholder(),
  }) {
    return SwaggerAuthInput(
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as ApiAuthKind,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      value: value == const $CopyWithPlaceholder()
          ? _value.value
          // ignore: cast_nullable_to_non_nullable
          : value as String?,
    );
  }
}

extension $SwaggerAuthInputCopyWith on SwaggerAuthInput {
  /// Returns a callable class that can be used as follows: `instanceOfSwaggerAuthInput.copyWith(...)` or like so:`instanceOfSwaggerAuthInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SwaggerAuthInputCWProxy get copyWith => _$SwaggerAuthInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwaggerAuthInput _$SwaggerAuthInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SwaggerAuthInput', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['kind']);
      final val = SwaggerAuthInput(
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$ApiAuthKindEnumMap, v),
        ),
        name: $checkedConvert('name', (v) => v as String?),
        value: $checkedConvert('value', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$SwaggerAuthInputToJson(SwaggerAuthInput instance) =>
    <String, dynamic>{
      'kind': _$ApiAuthKindEnumMap[instance.kind]!,
      'name': ?instance.name,
      'value': ?instance.value,
    };

const _$ApiAuthKindEnumMap = {
  ApiAuthKind.none: 'none',
  ApiAuthKind.bearer: 'bearer',
  ApiAuthKind.header: 'header',
  ApiAuthKind.query: 'query',
  ApiAuthKind.basic: 'basic',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swagger_rerun_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SwaggerRerunInputCWProxy {
  SwaggerRerunInput token(String? token);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerRerunInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerRerunInput(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerRerunInput call({String? token});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSwaggerRerunInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSwaggerRerunInput.copyWith.fieldName(...)`
class _$SwaggerRerunInputCWProxyImpl implements _$SwaggerRerunInputCWProxy {
  const _$SwaggerRerunInputCWProxyImpl(this._value);

  final SwaggerRerunInput _value;

  @override
  SwaggerRerunInput token(String? token) => this(token: token);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerRerunInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerRerunInput(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerRerunInput call({Object? token = const $CopyWithPlaceholder()}) {
    return SwaggerRerunInput(
      token: token == const $CopyWithPlaceholder()
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String?,
    );
  }
}

extension $SwaggerRerunInputCopyWith on SwaggerRerunInput {
  /// Returns a callable class that can be used as follows: `instanceOfSwaggerRerunInput.copyWith(...)` or like so:`instanceOfSwaggerRerunInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SwaggerRerunInputCWProxy get copyWith =>
      _$SwaggerRerunInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwaggerRerunInput _$SwaggerRerunInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SwaggerRerunInput', json, ($checkedConvert) {
      final val = SwaggerRerunInput(
        token: $checkedConvert('token', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$SwaggerRerunInputToJson(SwaggerRerunInput instance) =>
    <String, dynamic>{'token': ?instance.token};

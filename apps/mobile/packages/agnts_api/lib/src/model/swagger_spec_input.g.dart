// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swagger_spec_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SwaggerSpecInputCWProxy {
  SwaggerSpecInput url(String? url);

  SwaggerSpecInput spec(String? spec);

  SwaggerSpecInput auth(SwaggerAuthInput? auth);

  SwaggerSpecInput login(SwaggerSpecInputLogin? login);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerSpecInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerSpecInput(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerSpecInput call({
    String? url,
    String? spec,
    SwaggerAuthInput? auth,
    SwaggerSpecInputLogin? login,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSwaggerSpecInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSwaggerSpecInput.copyWith.fieldName(...)`
class _$SwaggerSpecInputCWProxyImpl implements _$SwaggerSpecInputCWProxy {
  const _$SwaggerSpecInputCWProxyImpl(this._value);

  final SwaggerSpecInput _value;

  @override
  SwaggerSpecInput url(String? url) => this(url: url);

  @override
  SwaggerSpecInput spec(String? spec) => this(spec: spec);

  @override
  SwaggerSpecInput auth(SwaggerAuthInput? auth) => this(auth: auth);

  @override
  SwaggerSpecInput login(SwaggerSpecInputLogin? login) => this(login: login);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerSpecInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerSpecInput(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerSpecInput call({
    Object? url = const $CopyWithPlaceholder(),
    Object? spec = const $CopyWithPlaceholder(),
    Object? auth = const $CopyWithPlaceholder(),
    Object? login = const $CopyWithPlaceholder(),
  }) {
    return SwaggerSpecInput(
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String?,
      spec: spec == const $CopyWithPlaceholder()
          ? _value.spec
          // ignore: cast_nullable_to_non_nullable
          : spec as String?,
      auth: auth == const $CopyWithPlaceholder()
          ? _value.auth
          // ignore: cast_nullable_to_non_nullable
          : auth as SwaggerAuthInput?,
      login: login == const $CopyWithPlaceholder()
          ? _value.login
          // ignore: cast_nullable_to_non_nullable
          : login as SwaggerSpecInputLogin?,
    );
  }
}

extension $SwaggerSpecInputCopyWith on SwaggerSpecInput {
  /// Returns a callable class that can be used as follows: `instanceOfSwaggerSpecInput.copyWith(...)` or like so:`instanceOfSwaggerSpecInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SwaggerSpecInputCWProxy get copyWith => _$SwaggerSpecInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwaggerSpecInput _$SwaggerSpecInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SwaggerSpecInput', json, ($checkedConvert) {
      final val = SwaggerSpecInput(
        url: $checkedConvert('url', (v) => v as String?),
        spec: $checkedConvert('spec', (v) => v as String?),
        auth: $checkedConvert(
          'auth',
          (v) => v == null
              ? null
              : SwaggerAuthInput.fromJson(v as Map<String, dynamic>),
        ),
        login: $checkedConvert(
          'login',
          (v) => v == null
              ? null
              : SwaggerSpecInputLogin.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SwaggerSpecInputToJson(SwaggerSpecInput instance) =>
    <String, dynamic>{
      'url': ?instance.url,
      'spec': ?instance.spec,
      'auth': ?instance.auth?.toJson(),
      'login': ?instance.login?.toJson(),
    };

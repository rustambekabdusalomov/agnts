// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swagger_server.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SwaggerServerCWProxy {
  SwaggerServer url(String url);

  SwaggerServer description(String? description);

  SwaggerServer variables(List<SwaggerServerVariablesInner>? variables);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerServer(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerServer(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerServer call({
    String url,
    String? description,
    List<SwaggerServerVariablesInner>? variables,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSwaggerServer.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSwaggerServer.copyWith.fieldName(...)`
class _$SwaggerServerCWProxyImpl implements _$SwaggerServerCWProxy {
  const _$SwaggerServerCWProxyImpl(this._value);

  final SwaggerServer _value;

  @override
  SwaggerServer url(String url) => this(url: url);

  @override
  SwaggerServer description(String? description) =>
      this(description: description);

  @override
  SwaggerServer variables(List<SwaggerServerVariablesInner>? variables) =>
      this(variables: variables);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerServer(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerServer(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerServer call({
    Object? url = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? variables = const $CopyWithPlaceholder(),
  }) {
    return SwaggerServer(
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      variables: variables == const $CopyWithPlaceholder()
          ? _value.variables
          // ignore: cast_nullable_to_non_nullable
          : variables as List<SwaggerServerVariablesInner>?,
    );
  }
}

extension $SwaggerServerCopyWith on SwaggerServer {
  /// Returns a callable class that can be used as follows: `instanceOfSwaggerServer.copyWith(...)` or like so:`instanceOfSwaggerServer.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SwaggerServerCWProxy get copyWith => _$SwaggerServerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwaggerServer _$SwaggerServerFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SwaggerServer', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['url']);
      final val = SwaggerServer(
        url: $checkedConvert('url', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String?),
        variables: $checkedConvert(
          'variables',
          (v) => (v as List<dynamic>?)
              ?.map(
                (e) => SwaggerServerVariablesInner.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SwaggerServerToJson(SwaggerServer instance) =>
    <String, dynamic>{
      'url': instance.url,
      'description': ?instance.description,
      'variables': ?instance.variables?.map((e) => e.toJson()).toList(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swagger_spec.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SwaggerSpecCWProxy {
  SwaggerSpec specRef(String? specRef);

  SwaggerSpec url(String? url);

  SwaggerSpec title(String? title);

  SwaggerSpec version(String? version);

  SwaggerSpec format(String? format);

  SwaggerSpec servers(List<SwaggerServer> servers);

  SwaggerSpec operations(List<SwaggerOperation> operations);

  SwaggerSpec securitySchemes(List<SwaggerSecurityScheme> securitySchemes);

  SwaggerSpec choices(List<SwaggerSpecChoicesInner> choices);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerSpec(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerSpec(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerSpec call({
    String? specRef,
    String? url,
    String? title,
    String? version,
    String? format,
    List<SwaggerServer> servers,
    List<SwaggerOperation> operations,
    List<SwaggerSecurityScheme> securitySchemes,
    List<SwaggerSpecChoicesInner> choices,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSwaggerSpec.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSwaggerSpec.copyWith.fieldName(...)`
class _$SwaggerSpecCWProxyImpl implements _$SwaggerSpecCWProxy {
  const _$SwaggerSpecCWProxyImpl(this._value);

  final SwaggerSpec _value;

  @override
  SwaggerSpec specRef(String? specRef) => this(specRef: specRef);

  @override
  SwaggerSpec url(String? url) => this(url: url);

  @override
  SwaggerSpec title(String? title) => this(title: title);

  @override
  SwaggerSpec version(String? version) => this(version: version);

  @override
  SwaggerSpec format(String? format) => this(format: format);

  @override
  SwaggerSpec servers(List<SwaggerServer> servers) => this(servers: servers);

  @override
  SwaggerSpec operations(List<SwaggerOperation> operations) =>
      this(operations: operations);

  @override
  SwaggerSpec securitySchemes(List<SwaggerSecurityScheme> securitySchemes) =>
      this(securitySchemes: securitySchemes);

  @override
  SwaggerSpec choices(List<SwaggerSpecChoicesInner> choices) =>
      this(choices: choices);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerSpec(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerSpec(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerSpec call({
    Object? specRef = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? format = const $CopyWithPlaceholder(),
    Object? servers = const $CopyWithPlaceholder(),
    Object? operations = const $CopyWithPlaceholder(),
    Object? securitySchemes = const $CopyWithPlaceholder(),
    Object? choices = const $CopyWithPlaceholder(),
  }) {
    return SwaggerSpec(
      specRef: specRef == const $CopyWithPlaceholder()
          ? _value.specRef
          // ignore: cast_nullable_to_non_nullable
          : specRef as String?,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as String?,
      format: format == const $CopyWithPlaceholder()
          ? _value.format
          // ignore: cast_nullable_to_non_nullable
          : format as String?,
      servers: servers == const $CopyWithPlaceholder()
          ? _value.servers
          // ignore: cast_nullable_to_non_nullable
          : servers as List<SwaggerServer>,
      operations: operations == const $CopyWithPlaceholder()
          ? _value.operations
          // ignore: cast_nullable_to_non_nullable
          : operations as List<SwaggerOperation>,
      securitySchemes: securitySchemes == const $CopyWithPlaceholder()
          ? _value.securitySchemes
          // ignore: cast_nullable_to_non_nullable
          : securitySchemes as List<SwaggerSecurityScheme>,
      choices: choices == const $CopyWithPlaceholder()
          ? _value.choices
          // ignore: cast_nullable_to_non_nullable
          : choices as List<SwaggerSpecChoicesInner>,
    );
  }
}

extension $SwaggerSpecCopyWith on SwaggerSpec {
  /// Returns a callable class that can be used as follows: `instanceOfSwaggerSpec.copyWith(...)` or like so:`instanceOfSwaggerSpec.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SwaggerSpecCWProxy get copyWith => _$SwaggerSpecCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwaggerSpec _$SwaggerSpecFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SwaggerSpec', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['servers', 'operations', 'securitySchemes', 'choices'],
  );
  final val = SwaggerSpec(
    specRef: $checkedConvert('specRef', (v) => v as String?),
    url: $checkedConvert('url', (v) => v as String?),
    title: $checkedConvert('title', (v) => v as String?),
    version: $checkedConvert('version', (v) => v as String?),
    format: $checkedConvert('format', (v) => v as String?),
    servers: $checkedConvert(
      'servers',
      (v) => (v as List<dynamic>)
          .map((e) => SwaggerServer.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    operations: $checkedConvert(
      'operations',
      (v) => (v as List<dynamic>)
          .map((e) => SwaggerOperation.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    securitySchemes: $checkedConvert(
      'securitySchemes',
      (v) => (v as List<dynamic>)
          .map((e) => SwaggerSecurityScheme.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    choices: $checkedConvert(
      'choices',
      (v) => (v as List<dynamic>)
          .map(
            (e) => SwaggerSpecChoicesInner.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$SwaggerSpecToJson(
  SwaggerSpec instance,
) => <String, dynamic>{
  'specRef': ?instance.specRef,
  'url': ?instance.url,
  'title': ?instance.title,
  'version': ?instance.version,
  'format': ?instance.format,
  'servers': instance.servers.map((e) => e.toJson()).toList(),
  'operations': instance.operations.map((e) => e.toJson()).toList(),
  'securitySchemes': instance.securitySchemes.map((e) => e.toJson()).toList(),
  'choices': instance.choices.map((e) => e.toJson()).toList(),
};

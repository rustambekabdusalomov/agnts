// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swagger_operation.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SwaggerOperationCWProxy {
  SwaggerOperation method(String method);

  SwaggerOperation path(String path);

  SwaggerOperation operationId(String? operationId);

  SwaggerOperation summary(String? summary);

  SwaggerOperation tags(List<String>? tags);

  SwaggerOperation deprecated(bool? deprecated);

  SwaggerOperation sideEffect(String? sideEffect);

  SwaggerOperation security(List<String>? security);

  SwaggerOperation default_(bool default_);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerOperation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerOperation(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerOperation call({
    String method,
    String path,
    String? operationId,
    String? summary,
    List<String>? tags,
    bool? deprecated,
    String? sideEffect,
    List<String>? security,
    bool default_,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSwaggerOperation.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSwaggerOperation.copyWith.fieldName(...)`
class _$SwaggerOperationCWProxyImpl implements _$SwaggerOperationCWProxy {
  const _$SwaggerOperationCWProxyImpl(this._value);

  final SwaggerOperation _value;

  @override
  SwaggerOperation method(String method) => this(method: method);

  @override
  SwaggerOperation path(String path) => this(path: path);

  @override
  SwaggerOperation operationId(String? operationId) =>
      this(operationId: operationId);

  @override
  SwaggerOperation summary(String? summary) => this(summary: summary);

  @override
  SwaggerOperation tags(List<String>? tags) => this(tags: tags);

  @override
  SwaggerOperation deprecated(bool? deprecated) => this(deprecated: deprecated);

  @override
  SwaggerOperation sideEffect(String? sideEffect) =>
      this(sideEffect: sideEffect);

  @override
  SwaggerOperation security(List<String>? security) => this(security: security);

  @override
  SwaggerOperation default_(bool default_) => this(default_: default_);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerOperation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerOperation(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerOperation call({
    Object? method = const $CopyWithPlaceholder(),
    Object? path = const $CopyWithPlaceholder(),
    Object? operationId = const $CopyWithPlaceholder(),
    Object? summary = const $CopyWithPlaceholder(),
    Object? tags = const $CopyWithPlaceholder(),
    Object? deprecated = const $CopyWithPlaceholder(),
    Object? sideEffect = const $CopyWithPlaceholder(),
    Object? security = const $CopyWithPlaceholder(),
    Object? default_ = const $CopyWithPlaceholder(),
  }) {
    return SwaggerOperation(
      method: method == const $CopyWithPlaceholder()
          ? _value.method
          // ignore: cast_nullable_to_non_nullable
          : method as String,
      path: path == const $CopyWithPlaceholder()
          ? _value.path
          // ignore: cast_nullable_to_non_nullable
          : path as String,
      operationId: operationId == const $CopyWithPlaceholder()
          ? _value.operationId
          // ignore: cast_nullable_to_non_nullable
          : operationId as String?,
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as String?,
      tags: tags == const $CopyWithPlaceholder()
          ? _value.tags
          // ignore: cast_nullable_to_non_nullable
          : tags as List<String>?,
      deprecated: deprecated == const $CopyWithPlaceholder()
          ? _value.deprecated
          // ignore: cast_nullable_to_non_nullable
          : deprecated as bool?,
      sideEffect: sideEffect == const $CopyWithPlaceholder()
          ? _value.sideEffect
          // ignore: cast_nullable_to_non_nullable
          : sideEffect as String?,
      security: security == const $CopyWithPlaceholder()
          ? _value.security
          // ignore: cast_nullable_to_non_nullable
          : security as List<String>?,
      default_: default_ == const $CopyWithPlaceholder()
          ? _value.default_
          // ignore: cast_nullable_to_non_nullable
          : default_ as bool,
    );
  }
}

extension $SwaggerOperationCopyWith on SwaggerOperation {
  /// Returns a callable class that can be used as follows: `instanceOfSwaggerOperation.copyWith(...)` or like so:`instanceOfSwaggerOperation.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SwaggerOperationCWProxy get copyWith => _$SwaggerOperationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwaggerOperation _$SwaggerOperationFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SwaggerOperation', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['method', 'path', 'default']);
      final val = SwaggerOperation(
        method: $checkedConvert('method', (v) => v as String),
        path: $checkedConvert('path', (v) => v as String),
        operationId: $checkedConvert('operationId', (v) => v as String?),
        summary: $checkedConvert('summary', (v) => v as String?),
        tags: $checkedConvert(
          'tags',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        deprecated: $checkedConvert('deprecated', (v) => v as bool?),
        sideEffect: $checkedConvert('sideEffect', (v) => v as String?),
        security: $checkedConvert(
          'security',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        default_: $checkedConvert('default', (v) => v as bool),
      );
      return val;
    }, fieldKeyMap: const {'default_': 'default'});

Map<String, dynamic> _$SwaggerOperationToJson(SwaggerOperation instance) =>
    <String, dynamic>{
      'method': instance.method,
      'path': instance.path,
      'operationId': ?instance.operationId,
      'summary': ?instance.summary,
      'tags': ?instance.tags,
      'deprecated': ?instance.deprecated,
      'sideEffect': ?instance.sideEffect,
      'security': ?instance.security,
      'default': instance.default_,
    };

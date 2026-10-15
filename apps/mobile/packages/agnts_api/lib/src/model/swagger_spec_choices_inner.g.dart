// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swagger_spec_choices_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SwaggerSpecChoicesInnerCWProxy {
  SwaggerSpecChoicesInner name(String? name);

  SwaggerSpecChoicesInner url(String url);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerSpecChoicesInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerSpecChoicesInner(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerSpecChoicesInner call({String? name, String url});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSwaggerSpecChoicesInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSwaggerSpecChoicesInner.copyWith.fieldName(...)`
class _$SwaggerSpecChoicesInnerCWProxyImpl
    implements _$SwaggerSpecChoicesInnerCWProxy {
  const _$SwaggerSpecChoicesInnerCWProxyImpl(this._value);

  final SwaggerSpecChoicesInner _value;

  @override
  SwaggerSpecChoicesInner name(String? name) => this(name: name);

  @override
  SwaggerSpecChoicesInner url(String url) => this(url: url);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerSpecChoicesInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerSpecChoicesInner(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerSpecChoicesInner call({
    Object? name = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
  }) {
    return SwaggerSpecChoicesInner(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
    );
  }
}

extension $SwaggerSpecChoicesInnerCopyWith on SwaggerSpecChoicesInner {
  /// Returns a callable class that can be used as follows: `instanceOfSwaggerSpecChoicesInner.copyWith(...)` or like so:`instanceOfSwaggerSpecChoicesInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SwaggerSpecChoicesInnerCWProxy get copyWith =>
      _$SwaggerSpecChoicesInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwaggerSpecChoicesInner _$SwaggerSpecChoicesInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SwaggerSpecChoicesInner', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['url']);
  final val = SwaggerSpecChoicesInner(
    name: $checkedConvert('name', (v) => v as String?),
    url: $checkedConvert('url', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$SwaggerSpecChoicesInnerToJson(
  SwaggerSpecChoicesInner instance,
) => <String, dynamic>{'name': ?instance.name, 'url': instance.url};

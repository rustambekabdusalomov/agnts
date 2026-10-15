// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rotate_swagger_suite_hook200_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RotateSwaggerSuiteHook200ResponseCWProxy {
  RotateSwaggerSuiteHook200Response url(String url);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RotateSwaggerSuiteHook200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RotateSwaggerSuiteHook200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  RotateSwaggerSuiteHook200Response call({String url});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRotateSwaggerSuiteHook200Response.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRotateSwaggerSuiteHook200Response.copyWith.fieldName(...)`
class _$RotateSwaggerSuiteHook200ResponseCWProxyImpl
    implements _$RotateSwaggerSuiteHook200ResponseCWProxy {
  const _$RotateSwaggerSuiteHook200ResponseCWProxyImpl(this._value);

  final RotateSwaggerSuiteHook200Response _value;

  @override
  RotateSwaggerSuiteHook200Response url(String url) => this(url: url);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RotateSwaggerSuiteHook200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RotateSwaggerSuiteHook200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  RotateSwaggerSuiteHook200Response call({
    Object? url = const $CopyWithPlaceholder(),
  }) {
    return RotateSwaggerSuiteHook200Response(
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
    );
  }
}

extension $RotateSwaggerSuiteHook200ResponseCopyWith
    on RotateSwaggerSuiteHook200Response {
  /// Returns a callable class that can be used as follows: `instanceOfRotateSwaggerSuiteHook200Response.copyWith(...)` or like so:`instanceOfRotateSwaggerSuiteHook200Response.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RotateSwaggerSuiteHook200ResponseCWProxy get copyWith =>
      _$RotateSwaggerSuiteHook200ResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RotateSwaggerSuiteHook200Response _$RotateSwaggerSuiteHook200ResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RotateSwaggerSuiteHook200Response', json, (
  $checkedConvert,
) {
  $checkKeys(json, requiredKeys: const ['url']);
  final val = RotateSwaggerSuiteHook200Response(
    url: $checkedConvert('url', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$RotateSwaggerSuiteHook200ResponseToJson(
  RotateSwaggerSuiteHook200Response instance,
) => <String, dynamic>{'url': instance.url};

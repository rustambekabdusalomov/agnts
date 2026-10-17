// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_platform_run_prompt200_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GetPlatformRunPrompt200ResponseCWProxy {
  GetPlatformRunPrompt200Response prompt(String prompt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GetPlatformRunPrompt200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GetPlatformRunPrompt200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  GetPlatformRunPrompt200Response call({String prompt});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGetPlatformRunPrompt200Response.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGetPlatformRunPrompt200Response.copyWith.fieldName(...)`
class _$GetPlatformRunPrompt200ResponseCWProxyImpl
    implements _$GetPlatformRunPrompt200ResponseCWProxy {
  const _$GetPlatformRunPrompt200ResponseCWProxyImpl(this._value);

  final GetPlatformRunPrompt200Response _value;

  @override
  GetPlatformRunPrompt200Response prompt(String prompt) => this(prompt: prompt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GetPlatformRunPrompt200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GetPlatformRunPrompt200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  GetPlatformRunPrompt200Response call({
    Object? prompt = const $CopyWithPlaceholder(),
  }) {
    return GetPlatformRunPrompt200Response(
      prompt: prompt == const $CopyWithPlaceholder()
          ? _value.prompt
          // ignore: cast_nullable_to_non_nullable
          : prompt as String,
    );
  }
}

extension $GetPlatformRunPrompt200ResponseCopyWith
    on GetPlatformRunPrompt200Response {
  /// Returns a callable class that can be used as follows: `instanceOfGetPlatformRunPrompt200Response.copyWith(...)` or like so:`instanceOfGetPlatformRunPrompt200Response.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GetPlatformRunPrompt200ResponseCWProxy get copyWith =>
      _$GetPlatformRunPrompt200ResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetPlatformRunPrompt200Response _$GetPlatformRunPrompt200ResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('GetPlatformRunPrompt200Response', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['prompt']);
  final val = GetPlatformRunPrompt200Response(
    prompt: $checkedConvert('prompt', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$GetPlatformRunPrompt200ResponseToJson(
  GetPlatformRunPrompt200Response instance,
) => <String, dynamic>{'prompt': instance.prompt};

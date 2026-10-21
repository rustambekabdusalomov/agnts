// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_brief_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RepoBriefInputCWProxy {
  RepoBriefInput body(String body);

  RepoBriefInput architecture(String? architecture);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoBriefInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoBriefInput(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoBriefInput call({String body, String? architecture});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRepoBriefInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRepoBriefInput.copyWith.fieldName(...)`
class _$RepoBriefInputCWProxyImpl implements _$RepoBriefInputCWProxy {
  const _$RepoBriefInputCWProxyImpl(this._value);

  final RepoBriefInput _value;

  @override
  RepoBriefInput body(String body) => this(body: body);

  @override
  RepoBriefInput architecture(String? architecture) =>
      this(architecture: architecture);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoBriefInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoBriefInput(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoBriefInput call({
    Object? body = const $CopyWithPlaceholder(),
    Object? architecture = const $CopyWithPlaceholder(),
  }) {
    return RepoBriefInput(
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String,
      architecture: architecture == const $CopyWithPlaceholder()
          ? _value.architecture
          // ignore: cast_nullable_to_non_nullable
          : architecture as String?,
    );
  }
}

extension $RepoBriefInputCopyWith on RepoBriefInput {
  /// Returns a callable class that can be used as follows: `instanceOfRepoBriefInput.copyWith(...)` or like so:`instanceOfRepoBriefInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RepoBriefInputCWProxy get copyWith => _$RepoBriefInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepoBriefInput _$RepoBriefInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RepoBriefInput', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['body']);
      final val = RepoBriefInput(
        body: $checkedConvert('body', (v) => v as String),
        architecture: $checkedConvert('architecture', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$RepoBriefInputToJson(RepoBriefInput instance) =>
    <String, dynamic>{
      'body': instance.body,
      'architecture': ?instance.architecture,
    };

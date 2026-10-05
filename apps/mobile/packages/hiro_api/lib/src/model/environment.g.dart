// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EnvironmentCWProxy {
  Environment name(String name);

  Environment sha(String sha);

  Environment deployedAt(DateTime? deployedAt);

  Environment url(String url);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Environment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Environment(...).copyWith(id: 12, name: "My name")
  /// ````
  Environment call({String name, String sha, DateTime? deployedAt, String url});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEnvironment.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEnvironment.copyWith.fieldName(...)`
class _$EnvironmentCWProxyImpl implements _$EnvironmentCWProxy {
  const _$EnvironmentCWProxyImpl(this._value);

  final Environment _value;

  @override
  Environment name(String name) => this(name: name);

  @override
  Environment sha(String sha) => this(sha: sha);

  @override
  Environment deployedAt(DateTime? deployedAt) => this(deployedAt: deployedAt);

  @override
  Environment url(String url) => this(url: url);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Environment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Environment(...).copyWith(id: 12, name: "My name")
  /// ````
  Environment call({
    Object? name = const $CopyWithPlaceholder(),
    Object? sha = const $CopyWithPlaceholder(),
    Object? deployedAt = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
  }) {
    return Environment(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      sha: sha == const $CopyWithPlaceholder()
          ? _value.sha
          // ignore: cast_nullable_to_non_nullable
          : sha as String,
      deployedAt: deployedAt == const $CopyWithPlaceholder()
          ? _value.deployedAt
          // ignore: cast_nullable_to_non_nullable
          : deployedAt as DateTime?,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
    );
  }
}

extension $EnvironmentCopyWith on Environment {
  /// Returns a callable class that can be used as follows: `instanceOfEnvironment.copyWith(...)` or like so:`instanceOfEnvironment.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EnvironmentCWProxy get copyWith => _$EnvironmentCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Environment _$EnvironmentFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Environment', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['name', 'sha', 'url']);
      final val = Environment(
        name: $checkedConvert('name', (v) => v as String),
        sha: $checkedConvert('sha', (v) => v as String),
        deployedAt: $checkedConvert(
          'deployedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        url: $checkedConvert('url', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$EnvironmentToJson(Environment instance) =>
    <String, dynamic>{
      'name': instance.name,
      'sha': instance.sha,
      'deployedAt': ?instance.deployedAt?.toIso8601String(),
      'url': instance.url,
    };

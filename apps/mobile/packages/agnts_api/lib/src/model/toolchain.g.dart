// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toolchain.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ToolchainCWProxy {
  Toolchain tool(String tool);

  Toolchain version(String version);

  Toolchain source_(String? source_);

  Toolchain dir(String? dir);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Toolchain(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Toolchain(...).copyWith(id: 12, name: "My name")
  /// ````
  Toolchain call({String tool, String version, String? source_, String? dir});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfToolchain.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfToolchain.copyWith.fieldName(...)`
class _$ToolchainCWProxyImpl implements _$ToolchainCWProxy {
  const _$ToolchainCWProxyImpl(this._value);

  final Toolchain _value;

  @override
  Toolchain tool(String tool) => this(tool: tool);

  @override
  Toolchain version(String version) => this(version: version);

  @override
  Toolchain source_(String? source_) => this(source_: source_);

  @override
  Toolchain dir(String? dir) => this(dir: dir);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Toolchain(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Toolchain(...).copyWith(id: 12, name: "My name")
  /// ````
  Toolchain call({
    Object? tool = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
    Object? dir = const $CopyWithPlaceholder(),
  }) {
    return Toolchain(
      tool: tool == const $CopyWithPlaceholder()
          ? _value.tool
          // ignore: cast_nullable_to_non_nullable
          : tool as String,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as String,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as String?,
      dir: dir == const $CopyWithPlaceholder()
          ? _value.dir
          // ignore: cast_nullable_to_non_nullable
          : dir as String?,
    );
  }
}

extension $ToolchainCopyWith on Toolchain {
  /// Returns a callable class that can be used as follows: `instanceOfToolchain.copyWith(...)` or like so:`instanceOfToolchain.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ToolchainCWProxy get copyWith => _$ToolchainCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Toolchain _$ToolchainFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Toolchain', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['tool', 'version']);
      final val = Toolchain(
        tool: $checkedConvert('tool', (v) => v as String),
        version: $checkedConvert('version', (v) => v as String),
        source_: $checkedConvert('source', (v) => v as String?),
        dir: $checkedConvert('dir', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$ToolchainToJson(Toolchain instance) => <String, dynamic>{
  'tool': instance.tool,
  'version': instance.version,
  'source': ?instance.source_,
  'dir': ?instance.dir,
};

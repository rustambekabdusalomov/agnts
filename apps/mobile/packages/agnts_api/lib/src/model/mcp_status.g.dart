// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_status.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$McpStatusCWProxy {
  McpStatus url(String url);

  McpStatus staticToken(bool staticToken);

  McpStatus connections(int connections);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `McpStatus(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// McpStatus(...).copyWith(id: 12, name: "My name")
  /// ````
  McpStatus call({String url, bool staticToken, int connections});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMcpStatus.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMcpStatus.copyWith.fieldName(...)`
class _$McpStatusCWProxyImpl implements _$McpStatusCWProxy {
  const _$McpStatusCWProxyImpl(this._value);

  final McpStatus _value;

  @override
  McpStatus url(String url) => this(url: url);

  @override
  McpStatus staticToken(bool staticToken) => this(staticToken: staticToken);

  @override
  McpStatus connections(int connections) => this(connections: connections);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `McpStatus(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// McpStatus(...).copyWith(id: 12, name: "My name")
  /// ````
  McpStatus call({
    Object? url = const $CopyWithPlaceholder(),
    Object? staticToken = const $CopyWithPlaceholder(),
    Object? connections = const $CopyWithPlaceholder(),
  }) {
    return McpStatus(
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      staticToken: staticToken == const $CopyWithPlaceholder()
          ? _value.staticToken
          // ignore: cast_nullable_to_non_nullable
          : staticToken as bool,
      connections: connections == const $CopyWithPlaceholder()
          ? _value.connections
          // ignore: cast_nullable_to_non_nullable
          : connections as int,
    );
  }
}

extension $McpStatusCopyWith on McpStatus {
  /// Returns a callable class that can be used as follows: `instanceOfMcpStatus.copyWith(...)` or like so:`instanceOfMcpStatus.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$McpStatusCWProxy get copyWith => _$McpStatusCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

McpStatus _$McpStatusFromJson(Map<String, dynamic> json) => $checkedCreate(
  'McpStatus',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['url', 'staticToken', 'connections']);
    final val = McpStatus(
      url: $checkedConvert('url', (v) => v as String),
      staticToken: $checkedConvert('staticToken', (v) => v as bool),
      connections: $checkedConvert('connections', (v) => (v as num).toInt()),
    );
    return val;
  },
);

Map<String, dynamic> _$McpStatusToJson(McpStatus instance) => <String, dynamic>{
  'url': instance.url,
  'staticToken': instance.staticToken,
  'connections': instance.connections,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sec_tool_run.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SecToolRunCWProxy {
  SecToolRun tool(String tool);

  SecToolRun status(SecToolRunStatusEnum status);

  SecToolRun seconds(int seconds);

  SecToolRun hits(int hits);

  SecToolRun error(String? error);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SecToolRun(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SecToolRun(...).copyWith(id: 12, name: "My name")
  /// ````
  SecToolRun call({
    String tool,
    SecToolRunStatusEnum status,
    int seconds,
    int hits,
    String? error,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSecToolRun.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSecToolRun.copyWith.fieldName(...)`
class _$SecToolRunCWProxyImpl implements _$SecToolRunCWProxy {
  const _$SecToolRunCWProxyImpl(this._value);

  final SecToolRun _value;

  @override
  SecToolRun tool(String tool) => this(tool: tool);

  @override
  SecToolRun status(SecToolRunStatusEnum status) => this(status: status);

  @override
  SecToolRun seconds(int seconds) => this(seconds: seconds);

  @override
  SecToolRun hits(int hits) => this(hits: hits);

  @override
  SecToolRun error(String? error) => this(error: error);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SecToolRun(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SecToolRun(...).copyWith(id: 12, name: "My name")
  /// ````
  SecToolRun call({
    Object? tool = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? seconds = const $CopyWithPlaceholder(),
    Object? hits = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
  }) {
    return SecToolRun(
      tool: tool == const $CopyWithPlaceholder()
          ? _value.tool
          // ignore: cast_nullable_to_non_nullable
          : tool as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as SecToolRunStatusEnum,
      seconds: seconds == const $CopyWithPlaceholder()
          ? _value.seconds
          // ignore: cast_nullable_to_non_nullable
          : seconds as int,
      hits: hits == const $CopyWithPlaceholder()
          ? _value.hits
          // ignore: cast_nullable_to_non_nullable
          : hits as int,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String?,
    );
  }
}

extension $SecToolRunCopyWith on SecToolRun {
  /// Returns a callable class that can be used as follows: `instanceOfSecToolRun.copyWith(...)` or like so:`instanceOfSecToolRun.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SecToolRunCWProxy get copyWith => _$SecToolRunCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SecToolRun _$SecToolRunFromJson(Map<String, dynamic> json) => $checkedCreate(
  'SecToolRun',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['tool', 'status', 'seconds', 'hits']);
    final val = SecToolRun(
      tool: $checkedConvert('tool', (v) => v as String),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$SecToolRunStatusEnumEnumMap, v),
      ),
      seconds: $checkedConvert('seconds', (v) => (v as num).toInt()),
      hits: $checkedConvert('hits', (v) => (v as num).toInt()),
      error: $checkedConvert('error', (v) => v as String?),
    );
    return val;
  },
);

Map<String, dynamic> _$SecToolRunToJson(SecToolRun instance) =>
    <String, dynamic>{
      'tool': instance.tool,
      'status': _$SecToolRunStatusEnumEnumMap[instance.status]!,
      'seconds': instance.seconds,
      'hits': instance.hits,
      'error': ?instance.error,
    };

const _$SecToolRunStatusEnumEnumMap = {
  SecToolRunStatusEnum.ok: 'ok',
  SecToolRunStatusEnum.failed: 'failed',
  SecToolRunStatusEnum.timeout: 'timeout',
  SecToolRunStatusEnum.skipped: 'skipped',
};

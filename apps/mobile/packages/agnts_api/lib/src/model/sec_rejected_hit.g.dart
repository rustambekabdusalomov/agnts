// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sec_rejected_hit.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SecRejectedHitCWProxy {
  SecRejectedHit hit(String hit);

  SecRejectedHit tool(String? tool);

  SecRejectedHit rule(String? rule);

  SecRejectedHit file(String? file);

  SecRejectedHit line(int? line);

  SecRejectedHit reason(String reason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SecRejectedHit(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SecRejectedHit(...).copyWith(id: 12, name: "My name")
  /// ````
  SecRejectedHit call({
    String hit,
    String? tool,
    String? rule,
    String? file,
    int? line,
    String reason,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSecRejectedHit.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSecRejectedHit.copyWith.fieldName(...)`
class _$SecRejectedHitCWProxyImpl implements _$SecRejectedHitCWProxy {
  const _$SecRejectedHitCWProxyImpl(this._value);

  final SecRejectedHit _value;

  @override
  SecRejectedHit hit(String hit) => this(hit: hit);

  @override
  SecRejectedHit tool(String? tool) => this(tool: tool);

  @override
  SecRejectedHit rule(String? rule) => this(rule: rule);

  @override
  SecRejectedHit file(String? file) => this(file: file);

  @override
  SecRejectedHit line(int? line) => this(line: line);

  @override
  SecRejectedHit reason(String reason) => this(reason: reason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SecRejectedHit(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SecRejectedHit(...).copyWith(id: 12, name: "My name")
  /// ````
  SecRejectedHit call({
    Object? hit = const $CopyWithPlaceholder(),
    Object? tool = const $CopyWithPlaceholder(),
    Object? rule = const $CopyWithPlaceholder(),
    Object? file = const $CopyWithPlaceholder(),
    Object? line = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
  }) {
    return SecRejectedHit(
      hit: hit == const $CopyWithPlaceholder()
          ? _value.hit
          // ignore: cast_nullable_to_non_nullable
          : hit as String,
      tool: tool == const $CopyWithPlaceholder()
          ? _value.tool
          // ignore: cast_nullable_to_non_nullable
          : tool as String?,
      rule: rule == const $CopyWithPlaceholder()
          ? _value.rule
          // ignore: cast_nullable_to_non_nullable
          : rule as String?,
      file: file == const $CopyWithPlaceholder()
          ? _value.file
          // ignore: cast_nullable_to_non_nullable
          : file as String?,
      line: line == const $CopyWithPlaceholder()
          ? _value.line
          // ignore: cast_nullable_to_non_nullable
          : line as int?,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
    );
  }
}

extension $SecRejectedHitCopyWith on SecRejectedHit {
  /// Returns a callable class that can be used as follows: `instanceOfSecRejectedHit.copyWith(...)` or like so:`instanceOfSecRejectedHit.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SecRejectedHitCWProxy get copyWith => _$SecRejectedHitCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SecRejectedHit _$SecRejectedHitFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SecRejectedHit', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['hit', 'reason']);
      final val = SecRejectedHit(
        hit: $checkedConvert('hit', (v) => v as String),
        tool: $checkedConvert('tool', (v) => v as String?),
        rule: $checkedConvert('rule', (v) => v as String?),
        file: $checkedConvert('file', (v) => v as String?),
        line: $checkedConvert('line', (v) => (v as num?)?.toInt()),
        reason: $checkedConvert('reason', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$SecRejectedHitToJson(SecRejectedHit instance) =>
    <String, dynamic>{
      'hit': instance.hit,
      'tool': ?instance.tool,
      'rule': ?instance.rule,
      'file': ?instance.file,
      'line': ?instance.line,
      'reason': instance.reason,
    };

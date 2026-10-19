// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_stats_versions_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantStatsVersionsInnerCWProxy {
  AssistantStatsVersionsInner promptVersion(String promptVersion);

  AssistantStatsVersionsInner answered(int answered);

  AssistantStatsVersionsInner failed(int failed);

  AssistantStatsVersionsInner up(int up);

  AssistantStatsVersionsInner down(int down);

  AssistantStatsVersionsInner medianMs(int medianMs);

  AssistantStatsVersionsInner tokens(int tokens);

  AssistantStatsVersionsInner proposed(int proposed);

  AssistantStatsVersionsInner done(int done);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantStatsVersionsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantStatsVersionsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantStatsVersionsInner call({
    String promptVersion,
    int answered,
    int failed,
    int up,
    int down,
    int medianMs,
    int tokens,
    int proposed,
    int done,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantStatsVersionsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantStatsVersionsInner.copyWith.fieldName(...)`
class _$AssistantStatsVersionsInnerCWProxyImpl
    implements _$AssistantStatsVersionsInnerCWProxy {
  const _$AssistantStatsVersionsInnerCWProxyImpl(this._value);

  final AssistantStatsVersionsInner _value;

  @override
  AssistantStatsVersionsInner promptVersion(String promptVersion) =>
      this(promptVersion: promptVersion);

  @override
  AssistantStatsVersionsInner answered(int answered) =>
      this(answered: answered);

  @override
  AssistantStatsVersionsInner failed(int failed) => this(failed: failed);

  @override
  AssistantStatsVersionsInner up(int up) => this(up: up);

  @override
  AssistantStatsVersionsInner down(int down) => this(down: down);

  @override
  AssistantStatsVersionsInner medianMs(int medianMs) =>
      this(medianMs: medianMs);

  @override
  AssistantStatsVersionsInner tokens(int tokens) => this(tokens: tokens);

  @override
  AssistantStatsVersionsInner proposed(int proposed) =>
      this(proposed: proposed);

  @override
  AssistantStatsVersionsInner done(int done) => this(done: done);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantStatsVersionsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantStatsVersionsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantStatsVersionsInner call({
    Object? promptVersion = const $CopyWithPlaceholder(),
    Object? answered = const $CopyWithPlaceholder(),
    Object? failed = const $CopyWithPlaceholder(),
    Object? up = const $CopyWithPlaceholder(),
    Object? down = const $CopyWithPlaceholder(),
    Object? medianMs = const $CopyWithPlaceholder(),
    Object? tokens = const $CopyWithPlaceholder(),
    Object? proposed = const $CopyWithPlaceholder(),
    Object? done = const $CopyWithPlaceholder(),
  }) {
    return AssistantStatsVersionsInner(
      promptVersion: promptVersion == const $CopyWithPlaceholder()
          ? _value.promptVersion
          // ignore: cast_nullable_to_non_nullable
          : promptVersion as String,
      answered: answered == const $CopyWithPlaceholder()
          ? _value.answered
          // ignore: cast_nullable_to_non_nullable
          : answered as int,
      failed: failed == const $CopyWithPlaceholder()
          ? _value.failed
          // ignore: cast_nullable_to_non_nullable
          : failed as int,
      up: up == const $CopyWithPlaceholder()
          ? _value.up
          // ignore: cast_nullable_to_non_nullable
          : up as int,
      down: down == const $CopyWithPlaceholder()
          ? _value.down
          // ignore: cast_nullable_to_non_nullable
          : down as int,
      medianMs: medianMs == const $CopyWithPlaceholder()
          ? _value.medianMs
          // ignore: cast_nullable_to_non_nullable
          : medianMs as int,
      tokens: tokens == const $CopyWithPlaceholder()
          ? _value.tokens
          // ignore: cast_nullable_to_non_nullable
          : tokens as int,
      proposed: proposed == const $CopyWithPlaceholder()
          ? _value.proposed
          // ignore: cast_nullable_to_non_nullable
          : proposed as int,
      done: done == const $CopyWithPlaceholder()
          ? _value.done
          // ignore: cast_nullable_to_non_nullable
          : done as int,
    );
  }
}

extension $AssistantStatsVersionsInnerCopyWith on AssistantStatsVersionsInner {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantStatsVersionsInner.copyWith(...)` or like so:`instanceOfAssistantStatsVersionsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantStatsVersionsInnerCWProxy get copyWith =>
      _$AssistantStatsVersionsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantStatsVersionsInner _$AssistantStatsVersionsInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssistantStatsVersionsInner', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'promptVersion',
      'answered',
      'failed',
      'up',
      'down',
      'medianMs',
      'tokens',
      'proposed',
      'done',
    ],
  );
  final val = AssistantStatsVersionsInner(
    promptVersion: $checkedConvert('promptVersion', (v) => v as String),
    answered: $checkedConvert('answered', (v) => (v as num).toInt()),
    failed: $checkedConvert('failed', (v) => (v as num).toInt()),
    up: $checkedConvert('up', (v) => (v as num).toInt()),
    down: $checkedConvert('down', (v) => (v as num).toInt()),
    medianMs: $checkedConvert('medianMs', (v) => (v as num).toInt()),
    tokens: $checkedConvert('tokens', (v) => (v as num).toInt()),
    proposed: $checkedConvert('proposed', (v) => (v as num).toInt()),
    done: $checkedConvert('done', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$AssistantStatsVersionsInnerToJson(
  AssistantStatsVersionsInner instance,
) => <String, dynamic>{
  'promptVersion': instance.promptVersion,
  'answered': instance.answered,
  'failed': instance.failed,
  'up': instance.up,
  'down': instance.down,
  'medianMs': instance.medianMs,
  'tokens': instance.tokens,
  'proposed': instance.proposed,
  'done': instance.done,
};

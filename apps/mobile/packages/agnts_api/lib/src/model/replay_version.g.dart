// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'replay_version.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReplayVersionCWProxy {
  ReplayVersion promptVersion(String promptVersion);

  ReplayVersion replays(int replays);

  ReplayVersion checksPassed(int checksPassed);

  ReplayVersion reviewed(int reviewed);

  ReplayVersion looksGood(int looksGood);

  ReplayVersion avgOverlap(num avgOverlap);

  ReplayVersion avgRecall(num avgRecall);

  ReplayVersion avgTurns(num avgTurns);

  ReplayVersion avgCostUsd(num avgCostUsd);

  ReplayVersion originalTurns(num originalTurns);

  ReplayVersion originalCostUsd(num originalCostUsd);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReplayVersion(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReplayVersion(...).copyWith(id: 12, name: "My name")
  /// ````
  ReplayVersion call({
    String promptVersion,
    int replays,
    int checksPassed,
    int reviewed,
    int looksGood,
    num avgOverlap,
    num avgRecall,
    num avgTurns,
    num avgCostUsd,
    num originalTurns,
    num originalCostUsd,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReplayVersion.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReplayVersion.copyWith.fieldName(...)`
class _$ReplayVersionCWProxyImpl implements _$ReplayVersionCWProxy {
  const _$ReplayVersionCWProxyImpl(this._value);

  final ReplayVersion _value;

  @override
  ReplayVersion promptVersion(String promptVersion) =>
      this(promptVersion: promptVersion);

  @override
  ReplayVersion replays(int replays) => this(replays: replays);

  @override
  ReplayVersion checksPassed(int checksPassed) =>
      this(checksPassed: checksPassed);

  @override
  ReplayVersion reviewed(int reviewed) => this(reviewed: reviewed);

  @override
  ReplayVersion looksGood(int looksGood) => this(looksGood: looksGood);

  @override
  ReplayVersion avgOverlap(num avgOverlap) => this(avgOverlap: avgOverlap);

  @override
  ReplayVersion avgRecall(num avgRecall) => this(avgRecall: avgRecall);

  @override
  ReplayVersion avgTurns(num avgTurns) => this(avgTurns: avgTurns);

  @override
  ReplayVersion avgCostUsd(num avgCostUsd) => this(avgCostUsd: avgCostUsd);

  @override
  ReplayVersion originalTurns(num originalTurns) =>
      this(originalTurns: originalTurns);

  @override
  ReplayVersion originalCostUsd(num originalCostUsd) =>
      this(originalCostUsd: originalCostUsd);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReplayVersion(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReplayVersion(...).copyWith(id: 12, name: "My name")
  /// ````
  ReplayVersion call({
    Object? promptVersion = const $CopyWithPlaceholder(),
    Object? replays = const $CopyWithPlaceholder(),
    Object? checksPassed = const $CopyWithPlaceholder(),
    Object? reviewed = const $CopyWithPlaceholder(),
    Object? looksGood = const $CopyWithPlaceholder(),
    Object? avgOverlap = const $CopyWithPlaceholder(),
    Object? avgRecall = const $CopyWithPlaceholder(),
    Object? avgTurns = const $CopyWithPlaceholder(),
    Object? avgCostUsd = const $CopyWithPlaceholder(),
    Object? originalTurns = const $CopyWithPlaceholder(),
    Object? originalCostUsd = const $CopyWithPlaceholder(),
  }) {
    return ReplayVersion(
      promptVersion: promptVersion == const $CopyWithPlaceholder()
          ? _value.promptVersion
          // ignore: cast_nullable_to_non_nullable
          : promptVersion as String,
      replays: replays == const $CopyWithPlaceholder()
          ? _value.replays
          // ignore: cast_nullable_to_non_nullable
          : replays as int,
      checksPassed: checksPassed == const $CopyWithPlaceholder()
          ? _value.checksPassed
          // ignore: cast_nullable_to_non_nullable
          : checksPassed as int,
      reviewed: reviewed == const $CopyWithPlaceholder()
          ? _value.reviewed
          // ignore: cast_nullable_to_non_nullable
          : reviewed as int,
      looksGood: looksGood == const $CopyWithPlaceholder()
          ? _value.looksGood
          // ignore: cast_nullable_to_non_nullable
          : looksGood as int,
      avgOverlap: avgOverlap == const $CopyWithPlaceholder()
          ? _value.avgOverlap
          // ignore: cast_nullable_to_non_nullable
          : avgOverlap as num,
      avgRecall: avgRecall == const $CopyWithPlaceholder()
          ? _value.avgRecall
          // ignore: cast_nullable_to_non_nullable
          : avgRecall as num,
      avgTurns: avgTurns == const $CopyWithPlaceholder()
          ? _value.avgTurns
          // ignore: cast_nullable_to_non_nullable
          : avgTurns as num,
      avgCostUsd: avgCostUsd == const $CopyWithPlaceholder()
          ? _value.avgCostUsd
          // ignore: cast_nullable_to_non_nullable
          : avgCostUsd as num,
      originalTurns: originalTurns == const $CopyWithPlaceholder()
          ? _value.originalTurns
          // ignore: cast_nullable_to_non_nullable
          : originalTurns as num,
      originalCostUsd: originalCostUsd == const $CopyWithPlaceholder()
          ? _value.originalCostUsd
          // ignore: cast_nullable_to_non_nullable
          : originalCostUsd as num,
    );
  }
}

extension $ReplayVersionCopyWith on ReplayVersion {
  /// Returns a callable class that can be used as follows: `instanceOfReplayVersion.copyWith(...)` or like so:`instanceOfReplayVersion.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReplayVersionCWProxy get copyWith => _$ReplayVersionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReplayVersion _$ReplayVersionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ReplayVersion', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'promptVersion',
          'replays',
          'checksPassed',
          'reviewed',
          'looksGood',
          'avgOverlap',
          'avgRecall',
          'avgTurns',
          'avgCostUsd',
          'originalTurns',
          'originalCostUsd',
        ],
      );
      final val = ReplayVersion(
        promptVersion: $checkedConvert('promptVersion', (v) => v as String),
        replays: $checkedConvert('replays', (v) => (v as num).toInt()),
        checksPassed: $checkedConvert(
          'checksPassed',
          (v) => (v as num).toInt(),
        ),
        reviewed: $checkedConvert('reviewed', (v) => (v as num).toInt()),
        looksGood: $checkedConvert('looksGood', (v) => (v as num).toInt()),
        avgOverlap: $checkedConvert('avgOverlap', (v) => v as num),
        avgRecall: $checkedConvert('avgRecall', (v) => v as num),
        avgTurns: $checkedConvert('avgTurns', (v) => v as num),
        avgCostUsd: $checkedConvert('avgCostUsd', (v) => v as num),
        originalTurns: $checkedConvert('originalTurns', (v) => v as num),
        originalCostUsd: $checkedConvert('originalCostUsd', (v) => v as num),
      );
      return val;
    });

Map<String, dynamic> _$ReplayVersionToJson(ReplayVersion instance) =>
    <String, dynamic>{
      'promptVersion': instance.promptVersion,
      'replays': instance.replays,
      'checksPassed': instance.checksPassed,
      'reviewed': instance.reviewed,
      'looksGood': instance.looksGood,
      'avgOverlap': instance.avgOverlap,
      'avgRecall': instance.avgRecall,
      'avgTurns': instance.avgTurns,
      'avgCostUsd': instance.avgCostUsd,
      'originalTurns': instance.originalTurns,
      'originalCostUsd': instance.originalCostUsd,
    };

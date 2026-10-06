// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shot_ref.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ShotRefCWProxy {
  ShotRef runId(int runId);

  ShotRef shotId(String shotId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ShotRef(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ShotRef(...).copyWith(id: 12, name: "My name")
  /// ````
  ShotRef call({int runId, String shotId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfShotRef.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfShotRef.copyWith.fieldName(...)`
class _$ShotRefCWProxyImpl implements _$ShotRefCWProxy {
  const _$ShotRefCWProxyImpl(this._value);

  final ShotRef _value;

  @override
  ShotRef runId(int runId) => this(runId: runId);

  @override
  ShotRef shotId(String shotId) => this(shotId: shotId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ShotRef(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ShotRef(...).copyWith(id: 12, name: "My name")
  /// ````
  ShotRef call({
    Object? runId = const $CopyWithPlaceholder(),
    Object? shotId = const $CopyWithPlaceholder(),
  }) {
    return ShotRef(
      runId: runId == const $CopyWithPlaceholder()
          ? _value.runId
          // ignore: cast_nullable_to_non_nullable
          : runId as int,
      shotId: shotId == const $CopyWithPlaceholder()
          ? _value.shotId
          // ignore: cast_nullable_to_non_nullable
          : shotId as String,
    );
  }
}

extension $ShotRefCopyWith on ShotRef {
  /// Returns a callable class that can be used as follows: `instanceOfShotRef.copyWith(...)` or like so:`instanceOfShotRef.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ShotRefCWProxy get copyWith => _$ShotRefCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShotRef _$ShotRefFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ShotRef', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['runId', 'shotId']);
      final val = ShotRef(
        runId: $checkedConvert('runId', (v) => (v as num).toInt()),
        shotId: $checkedConvert('shotId', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ShotRefToJson(ShotRef instance) => <String, dynamic>{
  'runId': instance.runId,
  'shotId': instance.shotId,
};

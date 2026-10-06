// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stage.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StageCWProxy {
  Stage id(int id);

  Stage name(String name);

  Stage status(CI status);

  Stage durationMs(int durationMs);

  Stage manual(bool manual);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Stage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Stage(...).copyWith(id: 12, name: "My name")
  /// ````
  Stage call({int id, String name, CI status, int durationMs, bool manual});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStage.copyWith.fieldName(...)`
class _$StageCWProxyImpl implements _$StageCWProxy {
  const _$StageCWProxyImpl(this._value);

  final Stage _value;

  @override
  Stage id(int id) => this(id: id);

  @override
  Stage name(String name) => this(name: name);

  @override
  Stage status(CI status) => this(status: status);

  @override
  Stage durationMs(int durationMs) => this(durationMs: durationMs);

  @override
  Stage manual(bool manual) => this(manual: manual);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Stage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Stage(...).copyWith(id: 12, name: "My name")
  /// ````
  Stage call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? durationMs = const $CopyWithPlaceholder(),
    Object? manual = const $CopyWithPlaceholder(),
  }) {
    return Stage(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as CI,
      durationMs: durationMs == const $CopyWithPlaceholder()
          ? _value.durationMs
          // ignore: cast_nullable_to_non_nullable
          : durationMs as int,
      manual: manual == const $CopyWithPlaceholder()
          ? _value.manual
          // ignore: cast_nullable_to_non_nullable
          : manual as bool,
    );
  }
}

extension $StageCopyWith on Stage {
  /// Returns a callable class that can be used as follows: `instanceOfStage.copyWith(...)` or like so:`instanceOfStage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StageCWProxy get copyWith => _$StageCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Stage _$StageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Stage', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['id', 'name', 'status', 'durationMs', 'manual'],
      );
      final val = Stage(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        name: $checkedConvert('name', (v) => v as String),
        status: $checkedConvert('status', (v) => $enumDecode(_$CIEnumMap, v)),
        durationMs: $checkedConvert('durationMs', (v) => (v as num).toInt()),
        manual: $checkedConvert('manual', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$StageToJson(Stage instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'status': _$CIEnumMap[instance.status]!,
  'durationMs': instance.durationMs,
  'manual': instance.manual,
};

const _$CIEnumMap = {
  CI.ok: 'ok',
  CI.fail: 'fail',
  CI.run: 'run',
  CI.pending: 'pending',
  CI.manual: 'manual',
  CI.skip: 'skip',
  CI.canceled: 'canceled',
  CI.none: 'none',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'implement_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImplementInputCWProxy {
  ImplementInput repoId(int? repoId);

  ImplementInput start(ImplementInputStartEnum? start);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImplementInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImplementInput(...).copyWith(id: 12, name: "My name")
  /// ````
  ImplementInput call({int? repoId, ImplementInputStartEnum? start});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImplementInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImplementInput.copyWith.fieldName(...)`
class _$ImplementInputCWProxyImpl implements _$ImplementInputCWProxy {
  const _$ImplementInputCWProxyImpl(this._value);

  final ImplementInput _value;

  @override
  ImplementInput repoId(int? repoId) => this(repoId: repoId);

  @override
  ImplementInput start(ImplementInputStartEnum? start) => this(start: start);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImplementInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImplementInput(...).copyWith(id: 12, name: "My name")
  /// ````
  ImplementInput call({
    Object? repoId = const $CopyWithPlaceholder(),
    Object? start = const $CopyWithPlaceholder(),
  }) {
    return ImplementInput(
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int?,
      start: start == const $CopyWithPlaceholder()
          ? _value.start
          // ignore: cast_nullable_to_non_nullable
          : start as ImplementInputStartEnum?,
    );
  }
}

extension $ImplementInputCopyWith on ImplementInput {
  /// Returns a callable class that can be used as follows: `instanceOfImplementInput.copyWith(...)` or like so:`instanceOfImplementInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImplementInputCWProxy get copyWith => _$ImplementInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImplementInput _$ImplementInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ImplementInput', json, ($checkedConvert) {
      final val = ImplementInput(
        repoId: $checkedConvert('repoId', (v) => (v as num?)?.toInt()),
        start: $checkedConvert(
          'start',
          (v) => $enumDecodeNullable(_$ImplementInputStartEnumEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ImplementInputToJson(ImplementInput instance) =>
    <String, dynamic>{
      'repoId': ?instance.repoId,
      'start': ?_$ImplementInputStartEnumEnumMap[instance.start],
    };

const _$ImplementInputStartEnumEnumMap = {
  ImplementInputStartEnum.code: 'code',
  ImplementInputStartEnum.queue: 'queue',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_acceptance_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AnalysisAcceptanceInnerCWProxy {
  AnalysisAcceptanceInner id(String id);

  AnalysisAcceptanceInner criterion(String criterion);

  AnalysisAcceptanceInner check(AnalysisAcceptanceInnerCheckEnum check);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnalysisAcceptanceInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnalysisAcceptanceInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AnalysisAcceptanceInner call({
    String id,
    String criterion,
    AnalysisAcceptanceInnerCheckEnum check,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAnalysisAcceptanceInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAnalysisAcceptanceInner.copyWith.fieldName(...)`
class _$AnalysisAcceptanceInnerCWProxyImpl
    implements _$AnalysisAcceptanceInnerCWProxy {
  const _$AnalysisAcceptanceInnerCWProxyImpl(this._value);

  final AnalysisAcceptanceInner _value;

  @override
  AnalysisAcceptanceInner id(String id) => this(id: id);

  @override
  AnalysisAcceptanceInner criterion(String criterion) =>
      this(criterion: criterion);

  @override
  AnalysisAcceptanceInner check(AnalysisAcceptanceInnerCheckEnum check) =>
      this(check: check);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnalysisAcceptanceInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnalysisAcceptanceInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AnalysisAcceptanceInner call({
    Object? id = const $CopyWithPlaceholder(),
    Object? criterion = const $CopyWithPlaceholder(),
    Object? check = const $CopyWithPlaceholder(),
  }) {
    return AnalysisAcceptanceInner(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      criterion: criterion == const $CopyWithPlaceholder()
          ? _value.criterion
          // ignore: cast_nullable_to_non_nullable
          : criterion as String,
      check: check == const $CopyWithPlaceholder()
          ? _value.check
          // ignore: cast_nullable_to_non_nullable
          : check as AnalysisAcceptanceInnerCheckEnum,
    );
  }
}

extension $AnalysisAcceptanceInnerCopyWith on AnalysisAcceptanceInner {
  /// Returns a callable class that can be used as follows: `instanceOfAnalysisAcceptanceInner.copyWith(...)` or like so:`instanceOfAnalysisAcceptanceInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AnalysisAcceptanceInnerCWProxy get copyWith =>
      _$AnalysisAcceptanceInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalysisAcceptanceInner _$AnalysisAcceptanceInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AnalysisAcceptanceInner', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['id', 'criterion', 'check']);
  final val = AnalysisAcceptanceInner(
    id: $checkedConvert('id', (v) => v as String),
    criterion: $checkedConvert('criterion', (v) => v as String),
    check: $checkedConvert(
      'check',
      (v) => $enumDecode(_$AnalysisAcceptanceInnerCheckEnumEnumMap, v),
    ),
  );
  return val;
});

Map<String, dynamic> _$AnalysisAcceptanceInnerToJson(
  AnalysisAcceptanceInner instance,
) => <String, dynamic>{
  'id': instance.id,
  'criterion': instance.criterion,
  'check': _$AnalysisAcceptanceInnerCheckEnumEnumMap[instance.check]!,
};

const _$AnalysisAcceptanceInnerCheckEnumEnumMap = {
  AnalysisAcceptanceInnerCheckEnum.ui: 'ui',
  AnalysisAcceptanceInnerCheckEnum.api: 'api',
  AnalysisAcceptanceInnerCheckEnum.test: 'test',
  AnalysisAcceptanceInnerCheckEnum.manual: 'manual',
};

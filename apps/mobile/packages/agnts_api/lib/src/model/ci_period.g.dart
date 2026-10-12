// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ci_period.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CIPeriodCWProxy {
  CIPeriod seen(int seen);

  CIPeriod new_(int new_);

  CIPeriod fixed(int fixed);

  CIPeriod autoFixed(int autoFixed);

  CIPeriod flaky(int flaky);

  CIPeriod fixMin(Spread fixMin);

  CIPeriod ownFixes(int ownFixes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CIPeriod(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CIPeriod(...).copyWith(id: 12, name: "My name")
  /// ````
  CIPeriod call({
    int seen,
    int new_,
    int fixed,
    int autoFixed,
    int flaky,
    Spread fixMin,
    int ownFixes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCIPeriod.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCIPeriod.copyWith.fieldName(...)`
class _$CIPeriodCWProxyImpl implements _$CIPeriodCWProxy {
  const _$CIPeriodCWProxyImpl(this._value);

  final CIPeriod _value;

  @override
  CIPeriod seen(int seen) => this(seen: seen);

  @override
  CIPeriod new_(int new_) => this(new_: new_);

  @override
  CIPeriod fixed(int fixed) => this(fixed: fixed);

  @override
  CIPeriod autoFixed(int autoFixed) => this(autoFixed: autoFixed);

  @override
  CIPeriod flaky(int flaky) => this(flaky: flaky);

  @override
  CIPeriod fixMin(Spread fixMin) => this(fixMin: fixMin);

  @override
  CIPeriod ownFixes(int ownFixes) => this(ownFixes: ownFixes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CIPeriod(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CIPeriod(...).copyWith(id: 12, name: "My name")
  /// ````
  CIPeriod call({
    Object? seen = const $CopyWithPlaceholder(),
    Object? new_ = const $CopyWithPlaceholder(),
    Object? fixed = const $CopyWithPlaceholder(),
    Object? autoFixed = const $CopyWithPlaceholder(),
    Object? flaky = const $CopyWithPlaceholder(),
    Object? fixMin = const $CopyWithPlaceholder(),
    Object? ownFixes = const $CopyWithPlaceholder(),
  }) {
    return CIPeriod(
      seen: seen == const $CopyWithPlaceholder()
          ? _value.seen
          // ignore: cast_nullable_to_non_nullable
          : seen as int,
      new_: new_ == const $CopyWithPlaceholder()
          ? _value.new_
          // ignore: cast_nullable_to_non_nullable
          : new_ as int,
      fixed: fixed == const $CopyWithPlaceholder()
          ? _value.fixed
          // ignore: cast_nullable_to_non_nullable
          : fixed as int,
      autoFixed: autoFixed == const $CopyWithPlaceholder()
          ? _value.autoFixed
          // ignore: cast_nullable_to_non_nullable
          : autoFixed as int,
      flaky: flaky == const $CopyWithPlaceholder()
          ? _value.flaky
          // ignore: cast_nullable_to_non_nullable
          : flaky as int,
      fixMin: fixMin == const $CopyWithPlaceholder()
          ? _value.fixMin
          // ignore: cast_nullable_to_non_nullable
          : fixMin as Spread,
      ownFixes: ownFixes == const $CopyWithPlaceholder()
          ? _value.ownFixes
          // ignore: cast_nullable_to_non_nullable
          : ownFixes as int,
    );
  }
}

extension $CIPeriodCopyWith on CIPeriod {
  /// Returns a callable class that can be used as follows: `instanceOfCIPeriod.copyWith(...)` or like so:`instanceOfCIPeriod.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CIPeriodCWProxy get copyWith => _$CIPeriodCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CIPeriod _$CIPeriodFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CIPeriod', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'seen',
          'new',
          'fixed',
          'autoFixed',
          'flaky',
          'fixMin',
          'ownFixes',
        ],
      );
      final val = CIPeriod(
        seen: $checkedConvert('seen', (v) => (v as num).toInt()),
        new_: $checkedConvert('new', (v) => (v as num).toInt()),
        fixed: $checkedConvert('fixed', (v) => (v as num).toInt()),
        autoFixed: $checkedConvert('autoFixed', (v) => (v as num).toInt()),
        flaky: $checkedConvert('flaky', (v) => (v as num).toInt()),
        fixMin: $checkedConvert(
          'fixMin',
          (v) => Spread.fromJson(v as Map<String, dynamic>),
        ),
        ownFixes: $checkedConvert('ownFixes', (v) => (v as num).toInt()),
      );
      return val;
    }, fieldKeyMap: const {'new_': 'new'});

Map<String, dynamic> _$CIPeriodToJson(CIPeriod instance) => <String, dynamic>{
  'seen': instance.seen,
  'new': instance.new_,
  'fixed': instance.fixed,
  'autoFixed': instance.autoFixed,
  'flaky': instance.flaky,
  'fixMin': instance.fixMin.toJson(),
  'ownFixes': instance.ownFixes,
};

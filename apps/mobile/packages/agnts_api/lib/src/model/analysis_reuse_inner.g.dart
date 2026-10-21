// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_reuse_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AnalysisReuseInnerCWProxy {
  AnalysisReuseInner name(String name);

  AnalysisReuseInner where(String where);

  AnalysisReuseInner for_(String? for_);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnalysisReuseInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnalysisReuseInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AnalysisReuseInner call({String name, String where, String? for_});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAnalysisReuseInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAnalysisReuseInner.copyWith.fieldName(...)`
class _$AnalysisReuseInnerCWProxyImpl implements _$AnalysisReuseInnerCWProxy {
  const _$AnalysisReuseInnerCWProxyImpl(this._value);

  final AnalysisReuseInner _value;

  @override
  AnalysisReuseInner name(String name) => this(name: name);

  @override
  AnalysisReuseInner where(String where) => this(where: where);

  @override
  AnalysisReuseInner for_(String? for_) => this(for_: for_);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnalysisReuseInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnalysisReuseInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AnalysisReuseInner call({
    Object? name = const $CopyWithPlaceholder(),
    Object? where = const $CopyWithPlaceholder(),
    Object? for_ = const $CopyWithPlaceholder(),
  }) {
    return AnalysisReuseInner(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      where: where == const $CopyWithPlaceholder()
          ? _value.where
          // ignore: cast_nullable_to_non_nullable
          : where as String,
      for_: for_ == const $CopyWithPlaceholder()
          ? _value.for_
          // ignore: cast_nullable_to_non_nullable
          : for_ as String?,
    );
  }
}

extension $AnalysisReuseInnerCopyWith on AnalysisReuseInner {
  /// Returns a callable class that can be used as follows: `instanceOfAnalysisReuseInner.copyWith(...)` or like so:`instanceOfAnalysisReuseInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AnalysisReuseInnerCWProxy get copyWith =>
      _$AnalysisReuseInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalysisReuseInner _$AnalysisReuseInnerFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AnalysisReuseInner', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['name', 'where']);
      final val = AnalysisReuseInner(
        name: $checkedConvert('name', (v) => v as String),
        where: $checkedConvert('where', (v) => v as String),
        for_: $checkedConvert('for', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'for_': 'for'});

Map<String, dynamic> _$AnalysisReuseInnerToJson(AnalysisReuseInner instance) =>
    <String, dynamic>{
      'name': instance.name,
      'where': instance.where,
      'for': ?instance.for_,
    };

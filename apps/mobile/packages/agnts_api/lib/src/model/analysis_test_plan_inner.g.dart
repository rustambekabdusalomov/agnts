// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_test_plan_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AnalysisTestPlanInnerCWProxy {
  AnalysisTestPlanInner file(String file);

  AnalysisTestPlanInner what(String what);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnalysisTestPlanInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnalysisTestPlanInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AnalysisTestPlanInner call({String file, String what});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAnalysisTestPlanInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAnalysisTestPlanInner.copyWith.fieldName(...)`
class _$AnalysisTestPlanInnerCWProxyImpl
    implements _$AnalysisTestPlanInnerCWProxy {
  const _$AnalysisTestPlanInnerCWProxyImpl(this._value);

  final AnalysisTestPlanInner _value;

  @override
  AnalysisTestPlanInner file(String file) => this(file: file);

  @override
  AnalysisTestPlanInner what(String what) => this(what: what);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnalysisTestPlanInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnalysisTestPlanInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AnalysisTestPlanInner call({
    Object? file = const $CopyWithPlaceholder(),
    Object? what = const $CopyWithPlaceholder(),
  }) {
    return AnalysisTestPlanInner(
      file: file == const $CopyWithPlaceholder()
          ? _value.file
          // ignore: cast_nullable_to_non_nullable
          : file as String,
      what: what == const $CopyWithPlaceholder()
          ? _value.what
          // ignore: cast_nullable_to_non_nullable
          : what as String,
    );
  }
}

extension $AnalysisTestPlanInnerCopyWith on AnalysisTestPlanInner {
  /// Returns a callable class that can be used as follows: `instanceOfAnalysisTestPlanInner.copyWith(...)` or like so:`instanceOfAnalysisTestPlanInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AnalysisTestPlanInnerCWProxy get copyWith =>
      _$AnalysisTestPlanInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalysisTestPlanInner _$AnalysisTestPlanInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AnalysisTestPlanInner', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['file', 'what']);
  final val = AnalysisTestPlanInner(
    file: $checkedConvert('file', (v) => v as String),
    what: $checkedConvert('what', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$AnalysisTestPlanInnerToJson(
  AnalysisTestPlanInner instance,
) => <String, dynamic>{'file': instance.file, 'what': instance.what};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_window.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UsageWindowCWProxy {
  UsageWindow utilization(double? utilization);

  UsageWindow resetsAt(DateTime? resetsAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UsageWindow(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UsageWindow(...).copyWith(id: 12, name: "My name")
  /// ````
  UsageWindow call({double? utilization, DateTime? resetsAt});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUsageWindow.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUsageWindow.copyWith.fieldName(...)`
class _$UsageWindowCWProxyImpl implements _$UsageWindowCWProxy {
  const _$UsageWindowCWProxyImpl(this._value);

  final UsageWindow _value;

  @override
  UsageWindow utilization(double? utilization) =>
      this(utilization: utilization);

  @override
  UsageWindow resetsAt(DateTime? resetsAt) => this(resetsAt: resetsAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UsageWindow(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UsageWindow(...).copyWith(id: 12, name: "My name")
  /// ````
  UsageWindow call({
    Object? utilization = const $CopyWithPlaceholder(),
    Object? resetsAt = const $CopyWithPlaceholder(),
  }) {
    return UsageWindow(
      utilization: utilization == const $CopyWithPlaceholder()
          ? _value.utilization
          // ignore: cast_nullable_to_non_nullable
          : utilization as double?,
      resetsAt: resetsAt == const $CopyWithPlaceholder()
          ? _value.resetsAt
          // ignore: cast_nullable_to_non_nullable
          : resetsAt as DateTime?,
    );
  }
}

extension $UsageWindowCopyWith on UsageWindow {
  /// Returns a callable class that can be used as follows: `instanceOfUsageWindow.copyWith(...)` or like so:`instanceOfUsageWindow.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UsageWindowCWProxy get copyWith => _$UsageWindowCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsageWindow _$UsageWindowFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UsageWindow', json, ($checkedConvert) {
      final val = UsageWindow(
        utilization: $checkedConvert(
          'utilization',
          (v) => (v as num?)?.toDouble(),
        ),
        resetsAt: $checkedConvert(
          'resetsAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$UsageWindowToJson(UsageWindow instance) =>
    <String, dynamic>{
      'utilization': ?instance.utilization,
      'resetsAt': ?instance.resetsAt?.toIso8601String(),
    };

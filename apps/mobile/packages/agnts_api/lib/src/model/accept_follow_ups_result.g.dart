// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accept_follow_ups_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AcceptFollowUpsResultCWProxy {
  AcceptFollowUpsResult results(List<AcceptFollowUpResult> results);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AcceptFollowUpsResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AcceptFollowUpsResult(...).copyWith(id: 12, name: "My name")
  /// ````
  AcceptFollowUpsResult call({List<AcceptFollowUpResult> results});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAcceptFollowUpsResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAcceptFollowUpsResult.copyWith.fieldName(...)`
class _$AcceptFollowUpsResultCWProxyImpl
    implements _$AcceptFollowUpsResultCWProxy {
  const _$AcceptFollowUpsResultCWProxyImpl(this._value);

  final AcceptFollowUpsResult _value;

  @override
  AcceptFollowUpsResult results(List<AcceptFollowUpResult> results) =>
      this(results: results);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AcceptFollowUpsResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AcceptFollowUpsResult(...).copyWith(id: 12, name: "My name")
  /// ````
  AcceptFollowUpsResult call({Object? results = const $CopyWithPlaceholder()}) {
    return AcceptFollowUpsResult(
      results: results == const $CopyWithPlaceholder()
          ? _value.results
          // ignore: cast_nullable_to_non_nullable
          : results as List<AcceptFollowUpResult>,
    );
  }
}

extension $AcceptFollowUpsResultCopyWith on AcceptFollowUpsResult {
  /// Returns a callable class that can be used as follows: `instanceOfAcceptFollowUpsResult.copyWith(...)` or like so:`instanceOfAcceptFollowUpsResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AcceptFollowUpsResultCWProxy get copyWith =>
      _$AcceptFollowUpsResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcceptFollowUpsResult _$AcceptFollowUpsResultFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AcceptFollowUpsResult', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['results']);
  final val = AcceptFollowUpsResult(
    results: $checkedConvert(
      'results',
      (v) => (v as List<dynamic>)
          .map((e) => AcceptFollowUpResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$AcceptFollowUpsResultToJson(
  AcceptFollowUpsResult instance,
) => <String, dynamic>{
  'results': instance.results.map((e) => e.toJson()).toList(),
};

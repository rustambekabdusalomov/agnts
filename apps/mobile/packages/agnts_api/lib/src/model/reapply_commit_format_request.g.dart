// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reapply_commit_format_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReapplyCommitFormatRequestCWProxy {
  ReapplyCommitFormatRequest number(String? number);

  ReapplyCommitFormatRequest dryRun(bool? dryRun);

  ReapplyCommitFormatRequest only(List<String>? only);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReapplyCommitFormatRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReapplyCommitFormatRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ReapplyCommitFormatRequest call({
    String? number,
    bool? dryRun,
    List<String>? only,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReapplyCommitFormatRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReapplyCommitFormatRequest.copyWith.fieldName(...)`
class _$ReapplyCommitFormatRequestCWProxyImpl
    implements _$ReapplyCommitFormatRequestCWProxy {
  const _$ReapplyCommitFormatRequestCWProxyImpl(this._value);

  final ReapplyCommitFormatRequest _value;

  @override
  ReapplyCommitFormatRequest number(String? number) => this(number: number);

  @override
  ReapplyCommitFormatRequest dryRun(bool? dryRun) => this(dryRun: dryRun);

  @override
  ReapplyCommitFormatRequest only(List<String>? only) => this(only: only);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReapplyCommitFormatRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReapplyCommitFormatRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ReapplyCommitFormatRequest call({
    Object? number = const $CopyWithPlaceholder(),
    Object? dryRun = const $CopyWithPlaceholder(),
    Object? only = const $CopyWithPlaceholder(),
  }) {
    return ReapplyCommitFormatRequest(
      number: number == const $CopyWithPlaceholder()
          ? _value.number
          // ignore: cast_nullable_to_non_nullable
          : number as String?,
      dryRun: dryRun == const $CopyWithPlaceholder()
          ? _value.dryRun
          // ignore: cast_nullable_to_non_nullable
          : dryRun as bool?,
      only: only == const $CopyWithPlaceholder()
          ? _value.only
          // ignore: cast_nullable_to_non_nullable
          : only as List<String>?,
    );
  }
}

extension $ReapplyCommitFormatRequestCopyWith on ReapplyCommitFormatRequest {
  /// Returns a callable class that can be used as follows: `instanceOfReapplyCommitFormatRequest.copyWith(...)` or like so:`instanceOfReapplyCommitFormatRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReapplyCommitFormatRequestCWProxy get copyWith =>
      _$ReapplyCommitFormatRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReapplyCommitFormatRequest _$ReapplyCommitFormatRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ReapplyCommitFormatRequest', json, ($checkedConvert) {
  final val = ReapplyCommitFormatRequest(
    number: $checkedConvert('number', (v) => v as String?),
    dryRun: $checkedConvert('dryRun', (v) => v as bool?),
    only: $checkedConvert(
      'only',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ReapplyCommitFormatRequestToJson(
  ReapplyCommitFormatRequest instance,
) => <String, dynamic>{
  'number': ?instance.number,
  'dryRun': ?instance.dryRun,
  'only': ?instance.only,
};

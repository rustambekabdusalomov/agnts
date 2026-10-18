// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reapply_commit_format200_response_changes_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReapplyCommitFormat200ResponseChangesInnerCWProxy {
  ReapplyCommitFormat200ResponseChangesInner repoId(int repoId);

  ReapplyCommitFormat200ResponseChangesInner repoName(String repoName);

  ReapplyCommitFormat200ResponseChangesInner sha(String sha);

  ReapplyCommitFormat200ResponseChangesInner from(String from);

  ReapplyCommitFormat200ResponseChangesInner to(String to);

  ReapplyCommitFormat200ResponseChangesInner suggested(bool suggested);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReapplyCommitFormat200ResponseChangesInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReapplyCommitFormat200ResponseChangesInner(...).copyWith(id: 12, name: "My name")
  /// ````
  ReapplyCommitFormat200ResponseChangesInner call({
    int repoId,
    String repoName,
    String sha,
    String from,
    String to,
    bool suggested,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReapplyCommitFormat200ResponseChangesInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReapplyCommitFormat200ResponseChangesInner.copyWith.fieldName(...)`
class _$ReapplyCommitFormat200ResponseChangesInnerCWProxyImpl
    implements _$ReapplyCommitFormat200ResponseChangesInnerCWProxy {
  const _$ReapplyCommitFormat200ResponseChangesInnerCWProxyImpl(this._value);

  final ReapplyCommitFormat200ResponseChangesInner _value;

  @override
  ReapplyCommitFormat200ResponseChangesInner repoId(int repoId) =>
      this(repoId: repoId);

  @override
  ReapplyCommitFormat200ResponseChangesInner repoName(String repoName) =>
      this(repoName: repoName);

  @override
  ReapplyCommitFormat200ResponseChangesInner sha(String sha) => this(sha: sha);

  @override
  ReapplyCommitFormat200ResponseChangesInner from(String from) =>
      this(from: from);

  @override
  ReapplyCommitFormat200ResponseChangesInner to(String to) => this(to: to);

  @override
  ReapplyCommitFormat200ResponseChangesInner suggested(bool suggested) =>
      this(suggested: suggested);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReapplyCommitFormat200ResponseChangesInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReapplyCommitFormat200ResponseChangesInner(...).copyWith(id: 12, name: "My name")
  /// ````
  ReapplyCommitFormat200ResponseChangesInner call({
    Object? repoId = const $CopyWithPlaceholder(),
    Object? repoName = const $CopyWithPlaceholder(),
    Object? sha = const $CopyWithPlaceholder(),
    Object? from = const $CopyWithPlaceholder(),
    Object? to = const $CopyWithPlaceholder(),
    Object? suggested = const $CopyWithPlaceholder(),
  }) {
    return ReapplyCommitFormat200ResponseChangesInner(
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int,
      repoName: repoName == const $CopyWithPlaceholder()
          ? _value.repoName
          // ignore: cast_nullable_to_non_nullable
          : repoName as String,
      sha: sha == const $CopyWithPlaceholder()
          ? _value.sha
          // ignore: cast_nullable_to_non_nullable
          : sha as String,
      from: from == const $CopyWithPlaceholder()
          ? _value.from
          // ignore: cast_nullable_to_non_nullable
          : from as String,
      to: to == const $CopyWithPlaceholder()
          ? _value.to
          // ignore: cast_nullable_to_non_nullable
          : to as String,
      suggested: suggested == const $CopyWithPlaceholder()
          ? _value.suggested
          // ignore: cast_nullable_to_non_nullable
          : suggested as bool,
    );
  }
}

extension $ReapplyCommitFormat200ResponseChangesInnerCopyWith
    on ReapplyCommitFormat200ResponseChangesInner {
  /// Returns a callable class that can be used as follows: `instanceOfReapplyCommitFormat200ResponseChangesInner.copyWith(...)` or like so:`instanceOfReapplyCommitFormat200ResponseChangesInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReapplyCommitFormat200ResponseChangesInnerCWProxy get copyWith =>
      _$ReapplyCommitFormat200ResponseChangesInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReapplyCommitFormat200ResponseChangesInner
_$ReapplyCommitFormat200ResponseChangesInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ReapplyCommitFormat200ResponseChangesInner', json, (
  $checkedConvert,
) {
  $checkKeys(
    json,
    requiredKeys: const [
      'repoId',
      'repoName',
      'sha',
      'from',
      'to',
      'suggested',
    ],
  );
  final val = ReapplyCommitFormat200ResponseChangesInner(
    repoId: $checkedConvert('repoId', (v) => (v as num).toInt()),
    repoName: $checkedConvert('repoName', (v) => v as String),
    sha: $checkedConvert('sha', (v) => v as String),
    from: $checkedConvert('from', (v) => v as String),
    to: $checkedConvert('to', (v) => v as String),
    suggested: $checkedConvert('suggested', (v) => v as bool),
  );
  return val;
});

Map<String, dynamic> _$ReapplyCommitFormat200ResponseChangesInnerToJson(
  ReapplyCommitFormat200ResponseChangesInner instance,
) => <String, dynamic>{
  'repoId': instance.repoId,
  'repoName': instance.repoName,
  'sha': instance.sha,
  'from': instance.from,
  'to': instance.to,
  'suggested': instance.suggested,
};

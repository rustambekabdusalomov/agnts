// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'linked_commits.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LinkedCommitsCWProxy {
  LinkedCommits commits(List<LinkedCommit> commits);

  LinkedCommits total(int total);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LinkedCommits(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LinkedCommits(...).copyWith(id: 12, name: "My name")
  /// ````
  LinkedCommits call({List<LinkedCommit> commits, int total});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLinkedCommits.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLinkedCommits.copyWith.fieldName(...)`
class _$LinkedCommitsCWProxyImpl implements _$LinkedCommitsCWProxy {
  const _$LinkedCommitsCWProxyImpl(this._value);

  final LinkedCommits _value;

  @override
  LinkedCommits commits(List<LinkedCommit> commits) => this(commits: commits);

  @override
  LinkedCommits total(int total) => this(total: total);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LinkedCommits(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LinkedCommits(...).copyWith(id: 12, name: "My name")
  /// ````
  LinkedCommits call({
    Object? commits = const $CopyWithPlaceholder(),
    Object? total = const $CopyWithPlaceholder(),
  }) {
    return LinkedCommits(
      commits: commits == const $CopyWithPlaceholder()
          ? _value.commits
          // ignore: cast_nullable_to_non_nullable
          : commits as List<LinkedCommit>,
      total: total == const $CopyWithPlaceholder()
          ? _value.total
          // ignore: cast_nullable_to_non_nullable
          : total as int,
    );
  }
}

extension $LinkedCommitsCopyWith on LinkedCommits {
  /// Returns a callable class that can be used as follows: `instanceOfLinkedCommits.copyWith(...)` or like so:`instanceOfLinkedCommits.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LinkedCommitsCWProxy get copyWith => _$LinkedCommitsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinkedCommits _$LinkedCommitsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LinkedCommits', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['commits', 'total']);
      final val = LinkedCommits(
        commits: $checkedConvert(
          'commits',
          (v) => (v as List<dynamic>)
              .map((e) => LinkedCommit.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        total: $checkedConvert('total', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$LinkedCommitsToJson(LinkedCommits instance) =>
    <String, dynamic>{
      'commits': instance.commits.map((e) => e.toJson()).toList(),
      'total': instance.total,
    };

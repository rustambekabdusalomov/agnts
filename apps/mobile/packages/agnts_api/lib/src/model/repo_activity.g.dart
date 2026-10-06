// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_activity.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RepoActivityCWProxy {
  RepoActivity repo(Repository repo);

  RepoActivity open(int open);

  RepoActivity latest(Ticket? latest);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoActivity(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoActivity(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoActivity call({Repository repo, int open, Ticket? latest});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRepoActivity.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRepoActivity.copyWith.fieldName(...)`
class _$RepoActivityCWProxyImpl implements _$RepoActivityCWProxy {
  const _$RepoActivityCWProxyImpl(this._value);

  final RepoActivity _value;

  @override
  RepoActivity repo(Repository repo) => this(repo: repo);

  @override
  RepoActivity open(int open) => this(open: open);

  @override
  RepoActivity latest(Ticket? latest) => this(latest: latest);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoActivity(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoActivity(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoActivity call({
    Object? repo = const $CopyWithPlaceholder(),
    Object? open = const $CopyWithPlaceholder(),
    Object? latest = const $CopyWithPlaceholder(),
  }) {
    return RepoActivity(
      repo: repo == const $CopyWithPlaceholder()
          ? _value.repo
          // ignore: cast_nullable_to_non_nullable
          : repo as Repository,
      open: open == const $CopyWithPlaceholder()
          ? _value.open
          // ignore: cast_nullable_to_non_nullable
          : open as int,
      latest: latest == const $CopyWithPlaceholder()
          ? _value.latest
          // ignore: cast_nullable_to_non_nullable
          : latest as Ticket?,
    );
  }
}

extension $RepoActivityCopyWith on RepoActivity {
  /// Returns a callable class that can be used as follows: `instanceOfRepoActivity.copyWith(...)` or like so:`instanceOfRepoActivity.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RepoActivityCWProxy get copyWith => _$RepoActivityCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepoActivity _$RepoActivityFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RepoActivity', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['repo', 'open']);
      final val = RepoActivity(
        repo: $checkedConvert(
          'repo',
          (v) => Repository.fromJson(v as Map<String, dynamic>),
        ),
        open: $checkedConvert('open', (v) => (v as num).toInt()),
        latest: $checkedConvert(
          'latest',
          (v) => v == null ? null : Ticket.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$RepoActivityToJson(RepoActivity instance) =>
    <String, dynamic>{
      'repo': instance.repo.toJson(),
      'open': instance.open,
      'latest': ?instance.latest?.toJson(),
    };

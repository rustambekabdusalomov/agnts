// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_choice.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RepoChoiceCWProxy {
  RepoChoice repoId(int? repoId);

  RepoChoice repoIds(List<int>? repoIds);

  RepoChoice groupId(int? groupId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoChoice(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoChoice(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoChoice call({int? repoId, List<int>? repoIds, int? groupId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRepoChoice.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRepoChoice.copyWith.fieldName(...)`
class _$RepoChoiceCWProxyImpl implements _$RepoChoiceCWProxy {
  const _$RepoChoiceCWProxyImpl(this._value);

  final RepoChoice _value;

  @override
  RepoChoice repoId(int? repoId) => this(repoId: repoId);

  @override
  RepoChoice repoIds(List<int>? repoIds) => this(repoIds: repoIds);

  @override
  RepoChoice groupId(int? groupId) => this(groupId: groupId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoChoice(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoChoice(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoChoice call({
    Object? repoId = const $CopyWithPlaceholder(),
    Object? repoIds = const $CopyWithPlaceholder(),
    Object? groupId = const $CopyWithPlaceholder(),
  }) {
    return RepoChoice(
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int?,
      repoIds: repoIds == const $CopyWithPlaceholder()
          ? _value.repoIds
          // ignore: cast_nullable_to_non_nullable
          : repoIds as List<int>?,
      groupId: groupId == const $CopyWithPlaceholder()
          ? _value.groupId
          // ignore: cast_nullable_to_non_nullable
          : groupId as int?,
    );
  }
}

extension $RepoChoiceCopyWith on RepoChoice {
  /// Returns a callable class that can be used as follows: `instanceOfRepoChoice.copyWith(...)` or like so:`instanceOfRepoChoice.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RepoChoiceCWProxy get copyWith => _$RepoChoiceCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepoChoice _$RepoChoiceFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RepoChoice', json, ($checkedConvert) {
      final val = RepoChoice(
        repoId: $checkedConvert('repoId', (v) => (v as num?)?.toInt()),
        repoIds: $checkedConvert(
          'repoIds',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
        groupId: $checkedConvert('groupId', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$RepoChoiceToJson(RepoChoice instance) =>
    <String, dynamic>{
      'repoId': ?instance.repoId,
      'repoIds': ?instance.repoIds,
      'groupId': ?instance.groupId,
    };

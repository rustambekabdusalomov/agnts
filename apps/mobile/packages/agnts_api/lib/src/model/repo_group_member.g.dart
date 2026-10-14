// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_group_member.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RepoGroupMemberCWProxy {
  RepoGroupMember repoId(int repoId);

  RepoGroupMember repoName(String repoName);

  RepoGroupMember role(String role);

  RepoGroupMember archived(bool archived);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoGroupMember(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoGroupMember(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoGroupMember call({
    int repoId,
    String repoName,
    String role,
    bool archived,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRepoGroupMember.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRepoGroupMember.copyWith.fieldName(...)`
class _$RepoGroupMemberCWProxyImpl implements _$RepoGroupMemberCWProxy {
  const _$RepoGroupMemberCWProxyImpl(this._value);

  final RepoGroupMember _value;

  @override
  RepoGroupMember repoId(int repoId) => this(repoId: repoId);

  @override
  RepoGroupMember repoName(String repoName) => this(repoName: repoName);

  @override
  RepoGroupMember role(String role) => this(role: role);

  @override
  RepoGroupMember archived(bool archived) => this(archived: archived);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoGroupMember(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoGroupMember(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoGroupMember call({
    Object? repoId = const $CopyWithPlaceholder(),
    Object? repoName = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? archived = const $CopyWithPlaceholder(),
  }) {
    return RepoGroupMember(
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int,
      repoName: repoName == const $CopyWithPlaceholder()
          ? _value.repoName
          // ignore: cast_nullable_to_non_nullable
          : repoName as String,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as String,
      archived: archived == const $CopyWithPlaceholder()
          ? _value.archived
          // ignore: cast_nullable_to_non_nullable
          : archived as bool,
    );
  }
}

extension $RepoGroupMemberCopyWith on RepoGroupMember {
  /// Returns a callable class that can be used as follows: `instanceOfRepoGroupMember.copyWith(...)` or like so:`instanceOfRepoGroupMember.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RepoGroupMemberCWProxy get copyWith => _$RepoGroupMemberCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepoGroupMember _$RepoGroupMemberFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RepoGroupMember', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['repoId', 'repoName', 'role', 'archived'],
      );
      final val = RepoGroupMember(
        repoId: $checkedConvert('repoId', (v) => (v as num).toInt()),
        repoName: $checkedConvert('repoName', (v) => v as String),
        role: $checkedConvert('role', (v) => v as String),
        archived: $checkedConvert('archived', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$RepoGroupMemberToJson(RepoGroupMember instance) =>
    <String, dynamic>{
      'repoId': instance.repoId,
      'repoName': instance.repoName,
      'role': instance.role,
      'archived': instance.archived,
    };

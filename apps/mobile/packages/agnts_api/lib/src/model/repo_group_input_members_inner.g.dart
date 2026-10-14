// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_group_input_members_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RepoGroupInputMembersInnerCWProxy {
  RepoGroupInputMembersInner repoId(int repoId);

  RepoGroupInputMembersInner role(String? role);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoGroupInputMembersInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoGroupInputMembersInner(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoGroupInputMembersInner call({int repoId, String? role});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRepoGroupInputMembersInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRepoGroupInputMembersInner.copyWith.fieldName(...)`
class _$RepoGroupInputMembersInnerCWProxyImpl
    implements _$RepoGroupInputMembersInnerCWProxy {
  const _$RepoGroupInputMembersInnerCWProxyImpl(this._value);

  final RepoGroupInputMembersInner _value;

  @override
  RepoGroupInputMembersInner repoId(int repoId) => this(repoId: repoId);

  @override
  RepoGroupInputMembersInner role(String? role) => this(role: role);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoGroupInputMembersInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoGroupInputMembersInner(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoGroupInputMembersInner call({
    Object? repoId = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
  }) {
    return RepoGroupInputMembersInner(
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as String?,
    );
  }
}

extension $RepoGroupInputMembersInnerCopyWith on RepoGroupInputMembersInner {
  /// Returns a callable class that can be used as follows: `instanceOfRepoGroupInputMembersInner.copyWith(...)` or like so:`instanceOfRepoGroupInputMembersInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RepoGroupInputMembersInnerCWProxy get copyWith =>
      _$RepoGroupInputMembersInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepoGroupInputMembersInner _$RepoGroupInputMembersInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RepoGroupInputMembersInner', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['repoId']);
  final val = RepoGroupInputMembersInner(
    repoId: $checkedConvert('repoId', (v) => (v as num).toInt()),
    role: $checkedConvert('role', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$RepoGroupInputMembersInnerToJson(
  RepoGroupInputMembersInner instance,
) => <String, dynamic>{'repoId': instance.repoId, 'role': ?instance.role};

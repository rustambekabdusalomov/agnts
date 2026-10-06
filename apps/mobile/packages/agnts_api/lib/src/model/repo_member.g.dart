// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_member.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RepoMemberCWProxy {
  RepoMember username(String username);

  RepoMember name(String? name);

  RepoMember avatarUrl(String? avatarUrl);

  RepoMember url(String? url);

  RepoMember role(String role);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoMember(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoMember(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoMember call({
    String username,
    String? name,
    String? avatarUrl,
    String? url,
    String role,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRepoMember.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRepoMember.copyWith.fieldName(...)`
class _$RepoMemberCWProxyImpl implements _$RepoMemberCWProxy {
  const _$RepoMemberCWProxyImpl(this._value);

  final RepoMember _value;

  @override
  RepoMember username(String username) => this(username: username);

  @override
  RepoMember name(String? name) => this(name: name);

  @override
  RepoMember avatarUrl(String? avatarUrl) => this(avatarUrl: avatarUrl);

  @override
  RepoMember url(String? url) => this(url: url);

  @override
  RepoMember role(String role) => this(role: role);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoMember(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoMember(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoMember call({
    Object? username = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? avatarUrl = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
  }) {
    return RepoMember(
      username: username == const $CopyWithPlaceholder()
          ? _value.username
          // ignore: cast_nullable_to_non_nullable
          : username as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      avatarUrl: avatarUrl == const $CopyWithPlaceholder()
          ? _value.avatarUrl
          // ignore: cast_nullable_to_non_nullable
          : avatarUrl as String?,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String?,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as String,
    );
  }
}

extension $RepoMemberCopyWith on RepoMember {
  /// Returns a callable class that can be used as follows: `instanceOfRepoMember.copyWith(...)` or like so:`instanceOfRepoMember.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RepoMemberCWProxy get copyWith => _$RepoMemberCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepoMember _$RepoMemberFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RepoMember', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['username', 'role']);
      final val = RepoMember(
        username: $checkedConvert('username', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String?),
        avatarUrl: $checkedConvert('avatarUrl', (v) => v as String?),
        url: $checkedConvert('url', (v) => v as String?),
        role: $checkedConvert('role', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$RepoMemberToJson(RepoMember instance) =>
    <String, dynamic>{
      'username': instance.username,
      'name': ?instance.name,
      'avatarUrl': ?instance.avatarUrl,
      'url': ?instance.url,
      'role': instance.role,
    };

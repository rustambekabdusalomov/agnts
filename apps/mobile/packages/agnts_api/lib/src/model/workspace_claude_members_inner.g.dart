// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_claude_members_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkspaceClaudeMembersInnerCWProxy {
  WorkspaceClaudeMembersInner userId(int userId);

  WorkspaceClaudeMembersInner username(String username);

  WorkspaceClaudeMembersInner connected(bool connected);

  WorkspaceClaudeMembersInner pausedUntil(DateTime? pausedUntil);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkspaceClaudeMembersInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkspaceClaudeMembersInner(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkspaceClaudeMembersInner call({
    int userId,
    String username,
    bool connected,
    DateTime? pausedUntil,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkspaceClaudeMembersInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkspaceClaudeMembersInner.copyWith.fieldName(...)`
class _$WorkspaceClaudeMembersInnerCWProxyImpl
    implements _$WorkspaceClaudeMembersInnerCWProxy {
  const _$WorkspaceClaudeMembersInnerCWProxyImpl(this._value);

  final WorkspaceClaudeMembersInner _value;

  @override
  WorkspaceClaudeMembersInner userId(int userId) => this(userId: userId);

  @override
  WorkspaceClaudeMembersInner username(String username) =>
      this(username: username);

  @override
  WorkspaceClaudeMembersInner connected(bool connected) =>
      this(connected: connected);

  @override
  WorkspaceClaudeMembersInner pausedUntil(DateTime? pausedUntil) =>
      this(pausedUntil: pausedUntil);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkspaceClaudeMembersInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkspaceClaudeMembersInner(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkspaceClaudeMembersInner call({
    Object? userId = const $CopyWithPlaceholder(),
    Object? username = const $CopyWithPlaceholder(),
    Object? connected = const $CopyWithPlaceholder(),
    Object? pausedUntil = const $CopyWithPlaceholder(),
  }) {
    return WorkspaceClaudeMembersInner(
      userId: userId == const $CopyWithPlaceholder()
          ? _value.userId
          // ignore: cast_nullable_to_non_nullable
          : userId as int,
      username: username == const $CopyWithPlaceholder()
          ? _value.username
          // ignore: cast_nullable_to_non_nullable
          : username as String,
      connected: connected == const $CopyWithPlaceholder()
          ? _value.connected
          // ignore: cast_nullable_to_non_nullable
          : connected as bool,
      pausedUntil: pausedUntil == const $CopyWithPlaceholder()
          ? _value.pausedUntil
          // ignore: cast_nullable_to_non_nullable
          : pausedUntil as DateTime?,
    );
  }
}

extension $WorkspaceClaudeMembersInnerCopyWith on WorkspaceClaudeMembersInner {
  /// Returns a callable class that can be used as follows: `instanceOfWorkspaceClaudeMembersInner.copyWith(...)` or like so:`instanceOfWorkspaceClaudeMembersInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkspaceClaudeMembersInnerCWProxy get copyWith =>
      _$WorkspaceClaudeMembersInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkspaceClaudeMembersInner _$WorkspaceClaudeMembersInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WorkspaceClaudeMembersInner', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['userId', 'username', 'connected']);
  final val = WorkspaceClaudeMembersInner(
    userId: $checkedConvert('userId', (v) => (v as num).toInt()),
    username: $checkedConvert('username', (v) => v as String),
    connected: $checkedConvert('connected', (v) => v as bool),
    pausedUntil: $checkedConvert(
      'pausedUntil',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
  );
  return val;
});

Map<String, dynamic> _$WorkspaceClaudeMembersInnerToJson(
  WorkspaceClaudeMembersInner instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'username': instance.username,
  'connected': instance.connected,
  'pausedUntil': ?instance.pausedUntil?.toIso8601String(),
};

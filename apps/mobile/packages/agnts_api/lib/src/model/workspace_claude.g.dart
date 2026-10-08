// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_claude.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkspaceClaudeCWProxy {
  WorkspaceClaude mode(WorkspaceClaudeModeEnum mode);

  WorkspaceClaude fallback(bool fallback);

  WorkspaceClaude defaultMemberId(int? defaultMemberId);

  WorkspaceClaude connection(ClaudeConnectionState connection);

  WorkspaceClaude members(List<WorkspaceClaudeMembersInner> members);

  WorkspaceClaude creditsBalance(int creditsBalance);

  WorkspaceClaude subscriptionsAllowed(bool subscriptionsAllowed);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkspaceClaude(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkspaceClaude(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkspaceClaude call({
    WorkspaceClaudeModeEnum mode,
    bool fallback,
    int? defaultMemberId,
    ClaudeConnectionState connection,
    List<WorkspaceClaudeMembersInner> members,
    int creditsBalance,
    bool subscriptionsAllowed,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkspaceClaude.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkspaceClaude.copyWith.fieldName(...)`
class _$WorkspaceClaudeCWProxyImpl implements _$WorkspaceClaudeCWProxy {
  const _$WorkspaceClaudeCWProxyImpl(this._value);

  final WorkspaceClaude _value;

  @override
  WorkspaceClaude mode(WorkspaceClaudeModeEnum mode) => this(mode: mode);

  @override
  WorkspaceClaude fallback(bool fallback) => this(fallback: fallback);

  @override
  WorkspaceClaude defaultMemberId(int? defaultMemberId) =>
      this(defaultMemberId: defaultMemberId);

  @override
  WorkspaceClaude connection(ClaudeConnectionState connection) =>
      this(connection: connection);

  @override
  WorkspaceClaude members(List<WorkspaceClaudeMembersInner> members) =>
      this(members: members);

  @override
  WorkspaceClaude creditsBalance(int creditsBalance) =>
      this(creditsBalance: creditsBalance);

  @override
  WorkspaceClaude subscriptionsAllowed(bool subscriptionsAllowed) =>
      this(subscriptionsAllowed: subscriptionsAllowed);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkspaceClaude(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkspaceClaude(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkspaceClaude call({
    Object? mode = const $CopyWithPlaceholder(),
    Object? fallback = const $CopyWithPlaceholder(),
    Object? defaultMemberId = const $CopyWithPlaceholder(),
    Object? connection = const $CopyWithPlaceholder(),
    Object? members = const $CopyWithPlaceholder(),
    Object? creditsBalance = const $CopyWithPlaceholder(),
    Object? subscriptionsAllowed = const $CopyWithPlaceholder(),
  }) {
    return WorkspaceClaude(
      mode: mode == const $CopyWithPlaceholder()
          ? _value.mode
          // ignore: cast_nullable_to_non_nullable
          : mode as WorkspaceClaudeModeEnum,
      fallback: fallback == const $CopyWithPlaceholder()
          ? _value.fallback
          // ignore: cast_nullable_to_non_nullable
          : fallback as bool,
      defaultMemberId: defaultMemberId == const $CopyWithPlaceholder()
          ? _value.defaultMemberId
          // ignore: cast_nullable_to_non_nullable
          : defaultMemberId as int?,
      connection: connection == const $CopyWithPlaceholder()
          ? _value.connection
          // ignore: cast_nullable_to_non_nullable
          : connection as ClaudeConnectionState,
      members: members == const $CopyWithPlaceholder()
          ? _value.members
          // ignore: cast_nullable_to_non_nullable
          : members as List<WorkspaceClaudeMembersInner>,
      creditsBalance: creditsBalance == const $CopyWithPlaceholder()
          ? _value.creditsBalance
          // ignore: cast_nullable_to_non_nullable
          : creditsBalance as int,
      subscriptionsAllowed: subscriptionsAllowed == const $CopyWithPlaceholder()
          ? _value.subscriptionsAllowed
          // ignore: cast_nullable_to_non_nullable
          : subscriptionsAllowed as bool,
    );
  }
}

extension $WorkspaceClaudeCopyWith on WorkspaceClaude {
  /// Returns a callable class that can be used as follows: `instanceOfWorkspaceClaude.copyWith(...)` or like so:`instanceOfWorkspaceClaude.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkspaceClaudeCWProxy get copyWith => _$WorkspaceClaudeCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkspaceClaude _$WorkspaceClaudeFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WorkspaceClaude', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'mode',
          'fallback',
          'connection',
          'members',
          'creditsBalance',
          'subscriptionsAllowed',
        ],
      );
      final val = WorkspaceClaude(
        mode: $checkedConvert(
          'mode',
          (v) => $enumDecode(_$WorkspaceClaudeModeEnumEnumMap, v),
        ),
        fallback: $checkedConvert('fallback', (v) => v as bool),
        defaultMemberId: $checkedConvert(
          'defaultMemberId',
          (v) => (v as num?)?.toInt(),
        ),
        connection: $checkedConvert(
          'connection',
          (v) => ClaudeConnectionState.fromJson(v as Map<String, dynamic>),
        ),
        members: $checkedConvert(
          'members',
          (v) => (v as List<dynamic>)
              .map(
                (e) => WorkspaceClaudeMembersInner.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
        ),
        creditsBalance: $checkedConvert(
          'creditsBalance',
          (v) => (v as num).toInt(),
        ),
        subscriptionsAllowed: $checkedConvert(
          'subscriptionsAllowed',
          (v) => v as bool,
        ),
      );
      return val;
    });

Map<String, dynamic> _$WorkspaceClaudeToJson(WorkspaceClaude instance) =>
    <String, dynamic>{
      'mode': _$WorkspaceClaudeModeEnumEnumMap[instance.mode]!,
      'fallback': instance.fallback,
      'defaultMemberId': ?instance.defaultMemberId,
      'connection': instance.connection.toJson(),
      'members': instance.members.map((e) => e.toJson()).toList(),
      'creditsBalance': instance.creditsBalance,
      'subscriptionsAllowed': instance.subscriptionsAllowed,
    };

const _$WorkspaceClaudeModeEnumEnumMap = {
  WorkspaceClaudeModeEnum.shared: 'shared',
  WorkspaceClaudeModeEnum.member: 'member',
};

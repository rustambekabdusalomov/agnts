// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_workspace_claude_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpdateWorkspaceClaudeRequestCWProxy {
  UpdateWorkspaceClaudeRequest mode(UpdateWorkspaceClaudeRequestModeEnum? mode);

  UpdateWorkspaceClaudeRequest fallback(bool? fallback);

  UpdateWorkspaceClaudeRequest defaultMemberId(int? defaultMemberId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateWorkspaceClaudeRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateWorkspaceClaudeRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateWorkspaceClaudeRequest call({
    UpdateWorkspaceClaudeRequestModeEnum? mode,
    bool? fallback,
    int? defaultMemberId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpdateWorkspaceClaudeRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpdateWorkspaceClaudeRequest.copyWith.fieldName(...)`
class _$UpdateWorkspaceClaudeRequestCWProxyImpl
    implements _$UpdateWorkspaceClaudeRequestCWProxy {
  const _$UpdateWorkspaceClaudeRequestCWProxyImpl(this._value);

  final UpdateWorkspaceClaudeRequest _value;

  @override
  UpdateWorkspaceClaudeRequest mode(
    UpdateWorkspaceClaudeRequestModeEnum? mode,
  ) => this(mode: mode);

  @override
  UpdateWorkspaceClaudeRequest fallback(bool? fallback) =>
      this(fallback: fallback);

  @override
  UpdateWorkspaceClaudeRequest defaultMemberId(int? defaultMemberId) =>
      this(defaultMemberId: defaultMemberId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateWorkspaceClaudeRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateWorkspaceClaudeRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateWorkspaceClaudeRequest call({
    Object? mode = const $CopyWithPlaceholder(),
    Object? fallback = const $CopyWithPlaceholder(),
    Object? defaultMemberId = const $CopyWithPlaceholder(),
  }) {
    return UpdateWorkspaceClaudeRequest(
      mode: mode == const $CopyWithPlaceholder()
          ? _value.mode
          // ignore: cast_nullable_to_non_nullable
          : mode as UpdateWorkspaceClaudeRequestModeEnum?,
      fallback: fallback == const $CopyWithPlaceholder()
          ? _value.fallback
          // ignore: cast_nullable_to_non_nullable
          : fallback as bool?,
      defaultMemberId: defaultMemberId == const $CopyWithPlaceholder()
          ? _value.defaultMemberId
          // ignore: cast_nullable_to_non_nullable
          : defaultMemberId as int?,
    );
  }
}

extension $UpdateWorkspaceClaudeRequestCopyWith
    on UpdateWorkspaceClaudeRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUpdateWorkspaceClaudeRequest.copyWith(...)` or like so:`instanceOfUpdateWorkspaceClaudeRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpdateWorkspaceClaudeRequestCWProxy get copyWith =>
      _$UpdateWorkspaceClaudeRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateWorkspaceClaudeRequest _$UpdateWorkspaceClaudeRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UpdateWorkspaceClaudeRequest', json, ($checkedConvert) {
  final val = UpdateWorkspaceClaudeRequest(
    mode: $checkedConvert(
      'mode',
      (v) =>
          $enumDecodeNullable(_$UpdateWorkspaceClaudeRequestModeEnumEnumMap, v),
    ),
    fallback: $checkedConvert('fallback', (v) => v as bool?),
    defaultMemberId: $checkedConvert(
      'defaultMemberId',
      (v) => (v as num?)?.toInt(),
    ),
  );
  return val;
});

Map<String, dynamic> _$UpdateWorkspaceClaudeRequestToJson(
  UpdateWorkspaceClaudeRequest instance,
) => <String, dynamic>{
  'mode': ?_$UpdateWorkspaceClaudeRequestModeEnumEnumMap[instance.mode],
  'fallback': ?instance.fallback,
  'defaultMemberId': ?instance.defaultMemberId,
};

const _$UpdateWorkspaceClaudeRequestModeEnumEnumMap = {
  UpdateWorkspaceClaudeRequestModeEnum.shared: 'shared',
  UpdateWorkspaceClaudeRequestModeEnum.member: 'member',
};

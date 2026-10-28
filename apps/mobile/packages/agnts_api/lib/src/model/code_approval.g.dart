// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code_approval.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CodeApprovalCWProxy {
  CodeApproval id(String id);

  CodeApproval conversationId(int conversationId);

  CodeApproval ticketKey(String ticketKey);

  CodeApproval tool(String tool);

  CodeApproval command(String? command);

  CodeApproval path(String? path);

  CodeApproval reason(String reason);

  CodeApproval status(CodeApprovalStatusEnum status);

  CodeApproval expiresAt(DateTime expiresAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CodeApproval(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CodeApproval(...).copyWith(id: 12, name: "My name")
  /// ````
  CodeApproval call({
    String id,
    int conversationId,
    String ticketKey,
    String tool,
    String? command,
    String? path,
    String reason,
    CodeApprovalStatusEnum status,
    DateTime expiresAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCodeApproval.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCodeApproval.copyWith.fieldName(...)`
class _$CodeApprovalCWProxyImpl implements _$CodeApprovalCWProxy {
  const _$CodeApprovalCWProxyImpl(this._value);

  final CodeApproval _value;

  @override
  CodeApproval id(String id) => this(id: id);

  @override
  CodeApproval conversationId(int conversationId) =>
      this(conversationId: conversationId);

  @override
  CodeApproval ticketKey(String ticketKey) => this(ticketKey: ticketKey);

  @override
  CodeApproval tool(String tool) => this(tool: tool);

  @override
  CodeApproval command(String? command) => this(command: command);

  @override
  CodeApproval path(String? path) => this(path: path);

  @override
  CodeApproval reason(String reason) => this(reason: reason);

  @override
  CodeApproval status(CodeApprovalStatusEnum status) => this(status: status);

  @override
  CodeApproval expiresAt(DateTime expiresAt) => this(expiresAt: expiresAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CodeApproval(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CodeApproval(...).copyWith(id: 12, name: "My name")
  /// ````
  CodeApproval call({
    Object? id = const $CopyWithPlaceholder(),
    Object? conversationId = const $CopyWithPlaceholder(),
    Object? ticketKey = const $CopyWithPlaceholder(),
    Object? tool = const $CopyWithPlaceholder(),
    Object? command = const $CopyWithPlaceholder(),
    Object? path = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
  }) {
    return CodeApproval(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      conversationId: conversationId == const $CopyWithPlaceholder()
          ? _value.conversationId
          // ignore: cast_nullable_to_non_nullable
          : conversationId as int,
      ticketKey: ticketKey == const $CopyWithPlaceholder()
          ? _value.ticketKey
          // ignore: cast_nullable_to_non_nullable
          : ticketKey as String,
      tool: tool == const $CopyWithPlaceholder()
          ? _value.tool
          // ignore: cast_nullable_to_non_nullable
          : tool as String,
      command: command == const $CopyWithPlaceholder()
          ? _value.command
          // ignore: cast_nullable_to_non_nullable
          : command as String?,
      path: path == const $CopyWithPlaceholder()
          ? _value.path
          // ignore: cast_nullable_to_non_nullable
          : path as String?,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as CodeApprovalStatusEnum,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime,
    );
  }
}

extension $CodeApprovalCopyWith on CodeApproval {
  /// Returns a callable class that can be used as follows: `instanceOfCodeApproval.copyWith(...)` or like so:`instanceOfCodeApproval.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CodeApprovalCWProxy get copyWith => _$CodeApprovalCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CodeApproval _$CodeApprovalFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CodeApproval', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'conversationId',
          'ticketKey',
          'tool',
          'reason',
          'status',
          'expiresAt',
        ],
      );
      final val = CodeApproval(
        id: $checkedConvert('id', (v) => v as String),
        conversationId: $checkedConvert(
          'conversationId',
          (v) => (v as num).toInt(),
        ),
        ticketKey: $checkedConvert('ticketKey', (v) => v as String),
        tool: $checkedConvert('tool', (v) => v as String),
        command: $checkedConvert('command', (v) => v as String?),
        path: $checkedConvert('path', (v) => v as String?),
        reason: $checkedConvert('reason', (v) => v as String),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$CodeApprovalStatusEnumEnumMap, v),
        ),
        expiresAt: $checkedConvert(
          'expiresAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CodeApprovalToJson(CodeApproval instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'ticketKey': instance.ticketKey,
      'tool': instance.tool,
      'command': ?instance.command,
      'path': ?instance.path,
      'reason': instance.reason,
      'status': _$CodeApprovalStatusEnumEnumMap[instance.status]!,
      'expiresAt': instance.expiresAt.toIso8601String(),
    };

const _$CodeApprovalStatusEnumEnumMap = {
  CodeApprovalStatusEnum.pending: 'pending',
  CodeApprovalStatusEnum.allowed: 'allowed',
  CodeApprovalStatusEnum.denied: 'denied',
  CodeApprovalStatusEnum.expired: 'expired',
};

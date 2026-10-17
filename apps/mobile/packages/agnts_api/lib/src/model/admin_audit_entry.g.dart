// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_audit_entry.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdminAuditEntryCWProxy {
  AdminAuditEntry id(int id);

  AdminAuditEntry adminId(int? adminId);

  AdminAuditEntry adminName(String adminName);

  AdminAuditEntry action(String action);

  AdminAuditEntry target(String target);

  AdminAuditEntry workspaceId(int? workspaceId);

  AdminAuditEntry workspace(String? workspace);

  AdminAuditEntry ip(String? ip);

  AdminAuditEntry createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminAuditEntry(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminAuditEntry(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminAuditEntry call({
    int id,
    int? adminId,
    String adminName,
    String action,
    String target,
    int? workspaceId,
    String? workspace,
    String? ip,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdminAuditEntry.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdminAuditEntry.copyWith.fieldName(...)`
class _$AdminAuditEntryCWProxyImpl implements _$AdminAuditEntryCWProxy {
  const _$AdminAuditEntryCWProxyImpl(this._value);

  final AdminAuditEntry _value;

  @override
  AdminAuditEntry id(int id) => this(id: id);

  @override
  AdminAuditEntry adminId(int? adminId) => this(adminId: adminId);

  @override
  AdminAuditEntry adminName(String adminName) => this(adminName: adminName);

  @override
  AdminAuditEntry action(String action) => this(action: action);

  @override
  AdminAuditEntry target(String target) => this(target: target);

  @override
  AdminAuditEntry workspaceId(int? workspaceId) =>
      this(workspaceId: workspaceId);

  @override
  AdminAuditEntry workspace(String? workspace) => this(workspace: workspace);

  @override
  AdminAuditEntry ip(String? ip) => this(ip: ip);

  @override
  AdminAuditEntry createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminAuditEntry(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminAuditEntry(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminAuditEntry call({
    Object? id = const $CopyWithPlaceholder(),
    Object? adminId = const $CopyWithPlaceholder(),
    Object? adminName = const $CopyWithPlaceholder(),
    Object? action = const $CopyWithPlaceholder(),
    Object? target = const $CopyWithPlaceholder(),
    Object? workspaceId = const $CopyWithPlaceholder(),
    Object? workspace = const $CopyWithPlaceholder(),
    Object? ip = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return AdminAuditEntry(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      adminId: adminId == const $CopyWithPlaceholder()
          ? _value.adminId
          // ignore: cast_nullable_to_non_nullable
          : adminId as int?,
      adminName: adminName == const $CopyWithPlaceholder()
          ? _value.adminName
          // ignore: cast_nullable_to_non_nullable
          : adminName as String,
      action: action == const $CopyWithPlaceholder()
          ? _value.action
          // ignore: cast_nullable_to_non_nullable
          : action as String,
      target: target == const $CopyWithPlaceholder()
          ? _value.target
          // ignore: cast_nullable_to_non_nullable
          : target as String,
      workspaceId: workspaceId == const $CopyWithPlaceholder()
          ? _value.workspaceId
          // ignore: cast_nullable_to_non_nullable
          : workspaceId as int?,
      workspace: workspace == const $CopyWithPlaceholder()
          ? _value.workspace
          // ignore: cast_nullable_to_non_nullable
          : workspace as String?,
      ip: ip == const $CopyWithPlaceholder()
          ? _value.ip
          // ignore: cast_nullable_to_non_nullable
          : ip as String?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $AdminAuditEntryCopyWith on AdminAuditEntry {
  /// Returns a callable class that can be used as follows: `instanceOfAdminAuditEntry.copyWith(...)` or like so:`instanceOfAdminAuditEntry.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdminAuditEntryCWProxy get copyWith => _$AdminAuditEntryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminAuditEntry _$AdminAuditEntryFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AdminAuditEntry', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'adminName', 'action', 'target', 'createdAt'],
  );
  final val = AdminAuditEntry(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    adminId: $checkedConvert('adminId', (v) => (v as num?)?.toInt()),
    adminName: $checkedConvert('adminName', (v) => v as String),
    action: $checkedConvert('action', (v) => v as String),
    target: $checkedConvert('target', (v) => v as String),
    workspaceId: $checkedConvert('workspaceId', (v) => (v as num?)?.toInt()),
    workspace: $checkedConvert('workspace', (v) => v as String?),
    ip: $checkedConvert('ip', (v) => v as String?),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$AdminAuditEntryToJson(AdminAuditEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'adminId': ?instance.adminId,
      'adminName': instance.adminName,
      'action': instance.action,
      'target': instance.target,
      'workspaceId': ?instance.workspaceId,
      'workspace': ?instance.workspace,
      'ip': ?instance.ip,
      'createdAt': instance.createdAt.toIso8601String(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_overview_server_queue_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlatformOverviewServerQueueInnerCWProxy {
  PlatformOverviewServerQueueInner workspaceId(int workspaceId);

  PlatformOverviewServerQueueInner workspace(String? workspace);

  PlatformOverviewServerQueueInner ticketKey(String ticketKey);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlatformOverviewServerQueueInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlatformOverviewServerQueueInner(...).copyWith(id: 12, name: "My name")
  /// ````
  PlatformOverviewServerQueueInner call({
    int workspaceId,
    String? workspace,
    String ticketKey,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPlatformOverviewServerQueueInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPlatformOverviewServerQueueInner.copyWith.fieldName(...)`
class _$PlatformOverviewServerQueueInnerCWProxyImpl
    implements _$PlatformOverviewServerQueueInnerCWProxy {
  const _$PlatformOverviewServerQueueInnerCWProxyImpl(this._value);

  final PlatformOverviewServerQueueInner _value;

  @override
  PlatformOverviewServerQueueInner workspaceId(int workspaceId) =>
      this(workspaceId: workspaceId);

  @override
  PlatformOverviewServerQueueInner workspace(String? workspace) =>
      this(workspace: workspace);

  @override
  PlatformOverviewServerQueueInner ticketKey(String ticketKey) =>
      this(ticketKey: ticketKey);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlatformOverviewServerQueueInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlatformOverviewServerQueueInner(...).copyWith(id: 12, name: "My name")
  /// ````
  PlatformOverviewServerQueueInner call({
    Object? workspaceId = const $CopyWithPlaceholder(),
    Object? workspace = const $CopyWithPlaceholder(),
    Object? ticketKey = const $CopyWithPlaceholder(),
  }) {
    return PlatformOverviewServerQueueInner(
      workspaceId: workspaceId == const $CopyWithPlaceholder()
          ? _value.workspaceId
          // ignore: cast_nullable_to_non_nullable
          : workspaceId as int,
      workspace: workspace == const $CopyWithPlaceholder()
          ? _value.workspace
          // ignore: cast_nullable_to_non_nullable
          : workspace as String?,
      ticketKey: ticketKey == const $CopyWithPlaceholder()
          ? _value.ticketKey
          // ignore: cast_nullable_to_non_nullable
          : ticketKey as String,
    );
  }
}

extension $PlatformOverviewServerQueueInnerCopyWith
    on PlatformOverviewServerQueueInner {
  /// Returns a callable class that can be used as follows: `instanceOfPlatformOverviewServerQueueInner.copyWith(...)` or like so:`instanceOfPlatformOverviewServerQueueInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlatformOverviewServerQueueInnerCWProxy get copyWith =>
      _$PlatformOverviewServerQueueInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlatformOverviewServerQueueInner _$PlatformOverviewServerQueueInnerFromJson(
  Map<String, dynamic> json,
) =>
    $checkedCreate('PlatformOverviewServerQueueInner', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['workspaceId', 'ticketKey']);
      final val = PlatformOverviewServerQueueInner(
        workspaceId: $checkedConvert('workspaceId', (v) => (v as num).toInt()),
        workspace: $checkedConvert('workspace', (v) => v as String?),
        ticketKey: $checkedConvert('ticketKey', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$PlatformOverviewServerQueueInnerToJson(
  PlatformOverviewServerQueueInner instance,
) => <String, dynamic>{
  'workspaceId': instance.workspaceId,
  'workspace': ?instance.workspace,
  'ticketKey': instance.ticketKey,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_overview_runs_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlatformOverviewRunsInnerCWProxy {
  PlatformOverviewRunsInner workspaceId(int workspaceId);

  PlatformOverviewRunsInner workspace(String? workspace);

  PlatformOverviewRunsInner ticketKey(String ticketKey);

  PlatformOverviewRunsInner stage(String stage);

  PlatformOverviewRunsInner startedAt(DateTime startedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlatformOverviewRunsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlatformOverviewRunsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  PlatformOverviewRunsInner call({
    int workspaceId,
    String? workspace,
    String ticketKey,
    String stage,
    DateTime startedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPlatformOverviewRunsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPlatformOverviewRunsInner.copyWith.fieldName(...)`
class _$PlatformOverviewRunsInnerCWProxyImpl
    implements _$PlatformOverviewRunsInnerCWProxy {
  const _$PlatformOverviewRunsInnerCWProxyImpl(this._value);

  final PlatformOverviewRunsInner _value;

  @override
  PlatformOverviewRunsInner workspaceId(int workspaceId) =>
      this(workspaceId: workspaceId);

  @override
  PlatformOverviewRunsInner workspace(String? workspace) =>
      this(workspace: workspace);

  @override
  PlatformOverviewRunsInner ticketKey(String ticketKey) =>
      this(ticketKey: ticketKey);

  @override
  PlatformOverviewRunsInner stage(String stage) => this(stage: stage);

  @override
  PlatformOverviewRunsInner startedAt(DateTime startedAt) =>
      this(startedAt: startedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlatformOverviewRunsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlatformOverviewRunsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  PlatformOverviewRunsInner call({
    Object? workspaceId = const $CopyWithPlaceholder(),
    Object? workspace = const $CopyWithPlaceholder(),
    Object? ticketKey = const $CopyWithPlaceholder(),
    Object? stage = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
  }) {
    return PlatformOverviewRunsInner(
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
      stage: stage == const $CopyWithPlaceholder()
          ? _value.stage
          // ignore: cast_nullable_to_non_nullable
          : stage as String,
      startedAt: startedAt == const $CopyWithPlaceholder()
          ? _value.startedAt
          // ignore: cast_nullable_to_non_nullable
          : startedAt as DateTime,
    );
  }
}

extension $PlatformOverviewRunsInnerCopyWith on PlatformOverviewRunsInner {
  /// Returns a callable class that can be used as follows: `instanceOfPlatformOverviewRunsInner.copyWith(...)` or like so:`instanceOfPlatformOverviewRunsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlatformOverviewRunsInnerCWProxy get copyWith =>
      _$PlatformOverviewRunsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlatformOverviewRunsInner _$PlatformOverviewRunsInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PlatformOverviewRunsInner', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['workspaceId', 'ticketKey', 'stage', 'startedAt'],
  );
  final val = PlatformOverviewRunsInner(
    workspaceId: $checkedConvert('workspaceId', (v) => (v as num).toInt()),
    workspace: $checkedConvert('workspace', (v) => v as String?),
    ticketKey: $checkedConvert('ticketKey', (v) => v as String),
    stage: $checkedConvert('stage', (v) => v as String),
    startedAt: $checkedConvert('startedAt', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$PlatformOverviewRunsInnerToJson(
  PlatformOverviewRunsInner instance,
) => <String, dynamic>{
  'workspaceId': instance.workspaceId,
  'workspace': ?instance.workspace,
  'ticketKey': instance.ticketKey,
  'stage': instance.stage,
  'startedAt': instance.startedAt.toIso8601String(),
};
